import os
import sys

# 1. Setup paths to ensure local modules are visible
current_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(current_dir)

# Adding both current and parent directories to sys.path
if current_dir not in sys.path:
    sys.path.insert(0, current_dir)
if parent_dir not in sys.path:
    sys.path.insert(0, parent_dir)

# 2. Imports with the updated names
try:
    from db_config import Database
    from services.auth_service import AuthenticationService
    from services.real_gateway_service import RealGatewayService
    from patterns.proxy.gateway import AppAccessProxy
    
    print("✅ System components linked successfully!")
except ImportError as e:
    print(f"❌ Import Error: {e}")
    sys.exit(1)

def start_app():
    print("\n" + "="*45)
    print("   PetroVision System - Gateway v1.0   ")
    print("="*45 + "\n")
    
    # Initialize components
    db = Database()
    auth_service = AuthenticationService(db)
    real_gateway = RealGatewayService()
    proxy_gateway = AppAccessProxy(real_gateway, auth_service)

    # Testing Authentication
    print("[Action] Attempting secure login...")
    email = "user@petro.com"
    password = "1234" # Default password in AuthService
    
    if proxy_gateway.login(email, password):
        print("Result: Success! Gateway opened. ✅")
        user = db.find_user(email)
        proxy_gateway.access_dashboard(user)
    else:
        print("Result: Failure! Access blocked by Proxy. 🔒")
    
    print("\n" + "="*45)

if __name__ == "__main__":
    start_app()