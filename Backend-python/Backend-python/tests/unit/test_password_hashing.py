"""
Unit Tests ??? Password Hashing
===============================
Coverage:
  - AuthService._hash_password
  - AuthService._check_password
"""

import sys
import os
from unittest.mock import patch
from conftest import shared_mock_supabase

# ======== Path setup ========
sys.path.insert(0, os.path.join(os.path.dirname(__file__),
                                "../Backend-python/Backend-python"))

from app.services.auth_service import AuthService


def make_auth_service():
    return AuthService()


# =================================
# AuthService >>> Password Hashing
# =================================

class TestPasswordHashing:

    def setup_method(self):
        self.service = make_auth_service()

    def test_hash_is_different_from_plain_password(self):
        """Hashed value must not equal the original plain text."""
        plain = "MyPassword1!"
        hashed = self.service._hash_password(plain)
        assert hashed != plain

    def test_same_password_produces_different_hashes(self):
        """bcrypt uses random salts ??? two hashes of the same password differ."""
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

    