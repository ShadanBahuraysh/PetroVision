# ========================================================================================================
# PetroVision Mock Database Service
# --------------------------------------------------------------------------------------------------------
# This file defines a simple in-memory database
# used for storing and retrieving user data
# within the PetroVision platform.
#
# Features included:
# - Storing mock user account data
# - Retrieving users by email address
# - Supporting admin and customer account types
# - Creating Admin and Customer model objects
# - Simulating basic database lookup operations
#
# It also supports authentication workflows,
# user-type handling,
# and backend testing functionality
# within the PetroVision platform.
# ========================================================================================================

from app.models.user import Admin, Customer

class Database:
    def __init__(self):
        self._users = {
            "admin@petro.com": {"id": "1", "name": "Admin Ali", "type": "admin"},
            "user@petro.com": {"id": "2", "name": "Mohammed", "type": "customer"}
        }

    def find_user(self, email):
        data = self._users.get(email) 
        if not data: 
            return None
        
        if data["type"] == "admin":
            return Admin(data["id"], data["name"], email)
        return Customer(data["id"], data["name"], email) 