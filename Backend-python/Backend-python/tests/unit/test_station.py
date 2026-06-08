import pytest
import sys
import os

# Allow importing station model directly
sys.path.insert(0, os.path.join(os.path.dirname(__file__)))

# ---------------------------------------------------------------------------
# Inline copy of the model so tests run without the full backend installed.
# Replace with: from app.models.station import Station
# ---------------------------------------------------------------------------
class Station:
    def __init__(
        self,
        station_id,
        station_name=None,
        name=None,
        city=None,
        address=None,
        latitude=None,
        longitude=None,
        status="active",
        rating=None,
    ):
        self.station_id = station_id
        self.station_name = station_name or name
        self.city = city
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.status = status
        self.rating = rating

    def is_active(self):
        return str(self.status).lower() in ["active", "open", "operational"]

    def to_dict(self):
        return {
            "station_id": self.station_id,
            "station_name": self.station_name,
            "city": self.city,
            "address": self.address,
            "latitude": self.latitude,
            "longitude": self.longitude,
            "status": self.status,
            "rating": self.rating,
        }


# ===========================================================================
# Tests for Station.is_active()
# ===========================================================================
class TestIsActive:
    """Station.is_active() should return True for active/open/operational
    and False for anything else."""

    def test_active_lowercase(self):
        s = Station(1, status="active")
        assert s.is_active() is True

    def test_active_uppercase(self):
        """Status comparison must be case-insensitive."""
        s = Station(4, status="ACTIVE")
        assert s.is_active() is True

    def test_open_mixed_case(self):
        s = Station(5, status="Open")
        assert s.is_active() is True

    def test_closed_returns_false(self):
        s = Station(6, status="closed")
        assert s.is_active() is False

    def test_maintenance_returns_false(self):
        s = Station(8, status="maintenance")
        assert s.is_active() is False

    def test_default_status_is_active(self):
        """Default status is 'active', so is_active() should be True."""
        s = Station(10)
        assert s.is_active() is True


# ===========================================================================
# Tests for Station.to_dict()
# ===========================================================================
class TestToDict:
    """to_dict() must return a plain dict with all expected keys and values."""

    def _make_station(self):
        return Station(
            station_id=42,
            station_name="Haddaf",
            city="Jeddah",
            address="King Road",
            latitude=21.5433,
            longitude=39.1728,
            status="active",
            rating=4.8,
        )

    def test_returns_dict(self):
        assert isinstance(self._make_station().to_dict(), dict)

    def test_all_keys_present(self):
        keys = self._make_station().to_dict().keys()
        expected = {
            "station_id", "station_name", "city", "address",
            "latitude", "longitude", "status", "rating",
        }
        assert expected == set(keys)

    def test_values_match(self):
        d = self._make_station().to_dict()
        assert d["station_id"] == 42
        assert d["station_name"] == "Haddaf"
        assert d["city"] == "Jeddah"
        assert d["address"] == "King Road"
        assert d["latitude"] == pytest.approx(21.5433)
        assert d["longitude"] == pytest.approx(39.1728)
        assert d["status"] == "active"
        assert d["rating"] == pytest.approx(4.8)

    def test_none_values_preserved(self):
        """Fields left as None should appear as None in the dict."""
        s = Station(station_id=1)
        d = s.to_dict()
        assert d["station_name"] is None
        assert d["city"] is None
        assert d["rating"] is None


    def test_dict_is_independent_copy(self):
        """Mutating the returned dict should not affect the original object."""
        s = self._make_station()
        d = s.to_dict()
        d["city"] = "Riyadh"
        assert s.city == "Jeddah"
