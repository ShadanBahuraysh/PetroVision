import pandas as pd
from typing import Any, Dict, List

from app.patterns.template.template import Template
from app.models.report import Report
from app.ml.predictor import Predictor


class PerformanceModel(Template):
    def __init__(self):
        self.predictor = Predictor()

    def preprocess(self, stations: List[Dict[str, Any]]) -> pd.DataFrame:
        df = pd.DataFrame(stations)
        return df

    def process(self, prepared_data: pd.DataFrame):
        predictions = self.predictor.predict(prepared_data)
        return predictions

    def postprocess(self, processed_result):
        rounded_predictions = [round(float(p), 2) for p in processed_result]
        avg_score = round(float(sum(rounded_predictions) / len(rounded_predictions)), 2)

        report = Report(
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

        return report