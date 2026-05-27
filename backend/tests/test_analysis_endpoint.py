import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch, MagicMock
import os
import sys

import cv2
import numpy as np

# Add backend directory to Python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from main import app

client = TestClient(app)

@pytest.fixture
def mock_image():
    # Generate a valid 10x10 RGB black image and encode it as PNG bytes
    img = np.zeros((10, 10, 3), dtype=np.uint8)
    success, encoded_img = cv2.imencode('.png', img)
    if not success:
        raise ValueError("Failed to encode image to PNG format")
    return encoded_img.tobytes()

def test_analysis_success(mock_image):
    """
    Test POST /analysis with valid image and form data.
    AI analyze method is mocked to return custom mock results.
    """
    mock_response = {
        "success": True,
        "bmi": 22.5,
        "bodyFatPct": 16.2,
        "leanMassKg": 64.5,
        "confidenceScore": 0.9,
        "riskLevel": "Düşük Risk",
        "calories": 2500,
        "macros": {"protein_g": 150, "carbs_g": 300, "fat_g": 70},
        "dietPlan": ["Diyet 1", "Diyet 2"],
        "workoutPlan": ["Spor 1", "Spor 2"]
    }

    # Patch the analyze method inside backend/main.py
    with patch("main.analyzer.analyze", return_value=mock_response) as mock_analyze:
        response = client.post(
            "/analysis",
            files={"photo": ("test.png", mock_image, "image/png")},
            data={
                "userId": "user_123",
                "height": "180",
                "weight": "80",
                "age": "25",
                "gender": "male",
                "goal": "lose"
            }
        )

        assert response.status_code == 200
        json_data = response.json()
        
        # Verify response matches mocked AI values
        assert json_data["success"] is True
        assert json_data["bmi"] == 22.5
        assert json_data["bodyFatPct"] == 16.2
        assert json_data["leanMassKg"] == 64.5
        assert json_data["riskLevel"] == "Düşük Risk"
        assert json_data["calories"] == 2500
        assert json_data["macros"] == {"protein_g": 150, "carbs_g": 300, "fat_g": 70}
        assert "dietPlan" in json_data
        assert "workoutPlan" in json_data

        # Verify correct arguments were passed to analyze
        mock_analyze.assert_called_once()

def test_analysis_invalid_photo(mock_image):
    """
    Test POST /analysis when the analyzer reports an invalid photo.
    """
    mock_response = {
        "success": False,
        "error": "invalid_photo",
        "message": "No human pose detected"
    }

    with patch("main.analyzer.analyze", return_value=mock_response):
        response = client.post(
            "/analysis",
            files={"photo": ("test.png", mock_image, "image/png")},
            data={
                "userId": "user_123",
                "height": "180",
                "weight": "80",
                "age": "25",
                "gender": "male",
                "goal": "lose"
            }
        )

        assert response.status_code == 200
        json_data = response.json()
        assert json_data["success"] is False
        assert json_data["error"] == "invalid_photo"

def test_analysis_non_numeric_inputs(mock_image):
    """
    Test POST /analysis when height, weight, or age are non-numeric strings.
    """
    response = client.post(
        "/analysis",
        files={"photo": ("test.png", mock_image, "image/png")},
        data={
            "userId": "user_123",
            "height": "abc", # Non-numeric
            "weight": "80",
            "age": "25",
            "gender": "male",
            "goal": "lose"
        }
    )

    assert response.status_code == 200
    json_data = response.json()
    assert json_data["success"] is False
    assert json_data["error"] == "invalid_photo"
