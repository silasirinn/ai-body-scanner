import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../config/app_colors.dart';
import '../../config/app_typography.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/custom_text_field.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const SettingsScreen({super.key, this.onBack});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Form State
  String name = "";
  String age = "";
  String gender = "female";
  double weight = 70;
  double height = 170;
  String goal = "maintain";

  @override
  Widget build(BuildContext context) {
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
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            child: Row(
                                children: [
                                    InkWell(
                                        onTap: widget.onBack,
                                        borderRadius: BorderRadius.circular(50),
                                        child: Container(
                                            width: 40, height: 40,
                                            decoration: const BoxDecoration(color: AppColors.gray100, shape: BoxShape.circle),
                                            child: const Icon(LucideIcons.chevronLeft, color: AppColors.gray600),
                                        ),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            Text("Ayarlar", style: AppTypography.h2),
                                            Text("Kişisel bilgilerinizi düzenleyin", style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground)),
                                        ],
                                    )
                                ],
                            ),
                        ),

                        Expanded(
                            child: ListView(
                                padding: const EdgeInsets.all(24),
                                children: [
                                    FadeInLeft(
                                        child: CustomTextField(
                                            label: "Ad Soyad",
                                            placeholder: "Adınız ve Soyadınız",
                                            onChanged: (v) => name = v,
                                        ),
                                    ),
                                    const SizedBox(height: 24),
                                    FadeInLeft(
                                        delay: const Duration(milliseconds: 100),
                                        child: CustomTextField(
                                            label: "Yaş",
                                            placeholder: "Yaşınız",
                                            keyboardType: TextInputType.number,
                                            onChanged: (v) => age = v,
                                        ),
                                    ),
                                     const SizedBox(height: 24),
                                    
                                    // Gender
                                    FadeInLeft(
                                        delay: const Duration(milliseconds: 200),
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                const Text("Cinsiyet", style: TextStyle(fontWeight: FontWeight.bold)),
                                                const SizedBox(height: 12),
                                                Row(
                                                    children: [
                                                        Expanded(child: _buildGenderBtn("Kadın", "female", Colors.purple[50]!, AppColors.primary)),
                                                        const SizedBox(width: 12),
                                                        Expanded(child: _buildGenderBtn("Erkek", "male", Colors.green[50]!, AppColors.accent)),
                                                    ],
                                                )
                                            ],
                                        ),
                                    ),

                                    const SizedBox(height: 24),
                                    
                                    // Weight
                                    FadeInLeft(
                                        delay: const Duration(milliseconds: 300),
                                        child: _buildSlider("Kilo", weight, 30, 200, (v) => setState(() => weight = v), AppColors.primary),
                                    ),

                                    const SizedBox(height: 24),

                                    // Height
                                    FadeInLeft(
                                        delay: const Duration(milliseconds: 400),
                                        child: _buildSlider("Boy", height, 100, 250, (v) => setState(() => height = v), AppColors.accent),
                                    ),

                                    const SizedBox(height: 24),

                                    // Goal
                                    FadeInLeft(
                                        delay: const Duration(milliseconds: 500),
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                const Text("Hedef", style: TextStyle(fontWeight: FontWeight.bold)),
                                                const SizedBox(height: 12),
                                                _buildGoalBtn("Kilo Vermek", "lose"),
                                                const SizedBox(height: 8),
                                                _buildGoalBtn("Kiloyu Korumak", "maintain"),
                                                const SizedBox(height: 8),
                                                _buildGoalBtn("Kilo Almak", "gain"),
                                            ],
                                        ),
                                    ),
                                ],
                            ),
                        ),

                        Container(
                            padding: const EdgeInsets.all(24),
                            child: PrimaryButton(
                                onPressed: widget.onBack,
                                fullWidth: true,
                                child: const Text("Değişiklikleri Kaydet"),
                            ),
                        ),
                    ],
                ),
            ),
        ),
    );
  }

  Widget _buildGenderBtn(String label, String value, Color bg, Color border) {
    final selected = gender == value;
    return GestureDetector(
        onTap: () => setState(() => gender = value),
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: selected ? bg : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: selected ? border : AppColors.gray200, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.foreground)),
        ),
    );
  }

  Widget _buildGoalBtn(String label, String value) {
    final selected = goal == value;
    return GestureDetector(
        onTap: () => setState(() => goal = value),
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
                color: selected ? AppColors.purple50 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: selected ? AppColors.primary : AppColors.gray200, width: 2),
            ),
            child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.foreground)),
        ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged, Color activeColor) {
    return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gray100),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text("${value.round()} ${label == 'Boy' ? 'cm' : 'kg'}", style: TextStyle(fontWeight: FontWeight.bold, color: activeColor)),
                    ],
                ),
                SliderTheme(
                    data: SliderThemeData(
                        activeTrackColor: activeColor,
                        inactiveTrackColor: AppColors.gray200,
                        thumbColor: Colors.white,
                        trackHeight: 8,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12, elevation: 2),
                        overlayColor: activeColor.withOpacity(0.2),
                    ),
                    child: Slider(
                        value: value,
                        min: min,
                        max: max,
                        onChanged: onChanged,
                    ),
                ),
            ],
        ),
    );
  }
}
