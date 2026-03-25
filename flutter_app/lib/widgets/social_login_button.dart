import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../config/app_colors.dart';
import '../config/app_typography.dart';

class SocialLoginButton extends StatefulWidget {
  final Widget icon; // Can be SvgPicture or generic Widget
  final String text;
  final VoidCallback? onPressed;

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.text,
    this.onPressed,
  });

  @override
  State<SocialLoginButton> createState() => _SocialLoginButtonState();
}

class _SocialLoginButtonState extends State<SocialLoginButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // React: w-full flex items-center justify-center gap-3 px-6 py-3 rounded-lg
    // bg-white border-2 border-border text-foreground
    // hover:bg-gray-50
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // px-6 py-3
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.gray50 : AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.icon,
              const SizedBox(width: 12), // gap-3 (12px)
              Text(
                widget.text,
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w500, // Usually buttons are medium
                  color: AppColors.foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
