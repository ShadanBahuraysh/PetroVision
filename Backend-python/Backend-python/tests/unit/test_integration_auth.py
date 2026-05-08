"""
=============================================================
INTEGRATION TESTS — Auth API Routes
=============================================================
File covers:
  - POST /auth/login
  - POST /auth/signup
  - POST /auth/verify-otp
  - POST /auth/forgot-password
  - POST /auth/reset-password
  - POST /auth/verify-admin-job

Tests the communication between the FastAPI route layer,
AuthService, and the database (Supabase) — all Supabase calls
are mocked so no real DB connection is needed.
=============================================================
"""

import pytest
import sys
import os
from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient

# ── Path setup ────────────────────────────────────────────
sys.path.insert(0, os.path.join(os.path.dirname(__file__),
                                "../Backend-python/Backend-python"))

# ── Mock supabase before any app import ──────────────────
mock_supabase = MagicMock()
sys.modules["app.supabase_client"] = MagicMock(supabase=mock_supabase)

import bcrypt
from fastapi import FastAPI
from app.api.auth_routes import router

# Build a minimal test app
app = FastAPI()
app.include_router(router)
client = TestClient(app)


# ─────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────

def _hash(plain: str) -> str:
    return bcrypt.hashpw(plain.encode(), bcrypt.gensalt()).decode()

def _mock_user(role="customer"):
    """Return a fake Supabase user row."""
    return {
        "user_id": "U-0001",
        "fname": "Test",
        "lname": "User",
        "email": "test@petro.com",
        "password": _hash("ValidPass1!"),
        "role": role,
    }

def _make_table_mock(user_data, role="customer"):
    """
    Build a supabase mock where table() returns different results
    based on the table name — prevents RecursionError from MagicMock
    objects being passed to FastAPI's JSON encoder.
    """
    user_row = dict(user_data)  # copy so we can safely pop password below

    def table_side_effect(table_name):
        m = MagicMock()
        if table_name == "users":
            m.select.return_value.eq.return_value.execute.return_value.data = [user_row]
            m.update.return_value.eq.return_value.execute.return_value.data = [user_row]
            m.delete.return_value.eq.return_value.execute.return_value.data = []
        elif table_name == "admin":
            if role == "admin":
                m.select.return_value.eq.return_value.execute.return_value.data = [
                    {"user_id": "U-0001", "job_number": "JOB-001"}
                ]
                m.select.return_value.eq.return_value.eq.return_value.execute.return_value.data = [
                    {"user_id": "U-0001", "job_number": "JOB-001"}
                ]
            else:
                m.select.return_value.eq.return_value.execute.return_value.data = []
                m.select.return_value.eq.return_value.eq.return_value.execute.return_value.data = []
        elif table_name == "customer":
            if role == "customer":
                m.select.return_value.eq.return_value.execute.return_value.data = [
                    {"user_id": "U-0001", "username": "test_user"}
                ]
                m.insert.return_value.execute.return_value.data = [
                    {"user_id": "U-0001", "username": "test_user"}
                ]
            else:
                m.select.return_value.eq.return_value.execute.return_value.data = []
        else:
            # loyalty_account, membership, etc.
            m.select.return_value.eq.return_value.execute.return_value.data = []
            m.insert.return_value.execute.return_value.data = []
        return m

    return table_side_effect


# =============================================================
# POST /auth/login
# =============================================================

class TestLoginRoute:

    def _setup_valid_user(self, role="customer"):
        user = _mock_user(role)
        mock_supabase.table.side_effect = _make_table_mock(user, role)

    def test_login_success_returns_200(self):
        """Valid credentials must return HTTP 200."""
        self._setup_valid_user()
        with patch("app.services.auth_service.AuthService.send_otp_email"):
            res = client.post("/auth/login", json={
                "email": "test@petro.com",
                "password": "ValidPass1!"
            })
        assert res.status_code == 200

    def test_login_success_requires_otp(self):
        """Successful login must indicate OTP is required."""
        self._setup_valid_user()
        with patch("app.services.auth_service.AuthService.send_otp_email"):
            res = client.post("/auth/login", json={
                "email": "test@petro.com",
                "password": "ValidPass1!"
            })
        assert res.json()["requires_otp"] is True

    def test_login_success_returns_user(self):
        """Login response must include the user object."""
        self._setup_valid_user()
        with patch("app.services.auth_service.AuthService.send_otp_email"):
            res = client.post("/auth/login", json={
                "email": "test@petro.com",
                "password": "ValidPass1!"
            })
        assert "user" in res.json()

    def test_login_wrong_password_returns_401(self):
        """Wrong password must return HTTP 401 Unauthorized."""
        self._setup_valid_user()
        res = client.post("/auth/login", json={
            "email": "test@petro.com",
            "password": "WrongPass999!"
        })
        assert res.status_code == 401

    def test_login_nonexistent_email_returns_401(self):
        """Unknown email must return HTTP 401."""
        def empty_table(name):
            m = MagicMock()
            m.select.return_value.eq.return_value.execute.return_value.data = []
            return m
        mock_supabase.table.side_effect = empty_table
        res = client.post("/auth/login", json={
            "email": "ghost@petro.com",
            "password": "AnyPass1!"
        })
        assert res.status_code == 401

    def test_login_missing_email_field_returns_422(self):
        """Request missing 'email' field must return HTTP 422 Validation Error."""
        res = client.post("/auth/login", json={"password": "SomePass1!"})
        assert res.status_code == 422

    def test_login_missing_password_field_returns_422(self):
        """Request missing 'password' field must return HTTP 422."""
        res = client.post("/auth/login", json={"email": "test@petro.com"})
        assert res.status_code == 422

    def test_login_empty_body_returns_422(self):
        """Completely empty body must return HTTP 422."""
        res = client.post("/auth/login", json={})
        assert res.status_code == 422


# =============================================================
# POST /auth/verify-otp
# =============================================================

class TestVerifyOtpRoute:

    def _plant_otp(self, email: str, code: str, expired=False):
        """Directly insert an OTP into the auth_service's otp_store."""
        import time
        from app.api.auth_routes import auth_service
        auth_service.otp_store[email] = {
            "code": code,
            "expiry": time.time() - 1 if expired else time.time() + 300
        }

    def test_verify_otp_correct_code_returns_200(self):
        """Correct OTP code must return HTTP 200."""
        self._plant_otp("otp@petro.com", "123456")
        res = client.post("/auth/verify-otp", json={
            "email": "otp@petro.com",
            "code": "123456"
        })
        assert res.status_code == 200

    def test_verify_otp_correct_code_returns_verified_true(self):
        """Response must include verified=True on success."""
        self._plant_otp("otp2@petro.com", "654321")
        res = client.post("/auth/verify-otp", json={
            "email": "otp2@petro.com",
            "code": "654321"
        })
        assert res.json()["verified"] is True

    def test_verify_otp_wrong_code_returns_400(self):
        """Wrong OTP code must return HTTP 400."""
        self._plant_otp("wrong@petro.com", "111111")
        res = client.post("/auth/verify-otp", json={
            "email": "wrong@petro.com",
            "code": "999999"
        })
        assert res.status_code == 400

    def test_verify_otp_expired_code_returns_400(self):
        """Expired OTP must return HTTP 400, not 200."""
        self._plant_otp("exp@petro.com", "777777", expired=True)
        res = client.post("/auth/verify-otp", json={
            "email": "exp@petro.com",
            "code": "777777"
        })
        assert res.status_code == 400

    def test_verify_otp_no_otp_requested_returns_400(self):
        """Verifying OTP for an email with no OTP in store must return 400."""
        res = client.post("/auth/verify-otp", json={
            "email": "nocode@petro.com",
            "code": "000000"
        })
        assert res.status_code == 400

    def test_verify_otp_missing_fields_returns_422(self):
        """Missing 'code' field must return HTTP 422."""
        res = client.post("/auth/verify-otp", json={"email": "otp@petro.com"})
        assert res.status_code == 422


# =============================================================
# POST /auth/signup
# =============================================================

class TestSignupRoute:

    def test_signup_new_user_returns_200(self):
        """Signing up with a new email must return HTTP 200."""
        new_user = {
            "user_id": "U-0099", "fname": "New", "lname": "User",
            "email": "new@petro.com", "role": "customer"
        }

        def table_mock(name):
            m = MagicMock()
            if name == "users":
                # first call (check existing) → empty, second call (insert) → new user
                m.select.return_value.eq.return_value.execute.return_value.data = []
                m.insert.return_value.execute.return_value.data = [new_user]
            else:
                m.select.return_value.eq.return_value.execute.return_value.data = []
                m.insert.return_value.execute.return_value.data = []
            return m

        mock_supabase.table.side_effect = table_mock
        res = client.post("/auth/signup", json={
            "fname": "New", "lname": "User",
            "email": "new@petro.com", "phone": "0512345678",
            "password": "NewPass1!", "role": "customer"
        })
        assert res.status_code == 200

    def test_signup_returns_user_in_response(self):
        """Signup response must include the created user object."""
        new_user = {
            "user_id": "U-0099", "fname": "New", "lname": "User",
            "email": "new@petro.com", "role": "customer"
        }

        def table_mock(name):
            m = MagicMock()
            if name == "users":
                m.select.return_value.eq.return_value.execute.return_value.data = []
                m.insert.return_value.execute.return_value.data = [new_user]
            else:
                m.select.return_value.eq.return_value.execute.return_value.data = []
                m.insert.return_value.execute.return_value.data = []
            return m

        mock_supabase.table.side_effect = table_mock
        res = client.post("/auth/signup", json={
            "fname": "New", "lname": "User",
            "email": "new@petro.com", "phone": "0512345678",
            "password": "NewPass1!", "role": "customer"
        })
        assert "user" in res.json()

    def test_signup_duplicate_email_returns_400(self):
        """Registering with an already existing email must return HTTP 400."""
        existing = _mock_user()

        def table_mock(name):
            m = MagicMock()
            if name == "users":
                m.select.return_value.eq.return_value.execute.return_value.data = [existing]
            else:
                m.select.return_value.eq.return_value.execute.return_value.data = []
            return m

        mock_supabase.table.side_effect = table_mock
        res = client.post("/auth/signup", json={
            "fname": "Dup", "lname": "User",
            "email": "test@petro.com", "phone": "0512345678",
            "password": "DupPass1!", "role": "customer"
        })
        assert res.status_code == 400

    def test_signup_missing_required_field_returns_422(self):
        """Signup without 'email' must return HTTP 422."""
        res = client.post("/auth/signup", json={
            "fname": "No", "lname": "Email",
            "password": "NoEmail1!", "role": "customer"
        })
        assert res.status_code == 422


# =============================================================
# POST /auth/forgot-password
# =============================================================

class TestForgotPasswordRoute:

    def test_forgot_password_existing_email_returns_200(self):
        """Forgot-password for a real email must return HTTP 200."""
        mock_supabase.table.return_value.select.return_value \
            .eq.return_value.execute.return_value.data = [_mock_user()]
        with patch("app.services.auth_service.AuthService.send_otp_email"):
            res = client.post("/auth/forgot-password",
                              json={"email": "test@petro.com"})
        assert res.status_code == 200

    def test_forgot_password_nonexistent_email_returns_404(self):
        """Forgot-password for an unknown email must return HTTP 404."""
        def empty_table(name):
            m = MagicMock()
            m.select.return_value.eq.return_value.execute.return_value.data = []
            return m
        from unittest.mock import MagicMock as _M
        import sys
        sys.modules["app.supabase_client"].supabase.table.side_effect = empty_table
        res = client.post("/auth/forgot-password",
                          json={"email": "nobody@petro.com"})
        assert res.status_code == 404

    def test_forgot_password_missing_email_returns_422(self):
        """Missing email field must return HTTP 422."""
        res = client.post("/auth/forgot-password", json={})
        assert res.status_code == 422


# =============================================================
# POST /auth/reset-password
# =============================================================

class TestResetPasswordRoute:

    def _plant_reset_otp(self, email: str, code: str):
        import time
        from app.api.auth_routes import auth_service
        auth_service.otp_store[email] = {
            "code": code,
            "expiry": time.time() + 300,
            "purpose": "reset_password"
        }

    def test_reset_password_valid_otp_returns_200(self):
        """Valid OTP + new password must return HTTP 200."""
        self._plant_reset_otp("reset@petro.com", "888888")
        mock_supabase.table.return_value.update.return_value \
            .eq.return_value.execute.return_value.data = [{"user_id": "U-0001"}]
        res = client.post("/auth/reset-password", json={
            "email": "reset@petro.com",
            "code": "888888",
            "new_password": "NewSecure1!"
        })
        assert res.status_code == 200

    def test_reset_password_wrong_otp_returns_400(self):
        """Wrong OTP code during reset must return HTTP 400."""
        self._plant_reset_otp("reset2@petro.com", "111111")
        res = client.post("/auth/reset-password", json={
            "email": "reset2@petro.com",
            "code": "999999",
            "new_password": "NewSecure1!"
        })
        assert res.status_code == 400

    def test_reset_password_missing_fields_returns_422(self):
        """Missing new_password field must return HTTP 422."""
        res = client.post("/auth/reset-password", json={
            "email": "reset@petro.com",
            "code": "888888"
        })
        assert res.status_code == 422


# =============================================================
# POST /auth/verify-admin-job
# =============================================================

class TestVerifyAdminJobRoute:

    def test_valid_job_number_returns_200(self):
        """Correct user_id + job_number must return HTTP 200."""
        mock_supabase.table.return_value.select.return_value \
            .eq.return_value.eq.return_value \
            .execute.return_value.data = [{"user_id": "U-0001",
                                           "job_number": "JOB-001"}]
        res = client.post("/auth/verify-admin-job", json={
            "user_id": "U-0001",
            "job_number": "JOB-001"
        })
        assert res.status_code == 200

    def test_invalid_job_number_returns_403(self):
        """Wrong job number must return HTTP 403 Forbidden."""
        def no_match_table(name):
            m = MagicMock()
            m.select.return_value.eq.return_value.eq.return_value \
                .execute.return_value.data = []
            return m
        mock_supabase.table.side_effect = no_match_table
        res = client.post("/auth/verify-admin-job", json={
            "user_id": "U-0001",
            "job_number": "WRONG-999"
        })
        assert res.status_code == 403

    def test_missing_user_id_returns_422(self):
        """Missing user_id field must return HTTP 422."""
        res = client.post("/auth/verify-admin-job",
                          json={"job_number": "JOB-001"})
        assert res.status_code == 422

    def test_missing_job_number_returns_422(self):
        """Missing job_number field must return HTTP 422."""
        res = client.post("/auth/verify-admin-job",
                          json={"user_id": "U-0001"})
        assert res.status_code == 422
