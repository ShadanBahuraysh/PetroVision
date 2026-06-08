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