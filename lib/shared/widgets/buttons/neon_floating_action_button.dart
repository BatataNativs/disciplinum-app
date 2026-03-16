import 'package:flutter/material.dart';
import '../shared_widgets.dart';

/// FloatingActionButton com efeito neon
class NeonFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color glowColor;
  final String? tooltip;
  final bool isLoading;

  const NeonFloatingActionButton({
    required this.onPressed,
    required this.icon,
    this.glowColor = AppColors.neonBlue,
    this.tooltip,
    this.isLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: glowColor.withValues(alpha: 0.2),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: isLoading ? null : onPressed,
        tooltip: tooltip,
        backgroundColor: Colors.black,
        elevation: 0,
        shape: CircleBorder(
          side: BorderSide(
            color: glowColor.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(glowColor),
                ),
              )
            : Icon(
                icon,
                color: glowColor,
                size: 24,
              ),
      ),
    );
  }
}
