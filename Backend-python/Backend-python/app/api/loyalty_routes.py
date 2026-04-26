from fastapi import APIRouter, HTTPException
from app.supabase_client import supabase

router = APIRouter(prefix="/loyalty", tags=["Loyalty"])

@router.get("/account/{user_id}")
def get_loyalty_account(user_id: str):
    result = supabase.table("loyalty_account").select("*").eq("user_id", user_id).execute()
    if not result.data:
        raise HTTPException(status_code=404, detail="Loyalty account not found")
    return result.data[0]

@router.get("/points/{user_id}")
def get_points(user_id: str):
    result = supabase.table("loyalty_account").select("current_points, account_id").eq("user_id", user_id).execute()
    if not result.data:
        raise HTTPException(status_code=404, detail="No account found for this user")
    return {
        "user_id": user_id,
        "account_id": result.data[0]["account_id"],
        "current_points": result.data[0]["current_points"]
    }

@router.get("/membership/{user_id}")
def get_membership(user_id: str):
    account_result = supabase.table("loyalty_account").select("account_id").eq("user_id", user_id).execute()
    if not account_result.data:
        raise HTTPException(status_code=404, detail="No loyalty account found")
    account_id = account_result.data[0]["account_id"]
    mem_index = account_id.replace("ACC-", "MEM-")
    mem_result = supabase.table("membership").select("*").eq("membership_id", mem_index).execute()
    if not mem_result.data:
        mem_result = supabase.table("membership").select("*").limit(1).execute()
    return mem_result.data[0] if mem_result.data else {}

@router.get("/transactions/{user_id}")
def get_transactions(user_id: str):
    offers_result = supabase.table("offer").select("offer_id").eq("user_id", user_id).execute()
    if not offers_result.data:
        return []
    offer_ids = [o["offer_id"] for o in offers_result.data]
    transactions_result = supabase.table("transactions").select("*").in_("offer_id", offer_ids).order("date", desc=True).execute()
    return transactions_result.data

@router.get("/programs")
def get_loyalty_programs():
    result = supabase.table("loyalty_program").select("*").execute()
    return result.data
