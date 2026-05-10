"""
Unit Tests – User Model
========================
Coverage:
  - User.is_admin()
  - User.is_customer()
  - User.to_dict()
"""

import sys
import os

# ── Path setup ────────────────────────────────────────────
sys.path.insert(0, os.path.join(os.path.dirname(__file__),
                                "../Backend-python/Backend-python"))

from app.models.user import User


# ══════════════════════════════════════════════════════════════════════════════
# User
# ══════════════════════════════════════════════════════════════════════════════

class TestUserModel:

    def test_is_admin_returns_true_for_admin_role(self):
        """User with role='admin' should be identified as admin."""
        user = User("U-0001", "Ali Admin", "ali@petro.com", role="admin")
        assert user.is_admin() is True

    def test_is_admin_returns_false_for_customer_role(self):
        """Customer user must NOT be identified as admin."""
        user = User("U-0002", "Sara Customer", "sara@petro.com", role="customer")
        assert user.is_admin() is False

    def test_is_customer_returns_true_for_customer_role(self):
        """User with role='customer' should be identified as customer."""
        user = User("U-0003", "Noor User", "noor@petro.com", role="customer")
        assert user.is_customer() is True

    def test_is_customer_returns_false_for_admin_role(self):
        """Admin user must NOT be identified as customer."""
        user = User("U-0004", "Admin User", "admin@petro.com", role="admin")
        assert user.is_customer() is False

    def test_role_check_is_case_insensitive(self):
        """Role comparisons must handle mixed-case strings (e.g. 'Admin')."""
        user = User("U-0005", "Test", "t@petro.com", role="Admin")
        assert user.is_admin() is True

    def test_unknown_role_is_neither_admin_nor_customer(self):
        """A user with an unrecognised role should fail both checks."""
        user = User("U-0006", "Ghost", "g@petro.com", role="unknown")
        assert user.is_admin() is False
        assert user.is_customer() is False

    def test_to_dict_does_not_expose_password(self):
        """to_dict() must never include the password field."""
        user = User("U-0007", "Safe User", "safe@petro.com",
                    password="secret123", role="customer")
        d = user.to_dict()
        assert "password" not in d

    def test_to_dict_contains_expected_keys(self):
        """to_dict() should return user_id, name, email, and role."""
        user = User("U-0008", "Dict User", "dict@petro.com", role="customer")
        d = user.to_dict()
        assert set(d.keys()) == {"user_id", "name", "email", "role"}
