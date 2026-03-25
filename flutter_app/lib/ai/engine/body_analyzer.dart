import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../models/ai_output.dart';
import 'pose_detector.dart';
import 'quality_checker.dart';
import 'feature_extractor.dart';
import 'estimators.dart';
import 'recommender.dart';

class BodyAnalyzer {
  final _poseDetector = PoseDetectorWrapper();
  final _qualityChecker = QualityChecker();
  final _featureExtractor = FeatureExtractor();
  final _estimators = Estimators();
  final _recommender = Recommender();

  Future<AiOutput> analyze({
    required InputImage inputImage,
    required Size imageSize, // Need dimensions
    required double heightCm,
    required double weightKg,
    required int age,
    required String gender,
    required String goal,
  }) async {
    // 1. Detect Pose
    final landmarks = await _poseDetector.detect(inputImage);
    
    // Default error structure
    AiOutput errorResponse(String msg, {String risk = "Risk", double poseScore = 0.0, Map<String, dynamic>? qualityChecks}) {
        return AiOutput(
            landmarksDetected: false,
            riskLevel: risk,
            recommendations: AiRecommendations(dailyCalories: 0, macros: {}, dietPlan: [], workoutPlan: []),
            debug: AiDebug(
                poseScore: poseScore,
                qualityChecks: qualityChecks ?? {'fullBodyVisible': false, 'poseOk': false, 'error': msg},
                rawRatios: {},
                error: msg
            )
        );
    }

    if (landmarks == null || landmarks.isEmpty) {
        debugPrint("AI_DEBUG: BodyAnalyzer - No human pose detected");
        return errorResponse("No human pose detected");
    }
    debugPrint("AI_DEBUG: BodyAnalyzer - Landmarks detected: ${landmarks.length}");
    
    // Summary of landmarks to verify uniqueness
    final first5 = landmarks.take(5).map((l) => "(${l.x.toInt()},${l.y.toInt()})").join(", ");
    debugPrint("AI_DEBUG: BodyAnalyzer - First 5 Landmarks: $first5");
    
    final minX = landmarks.map((l) => l.x).reduce(min);
    final maxX = landmarks.map((l) => l.x).reduce(max);
    final minY = landmarks.map((l) => l.y).reduce(min);
    final maxY = landmarks.map((l) => l.y).reduce(max);
    debugPrint("AI_DEBUG: BodyAnalyzer - BBox: [${minX.toInt()}, ${minY.toInt()}] to [${maxX.toInt()}, ${maxY.toInt()}]");

    // 2. BMI Baseline Fallback (Always have a result)
    final heightM = heightCm / 100;
    double bmiBaseline = weightKg / (heightM * heightM);
    
    // 3. Quality Check
    final qualityChecks = _qualityChecker.check(landmarks, imageSize);
    bool fullBodyVisible = qualityChecks['fullBodyVisible'] ?? false;
    bool poseOk = qualityChecks['poseOk'] ?? false;
    
    if (!fullBodyVisible || !poseOk) {
        debugPrint("AI_DEBUG: BodyAnalyzer - Quality Issues Detected (ABORTING ANALYSIS)");
        debugPrint("   > Visible: $fullBodyVisible, PoseOk: $poseOk");
        debugPrint("   > Messages: ${qualityChecks['messages']}");
        return errorResponse("Fotoğraf analiz için uygun değil. Lütfen tam vücut ve talimatlara uygun bir fotoğraf yükleyin.", qualityChecks: qualityChecks);
    }

    // 3. Features
    final features = _featureExtractor.extract(landmarks);

    // Score heuristic (average visibility of key points)
    double score = landmarks.map((e) => e.likelihood).reduce((a, b) => a + b) / landmarks.length;
    double confidence = (qualityChecks['confidenceScore'] as double?) ?? score;

    // 4. Estimates
    final estimates = _estimators.estimate(
        heightCm: heightCm,
        weightKg: weightKg,
        age: age,
        gender: gender,
        features: features,
        confidenceScore: confidence
    );

    // 5. Recommendations
    final recs = _recommender.recommend(
        age: age,
        gender: gender,
        weightKg: weightKg,
        heightCm: heightCm,
        goal: goal,
        riskLevel: estimates['riskLevel'],
        bodyFatPct: estimates['bodyFatPct'],
        leanMassKg: estimates['leanMassKg']
    );
    
    debugPrint("AI_DEBUG: BodyAnalyzer - Pose Score: $score, Final Confidence: $confidence");
    debugPrint("AI_DEBUG: BodyAnalyzer - Estimates: $estimates");

    return AiOutput(
        landmarksDetected: true,
        bmi: estimates['bmi'],
        bodyFatPct: estimates['bodyFatPct'],
        leanMassKg: estimates['leanMassKg'],
        confidenceScore: confidence,
        riskLevel: estimates['riskLevel'],
        recommendations: recs,
        debug: AiDebug(
            poseScore: score,
            qualityChecks: qualityChecks,
            rawRatios: features,
        )
    );
  }

  void dispose() {
    _poseDetector.close();
  }
}
