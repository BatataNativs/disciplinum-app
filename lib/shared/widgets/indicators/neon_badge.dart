import 'package:flutter/material.dart';
import '../shared_widgets.dart';

/// Badge com tema neon
class NeonBadge extends StatelessWidget {
  final String text;
  final Color color;
  final NeonBadgeType type;
  final IconData? icon;
  final double? size;

  const NeonBadge({
    required this.text,
    this.color = AppColors.neonBlue,
    this.type = NeonBadgeType.standard,
    this.icon,
    this.size,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _getPadding(),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: _getBoxShadow(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon!,
              color: color,
              size: size ?? 16,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: size ?? 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  EdgeInsets _getPadding() {
    switch (type) {
      case NeonBadgeType.standard:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case NeonBadgeType.small:
        return const EdgeInsets.symmetric(horizontal: 6, vertical: 2);
      case NeonBadgeType.large:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    }
  }

  List<BoxShadow> _getBoxShadow() {
    switch (type) {
      case NeonBadgeType.standard:
        return [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ];
      case NeonBadgeType.small:
        return [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 2,
            spreadRadius: 0.5,
          ),
        ];
      case NeonBadgeType.large:
        return [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ];
    }
  }
}

/// Tipos de badge neon
enum NeonBadgeType {
  standard,
  small,
  large,
}

/// Badge circular com tema neon
class NeonCircularBadge extends StatelessWidget {
  final String text;
  final Color color;
  final double diameter;
  final bool showGlow;

  const NeonCircularBadge({
    required this.text,
    this.color = AppColors.neonBlue,
    this.diameter = 24,
    this.showGlow = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: diameter * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Badge de status com tema neon
class NeonStatusBadge extends StatelessWidget {
  final String text;
  final NeonStatus status;
  final IconData? icon;

  const NeonStatusBadge({
    required this.text,
    required this.status,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 2,
                  spreadRadius: 0.5,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          if (icon != null) ...[
            Icon(
              icon!,
              color: color,
              size: 14,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case NeonStatus.active:
        return AppColors.neonGreen;
      case NeonStatus.inactive:
        return AppColors.neonPink;
      case NeonStatus.pending:
        return AppColors.neonYellow;
      case NeonStatus.warning:
        return AppColors.neonOrange;
      case NeonStatus.error:
        return AppColors.neonPink;
      case NeonStatus.success:
        return AppColors.neonGreen;
      case NeonStatus.info:
        return AppColors.neonBlue;
    }
  }
}

/// Status do badge neon
enum NeonStatus {
  active,
  inactive,
  pending,
  warning,
  error,
  success,
  info,
}
