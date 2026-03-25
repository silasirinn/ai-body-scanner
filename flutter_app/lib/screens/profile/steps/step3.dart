import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_typography.dart';
import '../../../widgets/circle_icon_button.dart';

class ProfileStep3 extends StatefulWidget {
  final Function(String)? onNext;

  const ProfileStep3({super.key, this.onNext});

  @override
  State<ProfileStep3> createState() => _ProfileStep3State();
}

class _ProfileStep3State extends State<ProfileStep3> {
  String? gender;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeInUp(
                  child: Text("Cinsiyetiniz nedir?",
                      style: AppTypography.h2, textAlign: TextAlign.center),
                ),
                const SizedBox(height: 12),
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                      "Daha doğru analiz için bu bilgiye ihtiyacımız var",
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.mutedForeground),
                      textAlign: TextAlign.center),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                        child: _buildGenderCard("Kadın", "female",
                            AppColors.primary, AppColors.purple50)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildGenderCard("Erkek", "male",
                            AppColors.accent, AppColors.emerald50)),
                  ],
                )
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
                delay: const Duration(milliseconds: 300),
                child: CircleIconButton(
                  icon:
                      const Icon(LucideIcons.chevronRight, color: Colors.white),
                  onPressed: gender != null
                      ? () => widget.onNext?.call(gender!)
                      : null,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildGenderCard(
      String label, String value, Color color, Color bgColor) {
    final bool selected = gender == value;
    return GestureDetector(
      onTap: () => setState(() => gender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: selected ? bgColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: selected ? color : AppColors.gray200, width: 2),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5))
                ]
              : [],
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                  color: selected ? color : AppColors.gray100,
                  shape: BoxShape.circle),
              child: Icon(LucideIcons.user,
                  color: selected ? Colors.white : AppColors.gray400, size: 32),
            ),
            const SizedBox(height: 16),
            Text(label,
                style: AppTypography.h3
                    .copyWith(color: selected ? color : AppColors.foreground)),
          ],
        ),
      ),
    );
  }
}
