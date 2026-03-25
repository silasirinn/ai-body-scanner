import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'config/app_theme.dart';
import 'screens/login/login_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/instructions/instructions_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/analyzing/analyzing_screen.dart';
import 'screens/results/results_screen.dart';
import 'screens/program/program_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'ai/user_data_store.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/scanner/scanner_bloc.dart';
import 'services/api_service.dart';
import 'screens/history/history_screen.dart';

void main() {
  runApp(
    BlocProvider(
      create: (context) => ScannerBloc(ApiService()),
      child: const MainApp(),
    )
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Body Scanner',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      debugShowCheckedModeBanner: false,
      routes: {
        AppRoutes.login: (context) => LoginWrapper(),
        AppRoutes.profile: (context) => ProfileScreen(onComplete: () => Navigator.pushNamed(context, AppRoutes.instructions)),
        AppRoutes.instructions: (context) => InstructionsScreen(
          onNext: () => Navigator.pushNamed(context, AppRoutes.dashboard),
          onBack: () => Navigator.pop(context),
        ),
        AppRoutes.dashboard: (context) => DashboardWrapper(),
        AppRoutes.settings: (context) => SettingsScreen(onBack: () => Navigator.pop(context)),
        AppRoutes.analyzing: (context) {
          final image = ModalRoute.of(context)!.settings.arguments as XFile;
          return AnalyzingScreen(
            image: image,
            userData: UserDataStore().data,
            onComplete: (results, output) {
               Navigator.pushReplacementNamed(
                 context, 
                 AppRoutes.results, 
                 arguments: {'results': results, 'output': output}
               );
            }
          );
        },
        AppRoutes.results: (context) => ResultsScreen(
            onViewProgram: (output) => Navigator.pushNamed(context, AppRoutes.program, arguments: output),
            onBack: () => Navigator.popUntil(context, ModalRoute.withName(AppRoutes.dashboard)),
        ),
        AppRoutes.program: (context) => ProgramScreen(onBack: () => Navigator.pop(context)),
        AppRoutes.history: (context) => HistoryScreen(onBack: () => Navigator.pop(context)),
      },
    );
  }
}

class AppRoutes {
  static const String login = '/';
  static const String profile = '/profile';
  static const String instructions = '/instructions';
  static const String dashboard = '/dashboard';
  static const String settings = '/settings';
  static const String analyzing = '/analyzing';
  static const String results = '/results';
  static const String program = '/program';
  static const String history = '/history';
}

class LoginWrapper extends StatelessWidget {
   @override
   Widget build(BuildContext context) {
       return LoginScreen(
           onLogin: () => Navigator.pushNamed(context, AppRoutes.instructions),
           onRegister: () => Navigator.pushNamed(context, AppRoutes.profile),
       );
   }
}

class DashboardWrapper extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        final name = UserDataStore().data.name;
        return DashboardScreen(
            userName: name.isNotEmpty ? name : "Kullanıcı",
            onSettings: () => Navigator.pushNamed(context, AppRoutes.settings),
            onAnalyze: (image) => Navigator.pushNamed(context, AppRoutes.analyzing, arguments: image),
            onBack: () => Navigator.pop(context),
        );
    }
}
