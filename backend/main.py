from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import uvicorn
from statistics_engine import DistributionModel

app = FastAPI(title="Statistical Inference API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class InferenceRequest(BaseModel):
    distribution: str
    sample_data: Optional[List[float]] = None

@app.get("/")
def read_root():
    return {"status": "ok", "message": "Statistical Inference API is running"}

@app.post("/analyze")
def analyze_distribution(request: InferenceRequest):
    try:
        model = DistributionModel(request.distribution)
        results = model.analyze(request.sample_data)
        return results
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8000)
