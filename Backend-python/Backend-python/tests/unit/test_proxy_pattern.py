"""
Unit Tests ??? Proxy Pattern
============================
Coverage:
  - AppAccessProxy.login
  - AppAccessProxy.access_dashboard
  - RealApplicationGateway.access_dashboard
"""

import sys
import os
from unittest.mock import MagicMock

# ====== Path setup =======
sys.path.insert(0, os.path.join(os.path.dirname(__file__),
                                "../Backend-python/Backend-python"))

from app.patterns.proxy.gateway import AppAccessProxy
from app.patterns.proxy.real_gateway import RealApplicationGateway


# ================
# AppAccessProxy
# ================

class TestAppAccessProxy:

    def setup_method(self):
        self.real_gateway = RealApplicationGateway()
        self.mock_auth = MagicMock()
        self.proxy = AppAccessProxy(self.real_gateway, self.mock_auth)

    def test_login_allowed_when_credentials_valid(self):
        """Valid credentials must return allowed=True with user data."""
        self.mock_auth.authenticate.return_value = {
            "user_id": "U-0001", "role": "customer"
        }
        result = self.proxy.login("user@petro.com", "ValidPass1!")
        assert result["allowed"] is True
        assert result["user"] is not None

    def test_login_denied_when_credentials_invalid(self):
        """Invalid credentials (authenticate returns None) must return allowed=False."""
        self.mock_auth.authenticate.return_value = None
        result = self.proxy.login("bad@petro.com", "wrongpass")
        assert result["allowed"] is False
        assert result["user"] is None

    def test_login_returns_user_data_on_success(self):
        """Successful login result must contain the authenticated user object."""
        user_data = {"user_id": "U-0010", "role": "admin"}
        self.mock_auth.authenticate.return_value = user_data
        result = self.proxy.login("admin@petro.com", "AdminPass1!")
        assert result["user"] == user_data


# =======================
# RealApplicationGateway
# =======================

class TestRealApplicationGateway:

    def test_access_dashboard_returns_allowed_true(self):
        """RealApplicationGateway must always grant access."""
        gateway = RealApplicationGateway()
        user = {"user_id": "U-0013", "role": "customer"}
        result = gateway.access_dashboard(user)
        assert result["allowed"] is True

    def test_returns_user_in_response(self):
        """RealApplicationGateway must echo the user back in the response."""
        gateway = RealApplicationGateway()
        user = {"user_id": "U-0014", "role": "admin"}
        result = gateway.access_dashboard(user)
        assert result["user"] == user
