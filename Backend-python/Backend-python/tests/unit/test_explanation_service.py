import pytest
from app.services.explanation_service import ExplanationService


@pytest.fixture
def service():
    return ExplanationService()


# -------------------------
# Fallback text
# -------------------------

def test_fallback_text_success(service):
    result = service._fallback_text()

    assert isinstance(result, str)
    assert "Explanation generated locally" in result


def test_fallback_text_not_empty(service):
    result = service._fallback_text()

    assert result is not None
    assert result.strip() != ""


# -------------------------
# Compact station data
# -------------------------

def test_compact_station_data_success(service):
    sample_data = {
        "station_id": "S001",
        "final_station_score": 78.5,
        "priority": "Low",
        "best_time": {"time_slot": "Morning"},
        "worst_time": {"time_slot": "Night"},
        "main_issues": [
            {"issue": "High Queue Time"},
            {"issue": "Low Staff Availability"}
        ],
        "recommended_actions": [
            {"action": "Increase staffing"},
            {"action": "Improve queue handling"}
        ]
    }

    result = service._compact_station_data(sample_data)

    assert result["station_id"] == "S001"
    assert result["score"] == 78.5
    assert result["priority"] == "Low"
    assert result["best_time"] == "Morning"
    assert result["worst_time"] == "Night"
    assert len(result["issues"]) == 2
    assert len(result["actions"]) == 2


def test_compact_station_data_missing_fields(service):
    sample_data = {}

    result = service._compact_station_data(sample_data)

    assert result["station_id"] is None
    assert result["score"] == 0
    assert result["priority"] is None
    assert result["best_time"] is None
    assert result["worst_time"] is None
    assert result["issues"] == []
    assert result["actions"] == []


# -------------------------
# Compact overview data
# -------------------------

def test_compact_overview_data_success(service):
    sample_data = {
        "total_stations": 20,
        "overall_average_score": 74.2,
        "best_station": {"station_id": "S001"},
        "worst_station": {"station_id": "S010"},
        "low_performance_count": 4,
        "high_performance_count": 9,
        "most_common_issues": [
            {"issue": "Queue Time"},
            {"issue": "Downtime"}
        ]
    }

    result = service._compact_overview_data(sample_data)

    assert result["total_stations"] == 20
    assert result["overall_average_score"] == 74.2
    assert result["best_station_id"] == "S001"
    assert result["worst_station_id"] == "S010"
    assert result["low_performance_count"] == 4
    assert result["high_performance_count"] == 9
    assert len(result["most_common_issues"]) == 2


def test_compact_overview_data_missing_fields(service):
    sample_data = {}

    result = service._compact_overview_data(sample_data)

    assert result["total_stations"] == 0
    assert result["overall_average_score"] == 0
    assert result["best_station_id"] is None
    assert result["worst_station_id"] is None
    assert result["low_performance_count"] == 0
    assert result["high_performance_count"] == 0
    assert result["most_common_issues"] == []


# -------------------------
# Station prompt
# -------------------------

def test_station_prompt_success(service):
    compact = {
        "station_id": "S001",
        "score": 81,
        "priority": "Low",
        "best_time": "Morning",
        "worst_time": "Night",
        "issues": ["Queue Time"],
        "actions": ["Increase staff"]
    }

    prompt = service._station_prompt(compact)

    assert "S001" in prompt
    assert "81" in prompt
    assert "Queue Time" in prompt
    assert "Increase staff" in prompt


def test_station_prompt_missing_data(service):
    compact = {
        "station_id": None,
        "score": 0,
        "priority": None,
        "best_time": None,
        "worst_time": None,
        "issues": [],
        "actions": []
    }

    prompt = service._station_prompt(compact)

    assert isinstance(prompt, str)
    assert prompt.strip() != ""


# -------------------------
# Overview prompt
# -------------------------

def test_overview_prompt_success(service):
    compact = {
        "total_stations": 20,
        "overall_average_score": 75,
        "best_station_id": "S001",
        "worst_station_id": "S010",
        "low_performance_count": 3,
        "high_performance_count": 8,
        "most_common_issues": ["Queue Time", "Downtime"]
    }

    prompt = service._overview_prompt(compact)

    assert "20" in prompt
    assert "75" in prompt
    assert "S001" in prompt
    assert "Queue Time" in prompt


def test_overview_prompt_missing_data(service):
    compact = {
        "total_stations": 0,
        "overall_average_score": 0,
        "best_station_id": None,
        "worst_station_id": None,
        "low_performance_count": 0,
        "high_performance_count": 0,
        "most_common_issues": []
    }

    prompt = service._overview_prompt(compact)

    assert isinstance(prompt, str)
    assert prompt.strip() != ""


# -------------------------
# Compare prompt
# -------------------------

def test_compare_prompt_success(service):
    s1 = {
        "station_id": "S001",
        "score": 80,
        "issues": ["Queue Time"]
    }

    s2 = {
        "station_id": "S002",
        "score": 55,
        "issues": ["Downtime"]
    }

    prompt = service._compare_prompt(s1, s2)

    assert "S001" in prompt
    assert "S002" in prompt
    assert "80" in prompt
    assert "55" in prompt


def test_compare_prompt_missing_data(service):
    s1 = {
        "station_id": None,
        "score": 0,
        "issues": []
    }

    s2 = {
        "station_id": None,
        "score": 0,
        "issues": []
    }

    prompt = service._compare_prompt(s1, s2)

    assert isinstance(prompt, str)
    assert prompt.strip() != ""


# -------------------------
# Local station explanation
# -------------------------

def test_local_station_explanation_success(service):
    sample_data = {
        "station_id": "S001",
        "final_station_score": 72,
        "priority": "Medium",
        "best_time": {"time_slot": "Morning"},
        "worst_time": {"time_slot": "Night"},
        "main_issues": [
            {"issue": "Queue Time"}
        ],
        "recommended_actions": [
            {"action": "Increase staffing"}
        ]
    }

    result = service._local_station_explanation(sample_data)

    assert "S001" in result
    assert "72" in result
    assert "Queue Time" in result
    assert "Increase staffing" in result


def test_local_station_explanation_missing_data(service):
    sample_data = {}

    result = service._local_station_explanation(sample_data)

    assert isinstance(result, str)
    assert result.strip() != ""


# -------------------------
# Local overview explanation
# -------------------------

def test_local_overview_explanation_success(service):
    sample_data = {
        "total_stations": 15,
        "overall_average_score": 71,
        "best_station": {"station_id": "S001"},
        "worst_station": {"station_id": "S015"},
        "high_performance_count": 7,
        "low_performance_count": 3,
        "most_common_issues": [
            {"issue": "Queue Time"}
        ]
    }

    result = service._local_overview_explanation(sample_data)

    assert "15" in result
    assert "71" in result
    assert "S001" in result
    assert "Queue Time" in result


def test_local_overview_explanation_missing_data(service):
    sample_data = {}

    result = service._local_overview_explanation(sample_data)

    assert isinstance(result, str)
    assert result.strip() != ""


# -------------------------
# Clear cache
# -------------------------

def test_clear_explanation_cache_success(service):
    service.cached_overview_explanation = "cached"
    service.cached_station_explanations = {"S001": "data"}
    service.cached_compare_explanations = {"A_B": "data"}

    result = service.clear_explanation_cache()

    assert result["message"] == "Explanation cache cleared successfully"
    assert service.cached_overview_explanation is None
    assert service.cached_station_explanations == {}
    assert service.cached_compare_explanations == {}


def test_clear_explanation_cache_when_already_empty(service):
    service.cached_overview_explanation = None
    service.cached_station_explanations = {}
    service.cached_compare_explanations = {}

    result = service.clear_explanation_cache()

    assert result["message"] == "Explanation cache cleared successfully"
    assert service.cached_overview_explanation is None
    assert service.cached_station_explanations == {}
    assert service.cached_compare_explanations == {}