import pytest

from app.patterns.template.recommendation_model import RecommendationModel


@pytest.fixture
def model():
    return RecommendationModel()


# =========================
# preprocess tests
# =========================

def test_preprocess_success_returns_same_station_list(model):
    stations = [
        {"station_id": "S001", "downtime_minutes": 10},
        {"station_id": "S002", "downtime_minutes": 5},
    ]

    result = model.preprocess(stations)

    assert result == stations
    assert isinstance(result, list)


def test_preprocess_fail_with_none_input(model):
    result = model.preprocess(None)

    assert result is None


# =========================
# process tests
# =========================

def test_process_success_calls_recommendation_engine(monkeypatch, model):
    prepared_data = [
        {"station_id": "S001", "downtime_minutes": 10},
    ]

    fake_result = [
        {
            "station_id": "S001",
            "recommended_actions": [
                {"feature": "downtime_minutes", "action": "Reduce downtime"}
            ],
        }
    ]

    def fake_analyze(data):
        assert data == prepared_data
        return fake_result

    monkeypatch.setattr(model.engine, "analyze", fake_analyze)

    result = model.process(prepared_data)

    assert result == fake_result


def test_process_fail_when_engine_raises_error(monkeypatch, model):
    prepared_data = [
        {"station_id": "S001", "downtime_minutes": 10},
    ]

    def fake_analyze(data):
        raise RuntimeError("Recommendation engine failed")

    monkeypatch.setattr(model.engine, "analyze", fake_analyze)

    with pytest.raises(RuntimeError):
        model.process(prepared_data)


# =========================
# postprocess tests
# =========================

def test_postprocess_success_creates_report_with_recommendations(model):
    processed_result = [
        {
            "station_id": "S001",
            "recommended_actions": [
                {"feature": "downtime_minutes", "action": "Reduce downtime"},
                {"feature": "queue_time_avg", "action": "Improve queue flow"},
            ],
        },
        {
            "station_id": "S002",
            "recommended_actions": [
                {"feature": "complaints_count", "action": "Improve service quality"},
            ],
        },
    ]

    report = model.postprocess(processed_result)

    assert report.report_id == "recommendation_report"
    assert report.model_name == "RecommendationModel"
    assert report.summary == "Recommendation results generated from Model 2 engine"
    assert report.metrics["stations_analyzed"] == 2
    assert report.details["results"] == processed_result
    assert len(report.recommendations) == 3


def test_postprocess_fail_with_invalid_processed_result(model):
    invalid_result = None

    with pytest.raises(Exception):
        model.postprocess(invalid_result)


# =========================
# duplicate recommendations test
# =========================

def test_postprocess_success_removes_duplicate_recommendations(model):
    processed_result = [
        {
            "station_id": "S001",
            "recommended_actions": [
                {"feature": "downtime_minutes", "action": "Reduce downtime"},
                {"feature": "downtime_minutes", "action": "Reduce downtime"},
            ],
        },
        {
            "station_id": "S002",
            "recommended_actions": [
                {"feature": "downtime_minutes", "action": "Reduce downtime"},
            ],
        },
    ]

    report = model.postprocess(processed_result)

    assert len(report.recommendations) == 1
    assert report.recommendations[0]["feature"] == "downtime_minutes"
    assert report.recommendations[0]["action"] == "Reduce downtime"


def test_postprocess_success_empty_result(model):
    processed_result = []

    report = model.postprocess(processed_result)

    assert report.report_id == "recommendation_report"
    assert report.model_name == "RecommendationModel"
    assert report.metrics["stations_analyzed"] == 0
    assert report.details["results"] == []
    assert report.recommendations == []