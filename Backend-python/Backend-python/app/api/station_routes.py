from fastapi import APIRouter
import requests

router = APIRouter()

GOOGLE_API_KEY = "AIzaSyDjdMGkREctRQN52HyAOaC6PS04H-j47Vs"

@router.get("/stations")
def get_stations():
    url = "https://maps.googleapis.com/maps/api/place/textsearch/json"
    params = {
        "query": "Petromin station Saudi Arabia",
        "key": GOOGLE_API_KEY,
    }

    try:
        response = requests.get(url, params=params, timeout=10)
        data = response.json()

        print("Status:", data.get("status"))
        print("Results count:", len(data.get("results", [])))

        if data.get("status") != "OK":
            return {"error": data.get("status"), "message": data.get("error_message", "")}

        results = []
        for place in data.get("results", []):
            results.append({
                "name": place["name"],
                "lat": place["geometry"]["location"]["lat"],
                "lng": place["geometry"]["location"]["lng"],
                "address": place.get("formatted_address", "")
            })

        return results

    except Exception as e:
        return {"error": str(e)}