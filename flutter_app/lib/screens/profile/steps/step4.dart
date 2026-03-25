import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_typography.dart';
import '../../../widgets/circle_icon_button.dart';

class ProfileStep4 extends StatefulWidget {
  final Function(double, double)? onNext;

  const ProfileStep4({super.key, this.onNext});

  @override
  State<ProfileStep4> createState() => _ProfileStep4State();
}

class _ProfileStep4State extends State<ProfileStep4> {
  double weight = 70;
  double height = 170;

  @override
  Widget build(BuildContext context) {
    final bmi = (weight / ((height / 100) * (height / 100))).toStringAsFixed(1);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeInUp(
                  child: Text("Fiziksel ölçüleriniz",
                      style: AppTypography.h2, textAlign: TextAlign.center),
                ),
                const SizedBox(height: 12),
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: Text("Vücut kütle indeksinizi hesaplayalım",
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.mutedForeground),
                      textAlign: TextAlign.center),
                ),
                const SizedBox(height: 32),
                FadeInLeft(
                  delay: const Duration(milliseconds: 200),
                  child: _buildSlider(
                      "Kilo",
                      weight,
                      30,
                      200,
                      (v) => setState(() => weight = v),
                      AppColors.primary,
                      LucideIcons.scale),
                ),
                const SizedBox(height: 24),
                FadeInLeft(
                  delay: const Duration(milliseconds: 300),
                  child: _buildSlider(
                      "Boy",
                      height,
                      100,
                      250,
                      (v) => setState(() => height = v),
                      AppColors.accent,
                      LucideIcons.ruler),
                ),
                const SizedBox(height: 32),
                ZoomIn(
                  delay: const Duration(milliseconds: 400),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [AppColors.purple100, AppColors.emerald100]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text("Vücut Kütle İndeksi",
                            style: AppTypography.bodySmall
                                .copyWith(color: AppColors.mutedForeground)),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                                  colors: [AppColors.primary, AppColors.accent])
                              .createShader(bounds),
                          child: Text(bmi,
                              style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: CircleIconButton(
                  icon:
                      const Icon(LucideIcons.chevronRight, color: Colors.white),
                  onPressed: () => widget.onNext?.call(weight, height),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSlider(String label, double value, double min, double max,
      ValueChanged<double> onChanged, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: Colors.white, size: 20)),
              const SizedBox(width: 12),
              Expanded(
                // Wrapped in Expanded for safety
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                    Text("${value.round()} ${label == 'Boy' ? 'cm' : 'kg'}",
                        style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                  ],
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
                activeTrackColor: color,
                thumbColor: Colors.white,
                overlayColor: color.withOpacity(0.2)),
            child:
                Slider(value: value, min: min, max: max, onChanged: onChanged),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("${min.toInt()}",
                style: const TextStyle(color: Colors.grey, fontSize: 10)),
            Text("${max.toInt()}",
                style: const TextStyle(color: Colors.grey, fontSize: 10))
          ]),
        ],
      ),
    );
  }
}
