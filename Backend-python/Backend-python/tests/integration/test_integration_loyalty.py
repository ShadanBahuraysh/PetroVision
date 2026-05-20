import sys
from unittest.mock import MagicMock
from types import SimpleNamespace

mock_supabase = MagicMock()
sys.modules.setdefault("supabase", MagicMock())
sys.modules["app.supabase_client"] = MagicMock(supabase=mock_supabase)

from fastapi import FastAPI
from fastapi.testclient import TestClient
from app.api import loyalty_routes, offer_routes

app = FastAPI()
app.include_router(loyalty_routes.router)
app.include_router(offer_routes.router)
client = TestClient(app)

# ======= Fake data ========

FAKE_ACCOUNT     = {"account_id": "LA-001", "user_id": "USR-001", "current_points": 100}
FAKE_OFFER       = {"offer_id": "OFF-001", "name": "Coffee Discount", "category": "Coffee",
                    "earn_points": 10, "redeem_points": 50,
                    "earn_qr_code": "EFC-0001", "redeem_qr_code": "RFC-0001", "user_id": "USR-001"}
FAKE_MEMBERSHIP  = {"membership_id": "MEM-001", "account_id": "LA-001",
                    "user_id": "USR-001", "tier": "Bronze", "status": "active"}
FAKE_TRANSACTION = {"transaction_id": "TRX-001", "account_id": "LA-001",
                    "offer_id": "OFF-001", "type": "earn", "points": 10,
                    "date": "2025-03-10T10:00:00"}

# ======== FakeTable ========

class FakeTable:
    def __init__(self, rows=None, insert_rows=None, update_rows=None):
        self.rows        = rows or []
        self.insert_rows = insert_rows if insert_rows is not None else self.rows
        self.update_rows = update_rows if update_rows is not None else self.rows
        self.filters     = []

    def select(self, *a, **kw): return self
    def eq(self, key, value):   self.filters.append((key, value)); return self
    def order(self, *a, **kw):  return self

    def insert(self, *a, **kw): self.rows = self.insert_rows; return self
    def update(self, *a, **kw): self.rows = self.update_rows; return self

    def execute(self):
        data = self.rows
        for key, value in self.filters:
            data = [r for r in data if r.get(key) == value]
        return SimpleNamespace(data=data)

class FakeSupabase:
    def __init__(self, tables):
        self.tables = tables

    def table(self, name):
        value = self.tables.get(name, [])
        return value if isinstance(value, FakeTable) else FakeTable(value)

def patch_supabase(monkeypatch, tables):
    fake = FakeSupabase(tables)
    monkeypatch.setattr(loyalty_routes, "supabase", fake)
    monkeypatch.setattr(offer_routes,   "supabase", fake)

# ══════════════════════════════════════════════════════════════════════════════
# Points
# ══════════════════════════════════════════════════════════════════════════════

def test_get_points_success(monkeypatch):
    """Happy path ??? returns balance for a known user."""
    patch_supabase(monkeypatch, {"loyalty_account": [FAKE_ACCOUNT]})
    res = client.get("/loyalty/points/USR-001")
    assert res.status_code == 200
    assert res.json()["current_points"] == 100

def test_get_points_user_not_found(monkeypatch):
    """Unknown user ??? 404."""
    patch_supabase(monkeypatch, {"loyalty_account": []})
    res = client.get("/loyalty/points/UNKNOWN")
    assert res.status_code == 404

# ══════════════════════════════════════════════════════════════════════════════
# Earn points
# ══════════════════════════════════════════════════════════════════════════════

def test_earn_points_success(monkeypatch):
    """Valid QR + valid account ??? points added, transaction created."""
    patch_supabase(monkeypatch, {
        "offer":           [FAKE_OFFER],
        "loyalty_account": FakeTable([FAKE_ACCOUNT],
                                     update_rows=[{**FAKE_ACCOUNT, "current_points": 110}]),
        "transactions":    FakeTable([], insert_rows=[FAKE_TRANSACTION]),
        "membership":      [FAKE_MEMBERSHIP],
    })
    res = client.post("/loyalty/earn-points", json={
        "user_id": "USR-001", "amount": 100,
        "tier": "Bronze", "qr_code": "EFC-0001"
    })
    assert res.status_code == 200
    assert res.json()["earned_points"] == 10
    assert res.json()["current_points"] == 110

def test_earn_points_invalid_qr(monkeypatch):
    """Bad QR code ??? 404 before any points logic runs."""
    patch_supabase(monkeypatch, {"offer": [], "loyalty_account": [FAKE_ACCOUNT]})
    res = client.post("/loyalty/earn-points", json={
        "user_id": "USR-001", "amount": 100,
        "tier": "Bronze", "qr_code": "BAD-QR"
    })
    assert res.status_code == 404

def test_earn_points_zero_amount_rejected(monkeypatch):
    """Amount of 0 is a business rule violation ??? 400."""
    patch_supabase(monkeypatch, {})
    res = client.post("/loyalty/earn-points", json={
        "user_id": "USR-001", "amount": 0,
        "tier": "Bronze", "qr_code": "EFC-0001"
    })
    assert res.status_code == 400

def test_earn_points_already_used_offer(monkeypatch):
    """Same offer used twice by same user ??? 400."""
    patch_supabase(monkeypatch, {
        "offer":           [FAKE_OFFER],
        "loyalty_account": [FAKE_ACCOUNT],
        "transactions":    [FAKE_TRANSACTION],   # existing earn record
    })
    res = client.post("/loyalty/earn-points", json={
        "user_id": "USR-001", "amount": 100,
        "tier": "Bronze", "qr_code": "EFC-0001"
    })
    assert res.status_code == 400
    assert "already used" in res.json()["detail"]

# ══════════════════════════════════════════════════════════════════════════════
# Redeem points
# ══════════════════════════════════════════════════════════════════════════════

def test_redeem_success(monkeypatch):
    """Enough points + valid offer ??? balance reduced."""
    patch_supabase(monkeypatch, {
        "loyalty_account": FakeTable([{**FAKE_ACCOUNT, "current_points": 500}],
                                     update_rows=[{**FAKE_ACCOUNT, "current_points": 300}]),
        "offer":        [FAKE_OFFER],
        "transactions": FakeTable([], insert_rows=[FAKE_TRANSACTION]),
    })
    res = client.post("/loyalty/redeem-points", json={
        "user_id": "USR-001", "points": 200, "offer_id": "OFF-001"
    })
    assert res.status_code == 200
    assert res.json()["current_points"] == 300

def test_redeem_insufficient_points(monkeypatch):
    """Not enough points ??? 400, balance unchanged."""
    patch_supabase(monkeypatch, {
        "loyalty_account": [{**FAKE_ACCOUNT, "current_points": 50}],
        "offer": [FAKE_OFFER],
    })
    res = client.post("/loyalty/redeem-points", json={
        "user_id": "USR-001", "points": 200, "offer_id": "OFF-001"
    })
    assert res.status_code == 400
    assert res.json()["detail"] == "Not enough points"

def test_redeem_offer_not_found(monkeypatch):
    """Non-existent offer ??? 404."""
    patch_supabase(monkeypatch, {
        "loyalty_account": [FAKE_ACCOUNT],
        "offer": [],
    })
    res = client.post("/loyalty/redeem-points", json={
        "user_id": "USR-001", "points": 20, "offer_id": "OFF-404"
    })
    assert res.status_code == 404

# ══════════════════════════════════════════════════════════════════════════════
# Membership
# ══════════════════════════════════════════════════════════════════════════════

def test_get_membership_success(monkeypatch):
    """Known user with membership ??? returns tier."""
    patch_supabase(monkeypatch, {
        "loyalty_account": [FAKE_ACCOUNT],
        "membership":      [FAKE_MEMBERSHIP],
    })
    res = client.get("/loyalty/membership/USR-001")
    assert res.status_code == 200
    assert res.json()["tier"] == "Bronze"

def test_get_membership_no_account(monkeypatch):
    """No loyalty account at all ??? 404."""
    patch_supabase(monkeypatch, {"loyalty_account": []})
    res = client.get("/loyalty/membership/USR-001")
    assert res.status_code == 404

# ══════════════════════════════════════════════════════════════════════════════
# Transactions
# ══════════════════════════════════════════════════════════════════════════════

def test_get_transactions_success(monkeypatch):
    """Known user ??? returns transaction list."""
    patch_supabase(monkeypatch, {
        "loyalty_account": [FAKE_ACCOUNT],
        "transactions":    [FAKE_TRANSACTION],
    })
    res = client.get("/loyalty/transactions/USR-001")
    assert res.status_code == 200
    assert res.json()[0]["transaction_id"] == "TRX-001"

def test_get_transactions_no_account(monkeypatch):
    """No loyalty account ??? 404."""
    patch_supabase(monkeypatch, {"loyalty_account": []})
    res = client.get("/loyalty/transactions/USR-001")
    assert res.status_code == 404

# ══════════════════════════════════════════════════════════════════════════════
# Admin summary
# ══════════════════════════════════════════════════════════════════════════════

def test_admin_summary_success(monkeypatch):
    """Returns correct customer count and tier distribution."""
    patch_supabase(monkeypatch, {
        "customer":     [{"user_id": "USR-001"}, {"user_id": "USR-002"}],
        "membership":   [{"tier": "Bronze"}, {"tier": "Silver"}, {"tier": "Gold"}, {"tier": "Bronze"}],
        "transactions": [{"date": "2025-03-10T10:00:00", "type": "earn"}],
    })
    res = client.get("/loyalty/admin-summary?year=2025")
    assert res.status_code == 200
    assert res.json()["total_customers"] == 2
    assert res.json()["tier_distribution"]["Bronze"] == 2

def test_admin_summary_empty(monkeypatch):
    """Empty database ??? zeros, no crash."""
    patch_supabase(monkeypatch, {"customer": [], "membership": [], "transactions": []})
    res = client.get("/loyalty/admin-summary?year=2025")
    assert res.status_code == 200
    assert res.json()["total_customers"] == 0

# ══════════════════════════════════════════════════════════════════════════════
# Offers
# ══════════════════════════════════════════════════════════════════════════════

def test_get_all_offers_success(monkeypatch):
    """Returns all offers in the table."""
    patch_supabase(monkeypatch, {"offer": [FAKE_OFFER]})
    res = client.get("/offers/")
    assert res.status_code == 200
    assert len(res.json()) == 1

def test_get_user_offers_success(monkeypatch):
    """Returns offers filtered to a specific user."""
    patch_supabase(monkeypatch, {"offer": [FAKE_OFFER]})
    res = client.get("/offers/user/USR-001")
    assert res.status_code == 200
    assert res.json()[0]["user_id"] == "USR-001"

def test_get_all_offers_empty(monkeypatch):
    """Empty offer table ??? empty list, not an error."""
    patch_supabase(monkeypatch, {"offer": []})
    res = client.get("/offers/")
    assert res.status_code == 200
    assert res.json() == []