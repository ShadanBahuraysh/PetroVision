# ========================================================================================================
# PetroVision Loyalty Account Model
# --------------------------------------------------------------------------------------------------------
# This file defines the LoyaltyAccount class used
# within the PetroVision loyalty system.
#
# Features included:
# - Managing customer loyalty accounts
# - Storing loyalty account information
# - Adding loyalty points
# - Redeeming loyalty points
# - Validating point redemption operations
# - Converting loyalty account objects into dictionaries
#
# It also provides the core business logic for
# handling customer loyalty balances and
# membership-linked loyalty operations.
# ========================================================================================================
class LoyaltyAccount:
    def __init__(self, account_id, user_id, current_points=0, membership_id=None):
        self.account_id = account_id
        self.user_id = user_id
        self.current_points = current_points
        self.membership_id = membership_id

    def add_points(self, points):
        if points > 0:
            self.current_points += points

    def redeem_points(self, points):
        if points <= 0:
            return False

        if self.current_points < points:
            return False

        self.current_points -= points
        return True

    def to_dict(self):
        return {
            "account_id": self.account_id,
            "user_id": self.user_id,
            "current_points": self.current_points,
            "membership_id": self.membership_id
        }