from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class LoyaltyAccountResponse(BaseModel):
    account_id: str
    current_points: Optional[int] = 0
    user_id: Optional[str] = None


class LoyaltyProgramResponse(BaseModel):
    program_id: str
    type: str
    description: Optional[str] = None


class MembershipResponse(BaseModel):
    membership_id: str
    status: Optional[str] = None
    started_at: Optional[datetime] = None
    ended_at: Optional[datetime] = None
    tier: Optional[str] = None
    program_id: Optional[str] = None
    account_id: Optional[str] = None
    user_id: Optional[str] = None


class OfferResponse(BaseModel):
    offer_id: str
    offer_type: Optional[str] = None
    earn_points: Optional[int] = None
    redeem_points: Optional[int] = None
    user_id: Optional[str] = None


class TransactionResponse(BaseModel):
    transaction_id: str
    date: Optional[datetime] = None
    amount: Optional[float] = None
    points: Optional[int] = None
    type: Optional[str] = None
    offer_id: Optional[str] = None
    station_id: Optional[str] = None
    account_id: Optional[str] = None


class EarnPointsRequest(BaseModel):
    user_id: str
    station_id: Optional[str] = None
    amount: float
    tier: str = "Bronze"
    description: Optional[str] = "Points earned from station visit"


class RedeemPointsRequest(BaseModel):
    user_id: str
    points: int
    description: Optional[str] = "Points redeemed"