# ========================================================================================================
# PetroVision User Model
# --------------------------------------------------------------------------------------------------------
# This file defines the User class used
# within the PetroVision platform.
#
# Features included:
# - Managing user account information
# - Storing user identity and role details
# - Supporting admin and customer roles
# - Checking user role permissions
# - Converting user objects into dictionaries
#
# It also provides the core structure for handling
# authentication, authorization, and user-related
# operations within the PetroVision system.
# ========================================================================================================

class User:
    def __init__(self, user_id, name, email, password=None, role="customer"):
        self.user_id = user_id
        self.name = name
        self.email = email
        self.password = password
        self.role = role

    def is_admin(self):
        return self.role.lower() == "admin"

    def is_customer(self):
        return self.role.lower() == "customer"

    def to_dict(self):
        return {
            "user_id": self.user_id,
            "name": self.name,
            "email": self.email,
            "role": self.role
        }