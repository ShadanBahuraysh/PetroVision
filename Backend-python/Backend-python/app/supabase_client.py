# ========================================================================================================
# PetroVision Supabase Client Configuration
# --------------------------------------------------------------------------------------------------------
# This file is responsible for configuring and
# initializing the Supabase database client
# used within the PetroVision system.
#
# Features included:
# - Loading environment variables
# - Retrieving Supabase credentials
# - Initializing the Supabase client connection
# - Providing centralized database access
#
# It also serves as the shared database connection
# configuration used by backend services,
# routes, and authentication operations.
# ========================================================================================================
from supabase import create_client, Client
import os
from dotenv import load_dotenv

load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)