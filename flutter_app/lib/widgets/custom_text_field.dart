import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_typography.dart';

class CustomTextField extends StatelessWidget {
  final String? label;
  final String? placeholder;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    this.label,
    this.placeholder,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.body.copyWith(
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 8), // mb-2 (8px)
        ],
        Container(
          decoration: BoxDecoration(
             boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: AppTypography.body.copyWith(color: AppColors.foreground),
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: AppTypography.body.copyWith(color: AppColors.mutedForeground),
              filled: true,
              fillColor: AppColors.white, // bg-input-background (white)
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // px-4 py-3.5
              
              // Border-2 border-border
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border, width: 2),
              ),
              // Focus ring logic: ring-2 ring-primary/20 + border-primary
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary, width: 2), // border-primary
              ),
              // Note: ring-2 ring-primary/20 is a shadow/ring effect. 
              // We can approximate with focusedBorder or wrap in a container with shadow.
              // For simplicity and standard behavior, just valid border is usually fine.
              // But strictly, we could add a shadow here if needed.
            ),
          ),
        ),
      ],
    );
  }
}
