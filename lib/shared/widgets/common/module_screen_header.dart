import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Header reutilizável para telas de módulos
class ModuleScreenHeader extends ConsumerWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? trailing;
  final String? heroTag;

  const ModuleScreenHeader({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.trailing,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : Colors.black87,
              ),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          else
            const SizedBox(width: 48),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (trailing != null)
            trailing!
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}
