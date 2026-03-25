import 'package:flutter/foundation.dart';
import 'dart:math';
class Estimators {
  Map<String, dynamic> estimate({
    required double heightCm,
    required double weightKg,
    required int age,
    required String gender,
    required Map<String, double> features,
    required double confidenceScore,
  }) {
    // 1. BMI
    final heightM = heightCm / 100;
    double bmi = 0;
    if (heightM > 0) {
      bmi = weightKg / (heightM * heightM);
    }
    
    // 2. Body Fat % Baseline (Deurenberg)
    final sexFactor = gender.toLowerCase() == 'male' ? 1 : 0;
    double bfBaseline = (1.20 * bmi) + (0.23 * age) - (10.8 * sexFactor) - 5.4;

    // 3. AI Adjustment (Continuous Formulas)
    final whtr = features['whtrProxy'] ?? 0.0;
    final shr = features['shr'] ?? 0.0;
    final ltr = features['ltr'] ?? 0.0;
    final isHeightReliable = (features['isHeightReliable'] ?? 1.0) == 1.0;

    // Baselines for landmark ratios
    final double baselineWhtr = sexFactor == 1 ? 0.16 : 0.17;
    final double baselineShr = sexFactor == 1 ? 1.2 : 1.05;
    final double baselineLtr = 1.1;

    // Component Adjustments
    double whtrAdj = 0.0;
    double whtrDelta = 0.0;
    
    // Safety check: Suppress WHtR if height is truncated (common in mirror selfies)
    if (isHeightReliable && whtr > 0.05) {
        whtrDelta = whtr - baselineWhtr;
        double whtrSign = whtrDelta >= 0 ? 1 : -1;
        whtrAdj = whtrSign * pow(whtrDelta.abs(), 1.1) * 500.0; 
    } else {
        debugPrint("AI_DEBUG: Estimators - WHtR suppressed (Height unreliable or truncated)");
    }

    // SHR: V-taper adjustment. 
    double shrAdj = 0.0;
    double shrDelta = 0.0;
    if (shr > 0.1) {
        shrDelta = shr - baselineShr;
        shrAdj = shrDelta * -7.0; 
    }

    // LTR: Moderate adjustment (suppressed if height is unreliable)
    double ltrAdj = 0.0;
    double ltrDelta = 0.0;
    if (ltr > 0.1 && isHeightReliable) {
        ltrDelta = ltr - baselineLtr;
        ltrAdj = ltrDelta * -5.0;
    }

    double rawAdjustment = whtrAdj + shrAdj + ltrAdj;
    
    // Confidence Scaling: Poor photos should not pull the result too far
    double scaledAdjustment = rawAdjustment * confidenceScore;

    // Sanity Bounds: Max ±15% deviation from BMI baseline
    const double maxCorrection = 15.0;
    double finalAdjustment = scaledAdjustment.clamp(-maxCorrection, maxCorrection);
    bool wasClamped = (scaledAdjustment.abs() > maxCorrection);

    // Dynamic BMI Dominance:
    // If height is unreliable, we trust the BMI baseline MORE (95%).
    // If height is reliable, we trust it slightly less (85%) to allow visual features to swing.
    double weightBaselineFactor = isHeightReliable ? 0.85 : 0.95;
    double weightedBaseline = bfBaseline * weightBaselineFactor;
    
    // Add small offset adjustment. Truncated photos get less offset to stay near baseline.
    double baseOffset = isHeightReliable ? 3.0 : 1.0;
    double finalBf = weightedBaseline + finalAdjustment + baseOffset;

    // 4. Estimator Contribution Table (Log)
    debugPrint("--------------------------------------------------");
    debugPrint("AI_DEBUG: Estimator Contribution Table (Robust)");
    debugPrint("--------------------------------------------------");
    debugPrint("HEIGHT RELIABLE      : $isHeightReliable");
    debugPrint("BMI BASELINE (ORIG)  : ${bfBaseline.toStringAsFixed(1)}%");
    debugPrint("WEIGHTED BASELINE    : ${weightedBaseline.toStringAsFixed(1)}%");
    debugPrint("IMAGE ADJ (RAW)      : ${rawAdjustment.toStringAsFixed(1)}%");
    if (isHeightReliable) {
      debugPrint("  > WHtR Component   : ${whtrAdj.toStringAsFixed(1)}% (Δ: ${whtrDelta.toStringAsFixed(3)})");
    } else {
      debugPrint("  > WHtR Component   : [SUPPRESSED]");
    }
    debugPrint("  > SHR Component    : ${shrAdj.toStringAsFixed(1)}% (Δ: ${shrDelta.toStringAsFixed(3)})");
    debugPrint("CONFIDENCE SCALE     : ${confidenceScore.toStringAsFixed(2)}x");
    debugPrint("FINAL ADJUSTMENT     : ${finalAdjustment.toStringAsFixed(1)}% ${wasClamped ? '(CLAMPED)' : ''}");
    debugPrint("--------------------------------------------------");
    debugPrint("FINAL BODY FAT       : ${finalBf.toStringAsFixed(1)}%");
    debugPrint("--------------------------------------------------");
    
    // Clamp to realistic range
    if (finalBf < 5.0) finalBf = 5.0;
    if (finalBf > 50.0) finalBf = 50.0;

    // 5. Lean Mass
    double leanMassKg = weightKg * (1 - (finalBf / 100));

    // 6. Risk Level (Multi-Factor)
    String riskLevel = "Düşük Risk";
    
    if (confidenceScore < 0.6) {
        riskLevel = "Güven Düşük / Analiz Tekrar Gerekli";
        debugPrint("AI_DEBUG: Risk Classification - Low Confidence ($confidenceScore), aborted deep classification");
    } else {
        int riskPoints = 0;
        
        // Body Fat Points
        double riskBfThreshold = (sexFactor == 1) ? 25.0 : 32.0;
        double warnBfThreshold = (sexFactor == 1) ? 20.0 : 28.0;
        double fitBfThreshold = (sexFactor == 1) ? 15.0 : 22.0;
        
        bool isAthletic = finalBf <= fitBfThreshold;
        
        if (finalBf > riskBfThreshold) riskPoints += 3;
        else if (finalBf > warnBfThreshold) riskPoints += 1;
        
        // BMI Points (Composition-Aware)
        // If someone is athletic/lean, we do NOT penalize their high BMI (muscular build).
        if (!isAthletic) {
            if (bmi > 30.0) riskPoints += 2;
            else if (bmi > 25.0) riskPoints += 1;
        } else {
             debugPrint("AI_DEBUG: Risk Classification - High BMI ignored due to athletic body fat levels.");
        }
        
        // WHtR Points (Central Fat Indicator - Stricter)
        double whtrRiskThreshold = (sexFactor == 1) ? 0.53 : 0.54;
        double whtrWarnThreshold = (sexFactor == 1) ? 0.50 : 0.50;
        
        if (isHeightReliable && whtr > 0) {
            if (whtr >= whtrRiskThreshold) riskPoints += 3; // Severe central obesity is a huge red flag
            else if (whtr >= whtrWarnThreshold) riskPoints += 1;
        }

        // Final Category based on points
        if (riskPoints >= 4) {
            riskLevel = "Yüksek Risk";
        } else if (riskPoints >= 2) {
            riskLevel = "Orta Risk";
        } else {
            riskLevel = "Düşük Risk";
        }

        debugPrint("AI_DEBUG: Risk Classification - Final: $riskLevel | Points: $riskPoints (BF: ${finalBf.toStringAsFixed(1)}, BMI: ${bmi.toStringAsFixed(1)}, WHtR: ${whtr.toStringAsFixed(2)}, Athletic: $isAthletic)");
    }

    return {
        "bmi": double.parse(bmi.toStringAsFixed(2)),
        "bodyFatPct": double.parse(finalBf.toStringAsFixed(1)),
        "leanMassKg": double.parse(leanMassKg.toStringAsFixed(1)),
        "riskLevel": riskLevel
    };
  }
}
