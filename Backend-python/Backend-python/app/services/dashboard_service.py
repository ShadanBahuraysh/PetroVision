class DashboardService:
    def fill_customer_dashboard(self, account, membership, stations):
        return {
            "membership": {
                "tier": getattr(membership, "tier", None),
                "status": getattr(membership, "status", None)
            } if membership else None,
            "account": {
                "current_points": getattr(account, "current_points", 0),
                "savings": getattr(account, "savings", 0)
            } if account else None,
            "stations": [
                {
                    "station_id": getattr(station, "station_id", None),
                    "name": getattr(station, "station_name", None),
                    "city": getattr(station, "city", None),
                    "status": getattr(station, "status", None)
                }
                for station in stations
            ] if stations else []
        }

    def fill_admin_dashboard(self, stations):
        open_count = 0
        closed_count = 0

        if stations:
            for station in stations:
                status = str(getattr(station, "status", "")).lower()
                if status in ["open", "active", "operational"]:
                    open_count += 1
                else:
                    closed_count += 1

        return {
            "total_stations": len(stations) if stations else 0,
            "open_stations": open_count,
            "closed_stations": closed_count
        }