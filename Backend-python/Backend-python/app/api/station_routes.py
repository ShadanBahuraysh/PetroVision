# ========================================================================================================
# PetroVision Google Maps Routes
# --------------------------------------------------------------------------------------------------------
# This file contains API endpoints for retrieving
# fuel station location data using the Google Maps
# Places API.
#
# Features included:
# - Searching for fuel stations
# - Retrieving station coordinates and addresses
# - Formatting Google Maps response data
# - Handling Google API request errors
# - Returning station information for map integration
#
# It also validates Google API responses and converts
# external map data into a structured format used
# within the PetroVision system.
# ========================================================================================================
from fastapi import APIRouter, HTTPException
import os
import requests
from dotenv import load_dotenv

load_dotenv()

router = APIRouter()

GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")


@router.get("/stations")
def get_stations(query: str = "Petromin station Saudi Arabia"):
    try:
        if not GOOGLE_API_KEY:
            raise HTTPException(status_code=500, detail="GOOGLE_API_KEY is missing in .env")

        url = "https://maps.googleapis.com/maps/api/place/textsearch/json"
        params = {
            "query": query,
            "key": GOOGLE_API_KEY,
        }

        response = requests.get(url, params=params, timeout=10)
        data = response.json()

        if data.get("status") not in ["OK", "ZERO_RESULTS"]:
            raise HTTPException(
                status_code=400,
                detail={
                    "google_status": data.get("status"),
                    "message": data.get("error_message", "")
                }
            )

        results = []
        for place in data.get("results", []):
            location = place.get("geometry", {}).get("location", {})
            lat = location.get("lat")
            lng = location.get("lng")

            results.append({
                "station_id": place.get("place_id"),
                "station_name": place.get("name", ""),
                "name": place.get("name", ""),
                "latitude": lat,
                "longitude": lng,
                "lat": lat,
                "lng": lng,
                "address": place.get("formatted_address", ""),
                "status": "open" if place.get("business_status") == "OPERATIONAL" else place.get("business_status"),
                "city": None,
                "street": None,
                "side_code": None,
                "rating": place.get("rating"),
                "place_id": place.get("place_id")
            })

        return results

    except HTTPException:
        raise
    except requests.RequestException as e:
        raise HTTPException(status_code=502, detail=f"Google Maps request failed: {str(e)}")

    except KeyError as e:
        raise HTTPException(
            status_code=500,
            detail=f"Missing station information: {str(e)}"
        )

    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid station input: {str(e)}"
        )

    except TypeError:
        raise HTTPException(
            status_code=500,
            detail="Invalid station request format"
        )
    except Exception:
        raise HTTPException(status_code=500, detail="Internal server error")
