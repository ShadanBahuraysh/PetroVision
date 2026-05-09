# ========================================================================================================
# PetroVision Performance Model
# --------------------------------------------------------------------------------------------------------
# This file defines the PerformanceModel class used
# in the Template Method design pattern implementation
# within the PetroVision analytics system.
#
# Features included:
# - Preprocessing station performance data
# - Running AI-based performance predictions
# - Generating structured performance reports
# - Calculating average performance scores
# - Formatting prediction outputs
# - Handling empty prediction results
#
# It also implements the analytics workflow defined
# by the Template base class to provide
# station-performance analysis and reporting.
# ========================================================================================================
import pandas as pd
from typing import Any, Dict, List

from app.patterns.template.template import Template
from app.models.report import Report
from app.ml.predictor import Predictor


class PerformanceModel(Template):
    def __init__(self):
        self.predictor = Predictor()

    def preprocess(self, stations: List[Dict[str, Any]]) -> pd.DataFrame:
        return pd.DataFrame(stations)

    def process(self, prepared_data: pd.DataFrame):
        return self.predictor.predict(prepared_data)

    def postprocess(self, processed_result):
        rounded_predictions = [round(float(p), 2) for p in processed_result]

        if len(rounded_predictions) == 0:
            return Report(
                report_id="performance_report",
                model_name="PerformanceModel",
                summary="No prediction results available",
                metrics={
                    "average_performance_score": 0.0
                },
                details={
                    "predictions": []
                }
            )

        avg_score = round(float(sum(rounded_predictions) / len(rounded_predictions)), 2)

        return Report(
            report_id="performance_report",
            model_name="PerformanceModel",
            summary="Predicted station performance",
            metrics={
                "average_performance_score": avg_score
            },
            details={
                "predictions": rounded_predictions
            }
        )