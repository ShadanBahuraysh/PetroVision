import pandas as pd
import pytest

from app.services.analysis_service import AnalysisService


@pytest.fixture
def service():
    return AnalysisService()


# =========================
# _compute_station_score_metrics
# =========================

def test_compute_station_score_metrics_valid_predictions_success(service):
    df = pd.DataFrame({"station_id": ["S001"] * 5})
    predictions = [50, 60, 70, 80, 90]

    result = service._compute_station_score_metrics(df, predictions)

    assert result["predicted_mean"] == 70.0
    assert result["recent_predicted_mean"] == 70.0
    assert result["predicted_min"] == 50.0
    assert result["predicted_max"] == 90.0
    assert result["low_score_count"] == 1
    assert result["high_score_count"] == 2
    assert result["critical_score_count"] == 0
    assert result["final_station_score"] == 67.79


def test_compute_station_score_metrics_empty_predictions_fail_case(service):
    result = service._compute_station_score_metrics(pd.DataFrame(), [])

    assert result["predicted_mean"] == 0.0
    assert result["recent_predicted_mean"] == 0.0
    assert result["predicted_min"] == 0.0
    assert result["predicted_max"] == 0.0
    assert result["predicted_std"] == 0.0
    assert result["p10_score"] == 0.0
    assert result["low_score_count"] == 0
    assert result["high_score_count"] == 0
    assert result["critical_score_count"] == 0
    assert result["final_station_score"] == 0.0


# =========================
# _get_priority_from_metrics
# =========================

def test_get_priority_low_success(service):
    metrics = {
        "final_station_score": 75,
        "p10_score": 50,
    }

    result = service._get_priority_from_metrics(metrics)

    assert result == "Low"


def test_get_priority_high_fail_by_low_final_score(service):
    metrics = {
        "final_station_score": 50,
        "p10_score": 60,
    }

    result = service._get_priority_from_metrics(metrics)

    assert result == "High"


def test_get_priority_high_fail_by_low_p10_score(service):
    metrics = {
        "final_station_score": 80,
        "p10_score": 20,
    }

    result = service._get_priority_from_metrics(metrics)

    assert result == "High"


def test_get_priority_medium_success(service):
    metrics = {
        "final_station_score": 60,
        "p10_score": 40,
    }

    result = service._get_priority_from_metrics(metrics)

    assert result == "Medium"


# =========================
# _get_performance_status
# =========================

def test_get_performance_status_good_success(service):
    result = service._get_performance_status({"final_station_score": 70})

    assert result == "Good"


def test_get_performance_status_fair_success(service):
    result = service._get_performance_status({"final_station_score": 55})

    assert result == "Fair"


def test_get_performance_status_poor_fail_case(service):
    result = service._get_performance_status({"final_station_score": 54})

    assert result == "Poor"


# =========================
# _build_station_summary_text
# =========================

def test_build_station_summary_text_without_issues_success(service):
    metrics = {
        "final_station_score": 82,
        "predicted_mean": 80,
        "recent_predicted_mean": 85,
        "p10_score": 70,
    }

    result = service._build_station_summary_text(
        station_id="S001",
        score_metrics=metrics,
        worst_time="Night",
        best_time="Morning",
        issues=[],
    )

    assert "Station S001 has a final score of 82" in result
    assert "average predicted performance is 80" in result
    assert "strongest time is Morning" in result
    assert "weakest time is Night" in result
    assert "No major repeated issues were detected" in result


def test_build_station_summary_text_with_issues_fail_case(service):
    metrics = {
        "final_station_score": 45,
        "predicted_mean": 50,
        "recent_predicted_mean": 48,
        "p10_score": 25,
    }

    issues = [
        {"issue": "High downtime", "count": 3},
        {"issue": "Low transactions", "count": 2},
        {"issue": "Customer complaints", "count": 1},
    ]

    result = service._build_station_summary_text(
        station_id="S002",
        score_metrics=metrics,
        worst_time="Evening",
        best_time="Morning",
        issues=issues,
    )

    assert "Station S002 has a final score of 45" in result
    assert "High downtime" in result
    assert "Low transactions" in result
    assert "Customer complaints" in result


# =========================
# _extract_station_issue_summary
# =========================

def test_extract_station_issue_summary_success(service):
    recommendation_results = [
        {
            "top_negative_drivers": [
                {"feature": "downtime_minutes"},
                {"feature": "downtime_minutes"},
                {"feature": "complaints_count"},
            ]
        },
        {
            "top_negative_drivers": [
                {"feature": "queue_time_avg"},
                {"feature": "downtime_minutes"},
            ]
        },
    ]

    result = service._extract_station_issue_summary(recommendation_results)

    assert isinstance(result, list)
    assert len(result) <= 3
    assert result[0]["count"] == 3
    assert "issue" in result[0]
    assert "explanation" in result[0]


def test_extract_station_issue_summary_empty_fail_case(service):
    result = service._extract_station_issue_summary([])

    assert isinstance(result, list)
    assert result == []


# =========================
# _extract_station_actions
# =========================

def test_extract_station_actions_success(service):
    recommendation_results = [
        {
            "recommended_actions": [
                {"feature": "downtime_minutes"},
                {"feature": "downtime_minutes"},
                {"feature": "complaints_count"},
                {"feature": "performance_status"},
            ]
        }
    ]

    result = service._extract_station_actions(recommendation_results)

    assert isinstance(result, list)
    assert len(result) <= 5
    assert all(action["issue"].lower() != "performance status" for action in result)
    assert "issue" in result[0]
    assert "action" in result[0]


def test_extract_station_actions_empty_fail_case(service):
    result = service._extract_station_actions([])

    assert isinstance(result, list)
    assert result == []


# =========================
# _get_best_and_worst_time
# =========================

def test_get_best_and_worst_time_success(service):
    df = pd.DataFrame({
        "station_id": ["S001", "S001", "S001"],
        "time_slot": ["Morning", "Evening", "Night"],
        "performance_score": [90, 60, 40],
    })

    best_time, worst_time = service._get_best_and_worst_time(df)

    assert best_time == "Morning"
    assert worst_time == "Night"


def test_get_best_and_worst_time_without_time_slot_fail_case(service):
    df = pd.DataFrame({
        "station_id": ["S001", "S001"],
        "performance_score": [80, 60],
    })

    best_time, worst_time = service._get_best_and_worst_time(df)

    assert best_time is None
    assert worst_time is None


# =========================
# get_top_bottom_10
# =========================

def test_get_top_bottom_10_uses_cached_ranking_success(service):
    service.cached_top_bottom = {
        "bottom_10": [{"station_id": "S001"}],
        "top_10": [{"station_id": "S010"}],
    }

    result = service.get_top_bottom_10()

    assert result["bottom_10"][0]["station_id"] == "S001"
    assert result["top_10"][0]["station_id"] == "S010"


def test_get_top_bottom_10_empty_cache_fail_case(monkeypatch, service):
    monkeypatch.setattr(service, "get_ranking", lambda: [])

    result = service.get_top_bottom_10()

    assert result["bottom_10"] == []
    assert result["top_10"] == []


# =========================
# get_overview
# =========================

def test_get_overview_with_ranking_success(monkeypatch, service):
    fake_ranking = [
        {
            "station_id": "S001",
            "final_station_score": 90,
            "priority": "Low",
            "issues": [],
        },
        {
            "station_id": "S002",
            "final_station_score": 40,
            "priority": "High",
            "issues": [
                {"issue": "High downtime", "count": 2}
            ],
        },
    ]

    monkeypatch.setattr(service, "get_ranking", lambda: fake_ranking)

    result = service.get_overview()

    assert result["total_stations"] == 2
    assert result["best_station"] is not None
    assert result["worst_station"] is not None


def test_get_overview_empty_ranking_fail_case(monkeypatch, service):
    monkeypatch.setattr(service, "get_ranking", lambda: [])

    result = service.get_overview()

    assert result["total_stations"] == 0
    assert result["overall_average_score"] == 0
    assert result["best_station"] is None
    assert result["worst_station"] is None
    assert result["most_common_issues"] == []
    assert result["management_recommendations"] == []


# =========================
# clear_cache
# =========================

def test_clear_cache_success(service):
    service.cached_ranking = [{"station_id": "S001"}]
    service.cached_overview = {"total_stations": 1}
    service.cached_top_bottom = {"bottom_10": [], "top_10": []}
    service.cached_station_analyses = {"S001": {"station_id": "S001"}}

    result = service.clear_cache()

    assert result["message"] == "Analysis cache cleared successfully"
    assert service.cached_ranking is None
    assert service.cached_overview is None
    assert service.cached_top_bottom is None
    assert service.cached_station_analyses == {}


def test_clear_cache_when_already_empty_fail_case(service):
    service.cached_ranking = None
    service.cached_overview = None
    service.cached_top_bottom = None
    service.cached_station_analyses = {}

    result = service.clear_cache()

    assert result["message"] == "Analysis cache cleared successfully"
    assert service.cached_ranking is None
    assert service.cached_overview is None
    assert service.cached_top_bottom is None
    assert service.cached_station_analyses == {}