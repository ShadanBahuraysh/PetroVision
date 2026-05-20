"""
Unit Tests ??? Membership
=========================
Coverage:
  - Membership.is_eligible
"""

import sys
from unittest.mock import MagicMock

sys.modules["app.supabase_client"] = MagicMock()

from app.models.membership import Membership


class TestMembershipIsEligible:

    def test_eligible_exact_bronze_threshold(self):
        bronze = Membership("MEM-001", tier_name="Bronze", min_points=0)
        assert bronze.is_eligible(0) is True

    def test_eligible_above_silver_threshold(self):
        silver = Membership("MEM-002", tier_name="Silver", min_points=500)
        assert silver.is_eligible(600) is True

    def test_not_eligible_below_gold_threshold(self):
        gold = Membership("MEM-003", tier_name="Gold", min_points=1000)
        assert gold.is_eligible(999) is False

    def test_eligible_at_exact_gold_threshold(self):
        gold = Membership("MEM-004", tier_name="Gold", min_points=1000)
        assert gold.is_eligible(1000) is True

    def test_bronze_always_eligible_at_zero(self):
        bronze = Membership("MEM-005", tier_name="Bronze", min_points=0)
        assert bronze.is_eligible(0) is True

    def test_not_eligible_below_silver_threshold(self):
        silver = Membership("MEM-006", tier_name="Silver", min_points=500)
        assert silver.is_eligible(499) is False
