# ========================================================================================================
# PetroVision Station Data Service
# --------------------------------------------------------------------------------------------------------
# This file defines the StationDataService class
# used for retrieving and preparing station data
# within the PetroVision analytics system.
#
# Features included:
# - Connecting to the PostgreSQL database
# - Retrieving all station performance data
# - Retrieving data for a specific station
# - Cleaning and formatting station datasets
# - Normalizing column names and station IDs
# - Handling invalid and missing data
# - Preparing datasets for AI analysis workflows
#
# It also centralizes database-access operations
# and data preprocessing for analytics and
# machine learning services within PetroVision.
# ========================================================================================================

import pandas as pd
from sqlalchemy import create_engine
from app.config import DB_CONFIG, TABLE_NAME


class StationDataService:
    def __init__(self):
        self.connection_string = (
            f"postgresql://{DB_CONFIG['user']}:{DB_CONFIG['password']}"
            f"@{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}"
        )
        self.engine = create_engine(self.connection_string)

    def get_all_data(self):
        query = f"SELECT * FROM {TABLE_NAME}"
        df = pd.read_sql(query, self.engine)

        df.columns = df.columns.str.strip().str.lower()

        if "station_id" in df.columns:
            df["station_id"] = df["station_id"].astype(str).str.strip()
            df = df[df["station_id"].str.lower() != "station_id"]

        if "date" in df.columns:
            df["date"] = pd.to_datetime(df["date"], errors="coerce")

        df = df.dropna(subset=["station_id"]) if "station_id" in df.columns else df
        df = df.reset_index(drop=True)


        return df

    def get_station_data(self, station_id: str):
        query = f"""
            SELECT *
            FROM {TABLE_NAME}
            WHERE TRIM(LOWER(station_id)) = TRIM(LOWER(%s))
        """
        df = pd.read_sql(query, self.engine, params=(station_id,))
        df.columns = df.columns.str.strip().str.lower()

        if "station_id" in df.columns:
            df["station_id"] = df["station_id"].astype(str).str.strip()
            df = df[df["station_id"].str.lower() != "station_id"]

        if "date" in df.columns:
            df["date"] = pd.to_datetime(df["date"], errors="coerce")

        df = df.dropna(subset=["station_id"]) if "station_id" in df.columns else df
        df = df.reset_index(drop=True)
        return df
    
    