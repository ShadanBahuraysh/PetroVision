from abc import ABC, abstractmethod

# Interface for the Proxy and Real Subject
class IApplicationGateway(ABC):
    @abstractmethod
    def login(self, email, password):
        pass

    @abstractmethod
    def access_dashboard(self, user):
        pass

# The Proxy Class
class AppAccessProxy(IApplicationGateway):
    def __init__(self, real_gateway, auth_service):
        """
        Initialize the proxy with the real service and the authentication service.
        """
        self._real_gateway = real_gateway
        self._auth_service = auth_service

    def login(self, email, password):
        print(f"[Proxy] Validating access for: {email}")
        
        # Check credentials using the Auth Service
        if self._auth_service.authenticate(email, password):
            print("[Proxy] Authentication successful! ✅")
            return True
        else:
            print("[Proxy] Authentication failed! ❌ Access Denied.")
            return False

    def access_dashboard(self, user):
        # Additional logic can be added here (e.g., logging or permission checks)
        if user:
            print(f"[Proxy] Redirecting user {user.name} to the dashboard...")
            self._real_gateway.access_dashboard(user)
        else:
            print("[Proxy] Access Error: No valid user session found.")