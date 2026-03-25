# AI Body Scanner 💪🤖

A full-stack AI-powered mobile application that analyzes full-body photos to estimate body fat percentage, lean mass, and calculate health risk levels. It dynamically generates personalized diet and workout plans based on the user's bodily geometry.

## 🌟 Key Features
* **Advanced Pose Detection**: Uses Google's modern **MediaPipe Tasks API** to identify 33 precise 3D body landmarks.
* **Proportional Analysis**: Extracts true-pixel distances and calculates advanced proxies like:
  * WHtR (Waist-to-Height Ratio)
  * SHR (Shoulder-to-Hip Ratio)
  * LTR (Limb-to-Torso Ratio)
* **Robust Body Fat Estimator**: Combines baseline Deurenberg calculations with visual aspect-ratio-corrected image features for highly accurate, shape-sensitive outputs.
* **Smart Quality Gates**: Automatically rejects non-human photos, incomplete body frames, and poor lighting/poses to prevent hallucinated results.
* **Cross-Platform Mobile App**: Crafted natively with Flutter for seamless iOS & Android performance.

---

## 🏗️ Architecture

The project consists of two highly decoupled engines:

1. **`flutter_app/` (Frontend)**
   * Built with Flutter / Dart.
   * Handles camera operations, UI state management (Bloc), and dynamic rendering of the workout/diet recommendations.
2. **`backend/` (AI Engine)**
   * Built with Python 3 & FastAPI.
   * Processes the multipart-form image streams using OpenCV and MediaPipe.
   * Executes the complex mathematical ratios and health classification logic remotely.

---

## 🚀 Getting Started

### 1. Starting the Python Backend
Ensure you have Python 3.10+ installed.

```bash
cd backend
# Install required ML libraries (OpenCV, MediaPipe, FastAPI)
pip install -r requirements.txt

# Start the local AI server
uvicorn main:app --host 0.0.0.0 --port 3000
```

### 2. Running the Flutter App
Ensure you have the Flutter SDK installed.

```bash
cd flutter_app
# Install dependencies
flutter pub get

# Run on a connected physical device or iOS/Android simulator
flutter run
```

*(Note: To test on a physical iPhone, ensure your Mac and iPhone are on the same Wi-Fi network. Update `api_service.dart` with your Mac's true Local IP address instead of localhost.)*

---

## 🛠️ Tech Stack
* **Frontend**: Flutter, Dart, flutter_bloc, animate_do
* **Backend**: Python, FastAPI, Uvicorn
* **AI & Computer Vision**: OpenCV, MediaPipe (Tasks Vision API), NumPy
