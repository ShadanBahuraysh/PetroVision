from abc import ABC, abstractmethod


class IApplicationGateway(ABC):
    @abstractmethod
    def login(self, email, password):
        pass

    @abstractmethod
    def access_dashboard(self, user):
        pass


class AppAccessProxy:
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

        return {
            "allowed": True,
            "message": "Access granted",
            "dashboard": self._real_gateway.access_dashboard(user)
        }