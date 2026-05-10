import sys
from unittest.mock import MagicMock

mock_supabase = MagicMock()
sys.modules.setdefault("supabase", MagicMock())
sys.modules["app.supabase_client"] = MagicMock(supabase=mock_supabase)

"""
Integration tests for Loyalty and Offer API routes.
The tests call real FastAPI endpoints while replacing the Supabase dependency
with a lightweight fake object, so no real database is required.
"""

from types import SimpleNamespace
from fastapi import FastAPI
from fastapi.testclient import TestClient

from app.api import loyalty_routes, offer_routes

app = FastAPI()
app.include_router(loyalty_routes.router)
app.include_router(offer_routes.router)
client = TestClient(app)

FAKE_ACCOUNT = {"account_id": "LA-001", "user_id": "USR-001", "current_points": 100}
FAKE_OFFER = {
    "offer_id": "OFF-001",
    "name": "Coffee Discount",
    "category": "Coffee",
    "earn_points": 10,
    "redeem_points": 50,
    "earn_qr_code": "EFC-0001",
    "redeem_qr_code": "RFC-0001",
    "user_id": "USR-001",
}
FAKE_MEMBERSHIP = {"membership_id": "MEM-001", "account_id": "LA-001", "user_id": "USR-001", "tier": "Bronze", "status": "active"}
FAKE_TRANSACTION = {"transaction_id": "TRX-001", "account_id": "LA-001", "offer_id": "OFF-001", "type": "earn", "points": 10, "date": "2025-03-10T10:00:00"}


class FakeTable:
    def __init__(self, rows=None, insert_rows=None, update_rows=None):
        self.rows = rows or []
        self.insert_rows = insert_rows if insert_rows is not None else self.rows
        self.update_rows = update_rows if update_rows is not None else self.rows
        self.filters = []

    def select(self, *args, **kwargs):
        return self

    def eq(self, key, value):
        self.filters.append((key, value))
        return self

    def order(self, *args, **kwargs):
        return self

    def insert(self, *args, **kwargs):
        self.rows = self.insert_rows
        return self

    def update(self, *args, **kwargs):
        self.rows = self.update_rows
        return self

    def execute(self):
        data = self.rows
        for key, value in self.filters:
            data = [row for row in data if row.get(key) == value]
        return SimpleNamespace(data=data)


class FakeSupabase:
    def __init__(self, tables):
        self.tables = tables

    def table(self, name):
        value = self.tables.get(name, [])
        if isinstance(value, FakeTable):
            return value
        return FakeTable(value)


def patch_supabase(monkeypatch, tables):
    fake = FakeSupabase(tables)
    monkeypatch.setattr(loyalty_routes, "supabase", fake)
    monkeypatch.setattr(offer_routes, "supabase", fake)
    return fake


def test_get_points_success(monkeypatch):
    patch_supabase(monkeypatch, {"loyalty_account": [FAKE_ACCOUNT]})

    response = client.get("/loyalty/points/USR-001")

    assert response.status_code == 200
    assert response.json()["current_points"] == 100


def test_get_points_user_not_found(monkeypatch):
    patch_supabase(monkeypatch, {"loyalty_account": []})

    response = client.get("/loyalty/points/UNKNOWN")

    assert response.status_code == 404
    assert response.json()["detail"] == "No account found for this user"


def test_get_points_returns_zero_when_no_points(monkeypatch):
    account_no_points = {**FAKE_ACCOUNT, "current_points": 0}
    patch_supabase(monkeypatch, {"loyalty_account": [account_no_points]})

    response = client.get("/loyalty/points/USR-001")

    assert response.status_code == 200
    assert response.json()["current_points"] == 0


def test_earn_points_bronze(monkeypatch):
    patch_supabase(
        monkeypatch,
        {
            "offer": [FAKE_OFFER],
            "loyalty_account": FakeTable([FAKE_ACCOUNT], update_rows=[{**FAKE_ACCOUNT, "current_points": 110}]),
            "transactions": FakeTable([], insert_rows=[FAKE_TRANSACTION]),
        },
    )

    response = client.post("/loyalty/earn-points", json={"user_id": "USR-001", "amount": 100, "tier": "Bronze", "qr_code": "EFC-0001", "station_id": "STA-001"})

    assert response.status_code == 200
    assert response.json()["earned_points"] == 10
    assert response.json()["current_points"] == 110


def test_earn_points_silver_multiplier(monkeypatch):
    patch_supabase(
        monkeypatch,
        {
            "offer": [FAKE_OFFER],
            "loyalty_account": FakeTable([FAKE_ACCOUNT], update_rows=[{**FAKE_ACCOUNT, "current_points": 115}]),
            "transactions": FakeTable([], insert_rows=[FAKE_TRANSACTION]),
        },
    )

    response = client.post("/loyalty/earn-points", json={"user_id": "USR-001", "amount": 100, "tier": "Silver", "qr_code": "EFC-0001"})

    assert response.status_code == 200
    assert response.json()["earned_points"] >= 10


def test_earn_points_gold_multiplier(monkeypatch):
    patch_supabase(
        monkeypatch,
        {
            "offer": [FAKE_OFFER],
            "loyalty_account": FakeTable([FAKE_ACCOUNT], update_rows=[{**FAKE_ACCOUNT, "current_points": 120}]),
            "transactions": FakeTable([], insert_rows=[FAKE_TRANSACTION]),
        },
    )

    response = client.post("/loyalty/earn-points", json={"user_id": "USR-001", "amount": 100, "tier": "Gold", "qr_code": "EFC-0001"})

    assert response.status_code == 200
    assert response.json()["earned_points"] >= 10


def test_earn_points_invalid_qr(monkeypatch):
    patch_supabase(monkeypatch, {"offer": [], "loyalty_account": [FAKE_ACCOUNT]})

    response = client.post("/loyalty/earn-points", json={"user_id": "USR-001", "amount": 100, "tier": "Bronze", "qr_code": "BAD"})

    assert response.status_code == 404
    assert response.json()["detail"] == "Invalid QR code"


def test_earn_points_zero_amount_fails(monkeypatch):
    patch_supabase(monkeypatch, {})

    response = client.post("/loyalty/earn-points", json={"user_id": "USR-001", "amount": 0, "tier": "Bronze", "qr_code": "EFC-0001"})

    assert response.status_code == 400
    assert response.json()["detail"] == "Amount must be greater than zero"


def test_earn_points_already_used_offer(monkeypatch):
    patch_supabase(
        monkeypatch,
        {
            "offer": [FAKE_OFFER],
            "loyalty_account": [FAKE_ACCOUNT],
            "transactions": [FAKE_TRANSACTION],
        },
    )

    response = client.post("/loyalty/earn-points", json={"user_id": "USR-001", "amount": 100, "tier": "Bronze", "qr_code": "EFC-0001"})

    assert response.status_code == 400
    assert "already used" in response.json()["detail"]


def test_earn_points_account_not_found(monkeypatch):
    patch_supabase(monkeypatch, {"offer": [FAKE_OFFER], "loyalty_account": []})

    response = client.post("/loyalty/earn-points", json={"user_id": "USR-001", "amount": 100, "tier": "Bronze", "qr_code": "EFC-0001"})

    assert response.status_code == 404
    assert response.json()["detail"] == "Loyalty account not found"


def test_redeem_success(monkeypatch):
    patch_supabase(
        monkeypatch,
        {
            "loyalty_account": FakeTable([{**FAKE_ACCOUNT, "current_points": 500}], update_rows=[{**FAKE_ACCOUNT, "current_points": 300}]),
            "offer": [FAKE_OFFER],
            "transactions": FakeTable([], insert_rows=[FAKE_TRANSACTION]),
        },
    )

    response = client.post("/loyalty/redeem-points", json={"user_id": "USR-001", "points": 200, "offer_id": "OFF-001"})

    assert response.status_code == 200
    assert response.json()["current_points"] == 300


def test_redeem_insufficient_points(monkeypatch):
    patch_supabase(monkeypatch, {"loyalty_account": [{**FAKE_ACCOUNT, "current_points": 50}], "offer": [FAKE_OFFER]})

    response = client.post("/loyalty/redeem-points", json={"user_id": "USR-001", "points": 200, "offer_id": "OFF-001"})

    assert response.status_code == 400
    assert response.json()["detail"] == "Not enough points"


def test_redeem_user_not_found(monkeypatch):
    patch_supabase(monkeypatch, {"loyalty_account": [], "offer": [FAKE_OFFER]})

    response = client.post("/loyalty/redeem-points", json={"user_id": "USR-001", "points": 200, "offer_id": "OFF-001"})

    assert response.status_code == 404
    assert response.json()["detail"] == "Loyalty account not found"


def test_redeem_offer_not_found(monkeypatch):
    patch_supabase(monkeypatch, {"loyalty_account": [FAKE_ACCOUNT], "offer": []})

    response = client.post("/loyalty/redeem-points", json={"user_id": "USR-001", "points": 20, "offer_id": "OFF-404"})

    assert response.status_code == 404
    assert response.json()["detail"] == "Offer not found"


def test_get_membership_success(monkeypatch):
    patch_supabase(monkeypatch, {"loyalty_account": [FAKE_ACCOUNT], "membership": [FAKE_MEMBERSHIP]})

    response = client.get("/loyalty/membership/USR-001")

    assert response.status_code == 200
    assert response.json()["tier"] == "Bronze"


def test_get_membership_no_account(monkeypatch):
    patch_supabase(monkeypatch, {"loyalty_account": []})

    response = client.get("/loyalty/membership/USR-001")

    assert response.status_code == 404
    assert response.json()["detail"] == "No loyalty account found"


def test_get_membership_no_membership_returns_empty(monkeypatch):
    patch_supabase(monkeypatch, {"loyalty_account": [FAKE_ACCOUNT], "membership": []})

    response = client.get("/loyalty/membership/USR-001")

    assert response.status_code == 200
    assert response.json() == {}


def test_get_transactions_success(monkeypatch):
    patch_supabase(monkeypatch, {"loyalty_account": [FAKE_ACCOUNT], "transactions": [FAKE_TRANSACTION]})

    response = client.get("/loyalty/transactions/USR-001")

    assert response.status_code == 200
    assert response.json()[0]["transaction_id"] == "TRX-001"


def test_get_transactions_no_account(monkeypatch):
    patch_supabase(monkeypatch, {"loyalty_account": []})

    response = client.get("/loyalty/transactions/USR-001")

    assert response.status_code == 404
    assert response.json()["detail"] == "No loyalty account found"


def test_get_transactions_empty_list(monkeypatch):
    patch_supabase(monkeypatch, {"loyalty_account": [FAKE_ACCOUNT], "transactions": []})

    response = client.get("/loyalty/transactions/USR-001")

    assert response.status_code == 200
    assert response.json() == []


def test_admin_summary_success(monkeypatch):
    memberships = [{"tier": "Bronze"}, {"tier": "Silver"}, {"tier": "Gold"}, {"tier": "Bronze"}]
    transactions = [{"date": "2025-03-10T10:00:00", "type": "earn"}, {"date": "2025-03-15T10:00:00", "type": "redeem"}]
    customers = [{"user_id": "USR-001"}, {"user_id": "USR-002"}]
    patch_supabase(monkeypatch, {"customer": customers, "membership": memberships, "transactions": transactions})

    response = client.get("/loyalty/admin-summary?year=2025")

    assert response.status_code == 200
    data = response.json()
    assert data["total_customers"] == 2
    assert data["tier_distribution"]["Bronze"] == 2


def test_admin_summary_empty_data(monkeypatch):
    patch_supabase(monkeypatch, {"customer": [], "membership": [], "transactions": []})

    response = client.get("/loyalty/admin-summary?year=2025")

    assert response.status_code == 200
    assert response.json()["total_customers"] == 0


def test_admin_summary_with_month_filter(monkeypatch):
    transactions = [{"date": "2025-03-10T10:00:00", "type": "earn"}, {"date": "2025-04-15T10:00:00", "type": "redeem"}]
    patch_supabase(monkeypatch, {"customer": [], "membership": [], "transactions": transactions})

    response = client.get("/loyalty/admin-summary?year=2025&month=3")

    assert response.status_code == 200
    assert response.json()["member_growth"][2]["count"] == 1


def test_get_all_offers_success(monkeypatch):
    patch_supabase(monkeypatch, {"offer": [FAKE_OFFER]})

    response = client.get("/offers/")

    assert response.status_code == 200
    assert len(response.json()) == 1


def test_get_all_offers_empty(monkeypatch):
    patch_supabase(monkeypatch, {"offer": []})

    response = client.get("/offers/")

    assert response.status_code == 200
    assert response.json() == []


def test_get_user_offers_success(monkeypatch):
    patch_supabase(monkeypatch, {"offer": [FAKE_OFFER]})

    response = client.get("/offers/user/USR-001")

    assert response.status_code == 200
    assert response.json()[0]["user_id"] == "USR-001"


def test_get_user_offers_no_offers(monkeypatch):
    patch_supabase(monkeypatch, {"offer": []})

    response = client.get("/offers/user/USR-001")

    assert response.status_code == 200
    assert response.json() == []
