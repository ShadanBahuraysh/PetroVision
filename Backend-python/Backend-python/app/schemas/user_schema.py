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