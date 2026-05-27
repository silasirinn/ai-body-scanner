import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/screens/results/results_screen.dart';
import 'package:flutter_app/ai/models/ai_output.dart';

void main() {
  group('ResultsScreen Widget Tests', () {
    final Map<String, dynamic> mockResultsMap = <String, dynamic>{
      'bmi': 23.4,
      'bodyFat': 16.5,
      'leanMass': 68.2,
      'calories': 2400,
      'weight': 80,
      'height': 185,
    };

    final mockAiOutput = AiOutput(
      landmarksDetected: true,
      bmi: 23.4,
      bodyFatPct: 16.5,
      leanMassKg: 68.2,
      riskLevel: 'Düşük Risk',
      recommendations: AiRecommendations(
        dailyCalories: 2400,
        macros: {'protein_g': 150, 'carbs_g': 250, 'fat_g': 70},
        dietPlan: ['Sabah 1', 'Öğle 1', 'Akşam 1'],
        workoutPlan: ['Spor 1', 'Spor 2'],
      ),
      debug: AiDebug(
        poseScore: 0.95,
        qualityChecks: {},
        rawRatios: {},
      ),
    );

    testWidgets('Should display correct BMI, body fat, lean mass, and daily calories', (WidgetTester tester) async {
      // Set large viewport height so the lazy-loading ListView builds off-screen elements
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultsScreen(
                        results: mockResultsMap,
                      ),
                    ),
                  );
                },
                child: const Text('Go'),
              );
            },
          ),
        ),
      );

      // Tap 'Go' to navigate to ResultsScreen
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));

      // Check BMI text
      // bmi = 23.4, so it should display "23.4"
      expect(find.text('23.4'), findsOneWidget);

      // Check Body Fat circle chart text (displays as "16.5%")
      expect(find.text('16.5%'), findsOneWidget);

      // Check Lean Mass circle chart text (displays as "68.2%")
      expect(find.text('68.2%'), findsOneWidget);

      // Check Calories text (displays as "2400")
      expect(find.text('2400'), findsOneWidget);

      // Check Status logic: 23.4 is < 25 so status should be "Normal"
      expect(find.text('Normal'), findsOneWidget);
    });

    testWidgets('Should trigger onViewProgram callback when button is clicked', (WidgetTester tester) async {
      // Set large viewport height so the lazy-loading ListView builds off-screen elements
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      AiOutput? triggeredOutput;

      // Pushing via a real route using Navigator to ensure arguments are passed cleanly
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: RouteSettings(
                        arguments: <String, dynamic>{
                          'results': mockResultsMap,
                          'output': mockAiOutput,
                        },
                      ),
                      builder: (context) => ResultsScreen(
                        onViewProgram: (output) {
                          triggeredOutput = output;
                        },
                      ),
                    ),
                  );
                },
                child: const Text('Go'),
              );
            },
          ),
        ),
      );

      // Tap 'Go' to navigate to ResultsScreen
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));

      final button = find.text('KİŞİSEL PROGRAMIMI GÖR');
      expect(button, findsOneWidget);
      await tester.tap(button);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));

      expect(triggeredOutput, isNotNull);
      expect(triggeredOutput!.bmi, 23.4);
    });
  });
}
