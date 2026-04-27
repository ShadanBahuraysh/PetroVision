ISSUE_LABELS = {
    "actual_inventory_usage": "Inventory inefficiency",
    "total_sales": "Weak sales performance",
    "inventory_stockout": "Stockout risk",
    "pumps_working": "Pump availability issue",
    "avg_rating": "Customer satisfaction issue",
    "transactions": "Low transaction activity",
    "traffic_index": "Low traffic potential",
    "customer_flow_index": "Weak customer flow",
    "staff_count": "Staffing issue",
    "downtime_minutes": "Operational downtime",
    "queue_time_avg": "Long queue time",
    "complaints_count": "High complaint volume",
    "network_uptime_pct": "Network instability",
    "pos_uptime_pct": "POS instability",
    "fuel_volume": "Low fuel sales volume",
    "fuel_volume_91": "Low fuel sales volume",
    "fuel_volume_95": "Low fuel sales volume",
    "fuel_volume_diesel": "Low diesel sales volume",
    "incidents_reported": "Frequent incidents",
    "event_duration_minutes": "Long incident duration",
    "event_severity": "High incident severity",
    "is_shutdown": "Shutdown risk",
    "competitors_within_3km": "High competition pressure",
    "nearby_services_density": "Nearby service competition",
    "area_m2": "Space utilization issue",
    "customer_flow_index": "Weak customer flow"
}


ISSUE_EXPLANATIONS = {
    "Inventory inefficiency": "The station may not be aligning stock levels with real usage.",
    "Weak sales performance": "Sales performance appears weaker than expected.",
    "Stockout risk": "The station may be experiencing product shortages that affect service.",
    "Pump availability issue": "Some pumps may be unavailable or underperforming.",
    "Customer satisfaction issue": "Customer experience indicators suggest room for improvement.",
    "Low transaction activity": "The station may be serving fewer customers than expected.",
    "Low traffic potential": "Traffic conditions may be limiting station performance.",
    "Weak customer flow": "Customer movement through the station appears lower than expected.",
    "Staffing issue": "Staff allocation may not be optimal for the station demand.",
    "Operational downtime": "Operational interruptions may be reducing station efficiency.",
    "Long queue time": "Customers may be experiencing longer than expected waiting times.",
    "High complaint volume": "Customer complaints may be affecting performance.",
    "Network instability": "Network interruptions may be affecting station operations.",
    "POS instability": "Point-of-sale availability may be affecting transactions.",
    "Low fuel sales volume": "Fuel sales volume appears lower than expected.",
    "Low diesel sales volume": "Diesel sales volume appears lower than expected.",
    "Frequent incidents": "Repeated incidents may be reducing operational stability.",
    "Long incident duration": "Incidents may be taking too long to resolve.",
    "High incident severity": "Operational issues may be more severe than expected.",
    "Shutdown risk": "The station may be exposed to shutdown-related performance drops.",
    "High competition pressure": "Nearby competitors may be affecting station demand.",
    "Nearby service competition": "Other nearby services may be reducing this station's advantage.",
    "Space utilization issue": "The station layout or area may not be used efficiently."
}


ISSUE_RECOMMENDATIONS = {
    "Inventory inefficiency": "Improve inventory management and align replenishment with actual usage.",
    "Weak sales performance": "Review sales drivers and improve promotions, pricing, and service availability.",
    "Stockout risk": "Improve inventory replenishment and safety stock levels.",
    "Pump availability issue": "Check pump maintenance and maximize pump availability.",
    "Customer satisfaction issue": "Improve customer experience and service quality to increase station rating.",
    "Low transaction activity": "Investigate demand patterns and improve customer conversion.",
    "Low traffic potential": "Review site demand patterns and local traffic behavior.",
    "Weak customer flow": "Improve customer attraction and service efficiency.",
    "Staffing issue": "Adjust staffing allocation based on station demand.",
    "Operational downtime": "Reduce downtime through preventive maintenance and faster response.",
    "Long queue time": "Improve queue handling through staffing and pump allocation.",
    "High complaint volume": "Investigate complaint causes and improve service quality.",
    "Network instability": "Stabilize network connectivity and monitor outages closely.",
    "POS instability": "Improve POS uptime and resolve transaction system interruptions.",
    "Low fuel sales volume": "Review fuel demand and improve product availability and promotion.",
    "Low diesel sales volume": "Review diesel demand and improve diesel availability.",
    "Frequent incidents": "Reduce recurring incidents through monitoring and corrective actions.",
    "Long incident duration": "Speed up incident handling and escalation processes.",
    "High incident severity": "Prioritize prevention and early handling of critical incidents.",
    "Shutdown risk": "Reduce shutdown exposure by improving reliability and incident control.",
    "High competition pressure": "Strengthen offers and service differentiation against nearby competitors.",
    "Nearby service competition": "Review competitive positioning and customer value proposition.",
    "Space utilization issue": "Review space usage and improve operational layout."
}


def simplify_issue(feature_name: str) -> str:
    return ISSUE_LABELS.get(feature_name, feature_name.replace("_", " ").title())


def explain_issue(feature_name: str) -> str:
    label = simplify_issue(feature_name)
    return ISSUE_EXPLANATIONS.get(label, f"{label} may be affecting station performance.")


def recommend_for_issue(feature_name: str) -> str:
    label = simplify_issue(feature_name)
    return ISSUE_RECOMMENDATIONS.get(label, f"Review and improve factors related to {label.lower()}.")