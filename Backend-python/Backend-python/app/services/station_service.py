from app.models.station import Station


class StationService:
    def __init__(self):
        self.stations = [
            Station("S001", station_name="PetroVision Station 1", city="Jeddah", status="Open", rating=4.5),
            Station("S002", station_name="PetroVision Station 2", city="Riyadh", status="Closed", rating=4.1),
            Station("S003", station_name="PetroVision Station 3", city="Jeddah", status="Open", rating=4.7),
        ]

    def load_stations(self):
        return self.stations

    def load_stations_by_location(self, location):
        return [
            station for station in self.stations
            if station.city and station.city.lower() == location.lower()
        ]

    def get_station_by_id(self, station_id):
        for station in self.stations:
            if str(station.station_id) == str(station_id):
                return station

        return None