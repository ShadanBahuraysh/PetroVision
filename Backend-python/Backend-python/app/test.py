""" from models.loyalty_account import LoyaltyAccount
from models.membership import Membership
from services.loyalty_service import LoyaltyService

# Test file (we can remove it)
# create objects
account = LoyaltyAccount(account_id=1)
membership = Membership(
       membership_id=1,   
    tier="Gold",
    status="Active",
    start_date="2024-01-01",
    end_date="2025-01-01"
)

service = LoyaltyService()

# test earning
points = service.earn_points(account, membership, 100)
print("Points earned:", points)
print("Current points:", account.current_points)

# test redeeming
success = service.redeem_points(account, 50)
print("Redeem success:", success)
print("Current points after redeem:", account.current_points)
#/ """