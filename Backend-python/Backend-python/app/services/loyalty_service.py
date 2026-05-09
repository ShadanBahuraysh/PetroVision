# ========================================================================================================
# PetroVision Loyalty Service
# --------------------------------------------------------------------------------------------------------
# This file defines the LoyaltyService class used
# for loyalty-point operations within the PetroVision system.
#
# Features included:
# - Earning loyalty points
# - Redeeming loyalty points
# - Integrating membership-tier reward strategies
# - Dynamically calculating earned points
# - Validating point redemption requests
# - Managing loyalty account point balances
#
# It also integrates the Strategy design pattern
# to apply different point-calculation methods
# based on customer membership tiers.
# ========================================================================================================
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