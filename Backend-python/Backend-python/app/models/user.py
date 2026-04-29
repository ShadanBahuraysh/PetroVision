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