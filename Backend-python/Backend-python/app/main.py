from fastapi import FastAPI

from app.api.analysis_routes import router as analysis_router

app = FastAPI(title="PetroVision API")

app.include_router(analysis_router)


@app.get("/")
def root():
    return {"message": "PetroVision backend is running"}