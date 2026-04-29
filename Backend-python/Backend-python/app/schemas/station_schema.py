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