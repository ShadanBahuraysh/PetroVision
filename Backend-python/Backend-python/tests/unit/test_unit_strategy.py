"""
Unit Tests – Strategy Pattern
===============================
Coverage:
  - BronzePoints.calculate_points
  - SilverPoints.calculate_points
  - GoldPoints.calculate_points
  - PointCalculation.set_strategy_by_tier
  - PointCalculation.calculate
"""

import sys
from unittest.mock import MagicMock

sys.modules["app.supabase_client"] = MagicMock()

from app.patterns.strategy.bronze_points import BronzePoints
from app.patterns.strategy.silver_points import SilverPoints
from app.patterns.strategy.gold_points import GoldPoints
from app.patterns.strategy.point_calculation import PointCalculation


# ══════════════════════════════════════════════════════════════════════════════
# BronzePoints
# ══════════════════════════════════════════════════════════════════════════════

class TestBronzePoints:

    def test_normal_amount(self):
        assert BronzePoints().calculate_points(100) == 100

    def test_decimal_amount_truncates(self):
        assert BronzePoints().calculate_points(99.9) == 99

    def test_zero_amount(self):
        assert BronzePoints().calculate_points(0) == 0

    def test_large_amount(self):
        assert BronzePoints().calculate_points(5000) == 5000


# ══════════════════════════════════════════════════════════════════════════════
# SilverPoints
# ══════════════════════════════════════════════════════════════════════════════

class TestSilverPoints:

    def test_normal_amount(self):
        assert SilverPoints().calculate_points(100) == 125

    def test_decimal_result_truncates(self):
        assert SilverPoints().calculate_points(10) == 12

    def test_zero_amount(self):
        assert SilverPoints().calculate_points(0) == 0

    def test_large_amount(self):
        assert SilverPoints().calculate_points(1000) == 1250


# ══════════════════════════════════════════════════════════════════════════════
# GoldPoints
# ══════════════════════════════════════════════════════════════════════════════

class TestGoldPoints:

    def test_normal_amount(self):
        assert GoldPoints().calculate_points(100) == 150

    def test_zero_amount(self):
        assert GoldPoints().calculate_points(0) == 0

    def test_large_amount(self):
        assert GoldPoints().calculate_points(200) == 300

    def test_decimal_input(self):
        assert GoldPoints().calculate_points(50.5) == 75


# ══════════════════════════════════════════════════════════════════════════════
# PointCalculation
# ══════════════════════════════════════════════════════════════════════════════

class TestPointCalculation:

    def test_default_strategy_is_bronze(self):
        pc = PointCalculation()
        assert pc.calculate(100) == 100

    def test_set_bronze_tier(self):
        pc = PointCalculation()
        pc.set_strategy_by_tier("bronze")
        assert pc.calculate(100) == 100

    def test_set_silver_tier(self):
        pc = PointCalculation()
        pc.set_strategy_by_tier("silver")
        assert pc.calculate(100) == 125

    def test_set_gold_tier(self):
        pc = PointCalculation()
        pc.set_strategy_by_tier("gold")
        assert pc.calculate(100) == 150

    def test_tier_case_insensitive_gold(self):
        pc = PointCalculation()
        pc.set_strategy_by_tier("GOLD")
        assert pc.calculate(100) == 150

    def test_tier_case_insensitive_silver(self):
        pc = PointCalculation()
        pc.set_strategy_by_tier("SILVER")
        assert pc.calculate(100) == 125

    def test_unknown_tier_defaults_to_bronze(self):
        pc = PointCalculation()
        pc.set_strategy_by_tier("platinum")
        assert pc.calculate(100) == 100

    def test_strategy_switch(self):
        pc = PointCalculation()
        pc.set_strategy_by_tier("gold")
        assert pc.calculate(100) == 150
        pc.set_strategy_by_tier("bronze")
        assert pc.calculate(100) == 100
