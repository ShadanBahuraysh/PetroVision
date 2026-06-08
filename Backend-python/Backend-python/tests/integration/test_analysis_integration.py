import sys
from unittest.mock import MagicMock

mock_supabase = MagicMock()
sys.modules.setdefault("supabase", MagicMock())
sys.modules["app.supabase_client"] = MagicMock(supabase=mock_supabase)

from fastapi import FastAPI
from fastapi.testclient import TestClient
from app.api import analysis_routes

app = FastAPI()
app.include_router(analysis_routes.router, prefix="/analysis")
client = TestClient(app)


def test_run_all_analysis_success(monkeypatch):
    def fake_run_full_analysis(force=False):
        return {
            "message": "Full analysis completed and cached successfully",
            "cached": False,
        }
    monkeypatch.setattr(analysis_routes.analysis_service, "run_full_analysis", fake_run_full_analysis)
    response = client.get("/analysis/run-all?force=true")
    assert response.status_code == 200
    assert response.json()["message"] == "Full analysis completed and cached successfully"
    assert response.json()["cached"] is False


def test_overview_success(monkeypatch):
    def fake_get_overview():
        return {
            "total_stations": 10,
            "overall_average_score": 76.5,
            "low_performance_count": 2,
            "high_performance_count": 5,
            "most_common_issues": [],
            "management_recommendations": [],
        }
    monkeypatch.setattr(analysis_routes.analysis_service, "get_overview", fake_get_overview)
    response = client.get("/analysis/overview")
    assert response.status_code == 200
    data = response.json()
    assert data["total_stations"] == 10
    assert data["overall_average_score"] == 76.5


def test_ranking_success(monkeypatch):
    def fake_get_ranking():
        return [{"station_id": "S001", "final_station_score": 90, "performance_status": "Good"}]
    monkeypatch.setattr(analysis_routes.analysis_service, "get_ranking", fake_get_ranking)
    response = client.get("/analysis/ranking")
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 1
    assert data[0]["station_id"] == "S001"


def test_top_bottom_success(monkeypatch):
    def fake_get_top_bottom_10():
        return {
            "bottom_10": [{"station_id": "S010", "final_station_score": 40}],
            "top_10": [{"station_id": "S001", "final_station_score": 90}],
        }
    monkeypatch.setattr(analysis_routes.analysis_service, "get_top_bottom_10", fake_get_top_bottom_10)
    response = client.get("/analysis/top-bottom")
    assert response.status_code == 200
    data = response.json()
    assert data["bottom_10"][0]["station_id"] == "S010"
    assert data["top_10"][0]["station_id"] == "S001"


def test_station_analysis_success(monkeypatch):
    def fake_get_station_analysis(station_id):
        return {
            "station_id": station_id,
            "final_station_score": 82,
            "priority": "Low",
            "performance_status": "Good",
            "main_issues": [],
            "recommended_actions": [],
        }
    monkeypatch.setattr(analysis_routes.analysis_service, "get_station_analysis", fake_get_station_analysis)
    response = client.get("/analysis/station/S001")
    assert response.status_code == 200
    data = response.json()
    assert data["station_id"] == "S001"
    assert data["performance_status"] == "Good"


def test_invalid_station_analysis_returns_message(monkeypatch):
    def fake_get_station_analysis(station_id):
        return {"station_id": station_id, "message": "No data found for this station."}
    monkeypatch.setattr(analysis_routes.analysis_service, "get_station_analysis", fake_get_station_analysis)
    response = client.get("/analysis/station/INVALID_ID")
    assert response.status_code == 200
    data = response.json()
    assert data["station_id"] == "INVALID_ID"
    assert data["message"] == "No data found for this station."


def test_explain_overview_success(monkeypatch):
    def fake_explain_overview():
        return {"overview": {"total_stations": 10}, "explanation": "Network performance is stable."}
    monkeypatch.setattr(analysis_routes.explanation_service, "explain_overview", fake_explain_overview)
    response = client.get("/analysis/explain/overview")
    assert response.status_code == 200
    assert response.json()["explanation"] == "Network performance is stable."


def test_compare_stations_success(monkeypatch):
    def fake_compare_stations(station_1, station_2):
        return {
            "station_1": {"station_id": station_1},
            "station_2": {"station_id": station_2},
            "explanation": "Station S001 performs better than Station S002.",
        }
    monkeypatch.setattr(analysis_routes.explanation_service, "compare_stations", fake_compare_stations)
    response = client.get("/analysis/compare/S001/S002")
    assert response.status_code == 200
    data = response.json()
    assert data["station_1"]["station_id"] == "S001"
    assert data["station_2"]["station_id"] == "S002"
    assert "performs better" in data["explanation"]


def test_export_report_success(monkeypatch):
    def fake_build_export_rows():
        return (
            "2026-05-08T10:00:00+03:00",
            {"total_stations": 1, "average_score": 80, "good_stations": 1, "fair_stations": 0, "poor_stations": 0},
            ["Top performing station is S001 with score 80."],
            [{"station_id": "S001", "score": 80, "status": "Good", "priority": "Low",
              "top_issue": "No major issue", "recommendation": "Monitor station performance."}],
        )
    monkeypatch.setattr(analysis_routes, "_build_export_rows", fake_build_export_rows)
    response = client.get("/analysis/export?save_to_db=false")
    assert response.status_code == 200
    data = response.json()
    assert data["summary"]["total_stations"] == 1
    assert len(data["rows"]) == 1
    assert data["rows"][0]["station_id"] == "S001"


def test_download_csv_success(monkeypatch):
    def fake_build_export_rows():
        return (
            "2026-05-08",
            {"total_stations": 1, "average_score": 88, "good_stations": 1, "fair_stations": 0, "poor_stations": 0},
            ["Insight"],
            [{"station_id": "S001", "score": 88, "status": "Good", "priority": "Low",
              "top_issue": "No issue", "recommendation": "Monitor station"}],
        )
    monkeypatch.setattr(analysis_routes, "_build_export_rows", fake_build_export_rows)
    response = client.get("/analysis/export/download?file_type=csv")
    assert response.status_code == 200
    assert response.headers["content-type"].startswith("text/csv")


def test_download_invalid_type(monkeypatch):
    def fake_build_export_rows():
        return (
            "2026-05-08",
            {"total_stations": 1, "average_score": 88, "good_stations": 1, "fair_stations": 0, "poor_stations": 0},
            ["Insight"],
            [{"station_id": "S001", "score": 88, "status": "Good", "priority": "Low",
              "top_issue": "No issue", "recommendation": "Monitor station"}],
        )
    monkeypatch.setattr(analysis_routes, "_build_export_rows", fake_build_export_rows)
    response = client.get("/analysis/export/download?file_type=pdf")
    assert response.status_code == 400
    assert "unsupported file type" in response.json()["detail"].lower()


def test_clear_cache_success(monkeypatch):
    def fake_clear_cache():
        return {"message": "Analysis cache cleared successfully"}

    def fake_clear_explanation_cache():
        return {"message": "Explanation cache cleared successfully"}

    monkeypatch.setattr(analysis_routes.analysis_service, "clear_cache", fake_clear_cache)
    monkeypatch.setattr(analysis_routes.explanation_service, "clear_explanation_cache", fake_clear_explanation_cache)
    response = client.get("/analysis/clear-cache")
    assert response.status_code == 200
    assert response.json()["message"] == "All caches cleared successfully"