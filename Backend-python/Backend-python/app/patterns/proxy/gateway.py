# ========================================================================================================
# PetroVision Application Access Proxy
# --------------------------------------------------------------------------------------------------------
# This file defines the application gateway interface
# and the AppAccessProxy class used in the Proxy
# design pattern implementation within PetroVision.
#
# Features included:
# - Defining application gateway operations
# - Handling user authentication requests
# - Validating user sessions and roles
# - Controlling dashboard access permissions
# - Restricting unauthorized access attempts
# - Delegating approved access requests to the real gateway
#
# It also separates basic access-control validation
# from the actual dashboard access functionality
# within the system.
# ========================================================================================================
from abc import ABC, abstractmethod


class IApplicationGateway(ABC):
    @abstractmethod
    def login(self, email, password):
        pass

    @abstractmethod
    def access_dashboard(self, user):
        pass


class AppAccessProxy(IApplicationGateway):
    def __init__(self, real_gateway, auth_service):
        self._real_gateway = real_gateway
        self._auth_service = auth_service

    def login(self, email, password):
        user = self._auth_service.authenticate(email, password)

        if not user:
            return {
                "allowed": False,
                "message": "Invalid email or password",
                "user": None
            }

        return {
            "allowed": True,
            "message": "Login successful",
            "user": user
        }

    def access_dashboard(self, user):
        if not user:
            return {
                "allowed": False,
                "message": "No user session"
            }

        role = str(user.get("role", "")).lower()

        if role not in ["admin", "customer"]:
            return {
                "allowed": False,
                "message": "Unauthorized user type"
            }

        return {
            "allowed": True,
            "message": "Access granted",
            "dashboard": self._real_gateway.access_dashboard(user)
        }