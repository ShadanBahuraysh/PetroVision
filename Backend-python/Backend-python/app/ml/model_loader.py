# ========================================================================================================
# PetroVision Model Loader
# --------------------------------------------------------------------------------------------------------
# This file is responsible for loading and managing
# machine learning models and analysis resources
# used by the PetroVision AI system.
#
# Features included:
# - Loading trained XGBoost performance models
# - Loading model feature columns
# - Loading global feature importance drivers
# - Loading recommendation rules from JSON files
# - Caching loaded resources for reuse
#
# It also centralizes access to AI model assets
# and prevents repeated loading operations
# during runtime.
# ========================================================================================================
from pathlib import Path
import json
import xgboost as xgb


class ModelLoader:
    _model = None
    _feature_cols = None
    _top_drivers = None
    _recommendation_rules = None

    def __init__(self):
        self.project_root = Path(__file__).resolve().parents[4]
        self.models_dir = self.project_root / "ml-models" / "trained_models"

    def load_performance_model(self):
        if ModelLoader._model is None:
            model_path = self.models_dir / "performance_model_station.json"

            if not model_path.exists():
                raise FileNotFoundError(f"Model file not found: {model_path}")

            booster = xgb.Booster()
            booster.load_model(str(model_path))

            ModelLoader._model = booster
            ModelLoader._feature_cols = list(booster.feature_names or [])

            if not ModelLoader._feature_cols:
                raise ValueError("Model feature names are empty.")

        return ModelLoader._model, ModelLoader._feature_cols

    def load_global_drivers(self):
        if ModelLoader._top_drivers is None:
            drivers_path = self.models_dir / "global_drivers.json"

            if not drivers_path.exists():
                ModelLoader._top_drivers = []
                return ModelLoader._top_drivers

            with open(drivers_path, "r", encoding="utf-8") as f:
                drivers = json.load(f)

            ModelLoader._top_drivers = [d["feature"] for d in drivers if "feature" in d]

        return ModelLoader._top_drivers

    def load_recommendation_rules(self):
        if ModelLoader._recommendation_rules is None:
            rules_path = self.models_dir / "recommendation_rules.json"

            if not rules_path.exists():
                ModelLoader._recommendation_rules = {}
                return ModelLoader._recommendation_rules

            with open(rules_path, "r", encoding="utf-8") as f:
                ModelLoader._recommendation_rules = json.load(f)

        return ModelLoader._recommendation_rules