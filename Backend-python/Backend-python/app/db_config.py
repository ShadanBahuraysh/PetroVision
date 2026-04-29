from app.models.user import Admin, Customer
# Test file (we can remove it)

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