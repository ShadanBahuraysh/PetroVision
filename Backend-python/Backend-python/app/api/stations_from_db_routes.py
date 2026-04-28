from fastapi import APIRouter
from app.supabase_client import supabase

router = APIRouter()

@router.get("/stations-db")
def get_stations_from_db():
    result = supabase.table("station").select("*").execute()
    stations = result.data

    output = []
    for station in stations:
        lat = station.get("latitude")
        lng = station.get("longitude")
        if lat and lng:
            output.append({
                "name": station.get("station_name"),
                "lat": lat,
                "lng": lng,
                "address": station.get("address", ""),
                "status": station.get("status"),
            })

    return output