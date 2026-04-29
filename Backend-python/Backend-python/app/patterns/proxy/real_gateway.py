class RealApplicationGateway:
    def access_dashboard(self, user):
        return {
            "allowed": True,
            "message": "Dashboard access granted",
            "user": user
        }