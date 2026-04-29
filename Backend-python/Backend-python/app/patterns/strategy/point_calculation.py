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