# ========================================================================================================
# PetroVision Authentication Routes
# --------------------------------------------------------------------------------------------------------
# This file contains all authentication and user-management
# API endpoints for the PetroVision system, including:
# - User login and signup
# - OTP generation and verification
# - Password reset and recovery
# - Admin job number verification
# - Dashboard access control
# - Customer and admin management
# - User retrieval, update, and deletion
#
# It also integrates the Proxy design pattern
# to control secure access to application features
# and dashboards based on user permissions.
# ========================================================================================================
from fastapi import APIRouter, HTTPException

from app.services.auth_service import AuthService
from app.patterns.proxy.gateway import AppAccessProxy
from app.patterns.proxy.real_gateway import RealApplicationGateway
from app.supabase_client import supabase
from app.schemas.user_schema import (
    UserLogin,
    UserCreate,
    VerifyOtpRequest,
    ResendOtpRequest,
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

    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid authentication input: {str(e)}"
        )

    except KeyError as e:
        raise HTTPException(
            status_code=500,
            detail=f"Missing required authentication field: {str(e)}"
        )

    except TypeError:
        raise HTTPException(
            status_code=500,
            detail="Invalid authentication data format"
        )

    except Exception:
        raise HTTPException(
            status_code=500,
            detail="Unexpected authentication service error"
        )


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


    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid authentication input: {str(e)}"
        )

    except KeyError as e:
        raise HTTPException(
            status_code=500,
            detail=f"Missing required authentication field: {str(e)}"
        )

    except TypeError:
        raise HTTPException(
            status_code=500,
            detail="Invalid authentication data format"
        )

    except Exception:
        raise HTTPException(
            status_code=500,
            detail="Unexpected authentication service error"
        )
    

@router.post("/resend-otp")
def resend_otp(data: ResendOtpRequest):
    try:
        auth_service.generate_otp(data.email)

        return {
            "message": "OTP resent successfully",
            "requires_otp": True
        }
    
    except HTTPException:
        raise


    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid authentication input: {str(e)}"
        )

    except KeyError as e:
        raise HTTPException(
            status_code=500,
            detail=f"Missing required authentication field: {str(e)}"
        )

    except TypeError:
        raise HTTPException(
            status_code=500,
            detail="Invalid authentication data format"
        )

    except Exception:
        raise HTTPException(
            status_code=500,
            detail="Unexpected authentication service error"
        )


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

    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid authentication input: {str(e)}"
        )

    except KeyError as e:
        raise HTTPException(
            status_code=500,
            detail=f"Missing required authentication field: {str(e)}"
        )

    except TypeError:
        raise HTTPException(
            status_code=500,
            detail="Invalid authentication data format"
        )

    except Exception:
        raise HTTPException(
            status_code=500,
            detail="Unexpected authentication service error"
        )


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

    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid authentication input: {str(e)}"
        )

    except KeyError as e:
        raise HTTPException(
            status_code=500,
            detail=f"Missing required authentication field: {str(e)}"
        )

    except TypeError:
        raise HTTPException(
            status_code=500,
            detail="Invalid authentication data format"
        )

    except Exception:
        raise HTTPException(
            status_code=500,
            detail="Unexpected authentication service error"
        )


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

    except ValueError as e:
        raise HTTPException(status_code=400, detail=f"Invalid authentication input: {str(e)}")

    except KeyError as e:
        raise HTTPException(status_code=500, detail=f"Missing required authentication field: {str(e)}")

    except TypeError:
        raise HTTPException(status_code=500, detail="Invalid authentication request format")

    except Exception:
        raise HTTPException(status_code=500, detail="Unexpected authentication service error")


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

    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid authentication input: {str(e)}"
        )

    except KeyError as e:
        raise HTTPException(
            status_code=500,
            detail=f"Missing required authentication field: {str(e)}"
        )

    except TypeError:
        raise HTTPException(
            status_code=500,
            detail="Invalid authentication data format"
        )

    except Exception:
        raise HTTPException(
            status_code=500,
            detail="Unexpected authentication service error"
        )



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


    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid authentication input: {str(e)}"
        )

    except KeyError as e:
        raise HTTPException(
            status_code=500,
            detail=f"Missing required authentication field: {str(e)}"
        )

    except TypeError:
        raise HTTPException(
            status_code=500,
            detail="Invalid authentication data format"
        )

    except Exception:
        raise HTTPException(
            status_code=500,
            detail="Unexpected authentication service error"
        )


@router.delete("/users/{user_id}")
def delete_user(user_id: str):
    try:
        supabase.table("users").delete().eq("user_id", user_id).execute()
        return {"message": "User deleted successfully"}
    
    except HTTPException:
        raise


    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid authentication input: {str(e)}"
        )

    except KeyError as e:
        raise HTTPException(
            status_code=500,
            detail=f"Missing required authentication field: {str(e)}"
        )

    except TypeError:
        raise HTTPException(
            status_code=500,
            detail="Invalid authentication data format"
        )

    except Exception:
        raise HTTPException(
            status_code=500,
            detail="Unexpected authentication service error"
        )


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

    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid authentication input: {str(e)}"
        )

    except KeyError as e:
        raise HTTPException(
            status_code=500,
            detail=f"Missing required authentication field: {str(e)}"
        )

    except TypeError:
        raise HTTPException(
            status_code=500,
            detail="Invalid authentication data format"
        )

    except Exception:
        raise HTTPException(
            status_code=500,
            detail="Unexpected authentication service error"
        )
    

@router.get("/admins")
def get_all_admins():
    try:
        admin_result = supabase.table("admin").select("*").execute()
        admins = admin_result.data or []

        users_result = (
            supabase.table("users")
            .select("user_id,fname,lname,email,phone")
            .execute()
        )

        users_map = {
            u["user_id"]: u for u in (users_result.data or [])
        }

        result = []

        for admin in admins:
            user = users_map.get(admin["user_id"], {})

            result.append({
                "user_id": admin["user_id"],
                "job_number": admin.get("job_number", ""),
                "name": f"{user.get('fname', '')} {user.get('lname', '')}".strip(),
                "email": user.get("email", ""),
                "phone": user.get("phone", ""),
            })

        return result
    
    except HTTPException:
        raise


    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid authentication input: {str(e)}"
        )

    except KeyError as e:
        raise HTTPException(
            status_code=500,
            detail=f"Missing required authentication field: {str(e)}"
        )

    except TypeError:
        raise HTTPException(
            status_code=500,
            detail="Invalid authentication data format"
        )

    except Exception:
        raise HTTPException(
            status_code=500,
            detail="Unexpected authentication service error"
        )
    



@router.post("/admins")
def add_admin(data: UserCreate):
    try:
        user = auth_service.signup(
            fname=data.fname,
            lname=data.lname,
            phone=data.phone,
            email=data.email,
            password=data.password,
            role="admin",
            job_number=data.job_number,
            username=None
        )

        if not user:
            raise HTTPException(status_code=400, detail="Failed to create admin")

        return {
            "message": "Admin created successfully",
            "admin": user
        }

    except HTTPException:
        raise


    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid authentication input: {str(e)}"
        )

    except KeyError as e:
        raise HTTPException(
            status_code=500,
            detail=f"Missing required authentication field: {str(e)}"
        )

    except TypeError:
        raise HTTPException(
            status_code=500,
            detail="Invalid authentication data format"
        )

    except Exception:
        raise HTTPException(
            status_code=500,
            detail="Unexpected authentication service error"
        )
    


@router.put("/admins/{user_id}")
def update_admin(user_id: str, data: dict):
    try:
        update_data = {
            "fname": data.get("fname"),
            "lname": data.get("lname"),
            "email": data.get("email"),
            "phone": data.get("phone"),
        }

        user_result = (
            supabase.table("users")
            .update(update_data)
            .eq("user_id", user_id)
            .execute()
        )

        admin_result = (
            supabase.table("admin")
            .update({"job_number": data.get("job_number")})
            .eq("user_id", user_id)
            .execute()
        )

        return {
            "message": "Admin updated successfully",
            "user": user_result.data,
            "admin": admin_result.data
        }
    except HTTPException:
        raise

    except ValueError as e:
        raise HTTPException(status_code=400, detail=f"Invalid authentication input: {str(e)}")

    except KeyError as e:
        raise HTTPException(status_code=500, detail=f"Missing required authentication field: {str(e)}")

    except TypeError:
        raise HTTPException(status_code=500, detail="Invalid authentication request format")

    except Exception:
        raise HTTPException(status_code=500, detail="Unexpected authentication service error")
