from abc import ABC, abstractmethod

class PointStrategy(ABC):
    @abstractmethod
    def calculate_points(self, amount):
        pass