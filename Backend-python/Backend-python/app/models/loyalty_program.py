# ========================================================================================================
# PetroVision Loyalty Program Model
# --------------------------------------------------------------------------------------------------------
# This file defines the LoyaltyProgram class used
# within the PetroVision loyalty system.
#
# Features included:
# - Managing loyalty program information
# - Storing loyalty program details and status
# - Checking whether a loyalty program is active
# - Defining points earned per visit
# - Converting loyalty program objects into dictionaries
#
# It also provides the core structure for handling
# customer reward programs and loyalty configurations
# within the PetroVision platform.
# ========================================================================================================
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