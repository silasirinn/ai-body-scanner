import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_typography.dart';
import '../../../widgets/circle_icon_button.dart';
import '../../../widgets/custom_text_field.dart';

class ProfileStep1 extends StatefulWidget {
  final Function(String)? onNext;

  const ProfileStep1({super.key, this.onNext});

  @override
  State<ProfileStep1> createState() => _ProfileStep1State();
}

class _ProfileStep1State extends State<ProfileStep1> {
  String name = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ZoomIn(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                      gradient: AppColors.logoGradient, shape: BoxShape.circle),
                  child: const Icon(LucideIcons.user,
                      color: Colors.white, size: 40),
                ),
              ),
              const SizedBox(height: 32),
              FadeInUp(
                child: Text("Sana nasıl hitap edebiliriz?",
                    style: AppTypography.h2, textAlign: TextAlign.center),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: Text(
                    "Kişiselleştirilmiş deneyim için adınızı öğrenmek isteriz",
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.mutedForeground),
                    textAlign: TextAlign.center),
              ),
              const SizedBox(height: 32),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: CustomTextField(
                    placeholder: "Adınız ve Soyadınız",
                    onChanged: (v) => setState(() => name = v),
                  ),
                ),
              ),
            ],
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
                  onPressed:
                      name.isNotEmpty ? () => widget.onNext?.call(name) : null,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
