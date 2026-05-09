# ========================================================================================================
# PetroVision Backend Configuration
# --------------------------------------------------------------------------------------------------------
# This file defines the backend configuration
# and environment-variable loading
# for the PetroVision platform.
#
# Features included:
# - Loading environment variables from .env files
# - Configuring PostgreSQL database connection settings
# - Defining ML-model database table names
# - Managing database connection parameters
# - Validating required backend environment variables
# - Providing centralized backend configuration management
#
# It also supports backend database integration,
# machine-learning data access,
# and environment configuration workflows
# within the PetroVision platform.
# ========================================================================================================

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