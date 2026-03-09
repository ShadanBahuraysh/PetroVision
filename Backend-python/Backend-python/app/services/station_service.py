from station import Station

class StationService:
    def __init__(self):
        self.stations = [
            Station(1, "PetroVision Station 1", "Jeddah", "Open", 4.5),
            Station(2, "PetroVision Station 2", "Riyadh", "Closed", 4.1),
            Station(3, "PetroVision Station 3", "Jeddah", "Open", 4.7),
        ]

    def load_stations(self):
        return self.stations

    def load_stations_by_location(self, location):
        filtered_stations = []

        for station in self.stations:
            if station.location.lower() == location.lower():
                filtered_stations.append(station)

        return filtered_stations

    def get_station_by_id(self, station_id):
        for station in self.stations:
            if station.station_id == station_id:
                return station
        return None