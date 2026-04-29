from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional

from app.supabase_client import supabase

router = APIRouter(prefix="/offers", tags=["Offers"])


class OfferRequest(BaseModel):
    offer_type: Optional[str] = None
    earn_points: Optional[int] = 0
    redeem_points: Optional[int] = 0
    user_id: Optional[str] = None


def generate_offer_id():
    result = supabase.table("offer").select("offer_id").execute()
    next_number = len(result.data or []) + 1
    return f"OFF-{next_number:04d}"


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
        offer_data = data.model_dump(exclude_none=True)
        offer_data["offer_id"] = generate_offer_id()

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
        result = (
            supabase.table("offer")
            .update(data.model_dump(exclude_none=True))
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