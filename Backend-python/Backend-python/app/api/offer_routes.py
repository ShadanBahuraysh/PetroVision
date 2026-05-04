from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from app.supabase_client import supabase

router = APIRouter(prefix="/offers", tags=["Offers"])


class OfferRequest(BaseModel):
    offer_type: Optional[str] = None
    earn_points: Optional[int] = 0
    redeem_points: Optional[int] = 0
    user_id: Optional[str] = None
    # Admin loyalty screen fields
    name: Optional[str] = None
    category: Optional[str] = None
    min_tier: Optional[str] = "Bronze"
    status: Optional[str] = "Active"


def generate_offer_id():
    result = supabase.table("offer").select("offer_id").execute()
    next_number = len(result.data or []) + 1
    return f"OFF-{next_number:04d}"


def generate_qr_codes(offer_id: str):
    """Derive QR codes from offer_id. OFF-0003 -> EFC-0003, RFC-0003"""
    num = offer_id.replace("OFF-", "")
    return f"EFC-{num}", f"RFC-{num}"


@router.get("/")
def get_all_offers():
    try:
        result = supabase.table("offer").select("*").execute()
        return result.data or []
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/user/{user_id}")
def get_user_offers(user_id: str):
    try:
        result = (
            supabase.table("offer")
            .select("*")
            .eq("user_id", user_id)
            .execute()
        )
        return result.data or []
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{offer_id}")
def get_offer(offer_id: str):
    try:
        result = (
            supabase.table("offer")
            .select("*")
            .eq("offer_id", offer_id)
            .execute()
        )
        if not result.data:
            raise HTTPException(status_code=404, detail="Offer not found")
        return result.data[0]
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/")
def create_offer(data: OfferRequest):
    try:
        offer_id = generate_offer_id()
        earn_qr, redeem_qr = generate_qr_codes(offer_id)

        offer_data = data.model_dump(exclude_none=True)
        offer_data["offer_id"] = offer_id
        offer_data["earn_qr_code"]   = earn_qr
        offer_data["redeem_qr_code"] = redeem_qr

        result = (
            supabase.table("offer")
            .insert(offer_data)
            .execute()
        )
        return {
            "message": "Offer created successfully",
            "offer": result.data[0] if result.data else None
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.put("/{offer_id}")
def update_offer(offer_id: str, data: OfferRequest):
    try:
        update_data = data.model_dump(exclude_none=True)
        # Never overwrite QR codes on update — they are permanent
        update_data.pop("earn_qr_code", None)
        update_data.pop("redeem_qr_code", None)

        result = (
            supabase.table("offer")
            .update(update_data)
            .eq("offer_id", offer_id)
            .execute()
        )
        if not result.data:
            raise HTTPException(status_code=404, detail="Offer not found")
        return {
            "message": "Offer updated successfully",
            "offer": result.data[0]
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.delete("/{offer_id}")
def delete_offer(offer_id: str):
    try:
        result = (
            supabase.table("offer")
            .delete()
            .eq("offer_id", offer_id)
            .execute()
        )
        return {
            "message": "Offer deleted successfully",
            "deleted": result.data
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    

""" 
@router.post("/scan-earn/{qr_code}")
def scan_earn_qr(qr_code: str, user_id: str, amount: float):
    try:
        offer_result = (
            supabase.table("offer")
            .select("*")
            .eq("earn_qr_code", qr_code)
            .execute()
        )

        if not offer_result.data:
            raise HTTPException(status_code=404, detail="Invalid QR code")

        offer = offer_result.data[0]

        account_result = (
            supabase.table("loyalty_account")
            .select("*")
            .eq("user_id", user_id)
            .execute()
        )

        if not account_result.data:
            raise HTTPException(status_code=404, detail="Loyalty account not found")

        account = account_result.data[0]
        account_id = account["account_id"]

        current_points = account.get("current_points", 0) or 0

        earned_points = offer.get("earn_points", 0) or 0

        new_points = current_points + earned_points

        supabase.table("loyalty_account").update({
            "current_points": new_points
        }).eq("account_id", account_id).execute()

        supabase.table("transactions").insert({
            "transaction_id": f"TRX-{datetime.utcnow().timestamp()}",
            "date": datetime.utcnow().isoformat(),
            "amount": amount,
            "points": earned_points,
            "type": "earn",
            "offer_id": offer["offer_id"],
            "account_id": account_id
        }).execute()

        return {
            "message": "Points earned successfully",
            "earned_points": earned_points,
            "current_points": new_points,
            "offer": offer
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e)) """