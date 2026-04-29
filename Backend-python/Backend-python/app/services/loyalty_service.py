from app.patterns.strategy.point_calculation import PointCalculation


class LoyaltyService:
    def earn_points(self, account, membership, amount):
        tier = getattr(membership, "tier", "Bronze")

        calculator = PointCalculation()
        calculator.set_strategy_by_tier(tier)

        points = calculator.calculate(amount)
        account.add_points(points)

        return points

    def redeem_points(self, account, points):
        if points <= 0:
            return False

        if account.current_points >= points:
            return account.redeem_points(points)

        return False