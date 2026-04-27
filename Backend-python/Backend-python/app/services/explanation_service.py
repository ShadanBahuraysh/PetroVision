import os
import requests

from app.services.analysis_service import AnalysisService


class ExplanationService:
    def __init__(self):
        self.analysis_service = AnalysisService()
        self.api_key = os.getenv("OPENROUTER_API_KEY")
        self.model_name = os.getenv("MODEL_NAME", "deepseek/deepseek-chat")
        self.base_url = "https://openrouter.ai/api/v1/chat/completions"

        # Cache only expensive explanation responses
        self.cached_overview_explanation = None
        self.cached_station_explanations = {}
        self.cached_compare_explanations = {}

    def _call_llm(self, prompt: str) -> str:
        if not self.api_key:
            return self._fallback_text("API key missing")

        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json",
        }

        payload = {
            "model": self.model_name,
            "messages": [
                {"role": "user", "content": prompt}
            ],
            "temperature": 0.2,
            "max_tokens": 180,
        }

        try:
            response = requests.post(
                self.base_url,
                headers=headers,
                json=payload,
                timeout=10,
            )

            if response.status_code != 200:
                return self._fallback_text(f"API error {response.status_code}")

            data = response.json()
            choices = data.get("choices", [])
            if not choices:
                return self._fallback_text("No choices returned")

            message = choices[0].get("message", {})
            content = message.get("content", "").strip()

            if not content:
                return self._fallback_text("Empty AI response")

            return content

        except Exception:
            return self._fallback_text("Timeout or connection error")

    def _fallback_text(self, reason: str = "") -> str:
        return "Explanation generated locally because the AI service is temporarily unavailable."

    def _local_station_explanation(self, d: dict) -> str:
        issues = [x.get("issue") for x in d.get("main_issues", [])[:3]]
        actions = [x.get("action") for x in d.get("recommended_actions", [])[:3]]
        best_time = d.get("best_time", {}).get("time_slot") if d.get("best_time") else "unknown"
        worst_time = d.get("worst_time", {}).get("time_slot") if d.get("worst_time") else "unknown"

        lines = [
            "Summary:",
            f"Station {d.get('station_id')} has a score of {d.get('final_station_score')} and is classified as {d.get('priority')} priority. Performance is strongest during {best_time} and weakest during {worst_time}.",
            "",
            "Top Issues:",
        ]
        for issue in issues:
            lines.append(f"- {issue}")

        lines.append("")
        lines.append("Recommended Actions:")
        for action in actions:
            lines.append(f"- {action}")

        return "\n".join(lines)

    def _local_overview_explanation(self, d: dict) -> str:
        issues = [x.get("issue") for x in d.get("most_common_issues", [])[:2]]
        best_station = d.get("best_station", {}).get("station_id") if d.get("best_station") else "N/A"
        worst_station = d.get("worst_station", {}).get("station_id") if d.get("worst_station") else "N/A"

        lines = [
            "Executive Summary:",
            f"The network includes {d.get('total_stations')} stations with an overall average score of {d.get('overall_average_score')}. Performance is mixed, with {d.get('high_performance_count')} strong stations and {d.get('low_performance_count')} weak stations.",
            "",
            "Key Insights:",
            f"- Best station: {best_station}",
            f"- Worst station: {worst_station}",
            f"- Most common issues: {', '.join(issues) if issues else 'No dominant issues detected'}",
            "",
            "Management Actions:",
            "- Review the practices of the best-performing station and apply relevant improvements elsewhere.",
            "- Prioritize support for the weakest-performing station.",
            "- Address the most common recurring issues across the network.",
        ]
        return "\n".join(lines)

    def _local_compare_explanation(self, d1: dict, d2: dict) -> str:
        s1 = d1.get("final_station_score", 0)
        s2 = d2.get("final_station_score", 0)

        stronger = d1 if s1 >= s2 else d2
        weaker = d2 if s1 >= s2 else d1

        stronger_id = stronger.get("station_id")
        weaker_id = weaker.get("station_id")

        stronger_issue = stronger.get("main_issues", [{}])[0].get("issue", "No major issue")
        weaker_issue = weaker.get("main_issues", [{}])[0].get("issue", "No major issue")

        lines = [
            "Comparison Summary:",
            f"Station {stronger_id} is performing better overall than Station {weaker_id} because it has a higher final score.",
            "",
            "Key Differences:",
            f"- {stronger_id} score: {stronger.get('final_station_score')}",
            f"- {weaker_id} score: {weaker.get('final_station_score')}",
            f"- Main issue difference: {stronger_id} → {stronger_issue}, {weaker_id} → {weaker_issue}",
            "",
            "Action Plan for Weaker Station:",
        ]

        for action in weaker.get("recommended_actions", [])[:3]:
            action_text = action.get("action")
            if action_text:
                lines.append(f"- {action_text}")

        return "\n".join(lines)

    def _compact_station_data(self, d: dict) -> dict:
        return {
            "station_id": d.get("station_id"),
            "score": d.get("final_station_score"),
            "priority": d.get("priority"),
            "best_time": d.get("best_time", {}).get("time_slot") if d.get("best_time") else None,
            "worst_time": d.get("worst_time", {}).get("time_slot") if d.get("worst_time") else None,
            "issues": [x.get("issue") for x in d.get("main_issues", [])[:3]],
            "actions": [x.get("action") for x in d.get("recommended_actions", [])[:3]],
        }

    def _compact_overview_data(self, d: dict) -> dict:
        return {
            "total_stations": d.get("total_stations"),
            "overall_average_score": d.get("overall_average_score"),
            "best_station_id": d.get("best_station", {}).get("station_id") if d.get("best_station") else None,
            "worst_station_id": d.get("worst_station", {}).get("station_id") if d.get("worst_station") else None,
            "low_performance_count": d.get("low_performance_count"),
            "high_performance_count": d.get("high_performance_count"),
            "most_common_issues": [x.get("issue") for x in d.get("most_common_issues", [])[:2]],
        }

    def _compact_comparison_data(self, d: dict) -> dict:
        return {
            "station_id": d.get("station_id"),
            "score": d.get("final_station_score"),
            "priority": d.get("priority"),
            "issues": [x.get("issue") for x in d.get("main_issues", [])[:3]],
        }

    def _station_prompt(self, d: dict) -> str:
        return f"""
You are a professional operations assistant for PetroVision.

Write a clear and natural explanation for a station manager.

Rules:
- Keep it short and practical
- Do NOT use markdown symbols
- Do NOT break sentences across lines
- Use simple professional English
- Focus on actions and decisions

Station:
ID: {d['station_id']}
Score: {d['score']} ({d['priority']} priority)
Best time: {d['best_time']}
Worst time: {d['worst_time']}

Main issues:
{', '.join(d['issues'])}

Recommended actions:
{', '.join(d['actions'])}

Output format EXACTLY:

Summary:
<2 short sentences>

Top Issues:
- issue 1
- issue 2
- issue 3

Recommended Actions:
- action 1
- action 2
- action 3
""".strip()

    def _overview_prompt(self, d: dict) -> str:
        return f"""
You are a professional operations assistant for PetroVision.

Explain the overall network performance for management.

Rules:
- Keep it concise and practical
- Do NOT use markdown symbols
- Do NOT break sentences across lines
- Write like a business report
- Focus on decisions, not raw data
- Keep the response under 120 words

Network Data:
Total stations: {d['total_stations']}
Average score: {d['overall_average_score']}
Best station ID: {d['best_station_id']}
Worst station ID: {d['worst_station_id']}
Low performance stations: {d['low_performance_count']}
High performance stations: {d['high_performance_count']}

Common issues:
{', '.join(d['most_common_issues'])}

Output format EXACTLY:

Executive Summary:
<2 short sentences>

Key Insights:
- insight 1
- insight 2
- insight 3

Management Actions:
- action 1
- action 2
- action 3
""".strip()

    def _compare_prompt(self, a: dict, b: dict) -> str:
        return f"""
You are a professional operations assistant for PetroVision.

Compare two stations clearly for a manager.

Rules:
- Be direct and clear
- Do NOT use markdown symbols
- Do NOT break sentences across lines
- Focus on differences and decisions
- Keep it short and practical

Station A:
ID: {a['station_id']}
Score: {a['score']}
Issues: {', '.join(a['issues'])}

Station B:
ID: {b['station_id']}
Score: {b['score']}
Issues: {', '.join(b['issues'])}

Output format EXACTLY:

Comparison Summary:
<who is better and why in 1-2 sentences>

Key Differences:
- difference 1
- difference 2
- difference 3

Action Plan for Weaker Station:
- action 1
- action 2
- action 3
""".strip()

    def explain_station(self, station_id: str) -> dict:
        if station_id in self.cached_station_explanations:
            return self.cached_station_explanations[station_id]

        data = self.analysis_service.analyze_single_station(station_id)

        if "message" in data:
            result = {
                "station_id": station_id,
                "explanation": data["message"]
            }
            self.cached_station_explanations[station_id] = result
            return result

        compact = self._compact_station_data(data)
        explanation = self._call_llm(self._station_prompt(compact))

        if explanation.startswith("Explanation generated locally"):
            explanation = self._local_station_explanation(data)

        result = {
            "station_id": station_id,
            "analysis": data,
            "explanation": explanation
        }
        self.cached_station_explanations[station_id] = result
        return result

    def explain_overview(self) -> dict:
        data = self.analysis_service.get_overview()

        if self.cached_overview_explanation is not None:
            return {
                "overview": data,
                "explanation": self.cached_overview_explanation
            }

        compact = self._compact_overview_data(data)
        explanation = self._call_llm(self._overview_prompt(compact))

        if explanation.startswith("Explanation generated locally"):
            explanation = self._local_overview_explanation(data)

        self.cached_overview_explanation = explanation

        return {
            "overview": data,
            "explanation": explanation
        }

    def compare_stations(self, s1: str, s2: str) -> dict:
        cache_key = tuple(sorted([s1, s2]))
        if cache_key in self.cached_compare_explanations:
            return self.cached_compare_explanations[cache_key]

        d1 = self.analysis_service.analyze_single_station(s1)
        d2 = self.analysis_service.analyze_single_station(s2)

        if "message" in d1 or "message" in d2:
            result = {
                "comparison": None,
                "explanation": "Analysis failed for one or both stations."
            }
            self.cached_compare_explanations[cache_key] = result
            return result

        c1 = self._compact_comparison_data(d1)
        c2 = self._compact_comparison_data(d2)
        explanation = self._call_llm(self._compare_prompt(c1, c2))

        if explanation.startswith("Explanation generated locally"):
            explanation = self._local_compare_explanation(d1, d2)

        result = {
            "station_1": d1,
            "station_2": d2,
            "explanation": explanation
        }
        self.cached_compare_explanations[cache_key] = result
        return result

    def clear_explanation_cache(self) -> dict:
        self.cached_overview_explanation = None
        self.cached_station_explanations = {}
        self.cached_compare_explanations = {}
        return {"message": "Explanation cache cleared successfully"}