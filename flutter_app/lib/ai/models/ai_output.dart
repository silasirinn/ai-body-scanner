import 'dart:convert';

class AiOutput {
  final bool landmarksDetected;
  final double? bmi;
  final double? bodyFatPct;
  final double? leanMassKg;
  final double confidenceScore;
  final String riskLevel;
  final AiRecommendations recommendations;
  final AiDebug debug;

  AiOutput({
    required this.landmarksDetected,
    this.bmi,
    this.bodyFatPct,
    this.leanMassKg,
    this.confidenceScore = 0.0,
    required this.riskLevel,
    required this.recommendations,
    required this.debug,
  });

  Map<String, dynamic> toJson() {
    return {
      'landmarksDetected': landmarksDetected,
      'bmi': bmi,
      'bodyFatPct': bodyFatPct,
      'leanMassKg': leanMassKg,
      'confidenceScore': confidenceScore,
      'riskLevel': riskLevel,
      'recommendations': recommendations.toJson(),
      'debug': debug.toJson(),
    };
  }
}

class AiRecommendations {
  final int dailyCalories;
  final Map<String, int> macros; // protein_g, carbs_g, fat_g
  final List<String> dietPlan;
  final List<String> workoutPlan;

  AiRecommendations({
    required this.dailyCalories,
    required this.macros,
    required this.dietPlan,
    required this.workoutPlan,
  });

  Map<String, dynamic> toJson() {
    return {
      'dailyCalories': dailyCalories,
      'macros': macros,
      'dietPlan': dietPlan,
      'workoutPlan': workoutPlan,
    };
  }
}

class AiDebug {
  final double poseScore;
  final Map<String, dynamic> qualityChecks;
  final Map<String, double> rawRatios;
  final String? error;

  AiDebug({
    required this.poseScore,
    required this.qualityChecks,
    required this.rawRatios,
    this.error,
  });

  Map<String, dynamic> toJson() {
    return {
      'poseScore': poseScore,
      'qualityChecks': qualityChecks,
      'rawRatios': rawRatios,
      'error': error,
    };
  }
}
