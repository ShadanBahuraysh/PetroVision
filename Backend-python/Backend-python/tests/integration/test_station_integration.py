import pytest
import sys
import os
import types
from unittest.mock import MagicMock, patch
from fastapi import FastAPI
from fastapi.testclient import TestClient

# ---------------------------------------------------------------------------
# Stub supabase_client before any app import
# ---------------------------------------------------------------------------
fake_supabase_module = types.ModuleType("app.supabase_client")
fake_supabase_module.supabase = MagicMock()
sys.modules["app.supabase_client"] = fake_supabase_module

PROJECT_ROOT = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "..")
)
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

from app.api.station_routes import router as station_router
from app.api.stations_from_db_routes import router as stations_db_router
from app.services.station_service import StationService

app = FastAPI()
app.include_router(station_router)
app.include_router(stations_db_router)
client = TestClient(app)

# ---------------------------------------------------------------------------
# Shared test data
# ---------------------------------------------------------------------------
STATION_ROWS = [
    {
        "station_id": "S001",
        "station_name": "Haddaf Jeddah",
        "latitude": 21.5433,
        "longitude": 39.1728,
        "status": "active",
        "city": "Jeddah",
        "address": "King Road",
        "street": "King Road St",
        "side_code": "A1",
    },
    {
        "station_id": "S002",
        "station_name": "Petromin Riyadh",
        "latitude": 24.7136,
        "longitude": 46.6753,
        "status": "closed",
        "city": "Riyadh",
        "address": "Olaya St",
        "street": None,
        "side_code": None,
    },
    {
        "station_id": "S003",
        "station_name": "No Coords Station",
        "latitude": None,
        "longitude": None,
        "status": "active",
        "city": "Mecca",
        "address": "Unknown",
        "street": None,
        "side_code": None,
    },
]

GOOGLE_PLACES = [
    {
        "place_id": "G001",
        "name": "Petromin Jeddah",
        "geometry": {"location": {"lat": 21.54, "lng": 39.17}},
        "formatted_address": "King Road, Jeddah",
        "business_status": "OPERATIONAL",
        "rating": 4.5,
    },
    {
        "place_id": "G002",
        "name": "Petromin Riyadh",
        "geometry": {"location": {"lat": 24.71, "lng": 46.67}},
        "formatted_address": "Olaya St, Riyadh",
        "business_status": "CLOSED_TEMPORARILY",
        "rating": 3.9,
    },
]


# ===========================================================================
# Integration: get_stations_from_db  (/stations-db)
# ===========================================================================
class TestGetStationsFromDbIntegration:
    """
    Tests the full pipeline:
    HTTP GET /stations-db → route → supabase.table("station").select("*") → filter → response
    """

    def _mock_db(self, rows):
        mock_result = MagicMock()
        mock_result.data = rows
        fake_supabase_module.supabase.table.return_value \
            .select.return_value.execute.return_value = mock_result

    def test_full_pipeline_returns_only_stations_with_coordinates(self):
        """
        Integration: DB returns 3 rows, one without coordinates.
        Route must filter it and return only 2.
        """
        self._mock_db(STATION_ROWS)
        r = client.get("/stations-db")
        assert r.status_code == 200
        data = r.json()
        assert len(data) == 2

    def test_response_shape_matches_frontend_contract(self):
        """
        Integration: Frontend expects lat/lng AND latitude/longitude in every station.
        Route must include both forms in the response.
        """
        self._mock_db(STATION_ROWS[:1])
        data = client.get("/stations-db").json()[0]
        for key in ["lat", "lng", "latitude", "longitude",
                    "station_id", "station_name", "name",
                    "address", "status", "city", "street", "side_code"]:
            assert key in data, f"Missing key: {key}"


    def test_station_name_exposed_as_both_name_and_station_name(self):
        """
        Integration: Route exposes station_name under both 'name' and
        'station_name' keys for backwards compatibility.
        """
        self._mock_db(STATION_ROWS[:1])
        data = client.get("/stations-db").json()[0]
        assert data["name"] == data["station_name"] == "Haddaf Jeddah"

    def test_correct_coordinates_flow_from_db_to_response(self):
        """
        Integration: Coordinates stored in DB must arrive unchanged in the response.
        """
        self._mock_db(STATION_ROWS[:1])
        data = client.get("/stations-db").json()[0]
        assert data["lat"] == pytest.approx(21.5433)
        assert data["lng"] == pytest.approx(39.1728)

    def test_status_flows_unchanged_from_db(self):
        """
        Integration: Status value in DB must not be transformed by the route.
        """
        self._mock_db(STATION_ROWS[:2])
        data = client.get("/stations-db").json()
        statuses = {s["station_id"]: s["status"] for s in data}
        assert statuses["S001"] == "active"
        assert statuses["S002"] == "closed"

    def test_optional_fields_flow_through(self):
        """
        Integration: street and side_code are optional — must appear in response
        whether they are filled or None.
        """
        self._mock_db(STATION_ROWS[:2])
        data = client.get("/stations-db").json()
        s001 = next(s for s in data if s["station_id"] == "S001")
        s002 = next(s for s in data if s["station_id"] == "S002")
        assert s001["street"] == "King Road St"
        assert s001["side_code"] == "A1"
        assert s002["street"] is None
        assert s002["side_code"] is None

    def test_empty_db_returns_empty_list_not_error(self):
        """
        Integration: Empty DB must return [] with 200, not 404 or 500.
        """
        self._mock_db([])
        r = client.get("/stations-db")
        assert r.status_code == 200
        assert r.json() == []

    def test_db_failure_propagates_as_500(self):
        """
        Integration: If Supabase throws, the route must catch it and return 500
        instead of crashing.
        """
        fake_supabase_module.supabase.table.return_value \
            .select.return_value.execute.side_effect = Exception("Connection lost")
        r = client.get("/stations-db")
        assert r.status_code == 500
        # Reset side_effect for subsequent tests
        fake_supabase_module.supabase.table.return_value \
            .select.return_value.execute.side_effect = None


# ===========================================================================
# Integration: get_station_from_db  (/stations-db/{station_id})
# ===========================================================================
class TestGetStationFromDbIntegration:
    """
    Tests the full pipeline:
    HTTP GET /stations-db/{id} → route → supabase.table.eq(id) → response
    """

    def _mock_by_id(self, rows):
        mock_result = MagicMock()
        mock_result.data = rows
        mock_execute = fake_supabase_module.supabase.table.return_value \
            .select.return_value.eq.return_value.execute
        mock_execute.side_effect = None
        mock_execute.return_value = mock_result

    def test_existing_id_returns_correct_station(self):
        """
        Integration: Requesting S001 must return exactly the S001 data.
        """
        self._mock_by_id([STATION_ROWS[0]])
        data = client.get("/stations-db/S001").json()
        assert data["station_id"] == "S001"
        assert data["station_name"] == "Haddaf Jeddah"
    

    def test_unknown_id_returns_404(self):
        """
        Integration: Requesting an ID not in the DB must return 404,
        not 200 with empty data.
        """
        self._mock_by_id([])
        r = client.get("/stations-db/UNKNOWN")
        assert r.status_code == 404
        assert "not found" in r.json()["detail"].lower()

    def test_db_failure_returns_500(self):
        """
        Integration: DB error on single-station lookup must return 500.
        """
        mock_execute = fake_supabase_module.supabase.table.return_value \
            .select.return_value.eq.return_value.execute
        mock_execute.side_effect = Exception("Timeout")
        r = client.get("/stations-db/S001")
        assert r.status_code == 500
        mock_execute.side_effect = None

# ===========================================================================
# Integration: get_stations  (/stations) — Google Maps API
# ===========================================================================
class TestGetStationsIntegration:
    """
    Tests the full pipeline:
    HTTP GET /stations → route → Google Maps API → transform → response
    """

    def _mock_google(self, status="OK", places=None):
        return {"status": status, "results": places or [], "error_message": ""}

    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")
    def test_google_results_flow_into_response(self, mock_get):
        """
        Integration: Two places from Google must produce two stations in response.
        """
        mock_get.return_value.json.return_value = self._mock_google(
            places=GOOGLE_PLACES
        )
        data = client.get("/stations").json()
        assert len(data) == 2

    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")
    def test_operational_transformed_to_open_in_full_pipeline(self, mock_get):
        """
        Integration: OPERATIONAL from Google must become 'open' in the
        response the frontend consumes.
        """
        mock_get.return_value.json.return_value = self._mock_google(
            places=[GOOGLE_PLACES[0]]
        )
        data = client.get("/stations").json()
        assert data[0]["status"] == "open"

    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")
    def test_closed_status_passes_through_unchanged(self, mock_get):
        """
        Integration: Non-OPERATIONAL status must pass through as-is.
        """
        mock_get.return_value.json.return_value = self._mock_google(
            places=[GOOGLE_PLACES[1]]
        )
        data = client.get("/stations").json()
        assert data[0]["status"] == "CLOSED_TEMPORARILY"

    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")
    def test_coordinates_flow_from_google_to_response(self, mock_get):
        """
        Integration: Coordinates from Google geometry must appear in both
        lat/lng and latitude/longitude.
        """
        mock_get.return_value.json.return_value = self._mock_google(
            places=[GOOGLE_PLACES[0]]
        )
        data = client.get("/stations").json()[0]
        assert data["lat"] == pytest.approx(21.54)
        assert data["latitude"] == pytest.approx(21.54)
        assert data["lng"] == pytest.approx(39.17)
        assert data["longitude"] == pytest.approx(39.17)

    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")
    def test_place_id_flows_as_station_id(self, mock_get):
        """
        Integration: Google's place_id must become the station_id in the response.
        """
        mock_get.return_value.json.return_value = self._mock_google(
            places=[GOOGLE_PLACES[0]]
        )
        data = client.get("/stations").json()[0]
        assert data["station_id"] == "G001"
        assert data["place_id"] == "G001"

    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")

    def test_rating_flows_from_google_to_response(self, mock_get):
        """
        Integration: Rating from Google must appear in the response.
        """
        mock_get.return_value.json.return_value = self._mock_google(
            places=[GOOGLE_PLACES[0]]
        )
        data = client.get("/stations").json()[0]
        assert data["rating"] == pytest.approx(4.5)

    @patch("app.api.station_routes.GOOGLE_API_KEY", None)
    def test_missing_api_key_blocks_pipeline(self):
        """
        Integration: Missing API key must stop the pipeline at the route
        level and return 500 before any Google call is made.
        """
        r = client.get("/stations")
        assert r.status_code == 500

    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")
    def test_google_api_error_stops_pipeline_with_400(self, mock_get):
        """
        Integration: Google error status must return 400 with google_status detail.
        """
        mock_get.return_value.json.return_value = self._mock_google(
            status="REQUEST_DENIED"
        )
        r = client.get("/stations")
        assert r.status_code == 400
        assert "google_status" in r.json()["detail"]

    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")
    def test_network_failure_returns_502(self, mock_get):
        """
        Integration: Network timeout to Google must return 502 Bad Gateway.
        """
        import requests as req
        mock_get.side_effect = req.RequestException("timeout")
        r = client.get("/stations")
        assert r.status_code == 502

    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")
    def test_custom_query_passed_to_google(self, mock_get):
        """
        Integration: Custom query param must be forwarded to Google API call.
        """
        mock_get.return_value.json.return_value = self._mock_google(places=[])
        client.get("/stations?query=Aramco+station+Riyadh")
        call_kwargs = mock_get.call_args
        assert "Aramco station Riyadh" in str(call_kwargs)


# ===========================================================================
# Integration: StationService — load_stations & get_station_by_id
# ===========================================================================
class TestStationServiceIntegration:
    """
    Tests the StationService layer using a mocked Supabase client.
    StationService calls supabase directly; we mock the DB result at the
    boundary so the full service logic (filtering, formatting) is exercised.
    """

    # Seed rows that the fake DB will return
    _DB_ROWS = [
        {
            "station_id": "S001",
            "station_name": "Haddaf Jeddah",
            "latitude": 21.5433,
            "longitude": 39.1728,
            "status": "Open",
            "city": "Jeddah",
            "address": "King Road",
            "street": "King Road St",
            "side_code": "A1",
        },
        {
            "station_id": "S002",
            "station_name": "Petromin Riyadh",
            "latitude": 24.7136,
            "longitude": 46.6753,
            "status": "Closed",
            "city": "Riyadh",
            "address": "Olaya St",
            "street": None,
            "side_code": None,
        },
        {
            "station_id": "S003",
            "station_name": "Gulf Station Mecca",
            "latitude": 21.3891,
            "longitude": 39.8579,
            "status": "active",
            "city": "Mecca",
            "address": "Haram Road",
            "street": None,
            "side_code": None,
        },
    ]

    def _mock_all(self, rows=None):
        """Mock supabase.table().select().execute() to return rows."""
        rows = rows if rows is not None else self._DB_ROWS
        mock_result = MagicMock()
        mock_result.data = rows
        fake_supabase_module.supabase.table.return_value \
            .select.return_value.execute.return_value = mock_result

    def _mock_by_id(self, rows):
        """Mock supabase.table().select().eq().execute() to return rows."""
        mock_result = MagicMock()
        mock_result.data = rows
        fake_supabase_module.supabase.table.return_value \
            .select.return_value.eq.return_value.execute.side_effect = None
        fake_supabase_module.supabase.table.return_value \
            .select.return_value.eq.return_value.execute.return_value = mock_result

    def setup_method(self):
        self.service = StationService()

    def test_load_stations_returns_all_stations(self):
        """
        Integration: load_stations must return all rows that have coordinates (3 here).
        """
        self._mock_all()
        stations = self.service.load_stations()
        assert len(stations) == 3


    def test_get_station_by_id_returns_correct_station(self):
        """
        Integration: get_station_by_id("S001") must return the Jeddah station.
        """
        self._mock_by_id([self._DB_ROWS[0]])
        station = self.service.get_station_by_id("S001")
        assert station is not None
        assert station["station_id"] == "S001"
        assert station["city"] == "Jeddah"

    def test_get_station_by_id_returns_none_for_unknown(self):
        """
        Integration: get_station_by_id with unknown ID must return None.
        """
        self._mock_by_id([])
        station = self.service.get_station_by_id("UNKNOWN")
        assert station is None

    def test_open_station_is_active(self):
        """
        Integration: Station with status "Open" must have is_active-like status.
        The service returns a dict; status "Open" is truthy and non-empty.
        """
        self._mock_by_id([self._DB_ROWS[0]])
        station = self.service.get_station_by_id("S001")
        assert station["status"].lower() in ["active", "open", "operational"]

    def test_closed_station_is_not_active(self):
        """
        Integration: Station with status "Closed" must not be active.
        """
        self._mock_by_id([self._DB_ROWS[1]])
        station = self.service.get_station_by_id("S002")
        assert station["status"].lower() not in ["active", "open", "operational"]   