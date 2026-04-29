import os
import random
import time
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from dotenv import load_dotenv

from app.supabase_client import supabase

load_dotenv()


class AuthService:
    def __init__(self):
        self.otp_store = {}

    def authenticate(self, email, password):
        result = (
            supabase.table("users")
            .select("*")
            .eq("email", email.strip().lower())
            .eq("password", password.strip())
            .execute()
        )

        if not result.data:
            return None

        user = result.data[0]
        user.pop("password", None)

        return self._attach_user_role_data(user)

    def send_otp_email(self, email, code):
        sender_email = os.getenv("EMAIL_ADDRESS")
        sender_password = os.getenv("EMAIL_PASSWORD")

        if not sender_email or not sender_password:
            raise Exception("Email settings are missing in .env")

        message = MIMEMultipart()
        message["From"] = sender_email
        message["To"] = email
        message["Subject"] = "PetroVision Verification Code"

        body = f"""
Hello,

Your PetroVision verification code is:

{code}

This code will expire in 5 minutes.

PetroVision Team
"""
        message.attach(MIMEText(body, "plain"))

        server = smtplib.SMTP("smtp.gmail.com", 587)
        server.starttls()
        server.login(sender_email, sender_password)
        server.send_message(message)
        server.quit()

    def generate_otp(self, email):
        code = str(random.randint(100000, 999999))
        expiry = time.time() + 300

        self.otp_store[email] = {
            "code": code,
            "expiry": expiry
        }

        try:
            self.send_otp_email(email, code)
            print("OTP email sent successfully")
        except Exception as e:
            print("Email sending failed:", e)
            print(f"OTP for {email}: {code}")

        return {
            "message": "OTP generated successfully",
            "email": email
        }

    def verify_otp(self, email, code):
        record = self.otp_store.get(email)

        if not record:
            return False

        if time.time() > record["expiry"]:
            self.otp_store.pop(email, None)
            return False

        if record["code"] != code:
            return False

        self.otp_store.pop(email, None)
        return True

    def verify_admin_job(self, user_id, job_number):
        result = (
            supabase.table("admin")
            .select("*")
            .eq("user_id", user_id)
            .eq("job_number", job_number)
            .execute()
        )

        return bool(result.data)
    
    def send_password_reset_otp(self, email):
        email = email.strip().lower()

        result = (
            supabase.table("users")
            .select("*")
            .eq("email", email)
            .execute()
        )

        if not result.data:
            return False

        code = str(random.randint(100000, 999999))
        expiry = time.time() + 300

        self.otp_store[email] = {
            "code": code,
            "expiry": expiry,
            "purpose": "reset_password"
        }

        try:
            self.send_otp_email(email, code)
            print("Password reset OTP sent successfully")
        except Exception as e:
            print("Email sending failed:", e)
            print(f"Reset OTP for {email}: {code}")

        return True

    def reset_password(self, email, code, new_password):
        email = email.strip().lower()

        record = self.otp_store.get(email)

        if not record:
            return False

        if record.get("purpose") != "reset_password":
            return False

        if time.time() > record["expiry"]:
            self.otp_store.pop(email, None)
            return False

        if record["code"] != code:
            return False

        result = (
            supabase.table("users")
            .update({"password": new_password})
            .eq("email", email)
            .execute()
        )

        self.otp_store.pop(email, None)

        return bool(result.data)


    def signup(
        self,
        fname,
        lname,
        phone,
        email,
        password,
        role="customer",
        job_number=None,
        username=None
    ):
        role = role.strip().lower()
        email = email.strip().lower()

        existing = (
            supabase.table("users")
            .select("*")
            .eq("email", email)
            .execute()
        )

        if existing.data:
            return None

        new_user_id = self._generate_user_id()

        user_result = (
            supabase.table("users")
            .insert({
                "user_id": new_user_id,
                "fname": fname,
                "lname": lname,
                "phone": phone,
                "email": email,
                "password": password
            })
            .execute()
        )

        if not user_result.data:
            return None

        user = user_result.data[0]

        if role == "admin":
            admin_result = (
                supabase.table("admin")
                .insert({
                    "user_id": user["user_id"],
                    "job_number": job_number
                })
                .execute()
            )

            user["role"] = "admin"
            user["admin"] = admin_result.data[0] if admin_result.data else None

        else:
            default_username = username or f"{fname}_{lname}".lower().replace(" ", "_")

            customer_result = (
                supabase.table("customer")
                .insert({
                    "user_id": user["user_id"],
                    "username": default_username
                })
                .execute()
            )

            user["role"] = "customer"
            user["customer"] = customer_result.data[0] if customer_result.data else None

        user.pop("password", None)
        return user

    def get_user(self, user_id):
        result = (
            supabase.table("users")
            .select("*")
            .eq("user_id", user_id)
            .execute()
        )

        if not result.data:
            return None

        user = result.data[0]
        user.pop("password", None)

        return self._attach_user_role_data(user)

    def _attach_user_role_data(self, user):
        admin_result = (
            supabase.table("admin")
            .select("*")
            .eq("user_id", user["user_id"])
            .execute()
        )

        customer_result = (
            supabase.table("customer")
            .select("*")
            .eq("user_id", user["user_id"])
            .execute()
        )

        if admin_result.data:
            user["role"] = "admin"
            user["admin"] = admin_result.data[0]
        elif customer_result.data:
            user["role"] = "customer"
            user["customer"] = customer_result.data[0]
        else:
            user["role"] = "unknown"

        return user

    def _generate_user_id(self):
        result = supabase.table("users").select("user_id").execute()
        existing_ids = result.data or []

        max_number = 0
        for row in existing_ids:
            user_id = str(row.get("user_id", ""))
            if user_id.startswith("U-"):
                try:
                    number = int(user_id.split("-")[1])
                    max_number = max(max_number, number)
                except Exception:
                    continue

        return f"U-{max_number + 1:04d}"