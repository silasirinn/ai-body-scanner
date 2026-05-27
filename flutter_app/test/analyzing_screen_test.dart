import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_app/screens/analyzing/analyzing_screen.dart';
import 'package:flutter_app/blocs/scanner/scanner_bloc.dart';
import 'package:flutter_app/services/api_service.dart';
import 'package:flutter_app/ai/models/ai_output.dart';
import 'package:flutter_app/ai/user_data_store.dart';

// Mock ApiService to control what the ScannerBloc emits
class MockApiService extends ApiService {
  final AiOutput? mockOutput;
  final Exception? mockException;

  MockApiService({this.mockOutput, this.mockException});

  @override
  Future<AiOutput> analyzePhoto(XFile image, Map<String, dynamic> userData) async {
    if (mockException != null) {
      throw mockException!;
    }
    return mockOutput ?? AiOutput(
      landmarksDetected: true,
      bmi: 24.5,
      bodyFatPct: 15.0,
      leanMassKg: 68.0,
      riskLevel: 'Düşük Risk',
      recommendations: AiRecommendations(
        dailyCalories: 2000,
        macros: {'protein_g': 140, 'carbs_g': 200, 'fat_g': 60},
        dietPlan: ['Diyet 1', 'Diyet 2', 'Diyet 3'],
        workoutPlan: ['Spor 1', 'Spor 2'],
      ),
      debug: AiDebug(
        poseScore: 0.95,
        qualityChecks: {'fullBodyVisible': true, 'poseOk': true},
        rawRatios: {},
      ),
    );
  }
}

void main() {
  group('AnalyzingScreen Widget Tests', () {
    final mockImage = XFile('/mock/image.png');
    final mockUserData = UserData(
      name: 'Test',
      age: 25,
      gender: 'male',
      weight: 80,
      height: 180,
      goal: 'lose',
    );

    testWidgets('Should call onComplete upon ScannerSuccess and animation end', (WidgetTester tester) async {
      final mockOutput = AiOutput(
        landmarksDetected: true,
        bmi: 24.5,
        bodyFatPct: 15.0,
        leanMassKg: 68.0,
        riskLevel: 'Düşük Risk',
        recommendations: AiRecommendations(
          dailyCalories: 2000,
          macros: {'protein_g': 140, 'carbs_g': 200, 'fat_g': 60},
          dietPlan: ['Diyet 1', 'Diyet 2', 'Diyet 3'],
          workoutPlan: ['Spor 1', 'Spor 2'],
        ),
        debug: AiDebug(
          poseScore: 0.95,
          qualityChecks: {'fullBodyVisible': true, 'poseOk': true},
          rawRatios: {},
        ),
      );

      final apiService = MockApiService(mockOutput: mockOutput);
      final scannerBloc = ScannerBloc(apiService);

      bool isCompleted = false;
      Map<String, dynamic>? completedResults;
      AiOutput? completedOutput;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ScannerBloc>.value(
            value: scannerBloc,
            child: AnalyzingScreen(
              image: mockImage,
              userData: mockUserData,
              onComplete: (results, output) {
                isCompleted = true;
                completedResults = results;
                completedOutput = output;
              },
            ),
          ),
        ),
      );

      // Pumping initial layout
      await tester.pump();

      // Verify screen layout contains progress info
      expect(find.text('Görsel işleniyor...'), findsOneWidget);

      // Let animation loop run (total step duration is 8000ms, let's pump in increments)
      for (int i = 0; i < 16; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }

      // Check if onComplete was called with correct values
      expect(isCompleted, isTrue);
      expect(completedOutput, isNotNull);
      expect(completedResults!['bmi'], 24.5);
    });

    testWidgets('Should display invalid photo dialog upon ScannerError with invalid_photo', (WidgetTester tester) async {
      final apiService = MockApiService(mockException: const FormatException('invalid_photo'));
      final scannerBloc = ScannerBloc(apiService);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ScannerBloc>.value(
            value: scannerBloc,
            child: AnalyzingScreen(
              image: mockImage,
              userData: mockUserData,
            ),
          ),
        ),
      );

      await tester.pump();

      // Trigger the event handler and let bloc emit failure state.
      // We pump 10 seconds so the entire 8-second animation loop completes and cancels its delayed timers.
      await tester.pump(const Duration(seconds: 10));

      // Invalid photo dialog contains a title "Geçersiz Fotoğraf" or "Hata"
      // Let's verify that the dialog is shown. In invalid_photo_dialog.dart it shows:
      // "Fotoğraf Analiz Edilemedi" or "Geçersiz Fotoğraf"
      expect(find.byType(Dialog), findsOneWidget);
    });
  });
}
