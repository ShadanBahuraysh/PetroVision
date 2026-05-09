# ========================================================================================================
# PetroVision Recommendation Model
# --------------------------------------------------------------------------------------------------------
# This file defines the RecommendationModel class used
# in the Template Method design pattern implementation
# within the PetroVision analytics system.
#
# Features included:
# - Running AI-driven recommendation analysis
# - Processing station recommendation data
# - Generating recommendation reports
# - Aggregating station analysis results
# - Removing duplicate recommendations
# - Formatting recommendation outputs
#
# It also implements the analytics workflow defined
# by the Template base class to provide
# operational recommendations and explainable
# AI insights for station performance improvement.
# ========================================================================================================
from typing import Any, Dict, List

from app.patterns.template.template import Template
from app.models.report import Report
from app.ml.recommendation_engine import RecommendationEngine


class RecommendationModel(Template):
    def __init__(self):
        self.engine = RecommendationEngine()

    def preprocess(self, stations: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        return stations

    def process(self, prepared_data: List[Dict[str, Any]]) -> Any:
        return self.engine.analyze(prepared_data)

    def postprocess(self, processed_result: Any) -> Report:
        seen = set()
        flat_recommendations = []

        for item in processed_result:
            for action in item["recommended_actions"]:
                key = (action["feature"], action["action"])
                if key not in seen:
                    seen.add(key)
                    flat_recommendations.append(action)

        report = Report(
            report_id="recommendation_report",
            model_name="RecommendationModel",
            summary="Recommendation results generated from Model 2 engine",
            metrics={
                "stations_analyzed": len(processed_result)
            },
            details={
                "results": processed_result
            },
            recommendations=flat_recommendations
        )

        return report