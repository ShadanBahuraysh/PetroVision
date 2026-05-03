from fastapi import APIRouter, HTTPException
from datetime import datetime

from app.supabase_client import supabase
from app.patterns.strategy.point_calculation import PointCalculation
from app.schemas.loyalty_schema import EarnPointsRequest, RedeemPointsRequest

router = APIRouter(prefix="/loyalty", tags=["Loyalty"])


def generate_transaction_id():
    result = supabase.table("transactions").select("transaction_id").execute()
    next_number = len(result.data or []) + 1
    return f"TRX-{next_number:04d}"


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
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


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
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/earn-points")
def earn_points(data: EarnPointsRequest):
    try:
        if data.amount <= 0:
            raise HTTPException(status_code=400, detail="Amount must be greater than zero")

        point_calculator = PointCalculation()
        point_calculator.set_strategy_by_tier(data.tier)
        earned_points = point_calculator.calculate(data.amount)

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
        new_points = current_points + earned_points

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
                "amount": data.amount,
                "points": earned_points,
                "type": "earn",
                "station_id": data.station_id,
                "account_id": account_id
            }).execute()
        except Exception as transaction_error:
            print("Transaction insert failed:", transaction_error)

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
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/redeem-points")
def redeem_points(data: RedeemPointsRequest):
    try:
        if data.points <= 0:
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
                "account_id": account_id
            }).execute()
        except Exception as transaction_error:
            print("Transaction insert failed:", transaction_error)

        return {
            "message": "Points redeemed successfully",
            "user_id": data.user_id,
            "account_id": account_id,
            "redeemed_points": data.points,
            "current_points": new_points,
            "account": update_result.data[0] if update_result.data else None
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


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
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


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
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/programs")
def get_loyalty_programs():
    try:
        result = supabase.table("loyalty_program").select("*").execute()
        return result.data or []

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


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

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))