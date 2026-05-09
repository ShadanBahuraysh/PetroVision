# ========================================================================================================
# PetroVision Transaction Model
# --------------------------------------------------------------------------------------------------------
# This file defines the Transaction class used
# within the PetroVision loyalty system.
#
# Features included:
# - Managing loyalty transaction records
# - Storing transaction details and amounts
# - Handling earned and redeemed points
# - Linking transactions to users and stations
# - Identifying transaction types
# - Automatically generating transaction timestamps
# - Converting transaction objects into dictionaries
#
# It also provides the core structure for tracking
# loyalty point activities and customer transactions
# within the PetroVision platform.
# ========================================================================================================

from datetime import datetime


class Transaction:
    def __init__(
        self,
        transaction_id,
        user_id,
        station_id=None,
        amount=0.0,
        points=0,
        transaction_type="earn",
        description=None,
        date=None
    ):
        self.transaction_id = transaction_id
        self.user_id = user_id
        self.station_id = station_id
        self.amount = amount
        self.points = points
        self.transaction_type = transaction_type
        self.description = description
        self.date = date or datetime.utcnow().isoformat()

    def is_earn(self):
        return str(self.transaction_type).lower() == "earn"

    def is_redeem(self):
        return str(self.transaction_type).lower() == "redeem"

    def to_dict(self):
        return {
            "transaction_id": self.transaction_id,
            "user_id": self.user_id,
            "station_id": self.station_id,
            "amount": self.amount,
            "points": self.points,
            "transaction_type": self.transaction_type,
            "description": self.description,
            "date": self.date
        }