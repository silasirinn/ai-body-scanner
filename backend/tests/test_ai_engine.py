import pytest
from unittest.mock import patch, MagicMock
import sys
import os
import math

# Add backend directory to Python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from ai_engine.body_analyzer import BodyAnalyzer
from ai_engine.quality_checker import QualityChecker
from ai_engine.feature_extractor import FeatureExtractor
from ai_engine.estimators import Estimators
from ai_engine.recommender import Recommender

class MockLandmark:
    def __init__(self, x, y, visibility=0.9):
        self.x = x
        self.y = y
        self.visibility = visibility

def make_mock_landmarks(visibility_dict=None, shoulder_level_diff=0.0):
    """
    Helper to generate a list of 33 mock landmarks for testing.
    """
    landmarks = []
    for i in range(33):
        visibility = 0.9
        if visibility_dict and i in visibility_dict:
            visibility = visibility_dict[i]
            
        # Standard default coordinates simulating standing pose
        x_val = 0.45 if i % 2 == 0 else 0.55
        y_val = 0.5
        
        if i == 0: # Nose
            y_val = 0.15
        elif i == 11: # Left shoulder
            y_val = 0.3
        elif i == 12: # Right shoulder
            y_val = 0.3 + shoulder_level_diff
        elif i == 23: # Left hip
            y_val = 0.55
        elif i == 24: # Right hip
            y_val = 0.55
        elif i == 25 or i == 26: # Knees
            y_val = 0.75
        elif i == 27 or i == 28: # Ankles
            y_val = 0.95
        elif i == 15 or i == 16: # Wrists
            y_val = 0.55 # Keep near hips but not touching
            
        landmarks.append(MockLandmark(x=x_val, y=y_val, visibility=visibility))
    return landmarks

def test_quality_checker_full_body_ok():
    """
    Verify QualityChecker passes standing pose with all visible landmarks.
    """
    checker = QualityChecker()
    landmarks = make_mock_landmarks()
    image_size = (600, 800)
    
    result = checker.check(landmarks, image_size)
    assert result['fullBodyVisible'] is True
    assert result['poseOk'] is True
    assert result['confidenceScore'] > 0.7

def test_quality_checker_missing_parts():
    """
    Verify QualityChecker fails and lowers confidence if body parts are invisible.
    """
    checker = QualityChecker()
    # Mark ankles (index 27, 28) as invisible (visibility <= 0.5)
    landmarks = make_mock_landmarks(visibility_dict={27: 0.1, 28: 0.1})
    image_size = (600, 800)
    
    result = checker.check(landmarks, image_size)
    assert result['fullBodyVisible'] is False
    # Ankles should be listed under missing parts
    assert "Feet" in result['missingParts']

def test_quality_checker_unlevel_shoulders():
    """
    Verify QualityChecker detects unlevel shoulders.
    """
    checker = QualityChecker()
    # Induce massive vertical shoulder slope difference (0.1 normalized in 800px is 80px difference)
    landmarks = make_mock_landmarks(shoulder_level_diff=0.1)
    image_size = (600, 800)
    
    result = checker.check(landmarks, image_size)
    assert result['poseOk'] is False
    assert any("Shoulders not level" in m for m in result['messages'])

def test_feature_extractor_ratios():
    """
    Verify FeatureExtractor computes key ratios.
    """
    extractor = FeatureExtractor()
    landmarks = make_mock_landmarks()
    image_size = (600, 800)
    
    features = extractor.extract(landmarks, image_size)
    assert "shoulderWidthPx" in features
    assert "hipWidthPx" in features
    assert "torsoLengthPx" in features
    assert features["shoulderWidthPx"] > 0
    assert features["hipWidthPx"] > 0
    assert features["shr"] == features["shoulderWidthPx"] / features["hipWidthPx"]

def test_estimators_calculations():
    """
    Verify Estimators computes BMI, body fat percentage, lean mass, and risk levels correctly.
    """
    estimators = Estimators()
    features = {
        "whtrProxy": 0.16,
        "shr": 1.2,
        "ltr": 1.1,
        "isHeightReliable": 1.0
    }
    
    # 180cm, 80kg male, 25 years old
    result = estimators.estimate(
        height_cm=180.0,
        weight_kg=80.0,
        age=25,
        gender="male",
        features=features,
        confidence_score=0.9
    )
    
    # BMI = 80 / (1.8^2) = 24.69
    assert result["bmi"] == 24.69
    assert result["bodyFatPct"] > 5.0
    assert result["leanMassKg"] > 40.0
    assert result["riskLevel"] in ["Düşük Risk", "Orta Risk", "Yüksek Risk"]

def test_recommender_maintain():
    """
    Verify Recommender calculates target calories and macros.
    """
    recommender = Recommender()
    
    # 80kg male, 180cm, 25 years old, Maintain goal
    result = recommender.recommend(
        age=25,
        gender="male",
        weight_kg=80.0,
        height_cm=180.0,
        goal="maintain",
        risk_level="Düşük Risk",
        body_fat_pct=15.0,
        lean_mass_kg=68.0
    )
    
    # Daily calories should be near ~2500 kcal
    assert 1800 < result["dailyCalories"] < 3000
    assert "macros" in result
    assert "dietPlan" in result
    assert "workoutPlan" in result
    assert len(result["dietPlan"]) >= 3
    assert len(result["workoutPlan"]) >= 2

def test_body_analyzer_integration():
    """
    Verify BodyAnalyzer runs the whole pipeline using mocked pose detector.
    """
    analyzer = BodyAnalyzer()
    
    # Mock the internal _pose_detector wrapper to return mock landmarks directly
    mock_landmarks = make_mock_landmarks()
    analyzer._pose_detector.detect = MagicMock(return_value=mock_landmarks)
    
    # Create empty mock image shape
    mock_image = MagicMock()
    mock_image.shape = (800, 600, 3) # Height, width, channels
    
    result = analyzer.analyze(
        image=mock_image,
        height_cm=180.0,
        weight_kg=80.0,
        age=25,
        gender="male",
        goal="lose"
    )
    
    assert result["success"] is True
    assert result["landmarksDetected"] is True
    assert "bmi" in result
    assert "bodyFatPct" in result
    assert "leanMassKg" in result
    assert "calories" in result
