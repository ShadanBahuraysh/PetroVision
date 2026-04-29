class Membership:
    def __init__(
        self,
        membership_id,
        user_id=None,
        tier_name="Bronze",
        min_points=0,
        benefits=None
    ):
        self.membership_id = membership_id
        self.user_id = user_id
        self.tier_name = tier_name
        self.min_points = min_points
        self.benefits = benefits or []

    def is_eligible(self, points):
        return points >= self.min_points

    def to_dict(self):
        return {
            "membership_id": self.membership_id,
            "user_id": self.user_id,
            "tier_name": self.tier_name,
            "min_points": self.min_points,
            "benefits": self.benefits
        }