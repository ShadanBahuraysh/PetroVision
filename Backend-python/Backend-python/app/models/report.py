# ========================================================================================================
# PetroVision Report Model
# --------------------------------------------------------------------------------------------------------
# This file defines the Report dataclass used
# within the PetroVision analysis system.
#
# Features included:
# - Managing generated analysis reports
# - Storing report summaries and metrics
# - Managing detailed report information
# - Storing AI-generated recommendations
# - Automatically generating report timestamps
# - Converting report objects into dictionaries and JSON format
#
# It also provides a structured format for handling
# AI analysis results and exporting reporting data
# within the PetroVision platform.
# ========================================================================================================

from dataclasses import dataclass, field
from datetime import datetime
from typing import Any, Dict, List


@dataclass
class Report:
    report_id: str
    generated_at: str = field(default_factory=lambda: datetime.utcnow().isoformat())
    model_name: str = ""
    summary: str = ""
    metrics: Dict[str, Any] = field(default_factory=dict)
    details: Dict[str, Any] = field(default_factory=dict)
    recommendations: List[str] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        return {
            "report_id": self.report_id,
            "generated_at": self.generated_at,
            "model_name": self.model_name,
            "summary": self.summary,
            "metrics": self.metrics,
            "details": self.details,
            "recommendations": self.recommendations,
        }

    def to_json(self) -> Dict[str, Any]:
        return self.to_dict()