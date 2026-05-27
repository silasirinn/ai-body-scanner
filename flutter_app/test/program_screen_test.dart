import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/screens/program/program_screen.dart';
import 'package:flutter_app/ai/models/ai_output.dart';
import 'package:flutter_app/ai/user_data_store.dart';
import 'package:flutter_app/ai/ai_result_mapper.dart';

void main() {
  group('ProgramScreen Widget Tests', () {
    final mockAiOutput = AiOutput(
      landmarksDetected: true,
      bmi: 24.5,
      bodyFatPct: 15.0,
      leanMassKg: 68.0,
      riskLevel: 'Düşük Risk',
      recommendations: AiRecommendations(
        dailyCalories: 2200,
        macros: {
          'protein_g': 150,
          'carbs_g': 250,
          'fat_g': 70,
        },
        dietPlan: [
          'Sabah: Yulaf ezmesi ve omlet',
          'Öğle: Izgara tavuk göğsü',
          'Akşam: Fırın somon ve brokoli'
        ],
        workoutPlan: [
          'Squat|3 set 12 tekrar',
          'Koşu|30 dk orta tempo',
        ],
      ),
      debug: AiDebug(
        poseScore: 0.95,
        qualityChecks: {},
        rawRatios: {},
      ),
    );

    testWidgets('Should parse AiOutput and display goal, macros, meals, and exercises', (WidgetTester tester) async {
      // Set large viewport height so the lazy-loading ListView builds off-screen elements
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Set the user goal in store to 'lose'
      UserDataStore().updateGoal('lose'); // Will map goal text to "Kilo Vermek"

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: RouteSettings(arguments: mockAiOutput),
                      builder: (context) => const ProgramScreen(),
                    ),
                  );
                },
                child: const Text('Go'),
              );
            },
          ),
        ),
      );

      // Navigate to ProgramScreen
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));

      // Check daily calories display
      expect(find.text('2200'), findsOneWidget);

      // Check goal text is displayed correctly based on 'lose'
      expect(find.text('Kilo Vermek'), findsOneWidget);

      // Protein Pct: (150*4)/(150*4 + 250*4 + 70*9) = 600/2230 = 27%
      // Carbs Pct: 1000/2230 = 45%
      // Fats Pct: 630/2230 = 28%
      expect(find.text('27%'), findsOneWidget); // Protein
      expect(find.text('45%'), findsOneWidget); // Carbs
      expect(find.text('28%'), findsOneWidget); // Fats

      // Check meals are shown
      expect(find.text('Kahvaltı'), findsOneWidget);
      expect(find.text('Sabah: Yulaf ezmesi ve omlet'), findsOneWidget);
      expect(find.text('Öğle Yemeği'), findsOneWidget);
      expect(find.text('Öğle: Izgara tavuk göğsü'), findsOneWidget);

      // Check exercises are shown
      expect(find.text('Squat'), findsOneWidget);
      expect(find.text('3 set 12 tekrar'), findsOneWidget);
      expect(find.text('Koşu'), findsOneWidget);
      expect(find.text('30 dk orta tempo'), findsOneWidget);
    });

    testWidgets('Should display fallback data when no AiOutput argument is provided', (WidgetTester tester) async {
      // Set large viewport height so the lazy-loading ListView builds off-screen elements
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: ProgramScreen(), // No arguments provided
        ),
      );

      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));

      // Check default fallback title/goal
      expect(find.text('Örnek Program'), findsOneWidget);
      expect(find.text('2000'), findsOneWidget);
    });
  });
}
