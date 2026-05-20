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

    # الـ response يحتوي على lat/lng/latitude/longitude كلهم — مهم لأن الـ Flutter يستخدمهم
    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")
    def test_response_contains_both_lat_and_latitude(self, mock_get):
        mock_get.return_value.json.return_value = _google_response(places=[_place()])
        data = client.get("/stations").json()[0]
        assert "lat" in data and "latitude" in data
        assert "lng" in data and "longitude" in data

    # المحطة اللي حالتها OPERATIONAL من Google تتحول إلى "open" في الـ response
    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")
    def test_operational_station_mapped_to_open(self, mock_get):
        mock_get.return_value.json.return_value = _google_response(places=[_place(business_status="OPERATIONAL")])
        assert client.get("/stations").json()[0]["status"] == "open"

    # الحالات غير OPERATIONAL تُرجع كما هي بدون تعديل
    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")
    def test_non_operational_status_preserved(self, mock_get):
        mock_get.return_value.json.return_value = _google_response(places=[_place(business_status="CLOSED_TEMPORARILY")])
        assert client.get("/stations").json()[0]["status"] == "CLOSED_TEMPORARILY"

    # لو Google ما رجع نتائج، الـ API يرجع list فارغة وليس خطأ
    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")
    def test_zero_results_returns_empty_list(self, mock_get):
        mock_get.return_value.json.return_value = _google_response(status="ZERO_RESULTS", places=[])
        r = client.get("/stations")
        assert r.status_code == 200
        assert r.json() == []

    # لو GOOGLE_API_KEY مو موجود، يرجع 500 مع رسالة واضحة
    @patch("app.api.station_routes.GOOGLE_API_KEY", None)
    def test_missing_api_key_returns_500(self):
        r = client.get("/stations")
        assert r.status_code == 500
        assert "GOOGLE_API_KEY" in r.json()["detail"]

    # لو Google رفض الطلب (REQUEST_DENIED)، يرجع 400
    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")
    def test_google_error_status_returns_400(self, mock_get):
        mock_get.return_value.json.return_value = _google_response(status="REQUEST_DENIED")
        assert client.get("/stations").status_code == 400

    # لو في مشكلة شبكة (timeout مثلاً)، يرجع 502
    @patch("app.api.station_routes.GOOGLE_API_KEY", "fake-key")
    @patch("app.api.station_routes.requests.get")
    def test_network_error_returns_502(self, mock_get):
        import requests as req
        mock_get.side_effect = req.RequestException("timeout")
        assert client.get("/stations").status_code == 502


class TestGetStationsFromDb:

    def _mock_load(self, rows):
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

    # يتحقق من قيم lat/lng الفعلية في الـ response
    def test_lat_lng_values_correct(self):
        self._mock_load([_db_station(lat=21.54, lng=39.17)])
        data = client.get("/stations-db").json()[0]
        assert data["lat"] == pytest.approx(21.54)
        assert data["lng"] == pytest.approx(39.17)

    # المحطات اللي ما عندها إحداثيات تُحذف من النتائج
    def test_station_without_coordinates_excluded(self):
        rows = [
            _db_station(station_id="S1", lat=21.54, lng=39.17),
            {**_db_station(station_id="S2"), "latitude": None, "longitude": None},
        ]
        self._mock_load(rows)
        data = client.get("/stations-db").json()
        assert len(data) == 1
        assert data[0]["station_id"] == "S1"

    # لو قاعدة البيانات فارغة، يرجع list فارغة وليس خطأ
    def test_empty_db_returns_empty_list(self):
        self._mock_load([])
        assert client.get("/stations-db").json() == []

    # كل المحطات اللي عندها إحداثيات تُرجع كاملة
    def test_multiple_stations_all_returned(self):
        self._mock_load([
            _db_station("S1", lat=21.0, lng=39.0),
            _db_station("S2", lat=22.0, lng=40.0),
            _db_station("S3", lat=23.0, lng=41.0),
        ])
        assert len(client.get("/stations-db").json()) == 3

    # لو Supabase رمى exception، يرجع 500
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

    # المحطة الموجودة ترجع 200
    def test_existing_station_returns_200(self):
        self._mock_get(_formatted(station_id="S1"))
        assert client.get("/stations-db/S1").status_code == 200

    # لو الـ ID مو موجود في قاعدة البيانات، يرجع 404
    def test_not_found_returns_404(self):
        self._mock_get(None)
        assert client.get("/stations-db/NOTEXIST").status_code == 404

    # لو Supabase رمى exception أثناء جلب المحطة، يرجع 500
    def test_exception_returns_500(self):
        self._mock_get_raise(Exception("DB error"))
        r = client.get("/stations-db/S1")
        assert r.status_code == 500