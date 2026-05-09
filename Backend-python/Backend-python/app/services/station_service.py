# ========================================================================================================
# PetroVision Station Service
# --------------------------------------------------------------------------------------------------------
# This file defines the StationService class used
# for retrieving and formatting station data
# from the PetroVision database.
#
# Features included:
# - Loading all stations from the database
# - Retrieving stations by station ID
# - Retrieving stations by location
# - Formatting station response data
# - Filtering stations with valid coordinates
# - Preparing station data for map integration
#
# It also centralizes station-data retrieval
# and formatting operations for dashboard,
# analytics, and location-based system features.
# ========================================================================================================

from app.supabase_client import supabase


class StationService:
    def _format_station(self, station):
        lat = station.get("latitude")
        lng = station.get("longitude")

        return {
            "station_id": station.get("station_id"),
            "station_name": station.get("station_name"),
            "name": station.get("station_name"),
            "latitude": lat,
            "longitude": lng,
            "lat": lat,
            "lng": lng,
            "address": station.get("address"),
            "status": station.get("status"),
            "city": station.get("city"),
            "street": station.get("street"),
            "side_code": station.get("side_code"),
        }

    def load_stations(self):
        result = supabase.table("station").select("*").execute()
        stations = result.data or []

        return [
            self._format_station(station)
            for station in stations
            if station.get("latitude") is not None and station.get("longitude") is not None
        ]

    def get_station_by_id(self, station_id):
        result = (
            supabase.table("station")
            .select("*")
            .eq("station_id", station_id)
            .execute()
        )

        if not result.data:
            return None

        return self._format_station(result.data[0])

    def load_stations_by_location(self, location):
        result = (
            supabase.table("station")
            .select("*")
            .eq("city", location)
            .execute()
        )

        stations = result.data or []

        return [
            self._format_station(station)
            for station in stations
            if station.get("latitude") is not None and station.get("longitude") is not None
        ]