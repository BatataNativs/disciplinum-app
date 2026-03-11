import 'package:flutter/material.dart';

/// Custom page transitions builder with fast durations for 120Hz displays.
/// Uses a quick fade + scale for a snappy, premium feel.
class FastPageTransitionsBuilder extends PageTransitionsBuilder {
  const FastPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Duration is controlled by the route, but we use fast curves
    final fadeIn = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    );

    final scaleIn = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );

    return FadeTransition(
      opacity: fadeIn,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1.0).animate(scaleIn),
        child: child,
      ),
    );
  }
}

/// A MaterialPageRoute with a faster transition duration.
class FastMaterialPageRoute<T> extends MaterialPageRoute<T> {
  FastMaterialPageRoute({
    required super.builder,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
  });

  @override
  Duration get transitionDuration => const Duration(milliseconds: 150);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 120);
}
