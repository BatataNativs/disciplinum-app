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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Cores premium
    final effectivePrimaryColor =
        primaryColor ?? const Color(0xFF6366F1); // Indigo
    final effectiveSecondaryColor =
        secondaryColor ?? const Color(0xFF8B5CF6); // Violet
    final effectiveAccentColor = accentColor ?? const Color(0xFF3B82F6); // Blue

    return GestureDetector(
      onTap: onTap,
      child: RepaintBoundary(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              // Brilho externo sutil (Glow)
              BoxShadow(
                color: effectivePrimaryColor.withValues(
                    alpha: (isDark ? 0.15 : 0.2) * contentOpacity),
                blurRadius: 2,
                spreadRadius: 2,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Stack(
              children: [
                // Efeito de Vidro (Blur)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        // cor dos cards
                        color: (backgroundColor ??
                                (isDark
                                    ? Colors.black
                                    : const Color.fromARGB(190, 232, 232, 235)))
                            .withValues(
                                alpha: (isDark ? 0.35 : 0.65) * contentOpacity),
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                    ),
                  ),
                ),

                // Gradiente de Fundo sutil
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          effectivePrimaryColor.withValues(
                              alpha: (isDark ? 0.1 : 0.05) * contentOpacity),
                          effectiveSecondaryColor.withValues(
                              alpha: (isDark ? 0.05 : 0.02) * contentOpacity),
                          effectiveAccentColor.withValues(
                              alpha: (isDark ? 0.08 : 0.04) * contentOpacity),
                        ],
                      ),
                    ),
                  ),
                ),

                // Borda "Glowing" Ultra-fina
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(
                      width: 1.0,
                      color: (isDark ? Colors.white : effectivePrimaryColor)
                          .withValues(
                              alpha: (isDark ? 0.15 : 0.2) * contentOpacity),
                    ),
                  ),
                  child: Padding(
                    padding: padding,
                    child: Opacity(
                      // Aplica opacidade no conteúdo filho se necessário
                      // (Texto/Icones são leves, Opacity aqui é ok pq é interno e pequeno)
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
                              alpha: (isDark ? 0.3 : 0.5) * contentOpacity),
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
    );
  }
}
