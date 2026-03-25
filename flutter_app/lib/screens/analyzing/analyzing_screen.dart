import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../config/app_colors.dart';

import 'package:image_picker/image_picker.dart';
import '../../ai/user_data_store.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/scanner/scanner_bloc.dart';
import '../../blocs/scanner/scanner_event.dart';
import '../../blocs/scanner/scanner_state.dart';
import '../../widgets/invalid_photo_dialog.dart';
import '../../ai/models/ai_output.dart';

class AnalyzingScreen extends StatefulWidget {
  final XFile image;
  final UserData userData;
  final Function(Map<String, dynamic> results, AiOutput rawOutput)? onComplete;

  const AnalyzingScreen({
    super.key, 
    required this.image, 
    required this.userData, 
    this.onComplete
  });

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen> with TickerProviderStateMixin {
  int _currentStep = 0;
  double _progress = 0;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  
  AiOutput? _aiOutput;
  Map<String, dynamic>? _resultsMap;
  bool _aiError = false;

  final List<Map<String, dynamic>> _steps = [
    {'icon': LucideIcons.scan, 'label': "Görsel işleniyor...", 'duration': 2000},
    {'icon': LucideIcons.brain, 'label': "AI analizi yapılıyor...", 'duration': 2500},
    {'icon': LucideIcons.zap, 'label': "Ölçümler hesaplanıyor...", 'duration': 2000},
    {'icon': LucideIcons.target, 'label': "Sonuçlar hazırlanıyor...", 'duration': 1500},
  ];

  @override
  void initState() {
    super.initState();
    _startAnalysisProcess();

    _pulseController = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))..repeat();
    
    _rotateController = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  Future<void> _startAnalysisProcess() async {
     // Start Animation loop independently
     _runAnimationLoop();
     
     // Start AI via Bloc
     context.read<ScannerBloc>().add(
        AnalyzePhotoEvent(widget.image, {
          'name': widget.userData.name,
          'age': widget.userData.age,
          'gender': widget.userData.gender,
          'weight': widget.userData.weight,
          'height': widget.userData.height,
          'goal': widget.userData.goal,
        })
     );
  }

  void _runAnimationLoop() {
    int totalDuration = _steps.fold(0, (sum, step) => sum + (step['duration'] as int));
    
    // Step update
    int elapsed = 0;
    for (int i = 0; i < _steps.length; i++) {
        Future.delayed(Duration(milliseconds: elapsed), () {
            if (mounted) setState(() => _currentStep = i);
        });
        elapsed += _steps[i]['duration'] as int;
    }

    // Progress update
    const updateInterval = 50;
    int currentProgressTime = 0;
    
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: updateInterval));
      if (!mounted) return false;
      
      currentProgressTime += updateInterval;
      double newProgress = (currentProgressTime / totalDuration) * 100;
      if (newProgress > 100) newProgress = 100;
      
      setState(() => _progress = newProgress);
      
          if (currentProgressTime >= totalDuration) {
              // Animation done. Check AI result.
              if (_aiError) {
                 return false;
              }
              
              if (_aiOutput != null && _resultsMap != null) {
                  debugPrint("AI_DEBUG: UI Flow - Analysis VALID. Navigating to ResultsScreen.");
                  
                  if (mounted) {
                      widget.onComplete?.call(_resultsMap!, _aiOutput!);
                  }
              } else {
                  return true; // Continue loop but keep progress at 100
              }
              
              return false;
          }
          return true;
      });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScannerBloc, ScannerState>(
      listener: (context, state) {
        if (state is ScannerError) {
           setState(() => _aiError = true);
           if (state.isInvalidPhoto) {
               showInvalidPhotoDialog(context);
           } else {
               ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text(state.message), backgroundColor: Colors.red)
               );
               Navigator.pop(context);
           }
        } else if (state is ScannerSuccess) {
           setState(() {
             _aiOutput = state.aiOutput;
             _resultsMap = state.resultsUiMap;
           });
        }
      },
      child: Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
                Color(0xFF9333EA), // purple-600
                Color(0xFFA855F7), // purple-500
                Color(0xFF10B981)  // emerald-500
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Icon Center
            Stack(
              alignment: Alignment.center,
              children: [
                // Pulse rings
                FadeTransition(
                  opacity: Tween(begin: 0.5, end: 0.0).animate(_pulseController),
                  child: ScaleTransition(
                    scale: Tween(begin: 1.0, end: 1.5).animate(_pulseController),
                    child: Container(
                      width: 128, height: 128,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                ScaleTransition(
                    scale: Tween(begin: 1.0, end: 1.8).animate(CurvedAnimation(parent: _pulseController, curve: const Interval(0.5, 1.0))),
                     child: FadeTransition(
                        opacity: Tween(begin: 0.3, end: 0.0).animate(CurvedAnimation(parent: _pulseController, curve: const Interval(0.5, 1.0))),
                        child: Container(
                        width: 128, height: 128,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                        ),
                        ),
                    ),
                ),

                // Main Icon Container
                RotationTransition(
                  turns: _rotateController,
                  child: Container(
                    width: 128, height: 128,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2), // backdrop blur simulated
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 4),
                    ),
                  ),
                ),
                
                // Icon
                AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                    child: Icon(
                        _steps[_currentStep]['icon'] as IconData,
                        key: ValueKey(_currentStep),
                        color: Colors.white,
                        size: 64,
                    ),
                ),
              ],
            ),
            
            const SizedBox(height: 48),

            // Text
            AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Column(
                    key: ValueKey(_currentStep),
                    children: [
                        Text(
                            _steps[_currentStep]['label'] as String,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                            "Lütfen bekleyin...",
                            style: TextStyle(color: Colors.white70),
                        ),
                    ],
                ),
            ),
            
            const SizedBox(height: 32),

            // Progress Bar
            SizedBox(
                width: 320,
                child: Column(
                    children: [
                        Container(
                            height: 8,
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                            ),
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: 320 * (_progress / 100),
                                    height: 8,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                    ),
                                ),
                            ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                            "%${_progress.round()}",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                    ],
                ),
            ),
          ],
        ),
      ),
    ));
  }
}
