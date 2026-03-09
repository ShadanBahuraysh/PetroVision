from bronze_points import BronzePoints
from silver_points import SilverPoints
from gold_points import GoldPoints

class PointCalculation:
    def __init__(self, strategy=None):
        self.strategy = strategy

    def set_strategy(self, strategy):
        self.strategy = strategy

    def select_tier(self, tier):
        if tier is None:
            return BronzePoints()

        tier = tier.lower()

        if tier == "silver":
            return SilverPoints()
        elif tier == "gold":
            return GoldPoints()
        else:
            return BronzePoints()

    def calculate(self, amount):
        if self.strategy is None:
            return 0
        return self.strategy.calculate_points(amount)