import 'package:flutter/material.dart';
import 'package:flux_bank/theme/app_theme.dart';

enum FluxButtonVariant { primary, secondary, danger, ghost }

class FluxButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final FluxButtonVariant variant;
  final IconData? icon;
  final double? width;
  final double height;
  final bool isDark;

  const FluxButton(
    this.label, {
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.variant = FluxButtonVariant.primary,
    this.icon,
    this.width,
    this.height = 52.0,
    this.isDark = false,
  });

  @override
  State<FluxButton> createState() => _FluxButtonState();
}

class _FluxButtonState extends State<FluxButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      upperBound: 0.05,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (widget.variant) {
      case FluxButtonVariant.primary:
        // White background, black text
        bg = AppColors.textPrimary;
        fg = Colors.black;
        break;
      case FluxButtonVariant.secondary:
        // Transparent bg, border, text
        bg = Colors.transparent;
        fg = widget.isDark ? Colors.white : AppColors.textPrimary;
        border = BorderSide(color: widget.isDark ? Colors.white : AppColors.textPrimary, width: 1.5);
        break;
      case FluxButtonVariant.danger:
        // Red bg, white text
        bg = AppColors.debit;
        fg = AppColors.textPrimary;
        break;
      case FluxButtonVariant.ghost:
        // Transparent, white text
        bg = Colors.transparent;
        fg = AppColors.textPrimary;
        break;
    }

    if (widget.onPressed == null) {
      bg = bg == Colors.transparent
          ? bg
          : bg.withValues(alpha: 0.4);
      fg = fg.withValues(alpha: 0.4);
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - _controller.value,
            child: child,
          );
        },
        child: SizedBox(
          width: widget.width ?? double.infinity,
          height: widget.height,
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: bg,
              foregroundColor: fg,
              disabledBackgroundColor: bg.withValues(alpha: 0.4),
              disabledForegroundColor: fg.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: border,
              ),
              elevation: 0,
            ),
            child: widget.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(fg),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 18),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
