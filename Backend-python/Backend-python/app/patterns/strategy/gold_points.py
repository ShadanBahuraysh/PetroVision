from point_strategy import PointStrategy

class GoldPoints(PointStrategy):
    def calculate_points(self, amount):
        return int(amount * 1.5)