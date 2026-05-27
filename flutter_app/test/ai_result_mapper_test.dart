import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/ai/ai_result_mapper.dart';
import 'package:flutter_app/ai/models/ai_output.dart';

void main() {
  group('AiResultMapper Tests', () {
    final mockAiOutput = AiOutput(
      landmarksDetected: true,
      bmi: 22.5,
      bodyFatPct: 18.2,
      leanMassKg: 65.4,
      confidenceScore: 0.95,
      riskLevel: 'Düşük Risk',
      recommendations: AiRecommendations(
        dailyCalories: 2200,
        macros: {
          'protein_g': 150,
          'carbs_g': 250,
          'fat_g': 70,
        },
        dietPlan: [
          'Sabah: Omlet ve yulaf',
          'Öğle: Tavuk ve pirinç pilavı',
          'Akşam: Izgara somon ve yeşil salata'
        ],
        workoutPlan: [
          'Squat|4 set 10 tekrar',
          'Dumbbell Press|3 set 12 tekrar',
          'Koşu|20 dk hafif tempo'
        ],
      ),
      debug: AiDebug(
        poseScore: 0.98,
        qualityChecks: {'fullBodyVisible': true, 'poseOk': true},
        rawRatios: {'shoulderWidthPx': 120.0, 'hipWidthPx': 100.0},
      ),
    );

    test('mapAiToResultsUi should map correct values', () {
      final result = AiResultMapper.mapAiToResultsUi(
        mockAiOutput,
        weight: 80,
        height: 180,
      );

      expect(result['bmi'], 22.5);
      expect(result['bodyFat'], 18.2);
      expect(result['leanMass'], 65.4);
      expect(result['calories'], 2200);
      expect(result['weight'], 80);
      expect(result['height'], 180);
    });

    test('mapAiToResultsUi should return empty map if landmarks not detected', () {
      final invalidAiOutput = AiOutput(
        landmarksDetected: false,
        riskLevel: 'Risk',
        recommendations: AiRecommendations(
          dailyCalories: 0,
          macros: {},
          dietPlan: [],
          workoutPlan: [],
        ),
        debug: AiDebug(
          poseScore: 0.0,
          qualityChecks: {},
          rawRatios: {},
        ),
      );

      final result = AiResultMapper.mapAiToResultsUi(
        invalidAiOutput,
        weight: 80,
        height: 180,
      );

      expect(result, isEmpty);
    });

    test('mapAiToProgramUi should compute correct macro percentages', () {
      final program = AiResultMapper.mapAiToProgramUi(
        mockAiOutput,
        goalText: 'Kilo Vermek',
      );

      expect(program['goal'], 'Kilo Vermek');
      expect(program['calories'], 2200);
      
      final macros = program['macros'] as Map<String, dynamic>;
      // Protein: 150g * 4 kcal = 600 kcal
      // Carbs: 250g * 4 kcal = 1000 kcal
      // Fats: 70g * 9 kcal = 630 kcal
      // Total: 2230 kcal
      // Protein Pct: (600 / 2230) * 100 = ~27%
      // Carbs Pct: (1000 / 2230) * 100 = ~45%
      // Fats Pct: 100 - 27 - 45 = 28%
      expect(macros['proteinPct'], 27);
      expect(macros['carbsPct'], 45);
      expect(macros['fatPct'], 28);
    });

    test('mapAiToProgramUi should extract meals correctly', () {
      final program = AiResultMapper.mapAiToProgramUi(
        mockAiOutput,
        goalText: 'Kilo Vermek',
      );

      final mealPlan = program['mealPlan'] as List<Map<String, dynamic>>;
      expect(mealPlan.length, 3);
      expect(mealPlan[0]['type'], 'Kahvaltı');
      expect(mealPlan[0]['meals'], contains('Sabah: Omlet ve yulaf'));
      expect(mealPlan[1]['type'], 'Öğle Yemeği');
      expect(mealPlan[2]['type'], 'Akşam Yemeği');
    });

    test('mapAiToProgramUi should parse exercises with custom icons and split names/durations', () {
      final program = AiResultMapper.mapAiToProgramUi(
        mockAiOutput,
        goalText: 'Kilo Vermek',
      );

      final exercises = program['exercises'] as List<Map<String, dynamic>>;
      expect(exercises.length, 3);
      
      // Squat should have a dumbbell/arm icon since it's resistance
      expect(exercises[0]['name'], 'Squat');
      expect(exercises[0]['duration'], '4 set 10 tekrar');
      expect(exercises[0]['icon'], '💪');

      // Koşu should have a running icon
      expect(exercises[2]['name'], 'Koşu');
      expect(exercises[2]['duration'], '20 dk hafif tempo');
      expect(exercises[2]['icon'], '🏃');
    });
  });
}
