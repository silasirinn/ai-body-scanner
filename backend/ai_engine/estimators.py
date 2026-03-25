import math

class Estimators:
    def estimate(self, height_cm, weight_kg, age, gender, features, confidence_score):
        # 1. BMI
        height_m = height_cm / 100
        bmi = 0
        if height_m > 0:
            bmi = weight_kg / (height_m * height_m)
            
        # 2. Body Fat % Baseline (Deurenberg)
        sex_factor = 1 if gender.lower() == 'male' else 0
        bf_baseline = (1.20 * bmi) + (0.23 * age) - (10.8 * sex_factor) - 5.4

        # 3. AI Adjustment (Continuous Formulas)
        whtr = features.get('whtrProxy', 0.0)
        shr = features.get('shr', 0.0)
        ltr = features.get('ltr', 0.0)
        is_height_reliable = (features.get('isHeightReliable', 1.0) == 1.0)

        # Baselines for landmark ratios
        baseline_whtr = 0.16 if sex_factor == 1 else 0.17
        baseline_shr = 1.2 if sex_factor == 1 else 1.05
        baseline_ltr = 1.1

        # Component Adjustments
        whtr_adj = 0.0
        whtr_delta = 0.0
        
        if is_height_reliable and whtr > 0.05:
            whtr_delta = whtr - baseline_whtr
            whtr_sign = 1 if whtr_delta >= 0 else -1
            whtr_adj = whtr_sign * math.pow(abs(whtr_delta), 1.1) * 500.0
        else:
            print("AI_DEBUG: Estimators - WHtR suppressed (Height unreliable or truncated)")

        shr_adj = 0.0
        shr_delta = 0.0
        if shr > 0.1:
            shr_delta = shr - baseline_shr
            shr_adj = shr_delta * -7.0
            
        ltr_adj = 0.0
        ltr_delta = 0.0
        if ltr > 0.1 and is_height_reliable:
            ltr_delta = ltr - baseline_ltr
            ltr_adj = ltr_delta * -5.0

        raw_adjustment = whtr_adj + shr_adj + ltr_adj
        
        scaled_adjustment = raw_adjustment * confidence_score

        max_correction = 15.0
        final_adjustment = max(-max_correction, min(max_correction, scaled_adjustment))
        was_clamped = (abs(scaled_adjustment) > max_correction)

        weight_baseline_factor = 0.85 if is_height_reliable else 0.95
        weighted_baseline = bf_baseline * weight_baseline_factor
        
        base_offset = 3.0 if is_height_reliable else 1.0
        final_bf = weighted_baseline + final_adjustment + base_offset

        print("-" * 50)
        print("AI_DEBUG: Estimator Contribution Table (Robust)")
        print("-" * 50)
        print(f"HEIGHT RELIABLE      : {is_height_reliable}")
        print(f"BMI BASELINE (ORIG)  : {bf_baseline:.1f}%")
        print(f"WEIGHTED BASELINE    : {weighted_baseline:.1f}%")
        print(f"IMAGE ADJ (RAW)      : {raw_adjustment:.1f}%")
        if is_height_reliable:
            print(f"  > WHtR Component   : {whtr_adj:.1f}% (Δ: {whtr_delta:.3f})")
        else:
            print("  > WHtR Component   : [SUPPRESSED]")
        print(f"  > SHR Component    : {shr_adj:.1f}% (Δ: {shr_delta:.3f})")
        print(f"CONFIDENCE SCALE     : {confidence_score:.2f}x")
        print(f"FINAL ADJUSTMENT     : {final_adjustment:.1f}% {'(CLAMPED)' if was_clamped else ''}")
        print("-" * 50)
        print(f"FINAL BODY FAT       : {final_bf:.1f}%")
        print("-" * 50)

        if final_bf < 5.0: final_bf = 5.0
        if final_bf > 50.0: final_bf = 50.0

        # 5. Lean Mass
        lean_mass_kg = weight_kg * (1 - (final_bf / 100))

        # 6. Risk Level
        risk_level = "Düşük Risk"
        
        if confidence_score < 0.6:
            risk_level = "Güven Düşük / Analiz Tekrar Gerekli"
            print(f"AI_DEBUG: Risk Classification - Low Confidence ({confidence_score}), aborted deep classification")
        else:
            risk_points = 0
            
            risk_bf_threshold = 25.0 if sex_factor == 1 else 32.0
            warn_bf_threshold = 20.0 if sex_factor == 1 else 28.0
            fit_bf_threshold = 15.0 if sex_factor == 1 else 22.0
            
            is_athletic = final_bf <= fit_bf_threshold
            
            if final_bf > risk_bf_threshold: risk_points += 3
            elif final_bf > warn_bf_threshold: risk_points += 1
            
            if not is_athletic:
                if bmi > 30.0: risk_points += 2
                elif bmi > 25.0: risk_points += 1
            else:
                print("AI_DEBUG: Risk Classification - High BMI ignored due to athletic body fat levels.")
                
            whtr_risk_threshold = 0.53 if sex_factor == 1 else 0.54
            whtr_warn_threshold = 0.50 if sex_factor == 1 else 0.50
            
            if is_height_reliable and whtr > 0:
                if whtr >= whtr_risk_threshold: risk_points += 3
                elif whtr >= whtr_warn_threshold: risk_points += 1

            if risk_points >= 4:
                risk_level = "Yüksek Risk"
            elif risk_points >= 2:
                risk_level = "Orta Risk"
            else:
                risk_level = "Düşük Risk"

            print(f"AI_DEBUG: Risk Classification - Final: {risk_level} | Points: {risk_points} (BF: {final_bf:.1f}, BMI: {bmi:.1f}, WHtR: {whtr:.2f}, Athletic: {is_athletic})")

        return {
            "bmi": round(bmi, 2),
            "bodyFatPct": round(final_bf, 1),
            "leanMassKg": round(lean_mass_kg, 1),
            "riskLevel": risk_level
        }
