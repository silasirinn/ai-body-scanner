import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../config/app_colors.dart';
import '../../config/app_typography.dart';
import '../../widgets/primary_button.dart';
import '../../ai/models/ai_output.dart';

class ResultsScreen extends StatelessWidget {
  final Function(AiOutput)? onViewProgram;
  final VoidCallback? onBack;
  final Map<String, dynamic>? results;

  const ResultsScreen({
    super.key,
    this.onViewProgram,
    this.onBack,
    this.results,
  });

  @override
  Widget build(BuildContext context) {
    // Read arguments
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final Map<String, dynamic> data = args?['results'] ?? results ?? {
      'bodyFat': 0.0,
      'leanMass': 0.0,
      'bmi': 0.0,
      'calories': 0,
      'weight': 0,
      'height': 0
    };
    final AiOutput? aiOutput = args?['output'];
    
    // Safety check: if data exists but keys are missing
    final double bmi = (data['bmi'] ?? 0.0).toDouble();
    final double bodyFat = (data['bodyFat'] ?? 0.0).toDouble();
    final int calories = (data['calories'] ?? 0).toInt();
    final double leanMass = (data['leanMass'] ?? 0.0).toDouble();
    final int weight = (data['weight'] ?? 0).toInt();
    final int height = (data['height'] ?? 0).toInt();

    // BMI Status Logic
    String status = "Normal";
    Color statusColor = AppColors.emerald500;
    Color statusBg = AppColors.emerald50; // bg-emerald-50

    if (bmi < 18.5) { status = "Zayıf"; statusColor = Colors.blue; statusBg = AppColors.blue50; }
    else if (bmi < 25) { status = "Normal"; statusColor = AppColors.emerald500; statusBg = AppColors.emerald50; }
    else if (bmi < 30) { status = "Fazla Kilolu"; statusColor = Colors.orange; statusBg = AppColors.orange50; }
    else if (bmi < 40) { status = "Obez"; statusColor = Colors.red; statusBg = AppColors.red50; }
    else { status = "Aşırı Obez"; statusColor = Colors.red[900]!; statusBg = Colors.red[100]!; }

    final bool showWarning = bmi > 40 || bodyFat > 35;

    return Scaffold(
        body: Container(
             decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [AppColors.purple50, AppColors.white, AppColors.emerald50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                ),
            ),
            child: SafeArea(
                child: Column(
                    children: [
                        // Header
                        Padding(
                            padding: const EdgeInsets.only(top: 24, bottom: 16, left: 24, right: 24),
                            child: FadeInDown(
                                from: 20,
                                child: Column(
                                    children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: InkWell(
                                              onTap: onBack ?? () => Navigator.pop(context),
                                              borderRadius: BorderRadius.circular(50),
                                              child: Container(
                                                  width: 40, height: 40,
                                                  decoration: const BoxDecoration(color: AppColors.gray100, shape: BoxShape.circle),
                                                  child: const Icon(LucideIcons.chevronLeft, color: AppColors.gray600),
                                              ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                            width: 48, height: 48,
                                            decoration: BoxDecoration(
                                                gradient: AppColors.logoGradient,
                                                borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Icon(LucideIcons.sparkles, color: Colors.white),
                                        ),
                                        const SizedBox(height: 12),
                                        Text("Analiz Sonuçlarınız Hazır", style: AppTypography.h2),
                                        const SizedBox(height: 4),
                                        Text("AI destekli vücut kompozisyon analizi", style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground)),
                                    ],
                                ),
                            ),
                        ),

                        Expanded(
                            child: ListView(
                                padding: const EdgeInsets.all(24),
                                children: [
                                    // Body Silhouette
                                    ZoomIn(
                                        child: Container(
                                            padding: const EdgeInsets.all(24),
                                            decoration: BoxDecoration(
                                                color: AppColors.white,
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(color: AppColors.gray100),
                                            ),
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: 200,
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                        SvgPicture.string(
                                                            '''<svg width="120" height="200" viewBox="0 0 120 200" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                            <ellipse cx="60" cy="25" rx="18" ry="22" fill="#D1D5DB"/>
                                                            <rect x="50" y="47" width="20" height="60" rx="10" fill="#D1D5DB"/>
                                                            <rect x="35" y="55" width="15" height="45" rx="7.5" fill="#D1D5DB"/>
                                                            <rect x="70" y="55" width="15" height="45" rx="7.5" fill="#D1D5DB"/>
                                                            <rect x="50" y="107" width="8" height="75" rx="4" fill="#D1D5DB"/>
                                                            <rect x="62" y="107" width="8" height="75" rx="4" fill="#D1D5DB"/>
                                                            
                                                            <circle cx="35" cy="55" r="4" fill="#8B5CF6"/>
                                                            <circle cx="85" cy="55" r="4" fill="#8B5CF6"/>
                                                            
                                                            <circle cx="45" cy="85" r="4" fill="#10B981"/>
                                                            <circle cx="75" cy="85" r="4" fill="#10B981"/>
                                                            
                                                            <circle cx="48" cy="107" r="4" fill="#8B5CF6"/>
                                                            <circle cx="72" cy="107" r="4" fill="#8B5CF6"/>
                                                            </svg>''',
                                                            height: 200,
                                                        ),
                                                        // Labels
                                                        Positioned(left: 20, top: 40, child: Text("Omuz", style: AppTypography.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold))),
                                                        Positioned(left: 20, top: 80, child: Text("Bel", style: AppTypography.caption.copyWith(color: AppColors.accent, fontWeight: FontWeight.bold))),
                                                        Positioned(left: 20, top: 120, child: Text("Kalça", style: AppTypography.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold))),
                                                      ],
                                                    ),
                                                ),
                                                const SizedBox(height: 16),
                                                Text("AI tarafından algılanan kilit noktalar", style: AppTypography.caption),
                                              ],
                                            ),
                                        ),
                                    ),

                                    const SizedBox(height: 24),

                                    FadeInUp(
                                        child: Column(
                                            children: [
                                                Row(
                                                    children: [
                                                        Container(width: 4, height: 24, decoration: BoxDecoration(gradient: AppColors.logoGradient, borderRadius: BorderRadius.circular(4))),
                                                        const SizedBox(width: 8),
                                                        Text("Vücut Kompozisyonu", style: AppTypography.h3),
                                                    ],
                                                ),
                                                const SizedBox(height: 16),
                                                Row(
                                                    children: [
                                                        Expanded(child: _buildCircleChart("Vücut Yağ Oranı", bodyFat, Colors.orange, AppColors.orange500)),
                                                        const SizedBox(width: 16),
                                                        Expanded(child: _buildCircleChart("Yağsız Kütle", leanMass, AppColors.emerald500, AppColors.emerald500)),
                                                    ],
                                                ),
                                            ],
                                        ),
                                    ),

                                    const SizedBox(height: 16),

                                    // Info Box
                                    FadeInUp(
                                        delay: const Duration(milliseconds: 200),
                                        child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                                color: AppColors.emerald50,
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: AppColors.emerald100),
                                            ),
                                            child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                    const Icon(LucideIcons.info, size: 20, color: AppColors.emerald500),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                        child: RichText(
                                                            text: TextSpan(
                                                                style: AppTypography.bodySmall.copyWith(color: Colors.black87),
                                                                children: const [
                                                                    TextSpan(text: "Yağsız kütle; ", style: TextStyle(fontWeight: FontWeight.bold)),
                                                                    TextSpan(text: "kaslarınızı, kemiklerinizi, organlarınızı ve vücut suyunuzu içerir."),
                                                                ]
                                                            ),
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ),
                                    ),

                                    const SizedBox(height: 24),
                                    
                                    // Health Data
                                    FadeInUp(
                                        delay: const Duration(milliseconds: 300),
                                        child: Column(
                                            children: [
                                                _buildCard(
                                                    child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                            Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                crossAxisAlignment: CrossAxisAlignment.start, // Align to top for safety
                                                                children: [
                                                                    Expanded( // Wrapped in Expanded
                                                                        child: Text("Vücut Kütle İndeksi (VKİ)", style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground)),
                                                                    ),
                                                                    const SizedBox(width: 8),
                                                                    Container(
                                                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                                        decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)),
                                                                        child: Text(status, style: AppTypography.caption.copyWith(color: statusColor, fontWeight: FontWeight.bold)),
                                                                    ),
                                                                ],
                                                            ),
                                                            const SizedBox(height: 8),
                                                            Text(bmi.toStringAsFixed(1), style: AppTypography.h1.copyWith(fontSize: 32, fontWeight: FontWeight.bold)),
                                                        ],
                                                    ),
                                                    borderColor: statusColor.withOpacity(0.3),
                                                    bg: statusBg.withOpacity(0.3), // Light tint
                                                ),
                                                const SizedBox(height: 12),
                                                _buildCard(
                                                    child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                            Expanded( // Wrapped in Expanded
                                                                child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                        Text("Günlük Hedef Kalori", style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground)),
                                                                        Row(
                                                                            crossAxisAlignment: CrossAxisAlignment.baseline,
                                                                            textBaseline: TextBaseline.alphabetic,
                                                                            children: [
                                                                                 Text("$calories", style: AppTypography.h2.copyWith(fontWeight: FontWeight.bold)),
                                                                                 const SizedBox(width: 4),
                                                                                 Text("kcal", style: AppTypography.bodySmall),
                                                                            ],
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                            const SizedBox(width: 16),
                                                            Container(
                                                                width: 48, height: 48,
                                                                decoration: BoxDecoration(
                                                                    gradient: AppColors.logoGradient,
                                                                    borderRadius: BorderRadius.circular(12),
                                                                ),
                                                                child: const Icon(LucideIcons.flame, color: Colors.white),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),

                                    if (showWarning)
                                        Padding(
                                            padding: const EdgeInsets.only(top: 16),
                                            child: Container(
                                                padding: const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                    gradient: const LinearGradient(colors: [AppColors.red50, AppColors.orange50]),
                                                    borderRadius: BorderRadius.circular(16),
                                                    border: Border.all(color: AppColors.red200),
                                                ),
                                                child: Row(
                                                    children: [
                                                        Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.destructive, borderRadius: BorderRadius.circular(12)), child: const Icon(LucideIcons.alertTriangle, color: Colors.white, size: 20)),
                                                        const SizedBox(width: 12),
                                                        Expanded(
                                                            child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                    Text("Sağlık Uyarısı", style: AppTypography.bodySmall.copyWith(color: Colors.red[900], fontWeight: FontWeight.bold)),
                                                                    Text("VKİ veya yağ oranınız riskli seviyelerde.", style: AppTypography.caption.copyWith(color: Colors.red[800])),
                                                                ],
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                            ),
                                        ),
                                ],
                            ),
                        ),

                        // Action Button
                        Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                                color: AppColors.white.withOpacity(0.9),
                                border: const Border(top: BorderSide(color: AppColors.gray100)),
                            ),
                            child: PrimaryButton(
                                onPressed: () {
                                    if (onViewProgram != null && aiOutput != null) {
                                        onViewProgram!(aiOutput);
                                    } else if (onViewProgram != null) {
                                        // Fallback
                                    }
                                },
                                fullWidth: true,
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                        Icon(LucideIcons.sparkles, size: 20, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text("KİŞİSEL PROGRAMIMI GÖR"),
                                    ],
                                ),
                            ),
                        ),
                    ],
                ),
            ),
        ),
    );
  }

  Widget _buildCard({required Widget child, Color? borderColor, Color? bg}) {
    return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: bg ?? AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor ?? AppColors.gray100),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: child,
    );
  }

  Widget _buildCircleChart(String label, double percentage, Color color, Color strokeColor) {
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Column(
            children: [
                SizedBox(
                    height: 80, width: 80,
                    child: Stack(
                        alignment: Alignment.center,
                        children: [
                            CircularProgressIndicator(
                                value: 1.0,
                                strokeWidth: 8,
                                valueColor: AlwaysStoppedAnimation(color.withOpacity(0.2)),
                            ),
                            TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: percentage / 100),
                                duration: const Duration(seconds: 2),
                                builder: (context, value, _) => CircularProgressIndicator(
                                    value: value,
                                    strokeWidth: 8,
                                    valueColor: AlwaysStoppedAnimation(strokeColor),
                                    strokeCap: StrokeCap.round,
                                ),
                            ),
                            Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    Text(
                                        "${percentage.toStringAsFixed(1)}%",
                                        style: AppTypography.h3.copyWith(
                                            fontWeight: FontWeight.w900, // Extra Bold
                                            color: strokeColor,
                                            fontSize: 20 // Bigger font
                                        )
                                    ),
                                ],
                            )
                        ],
                    ),
                ),
                const SizedBox(height: 12),
                Text(label, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center), // Center align and handle wrap
                Text("Tahmini", style: AppTypography.caption),
            ],
        ),
    );
  }
}
