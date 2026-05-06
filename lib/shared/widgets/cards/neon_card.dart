import 'package:flutter/material.dart';
import 'dart:ui';

class NeonCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double borderRadius;

  final double contentOpacity;
  final Color? primaryColor;
  final Color? secondaryColor;
  final Color? accentColor;
  final Color? backgroundColor;

  const NeonCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.onTap,
    this.borderRadius = 20,
    this.contentOpacity = 1.0,
    this.primaryColor,
    this.secondaryColor,
    this.accentColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Cores premium
    final effectivePrimaryColor =
        primaryColor ?? const Color(0xFF6366F1);
    final effectiveSecondaryColor =
        secondaryColor ?? const Color(0xFF8B5CF6);
    final effectiveAccentColor =
        accentColor ?? const Color(0xFFA855F7);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                  width: 1.5,
                ),
              ),
              child: Stack(
                children: [
                  // Base Layer - Gradient sutil de fundo
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          effectivePrimaryColor.withValues(
                              alpha: 0.075 * contentOpacity),
                          effectiveSecondaryColor.withValues(
                              alpha: 0.035 * contentOpacity),
                          effectiveAccentColor.withValues(
                              alpha: 0.06 * contentOpacity),
                        ],
                      ),
                    ),
                  ),

                  // Borda "Glowing" Ultra-fina
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius),
                      border: Border.all(
                        width: 1.0,
                        color: effectivePrimaryColor.withValues(
                            alpha: 0.175 * contentOpacity),
                      ),
                    ),
                    child: Padding(
                      padding: padding,
                      child: Opacity(
                        opacity: contentOpacity,
                        child: child,
                      ),
                    ),
                  ),

                  // Highlight superior (shimmer effect sutil)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(
                                alpha: 0.4 * contentOpacity),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
