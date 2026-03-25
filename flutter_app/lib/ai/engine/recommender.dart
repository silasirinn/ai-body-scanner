import 'package:flutter/foundation.dart';
import '../models/ai_output.dart';

class Recommender {
  AiRecommendations recommend({
    required int age,
    required String gender,
    required double weightKg,
    required double heightCm,
    required String goal, // 'lose', 'maintain', 'gain'
    required String riskLevel,
    double? bodyFatPct,
    double? leanMassKg,
  }) {
    // 1. BMR (Mifflin-St Jeor)
    // Men: 10W + 6.25H - 5A + 5
    // Women: 10W + 6.25H - 5A - 161
    double baseBmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
    if (gender.toLowerCase() == 'male') {
        baseBmr += 5;
    } else {
        baseBmr -= 161;
    }

    // 2. TDEE
    double tdee = baseBmr * 1.35;

    // 3. Target Calories
    double targetCalories = tdee;
    if (goal == 'lose') {
        // Safe deficit: larger if BMI is higher
        double deficit = (weightKg / ((heightCm / 100) * (heightCm / 100)) > 30) ? 600 : 400;
        targetCalories -= deficit;
    } else if (goal == 'gain') {
        targetCalories += 300;
    }
    
    if (targetCalories < 1200) targetCalories = 1200;

    // 4. Macros (Based on Lean Mass for Protein)
    // Use actual calculated lean mass instead of a generic proxy if provided
    double leanMass = leanMassKg ?? (weightKg * (1 - (15 / 100))); 
    
    // Distribute remaining calories to carbs and fats based on the exact profile
    Map<String, int> macros;
    
    // We determine exact protein needs first to preserve lean mass
    double proteinPerKgLean = 2.0; 
    if (goal == 'lose') proteinPerKgLean = 2.8; // High protein to preserve muscle in deficit
    else if (goal == 'gain') proteinPerKgLean = 2.4; // High protein for building
    
    int proteinG = (leanMass * proteinPerKgLean).round();
    int proteinKcal = proteinG * 4;
    
    int remainingKcal = targetCalories.round() - proteinKcal;
    
    if (goal == 'gain') {
        // High carb for muscle boundary
        int carbsKcal = (remainingKcal * 0.65).round(); 
        int fatsKcal = remainingKcal - carbsKcal;
        macros = {'protein_g': proteinG, 'carbs_g': (carbsKcal / 4).round(), 'fat_g': (fatsKcal / 9).round()};
    } else if (goal == 'lose') {
        // Lower carb, moderate fat
        int carbsKcal = (remainingKcal * 0.40).round(); 
        int fatsKcal = remainingKcal - carbsKcal;
        macros = {'protein_g': proteinG, 'carbs_g': (carbsKcal / 4).round(), 'fat_g': (fatsKcal / 9).round()};
    } else {
        // Balanced (Maintain)
        int carbsKcal = (remainingKcal * 0.50).round(); 
        int fatsKcal = remainingKcal - carbsKcal;
        macros = {'protein_g': proteinG, 'carbs_g': (carbsKcal / 4).round(), 'fat_g': (fatsKcal / 9).round()};
    }

    // 5. Diet Plan
    List<String> dietPlan = _getDynamicDietPlan(goal, targetCalories.round(), riskLevel, bodyFatPct ?? 20.0, leanMass, age, gender);

    // 6. Workout Plan
    List<String> workoutPlan = _getDynamicWorkoutPlan(goal, riskLevel, bodyFatPct ?? 20.0, leanMass, age, gender);

    debugPrint("AI_DEBUG: Recommender - Goal: $goal | Calories: ${targetCalories.round()}");
    debugPrint("AI_DEBUG: Recommender - Macros: P:${macros['protein_g']}g / C:${macros['carbs_g']}g / F:${macros['fat_g']}g");
    debugPrint("AI_DEBUG: Recommender - Diet Plan: $dietPlan");
    debugPrint("AI_DEBUG: Recommender - Workout Plan: $workoutPlan");

    return AiRecommendations(
        dailyCalories: targetCalories.round(),
        macros: macros,
        dietPlan: dietPlan,
        workoutPlan: workoutPlan
    );
  }

  List<String> _getDynamicDietPlan(String goal, int calories, String riskLevel, double bodyFatPct, double leanMass, int age, String gender) {
    bool isMale = gender.toLowerCase() == 'male';
    bool isHighFat = isMale ? (bodyFatPct > 25.0) : (bodyFatPct > 32.0);
    bool isLowFat = isMale ? (bodyFatPct < 15.0) : (bodyFatPct < 22.0);
    double bmiLocal = (leanMass / (1 - (bodyFatPct / 100))) / ((leanMass / (1 - (bodyFatPct / 100)) / (bmiHelperCalculateHeightFallbackHereButWeOnlyNeedLogicCheck(bodyFatPct, isMale))));
    // Simpler check for skinny-fat (Normal/Low BMI but High Fat)
    bool isSkinnyFat = isHighFat && (calories < 2000); // Rough heuristic

    List<String> plan = [];

    if (goal == 'lose' && isSkinnyFat) {
       plan = [
        "Sabah: 3 yulaflı omlet (Yüksek protein, ılımlı karbonhidrat)",
        "Öğle: Izgara tavuk/balık ve büyük porsiyon salata",
        "Ara: 1 avuç badem, şekersiz yeşil çay (Metabolizma destekleyici)",
        "Akşam: Fırınlanmış et ve zeytinyağlı sebze yemeği"
      ];
    } else if (goal == 'lose' && isHighFat) {
       plan = [
        "Sabah: Yüksek proteinli yumurta beyazı omleti, bol yeşillik",
        "Öğle: Sadece ızgara protein (Tavuk/Hindi) ve brokoli/kuşkonmaz",
        "Ara: Yoğurt veya kefir",
        "Akşam: Izgara balık ve bol limonlu mevsim salata"
      ];
    } else if (goal == 'lose') {
       plan = [
        "Sabah: Yulaf ezmesi, protein tozu/organik yumurta, orman meyvesi",
        "Öğle: Izgara tavuk göğsü, lifli sebze, az miktar kinoa",
        "Ara: Lor peyniri veya yoğurt",
        "Akşam: Izgara balık ve fırınlanmış ızgara sebze"
      ];
    } else if (goal == 'gain' && isHighFat) {
      // Re-comp for gainers who hold too much fat
      plan = [
        "Sabah: 2 tam yumurta, 2 beyaz, karabuğday, peynir",
        "Öğle: Et/Tavuk, esmer pirinç veya bulgur (Kontrollü Porsiyon)",
        "Ara: Protein shake",
        "Akşam: Kırmızı et, büyük kase yeşil salata"
      ];
    } else if (goal == 'gain' && isLowFat) {
      plan = [
        "Sabah: 3 yumurtalı omlet, yulaf, fıstık ezmesi, muz",
        "Öğle: Bol porsiyon et/tavuk, beyaz pirinç pilavı, sebze",
        "Ara: Yüksek kalorili protein shake, avuç kuruyemiş",
        "Akşam: Kırmızı et, patates püresi veya makarna"
      ];
    } else if (goal == 'gain') {
      plan = [
        "Sabah: Yulaf, chia tohumu, 2 tam yumurta",
        "Öğle: Izgara tavuk, bulgur pilavı, yeşillik",
        "Ara: Mevsim meyvesi ve ceviz",
        "Akşam: Yağsız kıyma veya tavuk, tam buğday makarna"
      ];
    } else {
      // Maintain
      plan = [
        "Sabah: Dengeli kahvaltı (Yumurta, az yağlı beyaz peynir, yeşillik)",
        "Öğle: Dengeli tabak (1/4 Karbonhidrat, 1/4 Protein, 1/2 Sebze)",
        "Ara: Taze meyve veya bir avuç çiğ kuruyemiş",
        "Akşam: Izgara protein ve bol zeytinyağlı mevsim salata"
      ];
    }

    if (riskLevel == 'Yüksek Risk') {
      plan.add("NOT: Şeker, işlenmiş gıda ve trans yağlardan tıbbi sebeplerle tamamen kaçının.");
    } else if (age > 50) {
      plan.add("NOT: Kemik sağlığı için diyetinize fazladan kalsiyum ve D vitamini kaynakları ekleyin.");
    }

    return plan;
  }
  
  // Dummy helper just for compilation flow logic placeholder
  double bmiHelperCalculateHeightFallbackHereButWeOnlyNeedLogicCheck(double fat, bool isMale) => 1.0;

  List<String> _getDynamicWorkoutPlan(String goal, String riskLevel, double bodyFatPct, double leanMass, int age, String gender) {
    bool isMale = gender.toLowerCase() == 'male';
    bool isHighFat = isMale ? (bodyFatPct > 25.0) : (bodyFatPct > 32.0);
    bool isLowFat = isMale ? (bodyFatPct < 15.0) : (bodyFatPct < 22.0);

    // Format: "Exercise Name|Duration/Reps"
    if (riskLevel == 'Yüksek Risk' || age > 65) {
      return [
        "Açık Alan Tempolu Yürüyüş|30-40 dk",
        "Yüzme veya Su Jimnastiği|45 dk",
        "Oturarak Eklem ve Mobilite Esnetme|15 dk"
      ];
    }

    if (goal == 'lose' && isHighFat) {
      // Joint protection is key here, no heavy impact HIIT yet
      return [
        "Düşük Tempolu Eliptik/Kardiyo (LISS)|45 dk",
        "Tüm Vücut Fonksiyonel Vücut Ağırlığı|30 dk",
        "Tempolu Doğa Yürüyüşü|10.000 adım"
      ];
    } else if (goal == 'lose') {
      return [
        "HIIT (Yüksek Yoğunluklu) Kardiyo|20 dk",
        "Ağırlık - Üst Vücut İtme/Çekme Blokajı|45 dk",
        "Ağırlık - Alt Vücut İzole Egzersizleri|45 dk"
      ];
    } else if (goal == 'gain' && isHighFat) {
      // Lean bulk / re-comp
      return [
        "Ağırlık Antrenmanı + Hafif Kardiyo Bitişi|60 dk",
        "Bileşik (Compound) Kaldırışlara Odaklanma|4x8 Set",
        "Aktif Dinlenme ve Bölgesel Kardiyo|2 Gün"
      ];
    } else if (goal == 'gain' && isLowFat) {
      return [
        "Ağır Squat/Deadlift Odaklı Çalışma|5x5 Set",
        "Hipertrofi (Kas Büyütme) Üst Vücut|45-60 dk",
        "Bölgesel İzole Ağırlık Antrenmanı|4 Gün Şiddetli"
      ];
    } else if (goal == 'gain') {
      return [
        "Tüm Vücut Orta Yoğunluk Ağırlık Antrenmanı|3 Gün",
        "Düşük Tempolu Kardiyo (Kalp Sağlığı)|20 dk",
        "Esneklik ve Mobilite Setleri|15 dk"
      ];
    } else {
      // Maintain
      return [
        "Fonksiyonel Fitness (Crossfit tarzı karma)|45 dk",
        "Dengeli Koşu veya Orta Tempo Bisiklet|30-40 dk",
        "Haftalık Yoga veya Pilates Stabilizasyonu|45 dk"
      ];
    }
  }
}
