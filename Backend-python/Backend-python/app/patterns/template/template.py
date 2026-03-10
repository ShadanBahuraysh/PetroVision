from abc import ABC, abstractmethod
from typing import Any, Dict, List

from app.models.report import Report


class Template(ABC):
    """
    Abstract template for analytics workflows.
    """

    def run(self, stations: List[Dict[str, Any]]) -> Report:
        prepared_data = self.preprocess(stations)
        processed_result = self.process(prepared_data)
        final_report = self.postprocess(processed_result)
        return final_report

    @abstractmethod
    def preprocess(self, stations: List[Dict[str, Any]]) -> Any:
        pass

    @abstractmethod
    def process(self, prepared_data: Any) -> Any:
        pass

    @abstractmethod
    def postprocess(self, processed_result: Any) -> Report:
        pass