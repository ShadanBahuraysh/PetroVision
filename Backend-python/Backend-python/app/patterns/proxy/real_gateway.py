# ========================================================================================================
# PetroVision Real Application Gateway
# --------------------------------------------------------------------------------------------------------
# This file defines the RealApplicationGateway class
# used in the Proxy design pattern implementation
# within the PetroVision system.
#
# Features included:
# - Providing dashboard access after authorization
# - Determining dashboard type based on user role
# - Supporting admin and customer dashboards
# - Handling unknown or unsupported user roles
# - Returning dashboard access responses
#
# It works together with the AppAccessProxy class
# to separate access-control validation from
# the actual dashboard access functionality.
# ========================================================================================================
class RealApplicationGateway:
    def access_dashboard(self, user):
        role = str(user.get("role", "")).lower()

        if role == "admin":
            dashboard = "Admin Dashboard"
        elif role == "customer":
            dashboard = "Customer Home"
        else:
            return {
                "allowed": False,
                "message": "Unknown user type",
                "user": user
            }

        return {
            "allowed": True,
            "message": "Dashboard access granted",
            "dashboard": dashboard,
            "user": user
        }