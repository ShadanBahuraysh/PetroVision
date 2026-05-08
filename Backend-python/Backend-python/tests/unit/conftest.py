"""
Shared test infrastructure for PetroVision auth tests.
Sets up a single shared mock_supabase used by ALL test files.
"""
import sys
import pytest
from unittest.mock import MagicMock

# ── Create ONE shared mock for all test files ─────────────────────────────────
_shared_mock_supabase = MagicMock()
_mock_module = MagicMock()
_mock_module.supabase = _shared_mock_supabase
sys.modules["app.supabase_client"] = _mock_module


def _empty_table(name):
    """Safe default: all DB queries return empty lists."""
    m = MagicMock()
    m.select.return_value.eq.return_value.execute.return_value.data = []
    m.select.return_value.eq.return_value.eq.return_value.execute.return_value.data = []
    m.insert.return_value.execute.return_value.data = []
    m.update.return_value.eq.return_value.execute.return_value.data = []
    m.delete.return_value.eq.return_value.execute.return_value.data = []
    return m


@pytest.fixture(autouse=True)
def reset_supabase_mock():
    """Reset the shared mock_supabase to safe empty state before each test."""
    _shared_mock_supabase.reset_mock(side_effect=True, return_value=True)
    _shared_mock_supabase.table.side_effect = _empty_table
    yield
    _shared_mock_supabase.reset_mock(side_effect=True, return_value=True)
    _shared_mock_supabase.table.side_effect = _empty_table


# Export so test files can import it
shared_mock_supabase = _shared_mock_supabase
