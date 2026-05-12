# ========================================================================================================
# PetroVision Loyalty Routes
# --------------------------------------------------------------------------------------------------------
# This file contains all loyalty-system API endpoints
# for the PetroVision system, including:
# - Loyalty account retrieval
# - Points balance management
# - Earning and redeeming loyalty points
# - Membership and tier handling
# - Transaction history retrieval
# - Loyalty program management
# - Loyalty analytics and admin summaries
#
# It also integrates the Strategy design pattern
# for calculating earned points dynamically
# based on customer membership tiers.
# ========================================================================================================

from fastapi import APIRouter, HTTPException
from datetime import datetime
from app.supabase_client import supabase
from app.patterns.strategy.point_calculation import PointCalculation
from app.schemas.loyalty_schema import EarnPointsRequest, RedeemPointsRequest

router = APIRouter(prefix="/loyalty", tags=["Loyalty"])


def generate_transaction_id():
    import uuid
    return f"TRX-{uuid.uuid4().hex[:8].upper()}"


@router.get("/account/{user_id}")
def get_loyalty_account(user_id: str):
    try:
        result = (
            supabase.table("loyalty_account")
            .select("*")
            .eq("user_id", user_id)
            .execute()
        )

        if not result.data:
            raise HTTPException(status_code=404, detail="Loyalty account not found")

        return result.data[0]

    except HTTPException:
        raise

    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid loyalty input: {str(e)}"
        )

    except KeyError as e:
        raise HTTPException(
            status_code=500,
            detail=f"Missing required loyalty field: {str(e)}"
        )

    except TypeError:
        raise HTTPException(
            status_code=500,
            detail="Invalid loyalty data format"
        )

    except Exception:
        raise HTTPException(
            status_code=500,
            detail="Unexpected loyalty service error"
        )


@router.get("/points/{user_id}")
def get_points(user_id: str):
    try:
        result = (
            supabase.table("loyalty_account")
            .select("account_id,current_points,user_id")
            .eq("user_id", user_id)
            .execute()
        )

        if not result.data:
            raise HTTPException(status_code=404, detail="No account found for this user")

        account = result.data[0]

        return {
            "user_id": user_id,
            "account_id": account["account_id"],
            "current_points": account.get("current_points", 0)
        }

    except HTTPException:
        raise

    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid loyalty input: {str(e)}"
        )

    except KeyError as e:
        raise HTTPException(
            status_code=500,
            detail=f"Missing required loyalty field: {str(e)}"
        )

    except TypeError:
        raise HTTPException(
            status_code=500,
            detail="Invalid loyalty data format"
        )

    except Exception:
        raise HTTPException(
            status_code=500,
            detail="Unexpected loyalty service error"
        )


@router.post("/earn-points")
def earn_points(data: EarnPointsRequest):
    try:
        if data.amount <= 0:
            raise HTTPException(status_code=400, detail="Amount must be greater than zero")
        
        # Find offer by earn QR code
        offer_result = (
            supabase.table("offer")
            .select("*")
            .eq("earn_qr_code", data.qr_code)
            .execute()
        )
        if not offer_result.data:
            raise HTTPException(status_code=404, detail="Invalid QR code")
        offer = offer_result.data[0]

        # Get user loyalty account
        account_result = (
            supabase.table("loyalty_account")
            .select("*")
            .eq("user_id", data.user_id)
            .execute()
        )
        if not account_result.data:
            raise HTTPException(status_code=404, detail="Loyalty account not found")
        account = account_result.data[0]
        account_id = account["account_id"]

        # Check if THIS user already earned from this offer (per-user, not global)
        used_by_user = (
            supabase.table("transactions")
            .select("transaction_id")
            .eq("offer_id", offer["offer_id"])
            .eq("account_id", account_id)
            .eq("type", "earn")
            .execute()
        )
        if used_by_user.data:
            raise HTTPException(
                status_code=400,
                detail="You have already used this offer. Each offer can only be earned once per user."
            )

        base_points = offer.get("earn_points", 0) or 0
        point_calculator = PointCalculation()
        point_calculator.set_strategy_by_tier(data.tier)
        earned_points = point_calculator.calculate(base_points)

        current_points = account.get("current_points", 0) or 0
        new_points = current_points + earned_points

        update_result = (
            supabase.table("loyalty_account")
            .update({"current_points": new_points})
            .eq("account_id", account_id)
            .execute()
        )

        # Auto tier upgrade based on new points balance
        if new_points >= 5000:
            new_tier = "Gold"
        elif new_points >= 1000:
            new_tier = "Silver"
        else:
            new_tier = "Bronze"

        supabase.table("membership").update(
            {"tier": new_tier}
        ).eq("account_id", account_id).execute()
        supabase.table("transactions").insert({
                "transaction_id": generate_transaction_id(),
                "date": datetime.utcnow().isoformat(),
                "amount": data.amount,
                "points": earned_points,
                "type": "earn",
                "station_id": data.station_id,
                "account_id": account_id,
                "offer_id": offer["offer_id"],
            }).execute()
        return {
            "message": "Points added successfully",
            "user_id": data.user_id,
            "account_id": account_id,
            "tier": data.tier,
            "amount": data.amount,
            "earned_points": earned_points,
            "current_points": new_points,
            "account": update_result.data[0] if update_result.data else None
        }
    except HTTPException:
        raise

    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid loyalty input: {str(e)}"
        )

    except KeyError as e:
        raise HTTPException(
            status_code=500,
            detail=f"Missing required loyalty field: {str(e)}"
        )

    except TypeError:
        raise HTTPException(
            status_code=500,
            detail="Invalid loyalty data format"
        )

    except Exception:
        raise HTTPException(
            status_code=500,
            detail="Unexpected loyalty service error"
        )


@router.post("/redeem-points")
def redeem_points(data: RedeemPointsRequest):
    try:
        if data.points < 0:
            raise HTTPException(status_code=400, detail="Points must be greater than zero")

        account_result = (
            supabase.table("loyalty_account")
            .select("*")
            .eq("user_id", data.user_id)
            .execute()
        )

        if not account_result.data:
            raise HTTPException(status_code=404, detail="Loyalty account not found")

        account = account_result.data[0]
        account_id = account["account_id"]
        current_points = account.get("current_points", 0) or 0
        offer_result = (
                supabase.table("offer")
                .select("*")
                .eq("offer_id", data.offer_id)
                .execute()
            )

        if not offer_result.data:
            raise HTTPException(status_code=404, detail="Offer not found")

        offer = offer_result.data[0]

        if current_points < data.points:
            raise HTTPException(status_code=400, detail="Not enough points")

        new_points = current_points - data.points

        update_result = (
            supabase.table("loyalty_account")
            .update({"current_points": new_points})
            .eq("account_id", account_id)
            .execute()
        )

        try:
            supabase.table("transactions").insert({
                "transaction_id": generate_transaction_id(),
                "date": datetime.utcnow().isoformat(),
                "amount": 0,
                "points": data.points,
                "type": "redeem",
                "station_id": None,
                "account_id": account_id,
                "offer_id": data.offer_id
            }).execute()
        except (RuntimeError, ValueError) as transaction_error:
            print("Transaction insert failed:", transaction_error)

        return {
            "message": "Points redeemed successfully",
            "offer_name": offer.get("name"),
            "redeem_qr_code": offer.get("redeem_qr_code"),
            "user_id": data.user_id,
            "account_id": account_id,
            "redeemed_points": data.points,
            "current_points": new_points,
            "account": update_result.data[0] if update_result.data else None
        }

    except HTTPException:
        raise

    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid loyalty input: {str(e)}"
        )

    except KeyError as e:
        raise HTTPException(
            status_code=500,
            detail=f"Missing required loyalty field: {str(e)}"
        )

    except TypeError:
        raise HTTPException(
            status_code=500,
            detail="Invalid loyalty data format"
        )

    except Exception:
        raise HTTPException(
            status_code=500,
            detail="Unexpected loyalty service error"
        )


@router.get("/membership/{user_id}")
def get_membership(user_id: str):
    try:
        account_result = (
            supabase.table("loyalty_account")
            .select("account_id")
            .eq("user_id", user_id)
            .execute()
        )

        if not account_result.data:
            raise HTTPException(status_code=404, detail="No loyalty account found")

        account_id = account_result.data[0]["account_id"]

        membership_result = (
            supabase.table("membership")
            .select("*")
            .eq("account_id", account_id)
            .execute()
        )

        if not membership_result.data:
            return {}

        return membership_result.data[0]

    except HTTPException:
        raise

    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid loyalty input: {str(e)}"
        )

    except KeyError as e:
        raise HTTPException(
            status_code=500,
            detail=f"Missing required loyalty field: {str(e)}"
        )

    except TypeError:
        raise HTTPException(
            status_code=500,
            detail="Invalid loyalty data format"
        )

    except Exception:
        raise HTTPException(
            status_code=500,
            detail="Unexpected loyalty service error"
        )


@router.get("/transactions/{user_id}")
def get_transactions(user_id: str):
    try:
        account_result = (
            supabase.table("loyalty_account")
            .select("account_id")
            .eq("user_id", user_id)
            .execute()
        )

        if not account_result.data:
            raise HTTPException(status_code=404, detail="No loyalty account found")

        account_id = account_result.data[0]["account_id"]

        transactions_result = (
            supabase.table("transactions")
            .select("*")
            .eq("account_id", account_id)
            .order("date", desc=True)
            .execute()
        )

        return transactions_result.data or []

    except HTTPException:
        raise

    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid loyalty input: {str(e)}"
        )

    except KeyError as e:
        raise HTTPException(
            status_code=500,
            detail=f"Missing required loyalty field: {str(e)}"
        )

    except TypeError:
        raise HTTPException(
            status_code=500,
            detail="Invalid loyalty data format"
        )

    except Exception:
        raise HTTPException(
            status_code=500,
            detail="Unexpected loyalty service error"
        )


@router.get("/programs")
def get_loyalty_programs():
    try:
        result = supabase.table("loyalty_program").select("*").execute()
        return result.data or []

    except HTTPException:
        raise


    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid loyalty input: {str(e)}"
        )

    except KeyError as e:
        raise HTTPException(
            status_code=500,
            detail=f"Missing required loyalty field: {str(e)}"
        )

    except TypeError:
        raise HTTPException(
            status_code=500,
            detail="Invalid loyalty data format"
        )

    except Exception:
        raise HTTPException(
            status_code=500,
            detail="Unexpected loyalty service error"
        )


@router.get("/admin-summary")
def get_loyalty_admin_summary(year: int = datetime.utcnow().year, month: int | None = None):
    try:
        customers = supabase.table("customer").select("*").execute().data or []
        memberships = supabase.table("membership").select("*").execute().data or []
        transactions = supabase.table("transactions").select("*").execute().data or []

        monthly_counts = {m: 0 for m in range(1, 13)}

        for transaction in transactions:
            date_value = transaction.get("date")
            if not date_value:
                continue

            try:
                date_text = str(date_value).replace("Z", "")
                dt = datetime.fromisoformat(date_text)
            except ValueError:
                continue

            except Exception:
                continue

            if dt.year == year and (month is None or dt.month == month):
                monthly_counts[dt.month] += 1

        member_growth = [
            {"month": m, "count": monthly_counts[m]} for m in range(1, 13)
        ]

        tier_counts = {"Gold": 0, "Silver": 0, "Bronze": 0}

        for membership in memberships:
            tier = str(membership.get("tier", "Bronze")).strip().capitalize()
            if tier in tier_counts:
                tier_counts[tier] += 1
            else:
                tier_counts["Bronze"] += 1

        return {
            "year": year,
            "month": month,
            "total_customers": len(customers),
            "member_growth": member_growth,
            "tier_distribution": tier_counts,
        }
    
    except HTTPException:
        raise

    except ValueError as e:
        raise HTTPException(status_code=400, detail=f"Invalid loyalty input: {str(e)}")

    except KeyError as e:
        raise HTTPException(status_code=500, detail=f"Missing required loyalty field: {str(e)}")

    except TypeError:
        raise HTTPException(status_code=500, detail="Invalid loyalty data format")

    except Exception:
        raise HTTPException(status_code=500, detail="Unexpected loyalty service error")
