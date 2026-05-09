# ========================================================================================================
# PetroVision User Schemas
# --------------------------------------------------------------------------------------------------------
# This file defines the Pydantic request and response
# schemas used for authentication and user-management
# operations within the PetroVision system.
#
# Features included:
# - Defining user registration and login schemas
# - Managing user response structures
# - Supporting OTP verification requests
# - Supporting password reset operations
# - Supporting admin job-number verification
# - Providing request and response validation
#
# It also ensures consistent user-data formatting
# and validation between backend authentication
# services and frontend applications.
# ========================================================================================================
from pydantic import BaseModel, EmailStr
from typing import Optional


class UserBase(BaseModel):
    email: EmailStr
    fname: str
    lname: str
    phone: Optional[str] = None


class UserCreate(UserBase):
    password: str
    role: str = "customer"
    job_number: Optional[str] = None
    username: Optional[str] = None


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserResponse(UserBase):
    user_id: str
    role: Optional[str] = None
    job_number: Optional[str] = None
    username: Optional[str] = None


class VerifyOtpRequest(BaseModel):
    email: EmailStr
    code: str


class AdminJobRequest(BaseModel):
    user_id: str
    job_number: str


class ForgotPasswordRequest(BaseModel):
    email: EmailStr


class ResetPasswordRequest(BaseModel):
    email: EmailStr
    code: str
    new_password: str


class ResendOtpRequest(BaseModel):
    email: str