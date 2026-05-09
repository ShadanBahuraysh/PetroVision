# ========================================================================================================
# PetroVision Offer Model
# --------------------------------------------------------------------------------------------------------
# This file defines the Offer class used
# within the PetroVision loyalty system.
#
# Features included:
# - Managing loyalty and promotional offers
# - Storing offer details and discount information
# - Managing offer activation status
# - Activating and deactivating offers
# - Linking offers to stations and users
# - Converting offer objects into dictionaries
#
# It also provides the core structure for handling
# customer rewards, discounts, and promotional
# campaigns within the PetroVision platform.
# ========================================================================================================

class Offer:
    def __init__(
        self,
        offer_id,
        title,
        description=None,
        discount=None,
        points_required=0,
        station_id=None,
        user_id=None,
        status="active"
    ):
        self.offer_id = offer_id
        self.title = title
        self.description = description
        self.discount = discount
        self.points_required = points_required
        self.station_id = station_id
        self.user_id = user_id
        self.status = status

    def is_active(self):
        return str(self.status).lower() == "active"

    def activate(self):
        self.status = "active"

    def deactivate(self):
        self.status = "inactive"

    def to_dict(self):
        return {
            "offer_id": self.offer_id,
            "title": self.title,
            "description": self.description,
            "discount": self.discount,
            "points_required": self.points_required,
            "station_id": self.station_id,
            "user_id": self.user_id,
            "status": self.status
        }