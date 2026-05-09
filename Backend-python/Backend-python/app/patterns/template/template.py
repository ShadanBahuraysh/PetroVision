# ========================================================================================================
# PetroVision Analytics Template
# --------------------------------------------------------------------------------------------------------
# This file defines the abstract Template class used
# in the Template Method design pattern implementation
# within the PetroVision analytics system.
#
# Features included:
# - Defining the standard analytics workflow structure
# - Managing preprocessing, processing, and postprocessing steps
# - Enforcing implementation of workflow stages
# - Supporting reusable analytics pipelines
# - Returning structured analysis reports
#
# It also provides a common workflow template for
# different AI analysis models while allowing
# subclasses to customize specific processing steps.
# ========================================================================================================

from abc import ABC, abstractmethod
from typing import Any, Dict, List

from app.models.report import Report


class Template(ABC):
  
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