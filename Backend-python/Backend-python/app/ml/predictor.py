import pandas as pd
import xgboost as xgb
from app.ml.model_loader import ModelLoader


class Predictor:

    def __init__(self):
        loader = ModelLoader()
        self.model, self.feature_cols = loader.load_performance_model()

    def predict(self, data: pd.DataFrame):

        df = data.copy()

        # one-hot encoding
        df = pd.get_dummies(df)

        # align columns with training
        df = df.reindex(columns=self.feature_cols, fill_value=0)

        dmatrix = xgb.DMatrix(df)

        preds = self.model.predict(dmatrix)

        return preds