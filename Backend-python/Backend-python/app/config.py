from dotenv import load_dotenv
import os

load_dotenv()

# =============================
# Database Configuration 
# =============================
DB_CONFIG = {
    "host": os.getenv("DB_HOST"),
    "database": os.getenv("DB_NAME"),
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD"),
    "port": os.getenv("DB_PORT"),
    "sslmode": os.getenv("DB_SSLMODE"),
}

# =============================
# Main Table for ML Model
# =============================
TABLE_NAME = os.getenv("DB_TABLE_NAME", "historical_station_metrics")

# =============================
# Debug / Safety Check 
# =============================
def validate_config():
    missing = [k for k, v in DB_CONFIG.items() if v is None]
    if missing:
        raise ValueError(f"Missing environment variables: {missing}")