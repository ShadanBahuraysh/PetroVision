# ========================================================================================================
# PetroVision Database Connection Service
# --------------------------------------------------------------------------------------------------------
# This file defines database connection utilities
# used for connecting the PetroVision backend
# to the PostgreSQL database.
#
# Features included:
# - Creating PostgreSQL database connections
# - Loading database credentials from configuration
# - Using dictionary-based query result formatting
# - Supporting secure SSL database connections
# - Handling database connection exceptions
# - Providing database connection test utilities
#
# It also supports backend database access,
# API data retrieval,
# and machine-learning data operations
# within the PetroVision platform.
# ========================================================================================================

import psycopg2
from psycopg2.extras import RealDictCursor
from app.config import DB_CONFIG


def get_db_connection():
    # Connect to database
    try:
        conn = psycopg2.connect(
            host=DB_CONFIG["host"],
            database=DB_CONFIG["database"],
            user=DB_CONFIG["user"],
            password=DB_CONFIG["password"],
            port=DB_CONFIG["port"],
            sslmode=DB_CONFIG["sslmode"],
            cursor_factory=RealDictCursor
        )
        return conn

    except Exception as e:
        print("❌ Database connection failed:", e)
        raise


def test_connection():
    # Run simple test query
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT 1;")
        print("✅ Connection successful:", cursor.fetchone())

        cursor.close()
        conn.close()

    except Exception as e:
        print("❌ Connection test failed:", e) 