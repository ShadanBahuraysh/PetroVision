import sys
from unittest.mock import MagicMock

mock_supabase = MagicMock()
sys.modules.setdefault("supabase", MagicMock())
sys.modules["app.supabase_client"] = MagicMock(supabase=mock_supabase)

"""
Integration tests for Auth API routes.
These tests validate the FastAPI route layer, request/response handling,
and the integration points with AuthService/AppAccessProxy using monkeypatching.
"""

from fastapi import FastAPI
from fastapi.testclient import TestClient
from app.api import auth_routes

app = FastAPI()
app.include_router(auth_routes.router)
client = TestClient(app)
ERROR_DETAIL = "Internal server error"


def test_login_success_returns_200(monkeypatch):
    def fake_login(email, password):
        return {
            "allowed": True,
            "message": "Login successful",
            "user": {"user_id": "U-0001", "email": email, "role": "customer"},
        }

    def fake_generate_otp(email):
        return {"message": "OTP generated successfully", "email": email}

    monkeypatch.setattr(auth_routes.access_proxy, "login", fake_login)
    monkeypatch.setattr(auth_routes.auth_service, "generate_otp", fake_generate_otp)

    response = client.post("/auth/login", json={"email": "test@petro.com", "password": "ValidPass1!"})

    assert response.status_code == 200
    data = response.json()
    assert data["requires_otp"] is True
    assert data["user"]["email"] == "test@petro.com"


def test_login_wrong_password_returns_401(monkeypatch):
    def fake_login(email, password):
        return {"allowed": False, "message": "Invalid email or password"}

    monkeypatch.setattr(auth_routes.access_proxy, "login", fake_login)

    response = client.post("/auth/login", json={"email": "test@petro.com", "password": "WrongPass999!"})

    assert response.status_code == 401
    assert response.json()["detail"] == "Invalid email or password"


def test_login_missing_email_field_returns_422():
    response = client.post("/auth/login", json={"password": "SomePass1!"})
    assert response.status_code == 422


def test_login_missing_password_field_returns_422():
    response = client.post("/auth/login", json={"email": "test@petro.com"})
    assert response.status_code == 422


def test_login_empty_body_returns_422():
    response = client.post("/auth/login", json={})
    assert response.status_code == 422


def test_verify_otp_correct_code_returns_200(monkeypatch):
    monkeypatch.setattr(auth_routes.auth_service, "verify_otp", lambda email, code: True)

    response = client.post("/auth/verify-otp", json={"email": "otp@petro.com", "code": "123456"})

    assert response.status_code == 200
    assert response.json()["verified"] is True


def test_verify_otp_wrong_code_returns_400(monkeypatch):
    monkeypatch.setattr(auth_routes.auth_service, "verify_otp", lambda email, code: False)

    response = client.post("/auth/verify-otp", json={"email": "wrong@petro.com", "code": "999999"})

    assert response.status_code == 400
    assert response.json()["detail"] == "Invalid or expired OTP"


def test_verify_otp_missing_fields_returns_422():
    response = client.post("/auth/verify-otp", json={"email": "otp@petro.com"})
    assert response.status_code == 422


def test_signup_new_user_returns_200(monkeypatch):
    new_user = {"user_id": "U-0099", "fname": "New", "lname": "User", "email": "new@petro.com", "role": "customer"}

    def fake_signup(**kwargs):
        return new_user

    monkeypatch.setattr(auth_routes.auth_service, "signup", fake_signup)

    response = client.post(
        "/auth/signup",
        json={
            "fname": "New",
            "lname": "User",
            "email": "new@petro.com",
            "phone": "0512345678",
            "password": "NewPass1!",
            "role": "customer",
        },
    )

    assert response.status_code == 200
    assert response.json()["user"]["user_id"] == "U-0099"


def test_signup_duplicate_email_returns_400(monkeypatch):
    def fake_signup(**kwargs):
        return None

    monkeypatch.setattr(auth_routes.auth_service, "signup", fake_signup)

    response = client.post(
        "/auth/signup",
        json={
            "fname": "Dup",
            "lname": "User",
            "email": "test@petro.com",
            "phone": "0512345678",
            "password": "DupPass1!",
            "role": "customer",
        },
    )

    assert response.status_code == 400
    assert response.json()["detail"] == "Email already exists or signup failed"


def test_signup_missing_required_field_returns_422():
    response = client.post("/auth/signup", json={"fname": "OnlyName"})
    assert response.status_code == 422


def test_forgot_password_existing_email_returns_200(monkeypatch):
    monkeypatch.setattr(auth_routes.auth_service, "send_password_reset_otp", lambda email: True)

    response = client.post("/auth/forgot-password", json={"email": "reset@petro.com"})

    assert response.status_code == 200
    assert response.json()["requires_otp"] is True


def test_forgot_password_nonexistent_email_returns_404(monkeypatch):
    monkeypatch.setattr(auth_routes.auth_service, "send_password_reset_otp", lambda email: False)

    response = client.post("/auth/forgot-password", json={"email": "missing@petro.com"})

    assert response.status_code == 404
    assert response.json()["detail"] == "Email not found"


def test_forgot_password_missing_email_returns_422():
    response = client.post("/auth/forgot-password", json={})
    assert response.status_code == 422


def test_reset_password_valid_otp_returns_200(monkeypatch):
    monkeypatch.setattr(auth_routes.auth_service, "reset_password", lambda email, code, new_password: True)

    response = client.post(
        "/auth/reset-password",
        json={"email": "reset@petro.com", "code": "888888", "new_password": "NewSecure1!"},
    )

    assert response.status_code == 200
    assert response.json()["message"] == "Password reset successfully"


def test_reset_password_wrong_otp_returns_400(monkeypatch):
    monkeypatch.setattr(auth_routes.auth_service, "reset_password", lambda email, code, new_password: False)

    response = client.post(
        "/auth/reset-password",
        json={"email": "reset@petro.com", "code": "000000", "new_password": "NewSecure1!"},
    )

    assert response.status_code == 400
    assert response.json()["detail"] == "Invalid OTP or email"


def test_reset_password_missing_fields_returns_422():
    response = client.post("/auth/reset-password", json={"email": "reset@petro.com"})
    assert response.status_code == 422


def test_valid_job_number_returns_200(monkeypatch):
    monkeypatch.setattr(auth_routes.auth_service, "verify_admin_job", lambda user_id, job_number: True)

    response = client.post("/auth/verify-admin-job", json={"user_id": "U-0001", "job_number": "JOB-001"})

    assert response.status_code == 200
    assert response.json()["verified"] is True


def test_invalid_job_number_returns_403(monkeypatch):
    monkeypatch.setattr(auth_routes.auth_service, "verify_admin_job", lambda user_id, job_number: False)

    response = client.post("/auth/verify-admin-job", json={"user_id": "U-0001", "job_number": "BAD-JOB"})

    assert response.status_code == 403
    assert response.json()["detail"] == "Invalid admin job number"


def test_missing_user_id_returns_422():
    response = client.post("/auth/verify-admin-job", json={"job_number": "JOB-001"})
    assert response.status_code == 422


def test_missing_job_number_returns_422():
    response = client.post("/auth/verify-admin-job", json={"user_id": "U-0001"})
    assert response.status_code == 422
