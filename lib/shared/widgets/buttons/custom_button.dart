import 'package:flutter/material.dart';
import '../shared_widgets.dart';

/// Botão personalizado com tema neon
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final CustomButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double? height;

  const CustomButton({
    required this.text,
    required this.onPressed,
    this.type = CustomButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: _getButtonStyle(),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(text),
                ],
              ),
      ),
    );
  }

  ButtonStyle _getButtonStyle() {
    switch (type) {
      case CustomButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonBlue,
          foregroundColor: Colors.black,
          elevation: 4,
          shadowColor: AppColors.neonBlue.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: AppColors.neonBlue.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
        );
      case CustomButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.neonBlue,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: AppColors.neonBlue.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
        );
      case CustomButtonType.outlined:
        return OutlinedButton.styleFrom(
          foregroundColor: AppColors.neonBlue,
          side: BorderSide(
            color: AppColors.neonBlue.withValues(alpha: 0.5),
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
    }
  }
}

/// Tipos de botão personalizado
enum CustomButtonType {
  primary,
  secondary,
  outlined,
}
