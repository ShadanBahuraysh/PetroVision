"""
Unit Tests ??? LoyaltyAccount
=============================
Coverage:
  - LoyaltyAccount.add_points
  - LoyaltyAccount.redeem_points
"""

import sys
from unittest.mock import MagicMock

sys.modules["app.supabase_client"] = MagicMock()

from app.models.loyalty_account import LoyaltyAccount


# ══════════════════════════════════════════════════════════════════════════════
# add_points
# ══════════════════════════════════════════════════════════════════════════════

class TestAddPoints:

    def test_add_points_increases_balance(self):
        acc = LoyaltyAccount("ACC-001", "USR-001", current_points=100)
        acc.add_points(50)
        assert acc.current_points == 150

    def test_add_zero_points_no_change(self):
        acc = LoyaltyAccount("ACC-002", "USR-002", current_points=100)
        acc.add_points(0)
        assert acc.current_points == 100

    def test_add_negative_points_no_change(self):
        acc = LoyaltyAccount("ACC-003", "USR-003", current_points=100)
        acc.add_points(-10)
        assert acc.current_points == 100


# ══════════════════════════════════════════════════════════════════════════════
# redeem_points
# ══════════════════════════════════════════════════════════════════════════════

class TestRedeemPoints:

    def test_successful_redeem(self):
        acc = LoyaltyAccount("ACC-004", "USR-004", current_points=500)
        result = acc.redeem_points(200)
        assert result is True
        assert acc.current_points == 300

    def test_redeem_insufficient_points(self):
        acc = LoyaltyAccount("ACC-006", "USR-006", current_points=50)
        result = acc.redeem_points(100)
        assert result is False
        assert acc.current_points == 50

    def test_redeem_negative_points_fails(self):
        acc = LoyaltyAccount("ACC-008", "USR-008", current_points=200)
        result = acc.redeem_points(-50)
        assert result is False

    def test_redeem_from_zero_balance(self):
        acc = LoyaltyAccount("ACC-009", "USR-009", current_points=0)
        result = acc.redeem_points(10)
        assert result is False
