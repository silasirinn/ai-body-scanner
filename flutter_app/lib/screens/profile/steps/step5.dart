import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_typography.dart';
import '../../../widgets/primary_button.dart';

class ProfileStep5 extends StatefulWidget {
  final Function(String)? onComplete;

  const ProfileStep5({super.key, this.onComplete});

  @override
  State<ProfileStep5> createState() => _ProfileStep5State();
}

class _ProfileStep5State extends State<ProfileStep5> {
  String? goal;

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
                  child: Text("Hedefin nedir?",
                      style: AppTypography.h2, textAlign: TextAlign.center),
                ),
                const SizedBox(height: 12),
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: Text("Sana özel bir plan oluşturalım",
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.mutedForeground),
                      textAlign: TextAlign.center),
                ),
                const SizedBox(height: 32),
                _buildGoalItem("Kilo Vermek", "lose", LucideIcons.trendingDown,
                    Colors.purple, 200),
                const SizedBox(height: 12),
                _buildGoalItem("Kiloyu Korumak", "maintain", LucideIcons.target,
                    Colors.teal, 300),
                const SizedBox(height: 12),
                _buildGoalItem("Kilo Almak", "gain", LucideIcons.trendingUp,
                    Colors.blue, 400),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: PrimaryButton(
              onPressed:
                  goal != null ? () => widget.onComplete?.call(goal!) : null,
              fullWidth: true,
              child: const Text("Tamamla ve Başla"),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildGoalItem(String title, String value, IconData icon,
      MaterialColor color, int delay) {
    final bool selected = goal == value;
    return FadeInLeft(
      delay: Duration(milliseconds: delay),
      child: GestureDetector(
        onTap: () => setState(() => goal = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: selected ? color[50] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: selected ? color : AppColors.gray200, width: 2),
            boxShadow: selected
                ? [
                    BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4))
                  ]
                : [],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    gradient:
                        LinearGradient(colors: [color[400]!, color[600]!]),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.h3.copyWith(fontSize: 16)),
                    Text("Açıklama...",
                        style: AppTypography.caption
                            .copyWith(color: AppColors.mutedForeground)),
                  ],
                ),
              ),
              if (selected)
                Container(
                    padding: const EdgeInsets.all(4),
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle),
                    child: const Icon(LucideIcons.check,
                        color: Colors.white, size: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
