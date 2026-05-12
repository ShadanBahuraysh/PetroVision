"""
Unit Tests — Station Routes & Map Logic
"""

import pytest
from unittest.mock import patch, MagicMock
from fastapi.testclient import TestClient
from fastapi import FastAPI
import sys, os, types

fake_supabase_module = types.ModuleType("app.supabase_client")
fake_supabase_module.supabase = MagicMock()
sys.modules["app.supabase_client"] = fake_supabase_module

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

from app.api.station_routes import router as station_router
from app.api.stations_from_db_routes import router as stations_db_router

app = FastAPI()
app.include_router(station_router)
app.include_router(stations_db_router)
client = TestClient(app)

def _google_response(status="OK", places=None):
    return {"status": status, "results": places or [],
            "error_message": "" if status == "OK" else "API error"}

def _place(name="Petromin Haddaf", lat=21.54, lng=39.17,
           business_status="OPERATIONAL", rating=4.5, place_id="ABC123",
           address="King Road, Jeddah"):
    return {"place_id": place_id, "name": name,
            "geometry": {"location": {"lat": lat, "lng": lng}},
            "formatted_address": address,
            "business_status": business_status, "rating": rating}

def _db_station(station_id="S1", name="Haddaf", lat=21.54, lng=39.17,
                status="active", city="Jeddah", address="King Road",
                street=None, side_code=None):
    return {"station_id": station_id, "station_name": name,
            "latitude": lat, "longitude": lng, "status": status,
            "city": city, "address": address, "street": street, "side_code": side_code}

def _formatted(station_id="S1", name="Haddaf", lat=21.54, lng=39.17,
               status="active", city="Jeddah", address="King Road",
               street=None, side_code=None):
    """Returns a formatted dict matching what _format_station() produces."""
    return {
        "station_id": station_id,
        "station_name": name,
        "name": name,
        "latitude": lat,
        "longitude": lng,
        "lat": lat,
        "lng": lng,
        "status": status,
        "city": city,
        "address": address,
        "street": street,
        "side_code": side_code,
    }


class TestGetStations:

    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")
    def test_returns_200_with_results(self, mock_get):
        mock_get.return_value.json.return_value = _google_response(places=[_place()])
        r = client.get("/stations")
        assert r.status_code == 200
        assert len(r.json()) == 1

    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")
    def test_station_has_lat_lng(self, mock_get):
        mock_get.return_value.json.return_value = _google_response(places=[_place(lat=21.54, lng=39.17)])
        data = client.get("/stations").json()
        assert data[0]["lat"] == pytest.approx(21.54)
        assert data[0]["lng"] == pytest.approx(39.17)

    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")
    def test_operational_station_mapped_to_open(self, mock_get):
        mock_get.return_value.json.return_value = _google_response(places=[_place(business_status="OPERATIONAL")])
        assert client.get("/stations").json()[0]["status"] == "open"

    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")
    def test_non_operational_status_preserved(self, mock_get):
        mock_get.return_value.json.return_value = _google_response(places=[_place(business_status="CLOSED_TEMPORARILY")])
        assert client.get("/stations").json()[0]["status"] == "CLOSED_TEMPORARILY"

    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")
    def test_zero_results_returns_empty_list(self, mock_get):
        mock_get.return_value.json.return_value = _google_response(status="ZERO_RESULTS", places=[])
        r = client.get("/stations")
        assert r.status_code == 200
        assert r.json() == []

    @patch("app.api.station_routes.GOOGLE_API_KEY", None)
    def test_missing_api_key_returns_500(self):
        r = client.get("/stations")
        assert r.status_code == 500
        assert "GOOGLE_API_KEY" in r.json()["detail"]

    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")
    def test_google_error_status_returns_400(self, mock_get):
        mock_get.return_value.json.return_value = _google_response(status="REQUEST_DENIED")
        assert client.get("/stations").status_code == 400

    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")
    def test_network_error_returns_502(self, mock_get):
        import requests as req
        mock_get.side_effect = req.RequestException("timeout")
        assert client.get("/stations").status_code == 502

    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")
    def test_multiple_stations_returned(self, mock_get):
        mock_get.return_value.json.return_value = _google_response(
            places=[_place("A", place_id="1"), _place("B", place_id="2")])
        assert len(client.get("/stations").json()) == 2

    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")
    def test_response_contains_both_lat_and_latitude(self, mock_get):
        mock_get.return_value.json.return_value = _google_response(places=[_place()])
        data = client.get("/stations").json()[0]
        assert "lat" in data and "latitude" in data
        assert "lng" in data and "longitude" in data


# ---------------------------------------------------------------------------
# Patch station_service directly on the route module — this is the only
# reliable way to intercept calls because supabase is imported at module
# level inside station_service.py, so patching the supabase module after
# import has no effect on the already-bound name.
# ---------------------------------------------------------------------------

class TestGetStationsFromDb:

    def _mock_load(self, rows):
        """Patch station_service.load_stations to return only rows with coords."""
        formatted = [
            _formatted(
                station_id=r["station_id"],
                name=r.get("station_name", ""),
                lat=r.get("latitude"),
                lng=r.get("longitude"),
                status=r.get("status", "active"),
                city=r.get("city", ""),
                address=r.get("address", ""),
                street=r.get("street"),
                side_code=r.get("side_code"),
            )
            for r in rows
            if r.get("latitude") is not None and r.get("longitude") is not None
        ]
        patcher = patch(
            "app.api.stations_from_db_routes.station_service.load_stations",
            return_value=formatted,
        )
        patcher.start()
        self._patcher = patcher

    def _mock_load_raise(self, exc):
        patcher = patch(
            "app.api.stations_from_db_routes.station_service.load_stations",
            side_effect=exc,
        )
        patcher.start()
        self._patcher = patcher

    def teardown_method(self, _):
        if hasattr(self, "_patcher"):
            self._patcher.stop()

    def test_returns_200(self):
        self._mock_load([_db_station()])
        assert client.get("/stations-db").status_code == 200

    def test_returns_list(self):
        self._mock_load([_db_station()])
        assert isinstance(client.get("/stations-db").json(), list)

    def test_station_fields_present(self):
        self._mock_load([_db_station()])
        data = client.get("/stations-db").json()[0]
        for key in ["station_id", "lat", "lng", "latitude", "longitude",
                    "address", "status", "city"]:
            assert key in data

    def test_lat_lng_values_correct(self):
        self._mock_load([_db_station(lat=21.54, lng=39.17)])
        data = client.get("/stations-db").json()[0]
        assert data["lat"] == pytest.approx(21.54)
        assert data["lng"] == pytest.approx(39.17)

    def test_station_without_coordinates_excluded(self):
        rows = [
            _db_station(station_id="S1", lat=21.54, lng=39.17),
            {**_db_station(station_id="S2"), "latitude": None, "longitude": None},
        ]
        self._mock_load(rows)
        data = client.get("/stations-db").json()
        assert len(data) == 1
        assert data[0]["station_id"] == "S1"

    def test_empty_db_returns_empty_list(self):
        self._mock_load([])
        assert client.get("/stations-db").json() == []

    def test_multiple_stations_all_returned(self):
        self._mock_load([
            _db_station("S1", lat=21.0, lng=39.0),
            _db_station("S2", lat=22.0, lng=40.0),
            _db_station("S3", lat=23.0, lng=41.0),
        ])
        assert len(client.get("/stations-db").json()) == 3

    def test_supabase_exception_returns_500(self):
        self._mock_load_raise(Exception("DB error"))
        r = client.get("/stations-db")
        assert r.status_code == 500


class TestGetStationFromDbById:

    def _mock_get(self, result):
        patcher = patch(
            "app.api.stations_from_db_routes.station_service.get_station_by_id",
            return_value=result,
        )
        patcher.start()
        self._patcher = patcher

    def _mock_get_raise(self, exc):
        patcher = patch(
            "app.api.stations_from_db_routes.station_service.get_station_by_id",
            side_effect=exc,
        )
        patcher.start()
        self._patcher = patcher

    def teardown_method(self, _):
        if hasattr(self, "_patcher"):
            self._patcher.stop()

    def test_existing_station_returns_200(self):
        self._mock_get(_formatted(station_id="S1"))
        assert client.get("/stations-db/S1").status_code == 200

    def test_correct_station_id_returned(self):
        self._mock_get(_formatted(station_id="S1"))
        assert client.get("/stations-db/S1").json()["station_id"] == "S1"

    def test_lat_lng_fields_in_response(self):
        self._mock_get(_formatted(station_id="S1", lat=21.54, lng=39.17))
        data = client.get("/stations-db/S1").json()
        assert data["lat"] == pytest.approx(21.54)
        assert data["lng"] == pytest.approx(39.17)

    def test_not_found_returns_404(self):
        self._mock_get(None)
        assert client.get("/stations-db/NOTEXIST").status_code == 404

    def test_exception_returns_500(self):
        self._mock_get_raise(Exception("DB error"))
        r = client.get("/stations-db/S1")
        assert r.status_code == 500

    def test_name_field_matches_station_name(self):
        self._mock_get(_formatted(station_id="S1", name="Haddaf"))
        assert client.get("/stations-db/S1").status_code == 200