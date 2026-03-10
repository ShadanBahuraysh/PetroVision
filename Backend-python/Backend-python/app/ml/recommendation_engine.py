from typing import Any, Dict, List
import json
import os
import pandas as pd
import xgboost as xgb

from app.ml.model_loader import ModelLoader


class RecommendationEngine:
    def __init__(self):
        loader = ModelLoader()
        self.model, self.feature_cols = loader.load_performance_model()
        self.top_drivers = self.load_global_drivers()
        self.recommendation_rules = self.load_recommendation_rules()

    def load_global_drivers(self) -> List[str]:
        drivers_path = r"C:\Users\iShad\OneDrive\Desktop\PetroVision\ml-models\trained_models\global_drivers.json"

        if not os.path.exists(drivers_path):
            return []

        with open(drivers_path, "r", encoding="utf-8") as f:
            drivers = json.load(f)

        return [d["feature"] for d in drivers if "feature" in d]

    def load_recommendation_rules(self) -> Dict[str, str]:
        rules_path = r"C:\Users\iShad\OneDrive\Desktop\PetroVision\ml-models\trained_models\recommendation_rules.json"

        if not os.path.exists(rules_path):
            return {}

        with open(rules_path, "r", encoding="utf-8") as f:
            return json.load(f)

    def build_X_for_inference(self, raw_df: pd.DataFrame) -> pd.DataFrame:
        df = raw_df.copy()
        df = pd.get_dummies(df)
        df = df.reindex(columns=self.feature_cols, fill_value=0)
        return df

    def predict_with_contribs(self, X_aligned: pd.DataFrame):
        dmat = xgb.DMatrix(X_aligned, feature_names=list(X_aligned.columns))
        preds = self.model.predict(dmat)
        contrib = self.model.predict(dmat, pred_contribs=True)
        shap_vals = contrib[:, :-1]
        return preds, shap_vals

    def top_negative_drivers_for_row(
        self,
        shap_row,
        feature_names,
        top_k: int = 3
    ) -> List[Dict[str, Any]]:
        s = pd.Series(shap_row, index=feature_names)

        if self.top_drivers:
            allowed = [f for f in self.top_drivers if f in s.index]
            if allowed:
                s = s.loc[allowed]

        exclude_keywords = ["_none"]
        for keyword in exclude_keywords:
            s = s[~s.index.str.contains(keyword, case=False, na=False)]

        exclude_prefixes = [
            "station_id_",
            "city_",
            "time_slot_",
            "fuel_type_",
            "complaint_type_",
            "event_type_",
            "shutdown_type_",
            "power_status_"
        ]
        for prefix in exclude_prefixes:
            s = s[~s.index.str.startswith(prefix, na=False)]

        # keep only truly negative drivers
        s = s[s < 0]

        neg = s.sort_values(ascending=True).head(top_k)

        return [
            {
                "feature": idx,
                "impact": float(round(val, 2))
            }
            for idx, val in neg.items()
        ]

    def dynamic_fallback_action(self, feature_name: str) -> str:
        f = feature_name.lower()
        clean_name = feature_name.replace("_", " ")

        if "downtime" in f or "shutdown" in f:
            return f"Reduce downtime related to {clean_name} through preventive maintenance and rapid incident response."
        if "complaint" in f:
            return f"Address customer complaints impacting {clean_name} through service quality improvements."
        if "queue" in f or "wait" in f:
            return f"Reduce waiting impact of {clean_name} by optimizing staffing and pump allocation."
        if "staff" in f or "employee" in f:
            return f"Optimize workforce planning related to {clean_name}."
        if "inventory" in f or "stock" in f:
            return f"Improve inventory management affecting {clean_name}."
        if "traffic" in f or "flow" in f:
            return f"Analyze traffic patterns affecting {clean_name} and adjust operations accordingly."
        if "sales" in f or "revenue" in f or "volume" in f:
            return f"Review business drivers related to {clean_name} and improve promotions, pricing, and availability."
        if "pump" in f:return f"Check pump availability and maintenance affecting {clean_name}."
        if "rating" in f:
            return f"Improve customer experience and service quality related to {clean_name}."
        return f"Investigate operational impact of {clean_name} and apply corrective measures."

    def generate_recommendations(self, neg_features: List[str]) -> List[Dict[str, str]]:
        recs = []
        for f in neg_features:
            action = self.recommendation_rules.get(f, self.dynamic_fallback_action(f))
            recs.append({
                "feature": f,
                "action": action
            })
        return recs

    def build_performance_status(self, score: float) -> str:
        if score >= 70:
            return "Station performance is strong. Only minor optimization opportunities were detected."
        if score >= 40:
            return "Station performance is moderate. Some operational improvements may increase efficiency."
        return "Station performance is below expectations. Operational improvements are recommended."

    def build_default_high_performance_message(self) -> List[Dict[str, str]]:
        return [
            {
                "feature": "performance_status",
                "action": "Station is performing well; continue monitoring operations and inventory efficiency."
            }
        ]

    def analyze(self, stations: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        if not stations:
            return []

        raw_df = pd.DataFrame(stations)
        X_inf = self.build_X_for_inference(raw_df)
        preds, shap_vals = self.predict_with_contribs(X_inf)

        results = []
        for i in range(len(raw_df)):
            score = round(float(preds[i]), 2)

            negs = self.top_negative_drivers_for_row(
                shap_vals[i],
                feature_names=X_inf.columns,
                top_k=3
            )

            recs = self.generate_recommendations([d["feature"] for d in negs])

            # if there are too few negative drivers, add a clearer message
            if len(negs) < 3:
                if score >= 70:
                    recs = self.build_default_high_performance_message()
                elif len(negs) == 0:
                    recs = [
                        {
                            "feature": "performance_status",
                            "action": "No major negative operational drivers were detected. Continue monitoring current performance."
                        }
                    ]

            results.append({
                "station_id": raw_df["station_id"].iloc[i] if "station_id" in raw_df.columns else None,
                "predicted_performance": score,
                "performance_status": self.build_performance_status(score),
                "top_negative_drivers": negs,
                "recommended_actions": recs,
            })

        return results