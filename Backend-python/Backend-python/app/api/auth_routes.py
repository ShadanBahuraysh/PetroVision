from fastapi import APIRouter, HTTPException

from app.services.auth_service import AuthService
from app.patterns.proxy.gateway import AppAccessProxy
from app.patterns.proxy.real_gateway import RealApplicationGateway
from app.supabase_client import supabase
from app.schemas.user_schema import (
    UserLogin,
    UserCreate,
    VerifyOtpRequest,
    AdminJobRequest,
    ForgotPasswordRequest,
    ResetPasswordRequest
)


router = APIRouter(prefix="/auth", tags=["Auth"])

auth_service = AuthService()
real_gateway = RealApplicationGateway()
access_proxy = AppAccessProxy(real_gateway, auth_service)


@router.post("/login")
def login(data: UserLogin):
    try:
        result = access_proxy.login(data.email, data.password)

        if not result["allowed"]:
            raise HTTPException(status_code=401, detail=result["message"])

        auth_service.generate_otp(data.email)

        return {
            "message": "Login successful. OTP sent to email.",
            "requires_otp": True,
            "user": result["user"]
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/verify-otp")
def verify_otp(data: VerifyOtpRequest):
    try:
        is_valid = auth_service.verify_otp(data.email, data.code)

        if not is_valid:
            raise HTTPException(status_code=400, detail="Invalid or expired OTP")

        return {
            "message": "OTP verified successfully",
            "verified": True
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/verify-admin-job")
def verify_admin_job(data: AdminJobRequest):
    try:
        is_valid = auth_service.verify_admin_job(data.user_id, data.job_number)

        if not is_valid:
            raise HTTPException(status_code=403, detail="Invalid admin job number")

        return {
            "message": "Admin job number verified successfully",
            "verified": True
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/signup")
def signup(data: UserCreate):
    try:
        user = auth_service.signup(
            fname=data.fname,
            lname=data.lname,
            phone=data.phone,
            email=data.email,
            password=data.password,
            role=data.role,
            job_number=data.job_number,
            username=data.username
        )

        if not user:
            raise HTTPException(status_code=400, detail="Email already exists or signup failed")

        return {
            "message": "Signup successful",
            "user": user
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/forgot-password")
def forgot_password(data: ForgotPasswordRequest):
    try:
        result = auth_service.send_password_reset_otp(data.email)

        if not result:
            raise HTTPException(status_code=404, detail="Email not found")

        return {
            "message": "Password reset OTP sent to email",
            "requires_otp": True
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/reset-password")
def reset_password(data: ResetPasswordRequest):
    try:
        result = auth_service.reset_password(
            email=data.email,
            code=data.code,
            new_password=data.new_password
        )

        if not result:
            raise HTTPException(status_code=400, detail="Invalid OTP or email")

        return {
            "message": "Password reset successfully"
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))



@router.get("/users")
def get_all_users():
    try:
        # Get all customer user_ids from the customer table
        customer_result = supabase.table("customer").select("user_id").execute()
        customer_ids = {c["user_id"] for c in (customer_result.data or [])}

        if not customer_ids:
            return []

        # Get user details
        users_result = supabase.table("users").select("user_id,fname,lname,email").execute()
        users = [u for u in (users_result.data or []) if u["user_id"] in customer_ids]

        loyalty_result = supabase.table("loyalty_account").select("user_id,current_points").execute()
        loyalty_map = {la["user_id"]: la for la in (loyalty_result.data or [])}

        membership_result = supabase.table("membership").select("user_id,tier,status").execute()
        membership_map = {m["user_id"]: m for m in (membership_result.data or [])}

        members = []
        for u in users:
            uid = u["user_id"]
            la  = loyalty_map.get(uid, {})
            mem = membership_map.get(uid, {})
            members.append({
                "user_id": uid,
                "name":    f"{u.get('fname', '')} {u.get('lname', '')}".strip(),
                "email":   u.get("email", ""),
                "tier":    mem.get("tier", "Bronze"),
                "points":  la.get("current_points", 0) or 0,
                "status":  mem.get("status", "active"),
            })

        return members

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.delete("/users/{user_id}")
def delete_user(user_id: str):
    try:
        supabase.table("users").delete().eq("user_id", user_id).execute()
        return {"message": "User deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/dashboard/{user_id}")
def access_dashboard(user_id: str):
    try:
        user = auth_service.get_user(user_id)

        result = access_proxy.access_dashboard(user)

        if not result["allowed"]:
            raise HTTPException(status_code=403, detail=result["message"])

        return result

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))