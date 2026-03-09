from point_calculation import PointCalculation

class LoyaltyService:
    def earn_points(self, account, membership, amount):
        if account is None or membership is None or amount <= 0:
            return 0

        point_calculation = PointCalculation()
        strategy = point_calculation.select_tier(membership.tier)
        point_calculation.set_strategy(strategy)

        earned_points = point_calculation.calculate(amount)
        account.add_points(earned_points)

        return earned_points

    def redeem_points(self, account, points_to_redeem):
        if account is None or points_to_redeem <= 0:
            return False
        return account.redeem_points(points_to_redeem)

    def get_current_tier(self, membership):
        if membership is None:
            return "No Membership"
        return membership.tier

    def get_current_points(self, account):
        if account is None:
            return 0
        return account.current_points

    def update_tier(self, membership, new_tier):
        if membership is not None and new_tier:
            membership.tier = new_tier

    def activate_membership(self, membership):
        if membership is not None:
            membership.activate()

    def deactivate_membership(self, membership):
        if membership is not None:
            membership.deactivate()