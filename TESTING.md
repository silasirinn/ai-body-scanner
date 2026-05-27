# AI Body Scanner Test Suite Guide

This project contains a comprehensive test suite covering the **Frontend (Flutter)**, **Backend (FastAPI)**, and the **AI Engine** logic. All tests are designed to be extremely fast and robust, heavily utilizing mocks (especially bypassing the heavy MediaPipe model loading during backend tests).

---

## 1. Frontend (Flutter) Test Suite

### Location
All frontend test files are located in the `flutter_app/test/` directory:
- `dashboard_screen_test.dart`: Tests photo capture/upload logic, conditional rendering of the "Analizi Başlat" button, and mock MethodChannel integration.
- `analyzing_screen_test.dart`: Tests BLoC states (`ScannerSuccess` / `ScannerError`) and correct dialog alerts for invalid photos.
- `results_screen_test.dart`: Tests data mapping, layout verification, and onViewProgram routing callback parameters.
- `program_screen_test.dart`: Tests meal and exercise plans rendering, macro calculation, and fallback UI layout.
- `ai_result_mapper_test.dart`: Unit tests verifying that raw `AiOutput` maps correctly into UI compatible schemas.

### Pre-requisites
Make sure you have Flutter installed and dependencies resolved:
```bash
cd flutter_app
flutter pub get
```

### Running Tests
Execute the entire Flutter test suite using:
```bash
flutter test
```

To run a specific test file:
```bash
flutter test test/dashboard_screen_test.dart
```

---

## 2. Backend & AI Engine (FastAPI) Test Suite

### Location
All backend test files are located in the `backend/tests/` directory:
- `test_analysis_endpoint.py`: Tests the `POST /analysis` endpoint with mock file streams, success states, invalid photo payloads, and non-numeric input validation.
- `test_history_endpoint.py`: Tests the `GET /analysis/history` and `GET /analysis/{id}` endpoints, utilizing an isolated JSON storage file fixture to keep your original data clean.
- `test_ai_engine.py`: Unit tests the math and physiology rules inside `QualityChecker`, `FeatureExtractor`, `Estimators`, and `Recommender` using simulated 33 standing pose landmarks.

### Pre-requisites
Make sure you have `pytest` and `httpx` installed in your Python environment:
```bash
cd backend
pip install pytest httpx
```

### Running Tests
Execute all python tests using:
```bash
pytest tests/
```

To run tests with detailed output (`-v` verbose and `-s` to display `stdout` prints):
```bash
pytest -v -s tests/
```

---

## 3. Recommended Automated CI/CD Execution Command

To run all tests across both modules in one go:
```bash
(cd flutter_app && flutter test) && (cd backend && pytest tests/)
```
