"""
=============================================================
UNIT TESTS — Authentication & Access Control
=============================================================
File covers:
  - AuthService: generate_otp, verify_otp, _hash_password,
                 _check_password
  - User model:  is_admin(), is_customer()
  - Proxy pattern: AppAccessProxy.login, AppAccessProxy.access_dashboard
  - RealApplicationGateway.access_dashboard
  - Flutter signup_screen validation logic (ported to Python)

All tests are fully isolated — NO database, NO email, NO network.
External dependencies (supabase, smtplib) are mocked.
=============================================================
"""

import time
import pytest
from unittest.mock import MagicMock, patch
import bcrypt
import sys
import os

# ── Path setup ────────────────────────────────────────────
sys.path.insert(0, os.path.join(os.path.dirname(__file__),
                                "../Backend-python/Backend-python"))

# ── Patch supabase BEFORE importing anything that uses it ─
import unittest.mock as mock

mock_supabase = MagicMock()
sys.modules["app.supabase_client"] = MagicMock(supabase=mock_supabase)

from app.models.user import User
from app.patterns.proxy.gateway import AppAccessProxy
from app.patterns.proxy.real_gateway import RealApplicationGateway


# ─────────────────────────────────────────────────────────
# Helper: build an AuthService without triggering supabase
# ─────────────────────────────────────────────────────────
def make_auth_service():
    with patch("app.supabase_client.supabase", mock_supabase):
        from app.services.auth_service import AuthService
        return AuthService()


# =============================================================
# SECTION 1 — User Model: is_admin() / is_customer()
# =============================================================

class TestUserModel:

    def test_is_admin_returns_true_for_admin_role(self):
        """User with role='admin' should be identified as admin."""
        user = User("U-0001", "Ali Admin", "ali@petro.com", role="admin")
        assert user.is_admin() is True

    def test_is_admin_returns_false_for_customer_role(self):
        """Customer user must NOT be identified as admin."""
        user = User("U-0002", "Sara Customer", "sara@petro.com", role="customer")
        assert user.is_admin() is False

    def test_is_customer_returns_true_for_customer_role(self):
        """User with role='customer' should be identified as customer."""
        user = User("U-0003", "Noor User", "noor@petro.com", role="customer")
        assert user.is_customer() is True

    def test_is_customer_returns_false_for_admin_role(self):
        """Admin user must NOT be identified as customer."""
        user = User("U-0004", "Admin User", "admin@petro.com", role="admin")
        assert user.is_customer() is False

    def test_role_check_is_case_insensitive(self):
        """Role comparisons must handle mixed-case strings (e.g. 'Admin')."""
        user = User("U-0005", "Test", "t@petro.com", role="Admin")
        assert user.is_admin() is True

    def test_unknown_role_is_neither_admin_nor_customer(self):
        """A user with an unrecognised role should fail both checks."""
        user = User("U-0006", "Ghost", "g@petro.com", role="unknown")
        assert user.is_admin() is False
        assert user.is_customer() is False

    def test_to_dict_does_not_expose_password(self):
        """to_dict() must never include the password field."""
        user = User("U-0007", "Safe User", "safe@petro.com",
                    password="secret123", role="customer")
        d = user.to_dict()
        assert "password" not in d

    def test_to_dict_contains_expected_keys(self):
        """to_dict() should return user_id, name, email, and role."""
        user = User("U-0008", "Dict User", "dict@petro.com", role="customer")
        d = user.to_dict()
        assert set(d.keys()) == {"user_id", "name", "email", "role"}


# =============================================================
# SECTION 2 — Password Hashing: _hash_password / _check_password
# =============================================================

class TestPasswordHashing:

    def setup_method(self):
        self.service = make_auth_service()

    def test_hash_password_returns_a_string(self):
        """Hashed password must be a non-empty string."""
        hashed = self.service._hash_password("MyPassword1!")
        assert isinstance(hashed, str)
        assert len(hashed) > 0

    def test_hash_is_different_from_plain_password(self):
        """Hashed value must not equal the original plain text."""
        plain = "MyPassword1!"
        hashed = self.service._hash_password(plain)
        assert hashed != plain

    def test_same_password_produces_different_hashes(self):
        """bcrypt uses random salts — two hashes of the same password differ."""
        hashed1 = self.service._hash_password("SamePass99")
        hashed2 = self.service._hash_password("SamePass99")
        assert hashed1 != hashed2

    def test_check_password_returns_true_for_correct_password(self):
        """Correct plain password must verify against its own hash."""
        plain = "CorrectHorse99!"
        hashed = self.service._hash_password(plain)
        assert self.service._check_password(plain, hashed) is True

    def test_check_password_returns_false_for_wrong_password(self):
        """Wrong plain password must NOT verify against a different hash."""
        hashed = self.service._hash_password("RealPassword1!")
        assert self.service._check_password("WrongPassword!", hashed) is False

    def test_check_password_returns_false_for_empty_password(self):
        """Empty string must not match a real password hash."""
        hashed = self.service._hash_password("SomePassword1!")
        assert self.service._check_password("", hashed) is False

    def test_check_password_handles_invalid_hash_gracefully(self):
        """
        Exception handling: _check_password catches bcrypt exceptions
        and returns False instead of crashing.
        """
        result = self.service._check_password("anypassword", "not_a_valid_hash")
        assert result is False


# =============================================================
# SECTION 3 — OTP: generate_otp / verify_otp
# =============================================================

class TestOtpLogic:

    def setup_method(self):
        self.service = make_auth_service()

    def test_generate_otp_stores_code_for_email(self):
        """After generating OTP, the email must exist in otp_store."""
        with patch.object(self.service, "send_otp_email"):
            self.service.generate_otp("user@petro.com")
        assert "user@petro.com" in self.service.otp_store

    def test_generate_otp_code_is_6_digits(self):
        """Generated OTP must be exactly 6 digits."""
        with patch.object(self.service, "send_otp_email"):
            self.service.generate_otp("digits@petro.com")
        code = self.service.otp_store["digits@petro.com"]["code"]
        assert len(code) == 6
        assert code.isdigit()

    def test_generate_otp_sets_expiry_in_future(self):
        """OTP expiry must be set ~5 minutes (300 s) in the future."""
        with patch.object(self.service, "send_otp_email"):
            self.service.generate_otp("expiry@petro.com")
        expiry = self.service.otp_store["expiry@petro.com"]["expiry"]
        assert expiry > time.time()
        assert expiry <= time.time() + 305  # small tolerance

    def test_generate_otp_normalises_email_to_lowercase(self):
        """Email key in otp_store must always be lowercase."""
        with patch.object(self.service, "send_otp_email"):
            self.service.generate_otp("UPPER@PETRO.COM")
        assert "upper@petro.com" in self.service.otp_store

    def test_generate_otp_email_send_failure_does_not_raise(self):
        """
        Exception handling: if send_otp_email raises, generate_otp must
        still succeed and store the OTP (fail-safe fallback).
        """
        with patch.object(self.service, "send_otp_email",
                          side_effect=Exception("SMTP error")):
            result = self.service.generate_otp("failmail@petro.com")
        assert "failmail@petro.com" in self.service.otp_store
        assert result["message"] == "OTP generated successfully"

    def test_verify_otp_returns_true_for_correct_code(self):
        """Correct OTP code submitted within expiry must return True."""
        with patch.object(self.service, "send_otp_email"):
            self.service.generate_otp("verify@petro.com")
        code = self.service.otp_store["verify@petro.com"]["code"]
        assert self.service.verify_otp("verify@petro.com", code) is True

    def test_verify_otp_returns_false_for_wrong_code(self):
        """Incorrect OTP code must return False."""
        with patch.object(self.service, "send_otp_email"):
            self.service.generate_otp("wrong@petro.com")
        assert self.service.verify_otp("wrong@petro.com", "000000") is False

    def test_verify_otp_returns_false_for_nonexistent_email(self):
        """Verifying OTP for an email that never requested one must return False."""
        assert self.service.verify_otp("ghost@petro.com", "123456") is False

    def test_verify_otp_removes_code_after_successful_verification(self):
        """After a successful verify, the OTP must be deleted (one-time use)."""
        with patch.object(self.service, "send_otp_email"):
            self.service.generate_otp("once@petro.com")
        code = self.service.otp_store["once@petro.com"]["code"]
        self.service.verify_otp("once@petro.com", code)
        assert "once@petro.com" not in self.service.otp_store

    def test_verify_otp_cannot_be_used_twice(self):
        """The same OTP must fail on the second submission (one-time use)."""
        with patch.object(self.service, "send_otp_email"):
            self.service.generate_otp("reuse@petro.com")
        code = self.service.otp_store["reuse@petro.com"]["code"]
        self.service.verify_otp("reuse@petro.com", code)           # 1st use
        assert self.service.verify_otp("reuse@petro.com", code) is False  # 2nd

    def test_verify_otp_returns_false_for_expired_code(self):
        """
        Exception handling: expired OTP (past expiry time) must return False
        and the record must be cleaned up from otp_store.
        """
        with patch.object(self.service, "send_otp_email"):
            self.service.generate_otp("expired@petro.com")
        # Manually set expiry to the past
        self.service.otp_store["expired@petro.com"]["expiry"] = time.time() - 1
        code = self.service.otp_store["expired@petro.com"]["code"]
        assert self.service.verify_otp("expired@petro.com", code) is False
        assert "expired@petro.com" not in self.service.otp_store

    def test_verify_otp_is_case_insensitive_for_email(self):
        """Email casing must not affect OTP verification."""
        with patch.object(self.service, "send_otp_email"):
            self.service.generate_otp("CaseTest@petro.com")
        code = self.service.otp_store["casetest@petro.com"]["code"]
        assert self.service.verify_otp("CASETEST@PETRO.COM", code) is True


# =============================================================
# SECTION 4 — Proxy Pattern: AppAccessProxy
# =============================================================

class TestAppAccessProxy:

    def setup_method(self):
        self.real_gateway = RealApplicationGateway()
        self.mock_auth = MagicMock()
        self.proxy = AppAccessProxy(self.real_gateway, self.mock_auth)

    # ── login ─────────────────────────────────────────────

    def test_login_allowed_when_credentials_valid(self):
        """Valid credentials must return allowed=True with user data."""
        self.mock_auth.authenticate.return_value = {
            "user_id": "U-0001", "role": "customer"
        }
        result = self.proxy.login("user@petro.com", "ValidPass1!")
        assert result["allowed"] is True
        assert result["user"] is not None

    def test_login_denied_when_credentials_invalid(self):
        """Invalid credentials (authenticate returns None) must return allowed=False."""
        self.mock_auth.authenticate.return_value = None
        result = self.proxy.login("bad@petro.com", "wrongpass")
        assert result["allowed"] is False
        assert result["user"] is None

    def test_login_denied_message_is_correct(self):
        """The denial message must clearly say invalid credentials."""
        self.mock_auth.authenticate.return_value = None
        result = self.proxy.login("bad@petro.com", "wrongpass")
        assert "Invalid" in result["message"]

    def test_login_returns_user_data_on_success(self):
        """Successful login result must contain the authenticated user object."""
        user_data = {"user_id": "U-0010", "role": "admin"}
        self.mock_auth.authenticate.return_value = user_data
        result = self.proxy.login("admin@petro.com", "AdminPass1!")
        assert result["user"] == user_data

    # ── access_dashboard ──────────────────────────────────

    def test_access_dashboard_allowed_for_valid_user(self):
        """Authenticated user must be granted dashboard access."""
        user = {"user_id": "U-0011", "role": "admin"}
        result = self.proxy.access_dashboard(user)
        assert result["allowed"] is True

    def test_access_dashboard_denied_for_none_user(self):
        """
        Exception handling: passing None as the user (no session) must
        return allowed=False, not raise an exception.
        """
        result = self.proxy.access_dashboard(None)
        assert result["allowed"] is False
        assert "No user session" in result["message"]

    def test_access_dashboard_contains_dashboard_data(self):
        """Dashboard result must contain a 'dashboard' key with data."""
        user = {"user_id": "U-0012", "role": "customer"}
        result = self.proxy.access_dashboard(user)
        assert "dashboard" in result

    def test_real_gateway_access_dashboard_returns_allowed_true(self):
        """RealApplicationGateway must always grant access."""
        gateway = RealApplicationGateway()
        user = {"user_id": "U-0013", "role": "customer"}
        result = gateway.access_dashboard(user)
        assert result["allowed"] is True

    def test_real_gateway_returns_user_in_response(self):
        """RealApplicationGateway must echo the user back in the response."""
        gateway = RealApplicationGateway()
        user = {"user_id": "U-0014", "role": "admin"}
        result = gateway.access_dashboard(user)
        assert result["user"] == user


# =============================================================
# SECTION 5 — Flutter Signup Validation Logic (ported to Python)
# These mirror the exact validation functions in signup_screen.dart
# =============================================================

import re

def validate_name(value: str):
    if not value.strip():
        return "Full name is required"
    if len(value.strip()) < 3:
        return "Name must be at least 3 characters"
    return None

def validate_email(value: str):
    if not value.strip():
        return "Email is required"
    pattern = r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$'
    if not re.match(pattern, value.strip()):
        return "Enter a valid email address"
    return None

def validate_phone(value: str):
    if not value.strip():
        return "Phone number is required"
    if not re.match(r'^[0-9]{10,15}$', value.strip()):
        return "Enter a valid phone number"
    return None

def validate_password(value: str):
    if not value:
        return "Password is required"
    if len(value) < 8:
        return "Password must be at least 8 characters"
    if not re.search(r'[A-Z]', value):
        return "Must contain at least one uppercase letter"
    if not re.search(r'[a-z]', value):
        return "Must contain at least one lowercase letter"
    if not re.search(r'[0-9]', value):
        return "Must contain at least one number"
    return None


class TestFlutterSignupValidation:

    # ── Name validation ───────────────────────────────────

    def test_valid_name_passes(self):
        assert validate_name("Sara Ali") is None

    def test_empty_name_fails(self):
        assert validate_name("") is not None

    def test_short_name_fails(self):
        assert validate_name("ab") is not None

    def test_name_with_only_spaces_fails(self):
        assert validate_name("   ") is not None

    # ── Email validation ──────────────────────────────────

    def test_valid_email_passes(self):
        assert validate_email("sara@gmail.com") is None

    def test_empty_email_fails(self):
        assert validate_email("") is not None

    def test_email_missing_at_sign_fails(self):
        assert validate_email("saragmail.com") is not None

    def test_email_missing_domain_fails(self):
        assert validate_email("sara@") is not None

    def test_email_with_spaces_fails(self):
        assert validate_email("sara @gmail.com") is not None

    # ── Phone validation ──────────────────────────────────

    def test_valid_phone_passes(self):
        assert validate_phone("0512345678") is None

    def test_empty_phone_fails(self):
        assert validate_phone("") is not None

    def test_phone_with_letters_fails(self):
        assert validate_phone("05abc12345") is not None

    def test_phone_too_short_fails(self):
        assert validate_phone("12345") is not None

    # ── Password validation ───────────────────────────────

    def test_valid_password_passes(self):
        assert validate_password("Secure1Pass") is None

    def test_empty_password_fails(self):
        assert validate_password("") is not None

    def test_password_too_short_fails(self):
        assert validate_password("Ab1") is not None

    def test_password_missing_uppercase_fails(self):
        assert validate_password("lowercase1") is not None

    def test_password_missing_lowercase_fails(self):
        assert validate_password("UPPERCASE1") is not None

    def test_password_missing_number_fails(self):
        assert validate_password("NoNumbers!") is not None

    def test_strong_password_passes_all_rules(self):
        assert validate_password("StrongPass99") is None
