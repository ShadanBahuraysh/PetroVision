"""
=============================================================
NON-FUNCTIONAL TESTS — Security Testing
=============================================================
Tests the security properties of the authentication system:

  1.  Password never stored or returned in plain text
  2.  bcrypt hashing is used (irreversible)
  3.  OTP expires after 5 minutes
  4.  OTP is one-time use only
  5.  OTP is 6 digits (cannot be easily guessed)
  6.  Password stripped from all API responses
  7.  Unauthorized dashboard access is denied
  8.  Admin job number adds a second layer of security
  9.  Brute-force: 10 wrong OTP attempts all fail
  10. Brute-force: 10 wrong passwords all return 401
  11. SQL injection attempt in email does not crash the system
  12. Empty/null values in security fields are rejected
=============================================================
"""

import time
import pytest
import sys
import os
from unittest.mock import MagicMock, patch
import bcrypt

# ── Path setup ────────────────────────────────────────────
sys.path.insert(0, os.path.join(os.path.dirname(__file__),
                                "../Backend-python/Backend-python"))

mock_supabase = MagicMock()
sys.modules["app.supabase_client"] = MagicMock(supabase=mock_supabase)

from fastapi import FastAPI
from fastapi.testclient import TestClient
from app.api.auth_routes import router, auth_service
from app.services.auth_service import AuthService
from app.models.user import User
from app.patterns.proxy.gateway import AppAccessProxy
from app.patterns.proxy.real_gateway import RealApplicationGateway

app = FastAPI()
app.include_router(router)
client = TestClient(app)


# ─────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────

def _hash(plain: str) -> str:
    return bcrypt.hashpw(plain.encode(), bcrypt.gensalt()).decode()

def _fake_user(role="customer"):
    return {
        "user_id": "U-0001",
        "fname": "Test",
        "lname": "User",
        "email": "test@petro.com",
        "password": _hash("ValidPass1!"),
        "role": role,
    }

def make_service():
    return AuthService()


# =============================================================
# SECURITY TEST 1 — Passwords Are Never Stored in Plain Text
# =============================================================

class TestPasswordSecurity:

    def test_stored_password_is_not_plain_text(self):
        """Password saved to DB must be a bcrypt hash, not the plain string."""
        service = make_service()
        plain = "MySecret99!"
        hashed = service._hash_password(plain)
        assert hashed != plain
        assert hashed.startswith("$2b$"), "Must use bcrypt hashing"

    def test_hashed_password_cannot_be_reversed(self):
        """
        Security: bcrypt is a one-way function. Verify that the hash
        cannot be decoded back to the original plain text.
        """
        service = make_service()
        plain = "IrreversiblePass1!"
        hashed = service._hash_password(plain)
        # Cannot decode — we can only verify, not reverse
        assert plain not in hashed
        assert hashed != plain

    def test_wrong_password_always_fails_check(self):
        """Any password other than the correct one must fail verification."""
        service = make_service()
        hashed = service._hash_password("CorrectPass1!")
        wrong_attempts = ["wrongpass", "CorrectPass1", "CorrectPass1!!", ""]
        for attempt in wrong_attempts:
            assert service._check_password(attempt, hashed) is False, \
                f"'{attempt}' should not match the hash"

    def test_corrupted_hash_returns_false_not_exception(self):
        """
        Exception handling: a corrupted or tampered hash must return
        False safely — never raise an exception (prevents info leakage).
        """
        service = make_service()
        assert service._check_password("anypassword", "CORRUPTED$$HASH") is False


# =============================================================
# SECURITY TEST 2 — Password Never Returned in API Response
# =============================================================

class TestPasswordNotExposedInResponse:

    def test_login_response_does_not_contain_password(self):
        """Login API response must never include the password field."""
        user = _fake_user()

        def table_mock(name):
            m = MagicMock()
            if name == "users":
                m.select.return_value.eq.return_value.execute.return_value.data = [user]
            elif name == "admin":
                m.select.return_value.eq.return_value.execute.return_value.data = []
            elif name == "customer":
                m.select.return_value.eq.return_value.execute.return_value.data = [
                    {"user_id": "U-0001", "username": "test_user"}
                ]
            else:
                m.select.return_value.eq.return_value.execute.return_value.data = []
            return m

        mock_supabase.table.side_effect = table_mock

        with patch("app.services.auth_service.AuthService.send_otp_email"):
            res = client.post("/auth/login", json={
                "email": "test@petro.com",
                "password": "ValidPass1!"
            })
        body = res.text
        assert "ValidPass1!" not in body, \
            "Plain password must never appear in response"

    def test_user_model_to_dict_excludes_password(self):
        """User.to_dict() must never expose the password."""
        user = User("U-0001", "Test", "test@petro.com",
                    password="SuperSecret1!", role="customer")
        d = user.to_dict()
        assert "password" not in d
        assert "SuperSecret1!" not in str(d)


# =============================================================
# SECURITY TEST 3 — OTP Expiry (5-Minute Window)
# =============================================================

class TestOtpExpirySecurity:

    def test_otp_expires_after_300_seconds(self):
        """
        Security: OTP must be invalid once its 300-second window passes.
        """
        service = make_service()
        with patch.object(service, "send_otp_email"):
            service.generate_otp("expiry@petro.com")

        # Fast-forward time past expiry
        service.otp_store["expiry@petro.com"]["expiry"] = time.time() - 1
        code = service.otp_store["expiry@petro.com"]["code"]

        assert service.verify_otp("expiry@petro.com", code) is False

    def test_expired_otp_is_removed_from_store(self):
        """Expired OTP record must be deleted to prevent future replay."""
        service = make_service()
        with patch.object(service, "send_otp_email"):
            service.generate_otp("cleanup@petro.com")
        service.otp_store["cleanup@petro.com"]["expiry"] = time.time() - 1
        code = service.otp_store["cleanup@petro.com"]["code"]
        service.verify_otp("cleanup@petro.com", code)
        assert "cleanup@petro.com" not in service.otp_store


# =============================================================
# SECURITY TEST 4 — OTP One-Time Use
# =============================================================

class TestOtpOneTimeUseSecurity:

    def test_otp_cannot_be_reused_after_success(self):
        """
        Security: A successfully verified OTP must be invalidated
        immediately — replay attacks must fail.
        """
        service = make_service()
        with patch.object(service, "send_otp_email"):
            service.generate_otp("onetime@petro.com")
        code = service.otp_store["onetime@petro.com"]["code"]

        assert service.verify_otp("onetime@petro.com", code) is True   # 1st
        assert service.verify_otp("onetime@petro.com", code) is False  # replay


# =============================================================
# SECURITY TEST 5 — OTP Strength (6 Digits)
# =============================================================

class TestOtpStrength:

    def test_otp_is_always_6_digits(self):
        """OTP must always be exactly 6 numeric digits."""
        service = make_service()
        for _ in range(10):
            with patch.object(service, "send_otp_email"):
                service.generate_otp(f"user{_}@petro.com")
            code = service.otp_store[f"user{_}@petro.com"]["code"]
            assert len(code) == 6 and code.isdigit(), \
                f"OTP '{code}' must be 6 digits"

    def test_otp_is_within_valid_range(self):
        """OTP must be between 100000 and 999999 (inclusive)."""
        service = make_service()
        with patch.object(service, "send_otp_email"):
            service.generate_otp("range@petro.com")
        code = int(service.otp_store["range@petro.com"]["code"])
        assert 100000 <= code <= 999999


# =============================================================
# SECURITY TEST 6 — Unauthorized Dashboard Access Denied
# =============================================================

class TestUnauthorizedAccessDenied:

    def test_proxy_blocks_none_user_from_dashboard(self):
        """
        Security: Accessing the dashboard with no user session (None)
        must be denied by the Proxy — not forwarded to the real gateway.
        """
        real_gateway = RealApplicationGateway()
        mock_auth = MagicMock()
        proxy = AppAccessProxy(real_gateway, mock_auth)

        result = proxy.access_dashboard(None)
        assert result["allowed"] is False

    def test_proxy_denies_login_for_invalid_credentials(self):
        """
        Security: Proxy must never grant access when authenticate
        returns None (bad credentials).
        """
        real_gateway = RealApplicationGateway()
        mock_auth = MagicMock()
        mock_auth.authenticate.return_value = None
        proxy = AppAccessProxy(real_gateway, mock_auth)

        result = proxy.login("bad@petro.com", "wrongpass")
        assert result["allowed"] is False
        assert result["user"] is None


# =============================================================
# SECURITY TEST 7 — Admin Second-Factor (Job Number)
# =============================================================

class TestAdminSecondFactor:

    def test_admin_cannot_access_dashboard_with_wrong_job(self):
        """
        Security: Admin job number is a mandatory second factor.
        A wrong job number must return 403 even after valid login.
        """
        def no_match_table(name):
            m = MagicMock()
            m.select.return_value.eq.return_value.eq.return_value \
                .execute.return_value.data = []
            return m
        mock_supabase.table.side_effect = no_match_table
        res = client.post("/auth/verify-admin-job", json={
            "user_id": "U-0001",
            "job_number": "FAKE-000"
        })
        assert res.status_code == 403

    def test_admin_job_verification_returns_verified_true_on_correct(self):
        """Correct job number must return verified=True."""
        def job_match_table(name):
            m = MagicMock()
            m.select.return_value.eq.return_value.eq.return_value \
                .execute.return_value.data = [{"user_id": "U-0001",
                                               "job_number": "JOB-001"}]
            return m
        mock_supabase.table.side_effect = job_match_table
        res = client.post("/auth/verify-admin-job", json={
            "user_id": "U-0001",
            "job_number": "JOB-001"
        })
        assert res.status_code == 200
        assert res.json()["verified"] is True


# =============================================================
# SECURITY TEST 8 — Brute-Force OTP Resistance
# =============================================================

class TestBruteForceOtpResistance:

    def test_10_wrong_otp_attempts_all_fail(self):
        """
        Security: Submitting 10 wrong OTP codes in a row must all
        return 400 — the correct OTP must still remain valid after
        wrong attempts (store is only cleared on success/expiry).
        """
        service = make_service()
        with patch.object(service, "send_otp_email"):
            service.generate_otp("brute@petro.com")

        for i in range(10):
            wrong_code = f"{i:06d}"
            result = service.verify_otp("brute@petro.com", wrong_code)
            assert result is False, f"Attempt {i} with '{wrong_code}' should fail"

        # The real code must still work after all wrong attempts
        real_code = service.otp_store["brute@petro.com"]["code"]
        assert service.verify_otp("brute@petro.com", real_code) is True


# =============================================================
# SECURITY TEST 9 — Brute-Force Login Resistance
# =============================================================

class TestBruteForceLoginResistance:

    def test_10_wrong_password_attempts_all_return_401(self):
        """
        Security: Ten consecutive wrong password submissions must all
        return HTTP 401 — the account must not be bypassed.
        """
        user = _fake_user()
        mock_supabase.table.return_value.select.return_value \
            .eq.return_value.execute.return_value.data = [user]

        wrong_passwords = [
            "wrong1!", "wrong2!", "wrong3!", "WRONG1!",
            "ValidPass1", "ValidPass1!!", "validpass1!",
            "12345678", "password", "Pass1234!"
        ]
        for pwd in wrong_passwords:
            res = client.post("/auth/login", json={
                "email": "test@petro.com",
                "password": pwd
            })
            assert res.status_code == 401, \
                f"Password '{pwd}' should return 401"


# =============================================================
# SECURITY TEST 10 — Injection & Edge Case Inputs
# =============================================================

class TestEdgeCaseInputSecurity:

    def test_sql_injection_in_email_does_not_crash(self):
        """
        Security: A SQL injection string in the email field must not
        crash the system — it should return 401 or 422, not 500.
        """
        mock_supabase.table.return_value.select.return_value \
            .eq.return_value.execute.return_value.data = []
        res = client.post("/auth/login", json={
            "email": "' OR '1'='1",
            "password": "anything"
        })
        assert res.status_code in [401, 422], \
            "SQL injection attempt must be safely rejected"

    def test_empty_email_in_login_returns_422(self):
        """Empty email must fail schema validation (422)."""
        res = client.post("/auth/login", json={
            "email": "", "password": "SomePass1!"
        })
        assert res.status_code == 422

    def test_extremely_long_password_reveals_code_bug(self):
        """
        BUG FOUND BY TESTING: bcrypt rejects passwords longer than 72 bytes.
        The current _hash_password() has NO length check — this raises a
        ValueError and would crash the signup/login routes with a 500 error.
        
        This test documents the bug. The fix would be to add:
            password = password[:72]
        before calling bcrypt.hashpw().
        """
        service = make_service()
        long_pass = "A1!" + "x" * 997   # 1000 chars, way over 72 bytes
        with pytest.raises(ValueError, match="72 bytes"):
            service._hash_password(long_pass)

    def test_unicode_password_does_not_crash(self):
        """
        Exception handling: A password with Arabic/Unicode characters
        must be handled gracefully without exceptions.
        """
        service = make_service()
        unicode_pass = "كلمةالمرور123A"
        try:
            hashed = service._hash_password(unicode_pass)
            assert service._check_password(unicode_pass, hashed) is True
        except Exception as e:
            pytest.fail(f"Unicode password caused crash: {e}")
