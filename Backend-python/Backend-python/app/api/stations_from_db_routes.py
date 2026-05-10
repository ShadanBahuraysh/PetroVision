# ========================================================================================================
# PetroVision Station Routes
# --------------------------------------------------------------------------------------------------------
# This file contains API endpoints for retrieving
# station data from the PetroVision system.
#
# Features included:
# - Retrieving all stations from the database
# - Retrieving a specific station by ID
# - Integrating station service operations
# - Returning formatted station data
# - Handling station-not-found scenarios
# - Handling API request errors
#
# It also connects FastAPI route endpoints
# with the StationService layer to provide
# station-related data for frontend applications.
# ========================================================================================================

from fastapi import APIRouter, HTTPException
from app.services.station_service import StationService

router = APIRouter()

station_service = StationService()


@router.get("/stations-db")
def get_stations_from_db():
    try:
        return station_service.load_stations()


    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid station input: {str(e)}"
        )

    except KeyError as e:
        raise HTTPException(
            status_code=500,
            detail=f"Missing required station field: {str(e)}"
        )

    except TypeError:
        raise HTTPException(
            status_code=500,
            detail="Invalid station data format"
        )

    except Exception:
        raise HTTPException(
            status_code=500,
            detail="Unexpected station service error"
        )


@router.get("/stations-db/{station_id}")
def get_station_from_db(station_id: str):
    try:
        station = station_service.get_station_by_id(station_id)

        if not station:
            raise HTTPException(status_code=404, detail="Station not found")

        return station

    except HTTPException:
        raise

    except ValueError as e:
        raise HTTPException(status_code=400, detail=f"Invalid station value: {str(e)}")

    except KeyError as e:
        raise HTTPException(status_code=500, detail=f"Missing station field: {str(e)}")

    except TypeError:
        raise HTTPException(status_code=500, detail="Invalid station data format")

    except Exception:
        raise HTTPException(status_code=500, detail="Unexpected error occurred while retrieving station data")
