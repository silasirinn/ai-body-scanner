import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:math';

class FeatureExtractor {
  Map<String, double> extract(List<PoseLandmark> landmarks) {
    if (landmarks.isEmpty) return {};

    final nose = _find(landmarks, PoseLandmarkType.nose);
    final lShoulder = _find(landmarks, PoseLandmarkType.leftShoulder);
    final rShoulder = _find(landmarks, PoseLandmarkType.rightShoulder);
    final lHip = _find(landmarks, PoseLandmarkType.leftHip);
    final rHip = _find(landmarks, PoseLandmarkType.rightHip);
    final lAnkle = _find(landmarks, PoseLandmarkType.leftAnkle);
    final rAnkle = _find(landmarks, PoseLandmarkType.rightAnkle);

    if (lShoulder == null || rShoulder == null || lHip == null || rHip == null || nose == null || lAnkle == null || rAnkle == null) {
        return {
            "shoulderWidthPx": 0,
            "hipWidthPx": 0,
            "torsoLengthPx": 0,
            "whtrProxy": 0,
            "shr": 0
        };
    }

    // Distances
    final shoulderWidth = _dist(lShoulder, rShoulder);
    final hipWidth = _dist(lHip, rHip);
    
    // Torso Length (Mid Shoulder to Mid Hip)
    final midShoulderX = (lShoulder.x + rShoulder.x) / 2;
    final midShoulderY = (lShoulder.y + rShoulder.y) / 2;
    
    final midHipX = (lHip.x + rHip.x) / 2;
    final midHipY = (lHip.y + rHip.y) / 2;
    
    final torsoLength = sqrt(pow(midShoulderX - midHipX, 2) + pow(midShoulderY - midHipY, 2));

    // Leg Length (Hip to Ankle average)
    final lLeg = _dist(lHip, lAnkle);
    final rLeg = _dist(rHip, rAnkle);
    final legLength = (lLeg + rLeg) / 2;

    // Height Proxy (Nose Y to Avg Ankle Y)
    final lKnee = _find(landmarks, PoseLandmarkType.leftKnee);
    final rKnee = _find(landmarks, PoseLandmarkType.rightKnee);
    
    // Reliability Check: Do we have the bottom of the body?
    bool hasAnkles = (lAnkle.likelihood > 0.5 && rAnkle.likelihood > 0.5);
    bool hasKnees = (lKnee != null && lKnee.likelihood > 0.5 && rKnee != null && rKnee.likelihood > 0.5);
    
    double heightPxProxy = 0.0;
    if (hasAnkles) {
        final avgAnkleY = (lAnkle.y + rAnkle.y) / 2;
        heightPxProxy = (avgAnkleY - nose.y).abs();
    } else if (hasKnees) {
        // Fallback: Use knees and extrapolate (approximate)
        final avgKneeY = (lKnee!.y + rKnee!.y) / 2;
        heightPxProxy = (avgKneeY - nose.y).abs() * 1.3; // Heuristic extrapolation
    } else {
        // Just use torso + some buffer
        heightPxProxy = torsoLength * 2.5;
    }

    // Reliability signal for Estimator
    bool isHeightReliable = hasAnkles;

    // Ratios
    // WHtR Proxy: Trunk Width (avg of shoulders and hips) / Height Proxy
    // We use average to capture "thickness" better than just one point.
    double trunkWidth = (shoulderWidth + hipWidth) / 2;
    double whtr = 0.0;
    if (heightPxProxy > 0) {
        whtr = trunkWidth / heightPxProxy;
    }

    // SHR: Shoulder / Hip
    double shr = 0.0;
    if (hipWidth > 0) {
        shr = shoulderWidth / hipWidth;
    }

    // Limb to Torso Ratio
    double ltr = 0.0;
    if (torsoLength > 0) {
        ltr = legLength / torsoLength;
    }

    // Waist Proxy (Width mid-way between shoulders and hips)
    // Heuristic: We don't have a middle landmark, so we can't get actual waist easily,
    // but we can look for the narrowest point or just use hipWidth as a proxy if we assume it's calibrated.
    // However, since we want sensitivity, let's just ensure we have enough independent signals.
    double waistProxy = hipWidth * 0.9; // Placeholder for now, but in a real app we'd scan multiple points.

    final features = {
      "shoulderWidthPx": shoulderWidth,
      "hipWidthPx": hipWidth,
      "torsoLengthPx": torsoLength,
      "legLengthPx": legLength,
      "whtrProxy": whtr,
      "shr": shr,
      "ltr": ltr,
      "waistProxy": waistProxy,
      "isHeightReliable": isHeightReliable ? 1.0 : 0.0,
    };
    debugPrint("AI_DEBUG: FeatureExtractor - Height Reliable: $isHeightReliable, Proxy: ${heightPxProxy.toInt()}");
    debugPrint("AI_DEBUG: FeatureExtractor - Extracted Ratios: $features");
    return features;
  }

  PoseLandmark? _find(List<PoseLandmark> landmarks, PoseLandmarkType type) {
    try {
      return landmarks.firstWhere((element) => element.type == type);
    } catch (_) {
      return null;
    }
  }

  double _dist(PoseLandmark p1, PoseLandmark p2) {
    return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2));
  }
}
