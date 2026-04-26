from fastapi import APIRouter, HTTPException
from app.supabase_client import supabase

router = APIRouter(prefix="/offers", tags=["Offers"])

@router.get("/")
def get_all_offers():
    result = supabase.table("offer").select("*").execute()
    return result.data

@router.get("/{user_id}")
def get_user_offers(user_id: str):
    result = supabase.table("offer").select("*").eq("user_id", user_id).execute()
    if not result.data:
        raise HTTPException(status_code=404, detail="No offers found for this user")
    return result.data
