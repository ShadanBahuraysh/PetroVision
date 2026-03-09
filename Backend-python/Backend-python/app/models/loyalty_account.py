class LoyaltyAccount:
    def __init__(self, account_id, current_points=0, savings=0.0):
        self.account_id = account_id
        self.current_points = current_points
        self.savings = savings

    def add_points(self, points):
        if points > 0:
            self.current_points += points

    def redeem_points(self, points):
        if points > 0 and self.current_points >= points:
            self.current_points -= points
            return True
        return False

    def add_savings(self, amount):
        if amount > 0:
            self.savings += amount