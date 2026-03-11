from abc import ABC, abstractmethod

# المستخدم الأساسي (Abstract Class)
class User(ABC):
    def __init__(self, user_id, name, email):
        self.user_id = user_id
        self.name = name
        self.email = email
        self.role = None

# العميل (Customer)
class Customer(User):
    def __init__(self, user_id, name, email):
        super().__init__(user_id, name, email)
        self.role = "CUSTOMER"
        self.loyalty_id = f"L-{user_id}"

# الأدمن (Admin)
class Admin(User):
    def __init__(self, user_id, name, email):
        super().__init__(user_id, name, email)
        self.role = "ADMIN"