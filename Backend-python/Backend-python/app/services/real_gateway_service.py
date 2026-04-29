from app.patterns.proxy.gateway import IApplicationGateway


class RealGatewayService(IApplicationGateway):
    def login(self, email, password):
        return {
            "message": "Secure session established",
            "email": email
        }

    def access_dashboard(self, user):
        return {
            "allowed": True,
            "message": "Dashboard data access granted",
            "user": user
        }