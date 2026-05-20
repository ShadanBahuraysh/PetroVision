"""
Unit Tests >>> Offer
====================
Coverage:
  - Offer.is_active
  - Offer.activate
  - Offer.deactivate
"""

import sys
from unittest.mock import MagicMock

sys.modules["app.supabase_client"] = MagicMock()

from app.models.offer import Offer


class TestOfferIsActive:

    def test_active_offer(self):
        offer = Offer("OFF-001", "Fuel Discount", status="active")
        assert offer.is_active() is True

    def test_inactive_offer(self):
        offer = Offer("OFF-002", "Old Deal", status="inactive")
        assert offer.is_active() is False

    def test_status_case_insensitive(self):
        offer = Offer("OFF-003", "Deal", status="ACTIVE")
        assert offer.is_active() is True

    def test_activate_changes_status(self):
        offer = Offer("OFF-005", "Deal", status="inactive")
        offer.activate()
        assert offer.is_active() is True

    def test_deactivate_changes_status(self):
        offer = Offer("OFF-006", "Deal", status="active")
        offer.deactivate()
        assert offer.is_active() is False
