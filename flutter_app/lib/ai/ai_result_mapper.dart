import 'models/ai_output.dart';

class AiResultMapper {
  static Map<String, dynamic> mapAiToResultsUi(AiOutput ai, {required int weight, required int height}) {
    if (!ai.landmarksDetected) return {};

    return {
      'bmi': ai.bmi ?? 0.0,
      'bodyFat': ai.bodyFatPct ?? 0.0,
      'leanMass': ai.leanMassKg ?? 0.0,
      'calories': ai.recommendations.dailyCalories,
      'weight': weight,
      'height': height,
    };
  }

  static Map<String, dynamic> mapAiToProgramUi(AiOutput ai, {required String goalText}) {
     if (!ai.landmarksDetected) return {};

     final recs = ai.recommendations;
     
     // Calculate percentages
     final proteinG = recs.macros['protein_g'] ?? 0;
     final carbsG = recs.macros['carbs_g'] ?? 0;
     final fatG = recs.macros['fat_g'] ?? 0;
     
     final pKcal = proteinG * 4;
     final cKcal = carbsG * 4;
     final fKcal = fatG * 9;
     final totalKcal = pKcal + cKcal + fKcal;

     int pPct = totalKcal > 0 ? ((pKcal / totalKcal) * 100).round() : 0;
     int cPct = totalKcal > 0 ? ((cKcal / totalKcal) * 100).round() : 0;
     int fPct = 100 - pPct - cPct; // Ensure sum is 100

     // Map Diet Plan
     List<Map<String, dynamic>> mealPlan = [];
     if (recs.dietPlan.length >= 3) {
         mealPlan.add({'type': "Kahvaltı", 'icon': "☀️", 'meals': [recs.dietPlan[0]]});
         mealPlan.add({'type': "Öğle Yemeği", 'icon': "🌤️", 'meals': [recs.dietPlan[1]]});
         // If 4 items, usually snack is 3rd (index 2), dinner 4th (index 3)
         if (recs.dietPlan.length > 3) {
             mealPlan.add({'type': "Ara Öğün", 'icon': "🍎", 'meals': [recs.dietPlan[2]]});
             mealPlan.add({'type': "Akşam Yemeği", 'icon': "🌙", 'meals': [recs.dietPlan[3]]});
         } else {
             mealPlan.add({'type': "Akşam Yemeği", 'icon': "🌙", 'meals': [recs.dietPlan[2]]});
         }
     }

     // Map Workout Plan
     List<Map<String, dynamic>> exercises = recs.workoutPlan.map((step) {
         String name = step;
         String duration = "Plan dahilinde";
         
         if (step.contains('|')) {
             final parts = step.split('|');
             name = parts[0];
             duration = parts[1];
         }

         String icon = "🔥";
         String lower = name.toLowerCase();
         if (lower.contains("kardiyo") || lower.contains("yürüyüş") || lower.contains("koşu") || lower.contains("adım") || lower.contains("bisiklet")) icon = "🏃";
         else if (lower.contains("yoga") || lower.contains("pilates")) icon = "🧘";
         else if (lower.contains("ağırlık") || lower.contains("kuvvet") || lower.contains("squat") || lower.contains("kas") || lower.contains("hipertrofi") || lower.contains("deadlift")) icon = "💪";
         else if (lower.contains("yüzme") || lower.contains("su")) icon = "🏊";

         return {
             'name': name,
             'icon': icon,
             'duration': duration
         };
     }).toList();

     return {
         'goal': goalText,
         'calories': recs.dailyCalories,
         'macros': {
             'proteinPct': pPct,
             'carbsPct': cPct,
             'fatPct': fPct,
         },
         'mealPlan': mealPlan,
         'exercises': exercises
     };
  }
}
