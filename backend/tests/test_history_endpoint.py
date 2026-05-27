import pytest
from fastapi.testclient import TestClient
import os
import sys
import json

# Add backend directory to Python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import main
from main import app

client = TestClient(app)

TEST_STORAGE_FILE = "test_storage.json"

@pytest.fixture(autouse=True)
def setup_test_storage():
    """
    Fixture that redirects main.STORAGE_FILE to a temporary file
    and deletes it after tests run to protect original data.
    """
    # Overwrite the storage file path in main.py
    original_file = main.STORAGE_FILE
    main.STORAGE_FILE = TEST_STORAGE_FILE
    
    # Initialize with clean empty list
    with open(TEST_STORAGE_FILE, "w") as f:
        json.dump([], f)
        
    yield
    
    # Clean up file
    if os.path.exists(TEST_STORAGE_FILE):
        os.remove(TEST_STORAGE_FILE)
        
    # Restore original path
    main.STORAGE_FILE = original_file

def test_get_history_empty():
    """
    Verify get history returns empty list when no data is recorded.
    """
    response = client.get("/analysis/history")
    assert response.status_code == 200
    assert response.json() == []

def test_get_history_with_records():
    """
    Verify get history lists all recorded analyses.
    """
    mock_records = [
        {"id": "id_1", "userId": "user_1", "bmi": 21.0, "riskLevel": "Düşük Risk"},
        {"id": "id_2", "userId": "user_2", "bmi": 28.5, "riskLevel": "Orta Risk"}
    ]
    
    # Write mock data to our test storage
    with open(TEST_STORAGE_FILE, "w") as f:
        json.dump(mock_records, f)
        
    response = client.get("/analysis/history")
    assert response.status_code == 200
    json_data = response.json()
    assert len(json_data) == 2
    assert json_data[0]["id"] == "id_1"
    assert json_data[1]["id"] == "id_2"

def test_get_analysis_by_id_success():
    """
    Verify get analysis by ID returns correct record for valid ID.
    """
    mock_record = {"id": "target_id", "userId": "user_1", "bmi": 22.0, "riskLevel": "Düşük Risk"}
    
    with open(TEST_STORAGE_FILE, "w") as f:
        json.dump([mock_record], f)
        
    response = client.get("/analysis/target_id")
    assert response.status_code == 200
    json_data = response.json()
    assert json_data["id"] == "target_id"
    assert json_data["bmi"] == 22.0

def test_get_analysis_by_id_not_found():
    """
    Verify get analysis by ID returns 404 error code for non-existing ID.
    """
    response = client.get("/analysis/non_existent_id")
    assert response.status_code == 404
    assert response.json()["detail"] == "Analysis not found"
