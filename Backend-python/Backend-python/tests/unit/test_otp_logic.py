"""
Unit Tests ??? OTP Logic
=======================
Coverage:
  - AuthService.generate_otp
  - AuthService.verify_otp
"""

import time
import sys
import os
from unittest.mock import patch
from conftest import shared_mock_supabase

# ================== Path setup ================
sys.path.insert(0, os.path.join(os.path.dirname(__file__),
                                "../Backend-python/Backend-python"))

from app.services.auth_service import AuthService


def make_auth_service():
    return AuthService()


# ==================================================
# AuthService ----- OTP
# ==================================================

class TestOtpLogic:

    def setup_method(self):
        self.service = make_auth_service()

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

    def test_verify_otp_returns_false_for_expired_code(self):
        """
        Exception handling: expired OTP (past expiry time) must return False
        and the record must be cleaned up from otp_store.
        """
        with patch.object(self.service, "send_otp_email"):
            self.service.generate_otp("expired@petro.com")
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
