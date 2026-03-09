class Station:
    def __init__(self, station_id, name, location, status, rating):
        self.station_id = station_id
        self.name = name
        self.location = location
        self.status = status
        self.rating = rating

    def is_open(self):
        return self.status.lower() == "open"