# ========================================================================================================
# PetroVision Point Calculation Context
# --------------------------------------------------------------------------------------------------------
# This file defines the PointCalculation class used
# in the Strategy design pattern implementation
# within the PetroVision loyalty system.
#
# Features included:
# - Managing loyalty point calculation strategies
# - Dynamically selecting strategies based on membership tier
# - Supporting Bronze, Silver, and Gold reward systems
# - Delegating point calculations to strategy classes
# - Providing flexible loyalty reward calculations
#
# It also acts as the context class for the
# Strategy design pattern by controlling which
# point-calculation strategy is applied at runtime.
# ========================================================================================================

from app.patterns.strategy.bronze_points import BronzePoints
from app.patterns.strategy.silver_points import SilverPoints
from app.patterns.strategy.gold_points import GoldPoints


class PointCalculation:
    def __init__(self):
        self.strategy = BronzePoints()

    def set_strategy_by_tier(self, tier):
        tier = str(tier).lower()

        if tier == "gold":
            self.strategy = GoldPoints()
        elif tier == "silver":
            self.strategy = SilverPoints()
        else:
            self.strategy = BronzePoints()

    def calculate(self, amount):
        return self.strategy.calculate_points(amount)