from point_strategy import PointStrategy

class BronzePoints(PointStrategy):
    def calculate_points(self, amount):
        return int(amount)