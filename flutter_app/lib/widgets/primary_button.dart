import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_typography.dart';

class PrimaryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool fullWidth;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.fullWidth = false,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        lowerBound: 0.0,
        upperBound: 1.0);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onPressed == null;

    return MouseRegion(
      cursor: isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => isDisabled ? null : _controller.forward(),
        onTapUp: (_) => isDisabled ? null : _controller.reverse(),
        onTapCancel: () => isDisabled ? null : _controller.reverse(),
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double scale = _scaleAnimation.value;
            if (_isHovered && !isDisabled && _controller.isDismissed) {
              scale = 1.02;
            }
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Container(
            width: widget.fullWidth ? double.infinity : null,
            decoration: BoxDecoration(
              gradient: isDisabled
                  ? null
                  : const LinearGradient(
                      colors: [AppColors.primary, AppColors.purple600], // purple600 is defined in AppColors now
                    ),
              color: isDisabled ? AppColors.primary.withOpacity(0.5) : null,
              borderRadius: BorderRadius.circular(8),
              boxShadow: _isHovered && !isDisabled
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            alignment: Alignment.center,
            child: DefaultTextStyle.merge(
              style: AppTypography.bodyLarge.copyWith(
                color: Colors.white,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
