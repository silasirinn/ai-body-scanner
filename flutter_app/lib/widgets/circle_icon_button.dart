import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class CircleIconButton extends StatefulWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final bool sizeLarge; // size="lg" vs "md"
  final bool disabled;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.sizeLarge = true,
    this.disabled = false,
  });

  @override
  State<CircleIconButton> createState() => _CircleIconButtonState();
}

class _CircleIconButtonState extends State<CircleIconButton> with SingleTickerProviderStateMixin {
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.disabled || widget.onPressed == null;
    final double size = widget.sizeLarge ? 64 : 48; // w-16 (64px) vs w-12 (48px)

    return MouseRegion(
      cursor: isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => isDisabled ? null : _controller.forward(),
        onTapUp: (_) => isDisabled ? null : _controller.reverse(),
        onTapCancel: () => isDisabled ? null : _controller.reverse(),
        onTap: isDisabled ? null : widget.onPressed,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double scale = _scaleAnimation.value;
            if (_isHovered && !isDisabled && _controller.isDismissed) {
              scale = 1.05; // hover scale 1.05
            }
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: isDisabled
                  ? null
                  : const LinearGradient(
                      colors: [AppColors.accent, Color(0xFF059669)], // accent to emerald-600
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              color: isDisabled ? AppColors.accent.withOpacity(0.5) : null,
              shape: BoxShape.circle,
              boxShadow: _isHovered && !isDisabled
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ], // shadow-lg
            ),
            alignment: Alignment.center,
            child: IconTheme(
              data: const IconThemeData(color: Colors.white, size: 32),
              child: widget.icon,
            ),
          ),
        ),
      ),
    );
  }
}
