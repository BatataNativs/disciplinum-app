import 'package:flutter/material.dart';
import '../shared_widgets.dart';

/// Dialog base com tema neon
class NeonDialog extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Color? borderColor;
  final Color? glowColor;

  const NeonDialog({
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.borderColor,
    this.glowColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: width,
        height: height,
        padding: padding ?? const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor ?? AppColors.neonBlue.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: glowColor ?? AppColors.neonBlue.withValues(alpha: 0.2),
              blurRadius: 12,
              spreadRadius: 4,
            ),
            BoxShadow(
              color: glowColor ?? AppColors.neonBlue.withValues(alpha: 0.1),
              blurRadius: 24,
              spreadRadius: 8,
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  /// Método estático para mostrar dialog simples
  static Future<T?> showSimple<T>({
    required BuildContext context,
    required Widget child,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    Color? borderColor,
    Color? glowColor,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => NeonDialog(
        padding: padding,
        width: width,
        height: height,
        borderColor: borderColor,
        glowColor: glowColor,
        child: child,
      ),
    );
  }

  /// Método estático para mostrar dialog com título
  static Future<T?> showWithTitle<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    Color? borderColor,
    Color? glowColor,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => NeonDialog(
        padding: padding,
        width: width,
        height: height,
        borderColor: borderColor,
        glowColor: glowColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.neonBlue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            content,
            if (actions != null) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: actions,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
