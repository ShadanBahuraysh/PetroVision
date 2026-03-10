from fastapi import APIRouter
from pydantic import BaseModel
from typing import Any, Dict, List

from app.services.analysis_service import AnalysisService


router = APIRouter(prefix="/analysis", tags=["Analysis"])


class AnalysisRequest(BaseModel):
    stations: List[Dict[str, Any]]


@router.post("/predict")
def analyze_stations(request: AnalysisRequest):
    service = AnalysisService()
    result = service.analyze_stations(request.stations)
    return result