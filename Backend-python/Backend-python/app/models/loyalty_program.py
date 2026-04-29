class LoyaltyProgram:
    def __init__(
        self,
        program_id,
        program_name,
        description=None,
        points_per_visit=0,
        status="active"
    ):
        self.program_id = program_id
        self.program_name = program_name
        self.description = description
        self.points_per_visit = points_per_visit
        self.status = status

    def is_active(self):
        return str(self.status).lower() == "active"

    def to_dict(self):
        return {
            "program_id": self.program_id,
            "program_name": self.program_name,
            "description": self.description,
            "points_per_visit": self.points_per_visit,
            "status": self.status
        }