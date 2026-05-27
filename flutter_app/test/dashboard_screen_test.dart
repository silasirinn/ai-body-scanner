import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_app/screens/dashboard/dashboard_screen.dart';

void main() {
  group('DashboardScreen Widget Tests', () {
    // Setup MethodChannel mock for image_picker
    const MethodChannel channel = MethodChannel('plugins.flutter.io/image_picker');

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'pickImage') {
          return '/mock/image_path.png';
        }
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    testWidgets('Should not display "Analizi Başlat" button initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(userName: 'Test Kullanıcı'),
        ),
      );

      // Settle initial entry animations and clear pending delay timers
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));

      // Verify that "Analizi Başlat" button is not visible
      expect(find.text('Analizi Başlat'), findsNothing);
      // Verify upload placeholder is visible
      expect(find.text('Fotoğraf Yükle veya Çek'), findsOneWidget);
    });

    testWidgets('Should display "Analizi Başlat" button after picking image', (WidgetTester tester) async {
      XFile? analyzedImage;

      await tester.pumpWidget(
        MaterialApp(
          home: DashboardScreen(
            userName: 'Test Kullanıcı',
            onAnalyze: (image) {
              analyzedImage = image;
            },
          ),
        ),
      );

      // Verify that button is not there
      expect(find.text('Analizi Başlat'), findsNothing);

      // Tap on "Galeriden Seç" button
      final galleryButton = find.text('Galeriden Seç');
      expect(galleryButton, findsOneWidget);
      await tester.tap(galleryButton);
      await tester.pumpAndSettle();

      // Verify "Analizi Başlat" button is now visible because _selectedImage is set
      expect(find.text('Analizi Başlat'), findsOneWidget);

      // Tap on "Analizi Başlat" button
      final analyzeButton = find.text('Analizi Başlat');
      await tester.tap(analyzeButton);
      await tester.pumpAndSettle();

      // Verify that onAnalyze callback was triggered with the correct XFile
      expect(analyzedImage, isNotNull);
      expect(analyzedImage!.path, '/mock/image_path.png');
    });

    testWidgets('Should display "Analizi Başlat" button after camera capture', (WidgetTester tester) async {
      XFile? analyzedImage;

      await tester.pumpWidget(
        MaterialApp(
          home: DashboardScreen(
            userName: 'Test Kullanıcı',
            onAnalyze: (image) {
              analyzedImage = image;
            },
          ),
        ),
      );

      // Verify that button is not there
      expect(find.text('Analizi Başlat'), findsNothing);

      // Tap on "Kamera ile Çek" button
      final cameraButton = find.text('Kamera ile Çek');
      expect(cameraButton, findsOneWidget);
      await tester.tap(cameraButton);
      await tester.pumpAndSettle();

      // Verify "Analizi Başlat" button is now visible
      expect(find.text('Analizi Başlat'), findsOneWidget);

      // Tap on "Analizi Başlat"
      await tester.tap(find.text('Analizi Başlat'));
      await tester.pumpAndSettle();

      // Verify that onAnalyze was called
      expect(analyzedImage, isNotNull);
      expect(analyzedImage!.path, '/mock/image_path.png');
    });
  });
}
