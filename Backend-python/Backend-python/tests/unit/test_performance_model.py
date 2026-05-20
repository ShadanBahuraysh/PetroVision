import pandas as pd
import pytest

from app.patterns.template.performance_model import PerformanceModel


@pytest.fixture
def model():
    return PerformanceModel()


# =========================
# preprocess tests
# =========================

def test_preprocess_valid_list_converts_to_dataframe(model):
    stations = [
        {"station_id": "S001", "transactions_count": 120, "downtime_minutes": 5},
        {"station_id": "S002", "transactions_count": 90, "downtime_minutes": 10},
    ]

    result = model.preprocess(stations)

    assert isinstance(result, pd.DataFrame)
    assert len(result) == 2
    assert "station_id" in result.columns
    assert result.iloc[0]["station_id"] == "S001"


def test_preprocess_invalid_input_raises_error(model):
    invalid_data = "invalid input"

    with pytest.raises(Exception):
        model.preprocess(invalid_data)


# =========================
# process tests
# =========================

def test_process_valid_data_calls_predictor(monkeypatch, model):
    prepared_data = pd.DataFrame([
        {"station_id": "S001", "transactions_count": 120},
        {"station_id": "S002", "transactions_count": 90},
    ])

    def fake_predict(data):
        assert isinstance(data, pd.DataFrame)
        return [75.5, 82.3]

    monkeypatch.setattr(model.predictor, "predict", fake_predict)

    result = model.process(prepared_data)

    assert result == [75.5, 82.3]


def test_process_invalid_data_raises_error(monkeypatch, model):
    invalid_data = None

    def fake_predict(data):
        raise ValueError("Invalid prepared data")

    monkeypatch.setattr(model.predictor, "predict", fake_predict)

    with pytest.raises(ValueError):
        model.process(invalid_data)


# =========================
# postprocess tests
# =========================

def test_postprocess_valid_predictions(model):
    predictions = [75.456, 82.344, 60.111]

    report = model.postprocess(predictions)

    assert report.report_id == "performance_report"
    assert report.model_name == "PerformanceModel"
    assert report.summary == "Predicted station performance"
    assert report.metrics["average_performance_score"] == 72.64
    assert report.details["predictions"] == [75.46, 82.34, 60.11]


def test_postprocess_empty_predictions_returns_zero_report(model):
    predictions = []

    report = model.postprocess(predictions)

    assert report.report_id == "performance_report"
    assert report.model_name == "PerformanceModel"
    assert report.summary == "No prediction results available"
    assert report.metrics["average_performance_score"] == 0.0
    assert report.details["predictions"] == []


def test_postprocess_string_number_predictions(model):
    predictions = ["70.555", "80.444"]

    report = model.postprocess(predictions)

    assert report.details["predictions"] == [70.56, 80.44]
    assert report.metrics["average_performance_score"] == 75.5


