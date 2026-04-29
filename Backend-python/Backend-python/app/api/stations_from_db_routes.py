from fastapi import APIRouter, HTTPException
from app.supabase_client import supabase

router = APIRouter()


@router.get("/stations-db")
def get_stations_from_db():
    try:
        result = supabase.table("station").select("*").execute()
        stations = result.data or []

        output = []
        for station in stations:
            lat = station.get("latitude")
            lng = station.get("longitude")

            if lat is not None and lng is not None:
                output.append({
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
                    "side_code": station.get("side_code")
                })

        return output

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/stations-db/{station_id}")
def get_station_from_db(station_id: str):
    try:
        result = (
            supabase.table("station")
            .select("*")
            .eq("station_id", station_id)
            .execute()
        )

        if not result.data:
            raise HTTPException(status_code=404, detail="Station not found")

        station = result.data[0]
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
            "side_code": station.get("side_code")
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))