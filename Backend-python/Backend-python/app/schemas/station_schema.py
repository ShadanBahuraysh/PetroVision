# ========================================================================================================
# PetroVision Station Schemas
# --------------------------------------------------------------------------------------------------------
# This file defines the Pydantic request and response
# schemas used for station-related operations
# within the PetroVision system.
#
# Features included:
# - Defining station API response models
# - Defining station analysis request schemas
# - Managing station location and address structures
# - Supporting station analysis operations
# - Providing type validation for station data
#
# It also ensures consistent station-data formatting
# and request validation between backend services
# and frontend applications.
# ========================================================================================================
from pydantic import BaseModel
from typing import Optional


class StationResponse(BaseModel):
    station_id: str
    station_name: str
    side_code: Optional[str] = None
    city: Optional[str] = None
    street: Optional[str] = None
    address: Optional[str] = None
    status: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None


class StationAnalysisRequest(BaseModel):
    station_id: str