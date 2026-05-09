# ========================================================================================================
# PetroVision Prediction Service
# --------------------------------------------------------------------------------------------------------
# This file is responsible for preparing station
# performance data and generating AI predictions
# using the trained PetroVision XGBoost model.
#
# Features included:
# - Data preprocessing and feature preparation
# - Cleaning and formatting input datasets
# - Handling missing and invalid values
# - Encoding categorical features
# - Aligning input features with trained model features
# - Generating station performance predictions
#
# It also ensures compatibility between incoming
# station data and the trained machine learning model
# before performing prediction operations.
# ========================================================================================================

import pandas as pd
import xgboost as xgb
from app.ml.model_loader import ModelLoader


class Predictor:
    def __init__(self):
        loader = ModelLoader()
        self.model, self.feature_cols = loader.load_performance_model()

    def prepare_features(self, data: pd.DataFrame) -> pd.DataFrame:
        df = data.copy()

        df.columns = df.columns.str.strip().str.lower()

        if "station_id" in df.columns:
            df["station_id"] = df["station_id"].astype(str).str.strip()

        if "date" in df.columns:
            df["date"] = pd.to_datetime(df["date"], errors="coerce")
            df["year"] = df["date"].dt.year
            df["month"] = df["date"].dt.month
            df["day"] = df["date"].dt.day
            df["day_of_week"] = df["date"].dt.dayofweek

        drop_cols = [
            "date",
            "performance_score",
            "performance_score_obs",
            "metrics_id",
        ]
        df = df.drop(columns=[c for c in drop_cols if c in df.columns], errors="ignore")

        if "station_id" in df.columns:
            df = df[df["station_id"].str.lower() != "station_id"]

        df = df.drop_duplicates()

        df = pd.get_dummies(df)

        df = df.reindex(columns=self.feature_cols, fill_value=0)

        df = df.apply(pd.to_numeric, errors="coerce").fillna(0)

        return df
        
    def predict(self, data: pd.DataFrame):
        X = self.prepare_features(data)

        dmatrix = xgb.DMatrix(X, feature_names=self.feature_cols)
        preds = self.model.predict(dmatrix)

        preds = [round(float(p), 2) for p in preds]
        return preds
    