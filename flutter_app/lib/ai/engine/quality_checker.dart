import 'dart:ui';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:math';

class QualityChecker {
  Map<String, dynamic> check(List<PoseLandmark> landmarks, Size imageSize) {
    if (landmarks.isEmpty) {
      return {'fullBodyVisible': false, 'poseOk': false, 'lightingOk': false, 'messages': ["No landmarks detected"]};
    }

    // Map landmarks for easier access
    // ML Kit PoseLandmarkType enum:
    // 0: nose, 11: leftShoulder, 12: rightShoulder, 23: leftHip, 24: rightHip, 27: leftAnkle, 28: rightAnkle
    
    final nose = _find(landmarks, PoseLandmarkType.nose);
    final lShoulder = _find(landmarks, PoseLandmarkType.leftShoulder);
    final rShoulder = _find(landmarks, PoseLandmarkType.rightShoulder);
    final lHip = _find(landmarks, PoseLandmarkType.leftHip);
    final rHip = _find(landmarks, PoseLandmarkType.rightHip);
    final lAnkle = _find(landmarks, PoseLandmarkType.leftAnkle);
    final rAnkle = _find(landmarks, PoseLandmarkType.rightAnkle);

    // 1. Full Body Visibility
    // We need at least nose, shoulders, hips, and ankles to be somewhat visible
    bool fullBodyVisible = true;
    List<String> missing = [];
    
    if (!_isVisible(nose)) missing.add("Head");
    if (!_isVisible(lShoulder) || !_isVisible(rShoulder)) missing.add("Shoulders");
    if (!_isVisible(lHip) || !_isVisible(rHip)) missing.add("Hips");
    if (!_isVisible(lAnkle) || !_isVisible(rAnkle)) missing.add("Feet");

    if (missing.isNotEmpty) fullBodyVisible = false;

    // 2. Pose Ok (Upright)
    bool poseOk = true;
    List<String> poseMessages = [];

    if (fullBodyVisible) {
        // Shoulder slope
        double shoulderSlope = (lShoulder!.y - rShoulder!.y).abs();
        if (shoulderSlope > 40) { // Tolerant threshold in pixels, relative but ok for now
            poseOk = false;
            poseMessages.add("Shoulders not level");
        }
    } else {
        poseOk = false;
        poseMessages.add("Body parts missing");
    }

    // 3. Lighting (Simple placeholder)
    bool lightingOk = true; 

    // Essential landmarks for ANY analysis (Shoulders + Hips)
    List<PoseLandmarkType> essential = [
        PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder,
        PoseLandmarkType.leftHip, PoseLandmarkType.rightHip
    ];
    bool essentialVisible = essential.every((type) => landmarks.any((l) => l.type == type && l.likelihood > 0.5));

    List<String> messages = [];
    if (missing.isNotEmpty) {
        messages.add("Vücudun bazı bölümleri (ör: ${missing.join(', ')}) tam görünmüyor.");
    }
    if (!essentialVisible) {
        messages.add("Gövde net seçilemiyor, sonuçlar sadece tahminidir.");
    }
    messages.addAll(poseMessages);

    // 4. Confidence Calculation
    double confidence = 1.0;
    
    // Penalize missing parts but don't zero out
    if (missing.isNotEmpty) {
        confidence -= 0.15 * missing.length;
    }
    if (!essentialVisible) {
        confidence -= 0.35;
    }

    // Likelihood penalty
    double avgLikelihood = landmarks.map((e) => e.likelihood).reduce((a, b) => a + b) / landmarks.length;
    confidence *= avgLikelihood;

    // Hands in pockets heuristic (Wrist near hip)
    final lWrist = _find(landmarks, PoseLandmarkType.leftWrist);
    final rWrist = _find(landmarks, PoseLandmarkType.rightWrist);
    bool handsInPockets = false;
    if (lWrist != null && rWrist != null && lHip != null && rHip != null) {
        double lDist = _dist(lWrist, lHip);
        double rDist = _dist(rWrist, rHip);
        if (lDist < 0.1 * imageSize.height && rDist < 0.1 * imageSize.height) {
            handsInPockets = true;
            confidence -= 0.1;
            messages.add("Daha iyi analiz için ellerinizi görünür tutun.");
        }
    }

    if (confidence < 0.05) confidence = 0.05;

    return {
      'fullBodyVisible': missing.isEmpty,
      'essentialVisible': essentialVisible,
      'poseOk': poseMessages.isEmpty,
      'lightingOk': lightingOk,
      'confidenceScore': confidence,
      'handsInPockets': handsInPockets,
      'messages': messages,
      'missingParts': missing,
    };
  }

  double _dist(PoseLandmark p1, PoseLandmark p2) {
    return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2));
  }

  PoseLandmark? _find(List<PoseLandmark> landmarks, PoseLandmarkType type) {
    try {
      return landmarks.firstWhere((element) => element.type == type);
    } catch (_) {
      return null;
    }
  }

  bool _isVisible(PoseLandmark? landmark) {
    return landmark != null && landmark.likelihood > 0.5;
  }
}
