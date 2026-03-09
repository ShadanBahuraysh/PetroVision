class DashboardService:
    def fill_customer_dashboard(self, account, membership, stations):
        print("----- Customer Dashboard -----")

        if membership is not None:
            print("Tier:", membership.tier)
            print("Membership Status:", membership.status)

        if account is not None:
            print("Current Points:", account.current_points)
            print("Savings:", account.savings)

        print("Available Stations:")
        if stations is not None:
            for station in stations:
                print(f"- {station.name} | {station.location} | {station.status}")

    def fill_admin_dashboard(self, stations):
        print("----- Admin Dashboard -----")

        open_count = 0
        closed_count = 0

        if stations is not None:
            for station in stations:
                if station.is_open():
                    open_count += 1
                else:
                    closed_count += 1

        print("Total Stations:", len(stations) if stations else 0)
        print("Open Stations:", open_count)
        print("Closed Stations:", closed_count)