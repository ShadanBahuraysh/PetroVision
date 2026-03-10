from typing import Dict, List, Any

from app.patterns.template.performance_model import PerformanceModel
from app.patterns.template.recommendation_model import RecommendationModel


class AnalysisService:
    def __init__(self):
        self.performance_model = PerformanceModel()
        self.recommendation_model = RecommendationModel()

    def analyze_stations(self, stations: List[Dict[str, Any]]):
        performance_report = self.performance_model.run(stations)
        recommendation_report = self.recommendation_model.run(stations)

        return {
            "performance_report": performance_report.to_dict(),
            "recommendation_report": recommendation_report.to_dict()
        }