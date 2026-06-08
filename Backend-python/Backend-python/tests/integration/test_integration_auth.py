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
 
 
def test_verify_otp_correct_code_returns_200(monkeypatch): 
    monkeypatch.setattr(auth_routes.auth_service, "verify_otp", lambda email, code: True) 
 
    response = client.post("/auth/verify-otp", json={"email": "otp@petro.com", "code": "123456"}) 
 
    assert response.status_code == 200 
    assert response.json()["verified"] is True 
 
 
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
 
 
 
 
def test_reset_password_valid_otp_returns_200(monkeypatch): 
    monkeypatch.setattr(auth_routes.auth_service, "reset_password", lambda email, code, new_password: True) 
 
    response = client.post( 
        "/auth/reset-password", 
        json={"email": "reset@petro.com", "code": "888888", "new_password": "NewSecure1!"}, 
    ) 
 
    assert response.status_code == 200 
    assert response.json()["message"] == "Password reset successfully"