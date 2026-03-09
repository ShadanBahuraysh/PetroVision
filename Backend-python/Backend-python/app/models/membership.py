class Membership:
    def __init__(self, membership_id, tier, status, start_date, end_date):
        self.membership_id = membership_id
        self.tier = tier
        self.status = status
        self.start_date = start_date
        self.end_date = end_date

    def activate(self):
        self.status = "Active"

    def deactivate(self):
        self.status = "Inactive"

    def is_active(self):
        return self.status.lower() == "active"