# ========================================================================================================
# PetroVision FastAPI Application
# --------------------------------------------------------------------------------------------------------
# This file is the main entry point for the
# PetroVision backend application.
#
# Features included:
# - Initializing the FastAPI application
# - Configuring CORS middleware settings
# - Registering API route modules
# - Connecting authentication, station,
#   loyalty, offer, and analysis routes
# - Providing the root API status endpoint
#
# It also centralizes backend API configuration
# and manages the integration of all
# PetroVision backend services and routes.
# ========================================================================================================

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.auth_routes import router as auth_router
from app.api.station_routes import router as station_router
from app.api.stations_from_db_routes import router as stations_db_router
from app.api.loyalty_routes import router as loyalty_router
from app.api.offer_routes import router as offer_router
from app.api.analysis_routes import router as analysis_router    

app = FastAPI(title="PetroVision API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router)
app.include_router(station_router)
app.include_router(stations_db_router)
app.include_router(loyalty_router)
app.include_router(offer_router)
app.include_router(analysis_router, prefix="/analysis", tags=["Analysis"]) 

@app.get("/")
def root():
    return {"message": "PetroVision backend is running"}