from patterns.strategy.gold_points import GoldPoints
from patterns.strategy.silver_points import SilverPoints
from patterns.strategy.bronze_points import BronzePoints

class PointCalculation:
    def __init__(self):
        self.strategy = None

    def set_strategy_by_tier(self, tier):
        if tier == "Gold":
            self.strategy = GoldPoints()
        elif tier == "Silver":
            self.strategy = SilverPoints()
        else:
            self.strategy = BronzePoints()

    def calculate(self, amount):
        return self.strategy.calculate_points(amount)