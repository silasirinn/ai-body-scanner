from .pose_detector import PoseDetectorWrapper
from .quality_checker import QualityChecker
from .feature_extractor import FeatureExtractor
from .estimators import Estimators
from .recommender import Recommender

class BodyAnalyzer:
    def __init__(self):
        self._pose_detector = PoseDetectorWrapper()
        self._quality_checker = QualityChecker()
        self._feature_extractor = FeatureExtractor()
        self._estimators = Estimators()
        self._recommender = Recommender()

    def analyze(self, image, height_cm, weight_kg, age, gender, goal):
        """
        Analyzes the image and user stats.
        Returns a dictionary with success boolean and either an error or the full analysis.
        """
        # 1. Detect Pose
        landmarks = self._pose_detector.detect(image)
        
        def error_response(msg, risk="Risk", pose_score=0.0, quality_checks=None):
            if quality_checks is None:
                quality_checks = {'fullBodyVisible': False, 'poseOk': False, 'error': msg}
            return {
                "success": False,
                "error": "invalid_photo", # This matches Flutter expectations
                "message": msg,
                "debug": {
                    "poseScore": pose_score,
                    "qualityChecks": quality_checks
                }
            }

        if not landmarks:
            print("AI_DEBUG: BodyAnalyzer - No human pose detected")
            return error_response("No human pose detected")
            
        print(f"AI_DEBUG: BodyAnalyzer - Landmarks detected: {len(landmarks)}")

        # Print first 5
        first5 = ", ".join([f"({int(l.x*image.shape[1])},{int(l.y*image.shape[0])})" for l in landmarks[:5]])
        print(f"AI_DEBUG: BodyAnalyzer - First 5 Landmarks: {first5}")

        x_coords = [l.x * image.shape[1] for l in landmarks]
        y_coords = [l.y * image.shape[0] for l in landmarks]
        print(f"AI_DEBUG: BodyAnalyzer - BBox: [{int(min(x_coords))}, {int(min(y_coords))}] to [{int(max(x_coords))}, {int(max(y_coords))}]")

        # 2. Quality Check
        # image.shape is (height, width, channels)
        image_size = (image.shape[1], image.shape[0]) 
        quality_checks = self._quality_checker.check(landmarks, image_size)
        
        full_body_visible = quality_checks.get('fullBodyVisible', False)
        pose_ok = quality_checks.get('poseOk', False)

        if not full_body_visible or not pose_ok:
            print("AI_DEBUG: BodyAnalyzer - Quality Issues Detected (ABORTING ANALYSIS)")
            print(f"   > Visible: {full_body_visible}, PoseOk: {pose_ok}")
            print(f"   > Messages: {quality_checks.get('messages')}")
            return error_response("Fotoğraf analiz için uygun değil. Lütfen tam vücut ve talimatlara uygun bir fotoğraf yükleyin.", quality_checks=quality_checks)

        # 3. Features
        features = self._feature_extractor.extract(landmarks, image_size)

        # Score heuristic
        score = sum([l.visibility for l in landmarks]) / len(landmarks)
        confidence = quality_checks.get('confidenceScore', score)

        # 4. Estimates
        estimates = self._estimators.estimate(
            height_cm=height_cm,
            weight_kg=weight_kg,
            age=age,
            gender=gender,
            features=features,
            confidence_score=confidence
        )

        # 5. Recommendations
        recs = self._recommender.recommend(
            age=age,
            gender=gender,
            weight_kg=weight_kg,
            height_cm=height_cm,
            goal=goal,
            risk_level=estimates['riskLevel'],
            body_fat_pct=estimates['bodyFatPct'],
            lean_mass_kg=estimates['leanMassKg']
        )
        
        print(f"AI_DEBUG: BodyAnalyzer - Pose Score: {score}, Final Confidence: {confidence}")
        print(f"AI_DEBUG: BodyAnalyzer - Estimates: {estimates}")

        return {
            "success": True,
            "landmarksDetected": True,
            "bmi": estimates['bmi'],
            "bodyFatPct": estimates['bodyFatPct'],
            "leanMassKg": estimates['leanMassKg'],
            "confidenceScore": confidence,
            "riskLevel": estimates['riskLevel'],
            "calories": recs['dailyCalories'],
            "macros": recs['macros'],
            "dietPlan": recs['dietPlan'],
            "workoutPlan": recs['workoutPlan'],
            "debug": {
                "poseScore": score,
                "qualityChecks": quality_checks,
                "rawRatios": features
            }
        }

    def close(self):
        self._pose_detector.close()
