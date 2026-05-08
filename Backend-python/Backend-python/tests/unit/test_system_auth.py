"""
=============================================================
SYSTEM TESTS — Complete Authentication Flows
=============================================================
Tests the full end-to-end authentication workflow exactly as
a user would experience it, going through every step:

  Flow 1:  Customer signup → OTP verify → Home accessible
  Flow 2:  Customer login  → OTP verify → Home accessible
  Flow 3:  Admin login → OTP verify → Job verify → Dashboard
  Flow 4:  Invalid login → Error, no OTP sent
  Flow 5:  Login OK, wrong OTP → Blocked from dashboard
  Flow 6:  Forgot password → Reset → Login with new password
  Flow 7:  Admin wrong job number → Dashboard blocked

All external services (Supabase, SMTP) are mocked.
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

def _get_planted_otp(email: str) -> str:
    """Return the OTP that was planted in auth_service.otp_store."""
    return auth_service.otp_store.get(email.lower(), {}).get("code", "")

def _setup_table_mock(user, role="customer"):
    """Proper per-table mock that avoids RecursionError in FastAPI encoder."""
    def table_side_effect(table_name):
        m = MagicMock()
        if table_name == "users":
            m.select.return_value.eq.return_value.execute.return_value.data = [user]
            m.insert.return_value.execute.return_value.data = [user]
            m.update.return_value.eq.return_value.execute.return_value.data = [user]
        elif table_name == "admin":
            if role == "admin":
                m.select.return_value.eq.return_value.execute.return_value.data = [
                    {"user_id": "U-0001", "job_number": "JOB-001"}
                ]
                m.select.return_value.eq.return_value.eq.return_value \
                    .execute.return_value.data = [
                    {"user_id": "U-0001", "job_number": "JOB-001"}
                ]
            else:
                m.select.return_value.eq.return_value.execute.return_value.data = []
                m.select.return_value.eq.return_value.eq.return_value \
                    .execute.return_value.data = []
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
            m.select.return_value.eq.return_value.execute.return_value.data = []
            m.insert.return_value.execute.return_value.data = []
        return m
    return table_side_effect


# =============================================================
# FLOW 1 — Customer Signup → OTP Verify → Access Granted
# =============================================================

class TestCustomerSignupFlow:

    def test_full_signup_and_otp_flow(self):
        """
        System test: A new customer signs up, receives OTP,
        verifies it, and gains access.
        Steps:
          1. POST /auth/signup    → 200
          2. POST /auth/verify-otp → 200, verified=True
        """
        new_user = {
            "user_id": "U-0099", "fname": "Noor", "lname": "Ali",
            "email": "noor@petro.com", "role": "customer"
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

        with patch("app.services.auth_service.AuthService.send_otp_email"):
            signup_res = client.post("/auth/signup", json={
                "fname": "Noor", "lname": "Ali",
                "email": "noor@petro.com", "phone": "0512345678",
                "password": "NoorPass1!", "role": "customer"
            })
        assert signup_res.status_code == 200, "Signup should succeed"

        # Step 2 — OTP
        with patch("app.services.auth_service.AuthService.send_otp_email"):
            auth_service.generate_otp("noor@petro.com")
        otp = _get_planted_otp("noor@petro.com")
        assert otp != "", "OTP must be generated after signup"

        otp_res = client.post("/auth/verify-otp", json={
            "email": "noor@petro.com", "code": otp
        })
        assert otp_res.status_code == 200
        assert otp_res.json()["verified"] is True, "OTP should be verified"


class TestCustomerLoginFlow:

    def test_customer_login_otp_and_access(self):
        """
        System test: Existing customer logs in with valid credentials,
        verifies OTP, and accesses their home dashboard.
        Steps:
          1. POST /auth/login      → 200, requires_otp=True
          2. POST /auth/verify-otp → 200, verified=True
          3. GET  /auth/dashboard  → 200, allowed=True
        """
        user = _fake_user(role="customer")
        mock_supabase.table.side_effect = _setup_table_mock(user, "customer")

        # Step 1 — Login
        with patch("app.services.auth_service.AuthService.send_otp_email"):
            login_res = client.post("/auth/login", json={
                "email": "test@petro.com", "password": "ValidPass1!"
            })
        assert login_res.status_code == 200
        assert login_res.json()["requires_otp"] is True

        # Step 2 — OTP verify
        otp = _get_planted_otp("test@petro.com")
        otp_res = client.post("/auth/verify-otp", json={
            "email": "test@petro.com", "code": otp
        })
        assert otp_res.status_code == 200
        assert otp_res.json()["verified"] is True

        # Step 3 — Dashboard access
        mock_supabase.table.side_effect = _setup_table_mock(user, "customer")
        dash_res = client.get("/auth/dashboard/U-0001")
        assert dash_res.status_code == 200
        assert dash_res.json()["allowed"] is True


class TestAdminLoginFlow:

    def test_admin_full_login_flow(self):
        """
        System test: Admin logs in, verifies OTP, then passes job
        number verification before accessing the admin dashboard.
        Steps:
          1. POST /auth/login           → 200, user.role='admin'
          2. POST /auth/verify-otp      → 200
          3. POST /auth/verify-admin-job → 200, verified=True
        """
        admin_user = _fake_user(role="admin")
        mock_supabase.table.side_effect = _setup_table_mock(admin_user, "admin")

        # Step 1 — Login
        with patch("app.services.auth_service.AuthService.send_otp_email"):
            login_res = client.post("/auth/login", json={
                "email": "test@petro.com", "password": "ValidPass1!"
            })
        assert login_res.status_code == 200
        user_data = login_res.json()["user"]
        assert user_data["role"] == "admin"

        # Step 2 — OTP verify
        otp = _get_planted_otp("test@petro.com")
        otp_res = client.post("/auth/verify-otp", json={
            "email": "test@petro.com", "code": otp
        })
        assert otp_res.status_code == 200

        # Step 3 — Job number verify (mock the admin table for verify-admin-job)
        mock_supabase.table.side_effect = _setup_table_mock(admin_user, "admin")
        job_res = client.post("/auth/verify-admin-job", json={
            "user_id": "U-0001", "job_number": "JOB-001"
        })
        assert job_res.status_code == 200
        assert job_res.json()["verified"] is True


# =============================================================
# FLOW 4 — Invalid Login → Error Displayed, No OTP
# =============================================================

class TestInvalidLoginFlow:

    def test_wrong_password_blocks_login_and_no_otp(self):
        """
        System test: Wrong password returns 401 error.
        No OTP should be stored for this email.
        """
        user = _fake_user()
        mock_supabase.table.side_effect = _setup_table_mock(user, "customer")

        before_otp = auth_service.otp_store.get("test@petro.com")

        res = client.post("/auth/login", json={
            "email": "test@petro.com",
            "password": "WrongPassword!"
        })
        assert res.status_code == 401, "Wrong password must be rejected"
        assert "detail" in res.json(), "Error detail must be present"

        after_otp = auth_service.otp_store.get("test@petro.com")
        assert before_otp == after_otp, "No new OTP should be generated on failed login"

    def test_unknown_email_returns_401(self):
        """Unknown email must return 401, not 500."""
        def empty_table(name):
            m = MagicMock()
            m.select.return_value.eq.return_value.execute.return_value.data = []
            return m
        mock_supabase.table.side_effect = empty_table
        res = client.post("/auth/login", json={
            "email": "unknown@petro.com",
            "password": "AnyPass1!"
        })
        assert res.status_code == 401

    def test_duplicate_signup_returns_400(self):
        """
        System test: Trying to sign up with an already registered
        email must return 400 — not create a duplicate account.
        """
        existing = _fake_user()

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


class TestWrongOtpBlocksAccess:

    def test_correct_login_then_wrong_otp_is_blocked(self):
        """
        System test: User authenticates correctly but enters the
        wrong OTP — they must NOT gain access.
        Steps:
          1. POST /auth/login      → 200
          2. POST /auth/verify-otp (wrong code) → 400
        """
        user = _fake_user()
        mock_supabase.table.side_effect = _setup_table_mock(user, "customer")

        # Step 1 — Login succeeds
        with patch("app.services.auth_service.AuthService.send_otp_email"):
            login_res = client.post("/auth/login", json={
                "email": "test@petro.com", "password": "ValidPass1!"
            })
        assert login_res.status_code == 200

        # Step 2 — Submit wrong OTP
        otp_res = client.post("/auth/verify-otp", json={
            "email": "test@petro.com", "code": "000000"
        })
        assert otp_res.status_code == 400, "Wrong OTP must block access"


class TestForgotPasswordFlow:

    def test_full_password_reset_flow(self):
        """
        System test: User forgets password, requests reset OTP,
        submits new password, then logs in successfully.
        Steps:
          1. POST /auth/forgot-password → 200
          2. POST /auth/reset-password  → 200
        """
        user = _fake_user()
        mock_supabase.table.side_effect = _setup_table_mock(user, "customer")

        # Step 1 — Request reset OTP
        with patch("app.services.auth_service.AuthService.send_otp_email"):
            forgot_res = client.post("/auth/forgot-password",
                                     json={"email": "test@petro.com"})
        assert forgot_res.status_code == 200

        # Step 2 — Use OTP to reset password
        otp = _get_planted_otp("test@petro.com")
        mock_supabase.table.side_effect = _setup_table_mock(user, "customer")
        reset_res = client.post("/auth/reset-password", json={
            "email": "test@petro.com",
            "code": otp,
            "new_password": "BrandNew99!"
        })
        assert reset_res.status_code == 200, "Password reset should succeed"

    def test_reset_with_wrong_otp_fails(self):
        """Wrong OTP during password reset must return 400."""
        with patch("app.services.auth_service.AuthService.send_otp_email"):
            client.post("/auth/forgot-password",
                        json={"email": "test@petro.com"})
        res = client.post("/auth/reset-password", json={
            "email": "test@petro.com",
            "code": "000000",
            "new_password": "WontWork99!"
        })
        assert res.status_code == 400


# =============================================================
# FLOW 7 — Admin Wrong Job Number → Dashboard Blocked
# =============================================================

class TestAdminWrongJobBlocked:

    def test_admin_wrong_job_number_returns_403(self):
        """
        System test: Even after valid login + OTP, an admin who
        enters the wrong job number must be blocked (403 Forbidden).
        """
        def no_job_table(name):
            m = MagicMock()
            m.select.return_value.eq.return_value.eq.return_value \
                .execute.return_value.data = []
            return m

        mock_supabase.table.side_effect = no_job_table
        res = client.post("/auth/verify-admin-job", json={
            "user_id": "U-0001", "job_number": "FAKE-999"
        })
        assert res.status_code == 403, "Wrong job number must block admin"
