import sys
from unittest.mock import MagicMock

mock_supabase = MagicMock()
sys.modules.setdefault("supabase", MagicMock())
sys.modules["app.supabase_client"] = MagicMock(supabase=mock_supabase)

"""
Integration tests for Station API routes and StationService.
Tests are aligned with the current implementation, where StationService returns
formatted dictionaries, not Station model objects.
"""

from types import SimpleNamespace
from unittest.mock import patch
import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient

from app.api import station_routes, stations_from_db_routes
from app.services.station_service import StationService
import app.services.station_service as station_service_module


app = FastAPI()
app.include_router(station_routes.router)
app.include_router(stations_from_db_routes.router)
client = TestClient(app)

STATION_ROWS = [
    {
        "station_id": "S001",
        "station_name": "Haddaf Jeddah",
        "latitude": 21.5433,
        "longitude": 39.1728,
        "address": "Haddaf Jeddah, Jeddah",
        "status": "active",
        "city": "Jeddah",
        "street": "King Road St",
        "side_code": "A1",
    },
    {
        "station_id": "S002",
        "station_name": "Riyadh Central",
        "latitude": 24.7136,
        "longitude": 46.6753,
        "address": "Riyadh Central, Riyadh",
        "status": "closed",
        "city": "Riyadh",
        "street": None,
        "side_code": None,
    },
    {
        "station_id": "S003",
        "station_name": "Missing Coordinates",
        "latitude": None,
        "longitude": None,
        "address": "Unknown",
        "status": "active",
        "city": "Jeddah",
        "street": None,
        "side_code": None,
    },
]

GOOGLE_PLACES = [
    {
        "place_id": "G001",
        "name": "Google Station 1",
        "formatted_address": "Jeddah, Saudi Arabia",
        "business_status": "OPERATIONAL",
        "rating": 4.5,
        "geometry": {"location": {"lat": 21.54, "lng": 39.17}},
    },
    {
        "place_id": "G002",
        "name": "Google Station 2",
        "formatted_address": "Riyadh, Saudi Arabia",
        "business_status": "CLOSED_TEMPORARILY",
        "rating": 3.9,
        "geometry": {"location": {"lat": 24.71, "lng": 46.67}},
    },
]


class FakeTable:
    def __init__(self, rows=None, error=None):
        self.rows = rows or []
        self.error = error
        self.filters = []

    def select(self, *args, **kwargs):
        return self

    def eq(self, key, value):
        self.filters.append((key, value))
        return self

    def execute(self):
        if self.error:
            raise self.error
        data = self.rows
        for key, value in self.filters:
            data = [row for row in data if row.get(key) == value]
        return SimpleNamespace(data=data)


class FakeSupabase:
    def __init__(self, rows=None, error=None):
        self.rows = rows or []
        self.error = error

    def table(self, name):
        assert name == "station"
        return FakeTable(self.rows, self.error)


def formatted_station(row):
    return StationService()._format_station(row)


# ===========================================================================
# Integration: /stations-db routes
# ===========================================================================
class TestGetStationsFromDbIntegration:
    def test_full_pipeline_returns_only_stations_with_coordinates(self, monkeypatch):
        expected = [formatted_station(STATION_ROWS[0]), formatted_station(STATION_ROWS[1])]
        monkeypatch.setattr(stations_from_db_routes.station_service, "load_stations", lambda: expected)

        response = client.get("/stations-db")

        assert response.status_code == 200
        assert len(response.json()) == 2

    def test_response_shape_matches_frontend_contract(self, monkeypatch):
        monkeypatch.setattr(stations_from_db_routes.station_service, "load_stations", lambda: [formatted_station(STATION_ROWS[0])])

        data = client.get("/stations-db").json()[0]

        required_keys = {"station_id", "station_name", "name", "latitude", "longitude", "lat", "lng", "address", "status", "city", "street", "side_code"}
        assert required_keys.issubset(data.keys())

    def test_lat_lng_and_latitude_longitude_are_same_value(self, monkeypatch):
        monkeypatch.setattr(stations_from_db_routes.station_service, "load_stations", lambda: [formatted_station(STATION_ROWS[0])])

        data = client.get("/stations-db").json()[0]

        assert data["lat"] == data["latitude"]
        assert data["lng"] == data["longitude"]

    def test_station_name_exposed_as_both_name_and_station_name(self, monkeypatch):
        monkeypatch.setattr(stations_from_db_routes.station_service, "load_stations", lambda: [formatted_station(STATION_ROWS[0])])

        data = client.get("/stations-db").json()[0]

        assert data["name"] == data["station_name"] == "Haddaf Jeddah"

    def test_correct_coordinates_flow_from_db_to_response(self, monkeypatch):
        monkeypatch.setattr(stations_from_db_routes.station_service, "load_stations", lambda: [formatted_station(STATION_ROWS[0])])

        data = client.get("/stations-db").json()[0]

        assert data["lat"] == pytest.approx(21.5433)
        assert data["lng"] == pytest.approx(39.1728)

    def test_status_flows_unchanged_from_db(self, monkeypatch):
        expected = [formatted_station(STATION_ROWS[0]), formatted_station(STATION_ROWS[1])]
        monkeypatch.setattr(stations_from_db_routes.station_service, "load_stations", lambda: expected)

        data = client.get("/stations-db").json()
        statuses = {station["station_id"]: station["status"] for station in data}

        assert statuses["S001"] == "active"
        assert statuses["S002"] == "closed"

    def test_optional_fields_flow_through(self, monkeypatch):
        expected = [formatted_station(STATION_ROWS[0]), formatted_station(STATION_ROWS[1])]
        monkeypatch.setattr(stations_from_db_routes.station_service, "load_stations", lambda: expected)

        data = client.get("/stations-db").json()
        s001 = next(station for station in data if station["station_id"] == "S001")
        s002 = next(station for station in data if station["station_id"] == "S002")

        assert s001["street"] == "King Road St"
        assert s002["street"] is None

    def test_empty_db_returns_empty_list_not_error(self, monkeypatch):
        monkeypatch.setattr(stations_from_db_routes.station_service, "load_stations", lambda: [])

        response = client.get("/stations-db")

        assert response.status_code == 200
        assert response.json() == []

    def test_db_failure_propagates_as_500(self, monkeypatch):
        def raise_error():
            raise Exception("Connection lost")

        monkeypatch.setattr(stations_from_db_routes.station_service, "load_stations", raise_error)

        response = client.get("/stations-db")

        assert response.status_code == 500
        assert response.json()["detail"] == "Unexpected station service error"

class TestGetStationFromDbIntegration:
    def test_existing_id_returns_correct_station(self, monkeypatch):
        monkeypatch.setattr(stations_from_db_routes.station_service, "get_station_by_id", lambda station_id: formatted_station(STATION_ROWS[0]))

        data = client.get("/stations-db/S001").json()

        assert data["station_id"] == "S001"
        assert data["station_name"] == "Haddaf Jeddah"

    def test_coordinates_flow_correctly_for_single_station(self, monkeypatch):
        monkeypatch.setattr(stations_from_db_routes.station_service, "get_station_by_id", lambda station_id: formatted_station(STATION_ROWS[1]))

        data = client.get("/stations-db/S002").json()

        assert data["lat"] == pytest.approx(24.7136)
        assert data["lng"] == pytest.approx(46.6753)

    def test_response_includes_all_required_fields(self, monkeypatch):
        monkeypatch.setattr(stations_from_db_routes.station_service, "get_station_by_id", lambda station_id: formatted_station(STATION_ROWS[0]))

        data = client.get("/stations-db/S001").json()

        required_keys = {"station_id", "station_name", "name", "latitude", "longitude", "lat", "lng", "address", "status", "city", "street", "side_code"}
        assert required_keys.issubset(data.keys())

    def test_unknown_id_returns_404(self, monkeypatch):
        monkeypatch.setattr(stations_from_db_routes.station_service, "get_station_by_id", lambda station_id: None)

        response = client.get("/stations-db/UNKNOWN")

        assert response.status_code == 404
        assert response.json()["detail"] == "Station not found"

    def test_db_failure_returns_500(self, monkeypatch):
        def raise_error(station_id):
            raise Exception("Timeout")

        monkeypatch.setattr(stations_from_db_routes.station_service, "get_station_by_id", raise_error)

        response = client.get("/stations-db/S001")

        assert response.status_code == 500
        assert response.json()["detail"] == "Unexpected error occurred while retrieving station data"

    def test_name_equals_station_name_in_single_response(self, monkeypatch):
        monkeypatch.setattr(stations_from_db_routes.station_service, "get_station_by_id", lambda station_id: formatted_station(STATION_ROWS[0]))

        data = client.get("/stations-db/S001").json()

        assert data["name"] == data["station_name"]


# ===========================================================================
# Integration: /stations Google Maps route
# ===========================================================================
class TestGetStationsIntegration:
    def _mock_google(self, status="OK", places=None):
        return {"status": status, "results": places or [], "error_message": ""}

    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")
    def test_google_results_flow_into_response(self, mock_get):
        mock_get.return_value.json.return_value = self._mock_google(places=GOOGLE_PLACES)

        data = client.get("/stations").json()

        assert len(data) == 2

    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")
    def test_operational_transformed_to_open_in_full_pipeline(self, mock_get):
        mock_get.return_value.json.return_value = self._mock_google(places=[GOOGLE_PLACES[0]])

        data = client.get("/stations").json()

        assert data[0]["status"] == "open"

    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")
    def test_closed_status_passes_through_unchanged(self, mock_get):
        mock_get.return_value.json.return_value = self._mock_google(places=[GOOGLE_PLACES[1]])

        data = client.get("/stations").json()

        assert data[0]["status"] == "CLOSED_TEMPORARILY"

    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")
    def test_coordinates_flow_from_google_to_response(self, mock_get):
        mock_get.return_value.json.return_value = self._mock_google(places=[GOOGLE_PLACES[0]])

        data = client.get("/stations").json()[0]

        assert data["lat"] == pytest.approx(21.54)
        assert data["latitude"] == pytest.approx(21.54)
        assert data["lng"] == pytest.approx(39.17)
        assert data["longitude"] == pytest.approx(39.17)

    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")
    def test_place_id_flows_as_station_id(self, mock_get):
        mock_get.return_value.json.return_value = self._mock_google(places=[GOOGLE_PLACES[0]])

        data = client.get("/stations").json()[0]

        assert data["station_id"] == "G001"
        assert data["place_id"] == "G001"

    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")
    def test_rating_flows_from_google_to_response(self, mock_get):
        mock_get.return_value.json.return_value = self._mock_google(places=[GOOGLE_PLACES[0]])

        data = client.get("/stations").json()[0]

        assert data["rating"] == pytest.approx(4.5)

    @patch("app.api.station_routes.GOOGLE_API_KEY", None)
    def test_missing_api_key_blocks_pipeline(self):
        response = client.get("/stations")

        assert response.status_code == 500

    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")
    def test_google_api_error_stops_pipeline_with_400(self, mock_get):
        mock_get.return_value.json.return_value = self._mock_google(status="REQUEST_DENIED")

        response = client.get("/stations")

        assert response.status_code == 400
        assert "google_status" in response.json()["detail"]

    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")
    def test_network_failure_returns_502(self, mock_get):
        import requests as req

        mock_get.side_effect = req.RequestException("timeout")

        response = client.get("/stations")

        assert response.status_code == 502

    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")
    def test_custom_query_passed_to_google(self, mock_get):
        mock_get.return_value.json.return_value = self._mock_google(places=[])

        client.get("/stations?query=Aramco+station+Riyadh")

        assert "Aramco station Riyadh" in str(mock_get.call_args)


# ===========================================================================
# Integration: StationService current behavior
# ===========================================================================
class TestStationServiceIntegration:
    def setup_method(self):
        self.service = StationService()

    def test_load_stations_returns_only_rows_with_coordinates(self, monkeypatch):
        monkeypatch.setattr(station_service_module, "supabase", FakeSupabase(STATION_ROWS))

        stations = self.service.load_stations()

        assert len(stations) == 2

    def test_load_stations_returns_formatted_dicts(self, monkeypatch):
        monkeypatch.setattr(station_service_module, "supabase", FakeSupabase(STATION_ROWS))

        stations = self.service.load_stations()

        assert all(isinstance(station, dict) for station in stations)
        assert stations[0]["name"] == stations[0]["station_name"]

    def test_load_stations_contains_jeddah_and_riyadh(self, monkeypatch):
        monkeypatch.setattr(station_service_module, "supabase", FakeSupabase(STATION_ROWS))

        stations = self.service.load_stations()
        cities = {station["city"] for station in stations}

        assert "Jeddah" in cities
        assert "Riyadh" in cities

    def test_get_station_by_id_returns_correct_station(self, monkeypatch):
        monkeypatch.setattr(station_service_module, "supabase", FakeSupabase(STATION_ROWS))

        station = self.service.get_station_by_id("S001")

        assert station is not None
        assert station["station_id"] == "S001"
        assert station["city"] == "Jeddah"

    def test_get_station_by_id_returns_none_for_unknown(self, monkeypatch):
        monkeypatch.setattr(station_service_module, "supabase", FakeSupabase(STATION_ROWS))

        station = self.service.get_station_by_id("UNKNOWN")

        assert station is None

    def test_get_station_by_id_with_string_id(self, monkeypatch):
        monkeypatch.setattr(station_service_module, "supabase", FakeSupabase(STATION_ROWS))

        station = self.service.get_station_by_id("S002")

        assert station is not None
        assert station["city"] == "Riyadh"

    def test_active_status_flows_as_dict_value(self, monkeypatch):
        monkeypatch.setattr(station_service_module, "supabase", FakeSupabase(STATION_ROWS))

        station = self.service.get_station_by_id("S001")

        assert station["status"] == "active"

    def test_closed_status_flows_as_dict_value(self, monkeypatch):
        monkeypatch.setattr(station_service_module, "supabase", FakeSupabase(STATION_ROWS))

        station = self.service.get_station_by_id("S002")

        assert station["status"] == "closed"

    def test_load_stations_and_get_by_id_return_equivalent_data(self, monkeypatch):
        monkeypatch.setattr(station_service_module, "supabase", FakeSupabase(STATION_ROWS))

        all_stations = self.service.load_stations()
        by_id = self.service.get_station_by_id("S001")

        assert by_id in all_stations

    def test_formatted_station_integrates_with_service(self, monkeypatch):
        monkeypatch.setattr(station_service_module, "supabase", FakeSupabase(STATION_ROWS))

        station = self.service.get_station_by_id("S001")

        assert station["station_id"] == "S001"
        assert station["city"] == "Jeddah"
        assert station["status"] == "active"
