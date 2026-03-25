import os
import json
import uuid
import numpy as np
import cv2
from datetime import datetime
from fastapi import FastAPI, File, UploadFile, Form, HTTPException
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from ai_engine.body_analyzer import BodyAnalyzer

app = FastAPI()
analyzer = BodyAnalyzer()

# Allow cross-origin requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

STORAGE_FILE = "storage.json"

def load_data():
    if not os.path.exists(STORAGE_FILE):
        return []
    with open(STORAGE_FILE, "r") as f:
        try:
            return json.load(f)
        except:
            return []

def save_data(data):
    with open(STORAGE_FILE, "w") as f:
        json.dump(data, f, indent=4)

@app.post("/analysis")
async def analyze_photo(
    photo: UploadFile = File(...),
    userId: str = Form("default_user"),
    height: str = Form("0"),
    weight: str = Form("0"),
    age: str = Form("0"),
    gender: str = Form(""),
    goal: str = Form("")
):
    print(f"AI_DEBUG: Backend - Received request for {userId}")
    print(f"AI_DEBUG: Backend - Form data: H={height}, W={weight}, Age={age}, Gender={gender}, Goal={goal}")
    try:
        if not photo or not photo.filename:
            print("AI_DEBUG: Backend - Invalid photo payload")
            return JSONResponse(
                status_code=200,
                content={"success": False, "error": "invalid_photo"}
            )

        # Convert string inputs
        try:
            height_cm = float(height)
            weight_kg = float(weight)
            age_int = int(age)
        except ValueError:
            print("AI_DEBUG: Backend - Invalid numeric fields")
            return JSONResponse(status_code=200, content={"success": False, "error": "invalid_photo"})

        # Read image into memory
        print(f"AI_DEBUG: Backend - Processing file {photo.filename} ({photo.size} bytes)")
        file_bytes = np.frombuffer(await photo.read(), np.uint8)
        image = cv2.imdecode(file_bytes, cv2.IMREAD_COLOR)

        if image is None:
            print("AI_DEBUG: Backend - Failed to decode image")
            return JSONResponse(status_code=200, content={"success": False, "error": "invalid_photo"})

        # Run AI Analysis
        print("AI_DEBUG: Backend - Starting real AI analysis pipeline...")
        result = analyzer.analyze(
            image=image,
            height_cm=height_cm,
            weight_kg=weight_kg,
            age=age_int,
            gender=gender,
            goal=goal
        )

        if not result.get("success", False):
            print(f"AI_DEBUG: Backend - Analysis failed: {result.get('message')}")
            return JSONResponse(
                status_code=200,
                content={"success": False, "error": "invalid_photo"}
            )
            
    except Exception as e:
        print(f"AI_DEBUG: Backend - Unhandled Exception: {e}")
        return JSONResponse(
            status_code=200,
            content={"success": False, "error": "invalid_photo"}
        )

    print("AI_DEBUG: Backend - Analysis successful, saving record.")
    analysis_id = str(uuid.uuid4())
    record = {
        "id": analysis_id,
        "userId": userId,
        "date": datetime.now().isoformat(),
        # Computed AI Results matching the exact flutter contract
        "bmi": result["bmi"],
        "bodyFatPct": result["bodyFatPct"],
        "leanMassKg": result["leanMassKg"],
        "riskLevel": result["riskLevel"],
        "calories": result["calories"],
        "macros": result["macros"],
        "dietPlan": result["dietPlan"],
        "workoutPlan": result["workoutPlan"],
        "confidenceScore": result["confidenceScore"],
        "debug": result["debug"]
    }
    
    data = load_data()
    data.append(record)
    save_data(data)

    return {
        "success": True,
        **record
    }

@app.get("/analysis/history")
async def get_history():
    return load_data()

@app.get("/analysis/{id}")
async def get_analysis_by_id(id: str):
    data = load_data()
    for record in data:
        if record["id"] == id:
            return record
    raise HTTPException(status_code=404, detail="Analysis not found")
