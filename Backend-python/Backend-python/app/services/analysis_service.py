# ========================================================================================================
# PetroVision Analysis Service
# --------------------------------------------------------------------------------------------------------
# This file defines the AnalysisService class used
# for managing AI-based station analysis operations
# within the PetroVision system.
#
# Features included:
# - Running full station performance analysis
# - Generating station rankings and overview summaries
# - Running recommendation and performance models
# - Calculating station performance metrics
# - Identifying operational issues and recommendations
# - Managing cached analysis results
# - Generating top and bottom station reports
# - Building station summaries and performance insights
#
# It also coordinates machine learning models,
# recommendation engines, and station data services
# to provide explainable AI analytics and
# operational decision support.
# ========================================================================================================

from collections import Counter
import pandas as pd

from app.services.station_data_service import StationDataService
from app.patterns.template.performance_model import PerformanceModel
from app.patterns.template.recommendation_model import RecommendationModel
from app.utils.issue_mapper import simplify_issue, explain_issue, recommend_for_issue


class AnalysisService:
    def __init__(self):
        self.data_service = StationDataService()
        self.performance_model = PerformanceModel()
        self.recommendation_model = RecommendationModel()

        self.cached_ranking = None
        self.cached_overview = None
        self.cached_top_bottom = None
        self.cached_station_analyses = {}
        self.is_analysis_running = False
    def _compute_station_score_metrics(self, station_df: pd.DataFrame, predictions: list):
        if not predictions:
            return {
                "predicted_mean": 0.0,
                "recent_predicted_mean": 0.0,
                "predicted_min": 0.0,
                "predicted_max": 0.0,
                "predicted_std": 0.0,
                "p10_score": 0.0,
                "low_score_count": 0,
                "high_score_count": 0,
                "critical_score_count": 0,
                "final_station_score": 0.0,
            }

        scores = pd.Series(predictions, dtype="float64")

        predicted_mean = round(float(scores.mean()), 2)
        predicted_min = round(float(scores.min()), 2)
        predicted_max = round(float(scores.max()), 2)
        predicted_std = round(float(scores.std(ddof=0)), 2)
        p10_score = round(float(scores.quantile(0.10)), 2)

        recent_window = min(90, len(scores))
        recent_predicted_mean = round(float(scores.tail(recent_window).mean()), 2)

        low_score_count = int((scores < 60).sum())
        high_score_count = int((scores >= 80).sum())
        critical_score_count = int((scores < 40).sum())

        final_station_score = (
            0.55 * predicted_mean +
            0.25 * recent_predicted_mean +
            0.15 * p10_score -
            0.05 * predicted_std
        )
        final_station_score = round(float(max(0, min(100, final_station_score))), 2)

        return {
            "predicted_mean": predicted_mean,
            "recent_predicted_mean": recent_predicted_mean,
            "predicted_min": predicted_min,
            "predicted_max": predicted_max,
            "predicted_std": predicted_std,
            "p10_score": p10_score,
            "low_score_count": low_score_count,
            "high_score_count": high_score_count,
            "critical_score_count": critical_score_count,
            "final_station_score": final_station_score,
        }

    def _get_priority_from_metrics(self, score_metrics: dict) -> str:
        final_score = score_metrics.get("final_station_score", 0)
        p10_score = score_metrics.get("p10_score", 0)

        if final_score < 55 or p10_score < 30:
            return "High"
        if final_score < 70:
            return "Medium"
        return "Low"

    def _get_performance_status(self, score_metrics: dict) -> str:
        final_score = score_metrics.get("final_station_score", 0)

        if final_score >= 70:
            return "Good"
        if final_score >= 55:
            return "Fair"
        return "Poor"


    def _build_station_summary_text(self, station_id: str, score_metrics: dict, worst_time: str, best_time: str, issues: list) -> str:
        final_score = score_metrics.get("final_station_score", 0)
        mean_score = score_metrics.get("predicted_mean", 0)
        recent_score = score_metrics.get("recent_predicted_mean", 0)
        p10_score = score_metrics.get("p10_score", 0)

        if not issues:
            return (
                f"Station {station_id} has a final score of {final_score}. "
                f"The average predicted performance is {mean_score}, with a recent average of {recent_score}. "
                f"The strongest time is {best_time} and the weakest time is {worst_time}. "
                f"The lower-end performance band is {p10_score}. No major repeated issues were detected."
            )

        issue_text = ", ".join([issue["issue"] for issue in issues[:3]])
        return (
            f"Station {station_id} has a final score of {final_score}. "
            f"Its average predicted performance is {mean_score}, while the recent average is {recent_score}. "
            f"The strongest time is {best_time} and the weakest time is {worst_time}. "
            f"The lower-end performance band is {p10_score}. "
            f"The main issues affecting this station are {issue_text}."
        )

    def _extract_station_issue_summary(self, recommendation_results: list) -> list:
        issue_counter = Counter()

        for row in recommendation_results:
            for driver in row.get("top_negative_drivers", []):
                issue_name = simplify_issue(driver.get("feature", "unknown_issue"))
                issue_counter[issue_name] += 1

        most_common = issue_counter.most_common(3)

        return [
            {
                "issue": issue,
                "count": count,
                "explanation": explain_issue(issue)
            }
            for issue, count in most_common
        ]

    def _extract_station_actions(self, recommendation_results: list) -> list:
        seen = set()
        actions = []

        for row in recommendation_results:
            for action in row.get("recommended_actions", []):
                feature = action.get("feature", "")
                simplified = simplify_issue(feature)
                generated_action = recommend_for_issue(feature)

                if simplified.lower() == "performance status":
                    continue

                key = (simplified, generated_action)
                if key not in seen:
                    seen.add(key)
                    actions.append({
                        "issue": simplified,
                        "action": generated_action
                    })

        return actions[:5]

    def _get_best_and_worst_time(self, station_df: pd.DataFrame):
        if "time_slot" not in station_df.columns:
            return None, None

        temp_results = []

        for time_slot in station_df["time_slot"].dropna().unique():
            slot_df = station_df[station_df["time_slot"] == time_slot]
            stations = slot_df.to_dict(orient="records")
            performance_report = self.performance_model.run(stations).to_dict()
            score = performance_report.get("metrics", {}).get("average_performance_score", 0)

            temp_results.append({
                "time_slot": time_slot,
                "average_performance_score": score,
                "n_rows": len(slot_df)
            })

        if not temp_results:
            return None, None

        temp_results = sorted(temp_results, key=lambda x: x["average_performance_score"])
        worst_time = temp_results[0]
        best_time = temp_results[-1]

        return best_time, worst_time

    def analyze_single_station(self, station_id: str):
        df = self.data_service.get_station_data(station_id)

        if df.empty:
            return {
                "station_id": station_id,
                "message": "No data found for this station."
            }

        stations = df.to_dict(orient="records")

        performance_report = self.performance_model.run(stations).to_dict()
        recommendation_report = self.recommendation_model.run(stations).to_dict()

        predictions = performance_report.get("details", {}).get("predictions", [])
        avg_score = performance_report.get("metrics", {}).get("average_performance_score", 0)
        recommendation_results = recommendation_report.get("details", {}).get("results", [])

        score_metrics = self._compute_station_score_metrics(df, predictions)

        best_time, worst_time = self._get_best_and_worst_time(df)
        issue_summary = self._extract_station_issue_summary(recommendation_results)
        recommended_actions = self._extract_station_actions(recommendation_results)

        summary_text = self._build_station_summary_text(
            station_id=station_id,
            score_metrics=score_metrics,
            worst_time=worst_time["time_slot"] if worst_time else "unknown",
            best_time=best_time["time_slot"] if best_time else "unknown",
            issues=issue_summary
        )

        return {
            "station_id": station_id,
            "n_rows": len(df),
            "average_performance_score": avg_score,
            "predicted_mean": score_metrics["predicted_mean"],
            "recent_predicted_mean": score_metrics["recent_predicted_mean"],
            "predicted_min": score_metrics["predicted_min"],
            "predicted_max": score_metrics["predicted_max"],
            "predicted_std": score_metrics["predicted_std"],
            "p10_score": score_metrics["p10_score"],
            "low_score_count": score_metrics["low_score_count"],
            "high_score_count": score_metrics["high_score_count"],
            "critical_score_count": score_metrics["critical_score_count"],
            "final_station_score": score_metrics["final_station_score"],
            "priority": self._get_priority_from_metrics(score_metrics),
            "performance_status": self._get_performance_status(score_metrics),
            "best_time": best_time,
            "worst_time": worst_time,
            "main_issues": issue_summary,
            "recommended_actions": recommended_actions,
            "summary": summary_text
        }

    def get_station_analysis(self, station_id: str):
        if station_id in self.cached_station_analyses:
            return self.cached_station_analyses[station_id]

        result = self.analyze_single_station(station_id)
        self.cached_station_analyses[station_id] = result
        return result

    def analyze_all_stations_ranking(self):

        df = self.data_service.get_all_data()

        if df.empty:
            return []

        ranking = []

        for station_id in sorted(df["station_id"].dropna().unique()):
            try:
                station_df = df[df["station_id"] == station_id]

                if station_df.empty:
                    continue

                stations = station_df.to_dict(orient="records")
                performance_report = self.performance_model.run(stations).to_dict()
                recommendation_report = self.recommendation_model.run(stations).to_dict()

                predictions = performance_report.get("details", {}).get("predictions", [])
                avg_score = performance_report.get("metrics", {}).get("average_performance_score", 0)
                recommendation_results = recommendation_report.get("details", {}).get("results", [])

                issues = self._extract_station_issue_summary(recommendation_results)
                recommended_actions = self._extract_station_actions(recommendation_results)
                score_metrics = self._compute_station_score_metrics(station_df, predictions)

                ranking.append({
                    "station_id": station_id,
                    "average_performance_score": avg_score,
                    "predicted_mean": score_metrics["predicted_mean"],
                    "recent_predicted_mean": score_metrics["recent_predicted_mean"],
                    "predicted_min": score_metrics["predicted_min"],
                    "predicted_max": score_metrics["predicted_max"],
                    "predicted_std": score_metrics["predicted_std"],
                    "p10_score": score_metrics["p10_score"],
                    "low_score_count": score_metrics["low_score_count"],
                    "high_score_count": score_metrics["high_score_count"],
                    "critical_score_count": score_metrics["critical_score_count"],
                    "final_station_score": score_metrics["final_station_score"],
                    "priority": self._get_priority_from_metrics(score_metrics),
                    "performance_status": self._get_performance_status(score_metrics),
                    "top_issue": issues[0]["issue"] if issues else None,
                    "recommendation": recommended_actions[0]["action"] if recommended_actions else "Review station performance and monitor operational indicators.",
                    "n_rows": len(station_df)
                })

            except KeyError:
                continue

            except ValueError:
                continue

            except TypeError:
                continue

            except Exception as e:
                print(f"Skipping station {station_id} due to error: {e}")
                continue

        ranking.sort(key=lambda x: x["final_station_score"])

        for idx, item in enumerate(ranking, start=1):
            item["rank"] = idx

        return ranking


    def get_ranking(self):
        if self.cached_ranking is None:
            return []

        return self.cached_ranking


    def _build_overview_from_ranking(self, ranking: list):
        if not ranking:
            return {
                "total_stations": 0,
                "overall_average_score": 0,
                "best_station": None,
                "worst_station": None,
                "low_performance_count": 0,
                "high_performance_count": 0,
                "most_common_issues": [],
                "management_recommendations": []
            }

        total_stations = len(ranking)
        overall_average_score = round(
            sum(item["final_station_score"] for item in ranking) / total_stations, 2
        )

        best_station = max(ranking, key=lambda x: x["final_station_score"])
        worst_station = min(ranking, key=lambda x: x["final_station_score"])

        low_performance_count = sum(1 for item in ranking if item["final_station_score"] < 55)
        high_performance_count = sum(1 for item in ranking if item["final_station_score"] >= 70)

        issue_counter = Counter(item["top_issue"] for item in ranking if item.get("top_issue"))
        common_issues = issue_counter.most_common(3)

        most_common_issues = [
            {
                "issue": issue,
                "count": count,
                "explanation": explain_issue(issue)
            }
            for issue, count in common_issues
        ]

        management_recommendations = [
            recommend_for_issue(issue_data["issue"])
            for issue_data in most_common_issues
        ]

        return {
            "total_stations": total_stations,
            "overall_average_score": overall_average_score,
            "best_station": best_station,
            "worst_station": worst_station,
            "low_performance_count": low_performance_count,
            "high_performance_count": high_performance_count,
            "most_common_issues": most_common_issues,
            "management_recommendations": management_recommendations
        }


    def run_full_analysis(self, force: bool = False):
        if self.is_analysis_running:
            return {
                "message": "Analysis is already running",
                "status": "running",
                "cached": False
            }

        if (
            not force and
            self.cached_ranking is not None and
            self.cached_overview is not None and
            self.cached_top_bottom is not None
        ):
            return {
                "message": "Full analysis already cached",
                "status": "cached",
                "cached": True
            }

        self.is_analysis_running = True

        try:
            ranking = self.analyze_all_stations_ranking()

            self.cached_ranking = ranking
            self.cached_top_bottom = {
                "bottom_10": ranking[:10],
                "top_10": ranking[-10:]
            }

            self.cached_overview = self._build_overview_from_ranking(ranking)

            return {
                "message": "Full analysis completed and cached successfully",
                "status": "completed",
                "cached": False
            }

        finally:
            self.is_analysis_running = False


    def get_top_bottom_10(self):
        if self.cached_top_bottom is None:
            return {
            "bottom_10": [],
            "top_10": []
            }

        return self.cached_top_bottom

    def get_overview(self):
        if self.cached_overview is None:
            return {
                "message": "No analysis cache available. Please run analysis first.",
                "cached": False,
                "total_stations": 0,
                "overall_average_score": 0,
                "best_station": None,
                "worst_station": None,
                "low_performance_count": 0,
                "high_performance_count": 0,
                "most_common_issues": [],
                "management_recommendations": []
            }

        return self.cached_overview

    def clear_cache(self):
        self.cached_ranking = None
        self.cached_overview = None
        self.cached_top_bottom = None
        self.cached_station_analyses = {}
        return {"message": "Analysis cache cleared successfully"}
