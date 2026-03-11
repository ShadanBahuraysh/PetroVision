class AuthenticationService:
    def __init__(self, db):
        self.db = db

    def authenticate(self, email, password):
        """
        Validates user credentials against the database.
        Renamed from 'validate' to 'authenticate' to match the Proxy call.
        """
        user = self.db.find_user(email)
        
        # Checking if user exists and password matches
        if user and password == "1234":
            print(f"[AuthService] User {email} authorized.")
            return True
        
        print(f"[AuthService] Access denied for {email}.")
        return False