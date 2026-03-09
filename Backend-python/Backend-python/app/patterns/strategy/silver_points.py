from point_strategy import PointStrategy

class SilverPoints(PointStrategy):
    def calculate_points(self, amount):
        return int(amount * 1.25)