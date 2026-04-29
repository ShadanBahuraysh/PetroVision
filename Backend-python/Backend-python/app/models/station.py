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
        rating=None
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
            "rating": self.rating
        }