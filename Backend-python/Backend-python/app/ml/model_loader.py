import joblib
import xgboost as xgb


class ModelLoader:

    def __init__(self):
        self.model = None
        self.feature_cols = None

    def load_performance_model(self):

        if self.model is None:

            model_path = r"C:\Users\iShad\OneDrive\Desktop\PetroVision\ml-models\trained_models\performance_model_station_time.json"

            feature_cols_path = r"C:\Users\iShad\OneDrive\Desktop\PetroVision\ml-models\trained_models\feature_cols_station_time_holdout.pkl"

            booster = xgb.Booster()
            booster.load_model(model_path)

            self.model = booster
            self.feature_cols = joblib.load(feature_cols_path)

        return self.model, self.feature_cols