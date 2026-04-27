from fastapi import APIRouter, HTTPException

from app.services.analysis_service import AnalysisService
from app.services.explanation_service import ExplanationService

router = APIRouter()

analysis_service = AnalysisService()
explanation_service = ExplanationService()


@router.get("/run-all")
def run_all_analysis(force: bool = False):
    try:
        return analysis_service.run_full_analysis(force=force)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/overview")
def get_overview():
    try:
        return analysis_service.get_overview()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/ranking")
def get_ranking():
    try:
        return analysis_service.get_ranking()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/top-bottom")
def get_top_bottom():
    try:
        return analysis_service.get_top_bottom_10()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/station/{station_id}")
def analyze_station(station_id: str):
    try:
        return analysis_service.get_station_analysis(station_id)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/explain/station/{station_id}")
def explain_station(station_id: str):
    try:
        return explanation_service.explain_station(station_id)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/explain/overview")
def explain_overview():
    try:
        return explanation_service.explain_overview()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/compare/{station_1}/{station_2}")
def compare_stations(station_1: str, station_2: str):
    try:
        return explanation_service.compare_stations(station_1, station_2)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/clear-cache")
def clear_cache():
    try:
        analysis_result = analysis_service.clear_cache()
        explanation_service.clear_explanation_cache()
        return {
            "message": "All caches cleared successfully",
            "analysis": analysis_result
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))