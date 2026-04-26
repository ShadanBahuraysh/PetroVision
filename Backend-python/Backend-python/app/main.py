from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.analysis_routes import router as analysis_router
from app.api.station_routes import router as station_router
from app.api.loyalty_routes import router as loyalty_router
from app.api.offer_routes import router as offer_router

app = FastAPI(title="PetroVision API")

# لازم يكون هنا أول شيء
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(analysis_router)
app.include_router(station_router)
app.include_router(loyalty_router)
app.include_router(offer_router)

@app.get("/")
def root():
    return {"message": "PetroVision backend is running"}
