import 'dart:ui'; // Necessário para o ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/app/router/app_router.dart';
import 'package:disciplinum/core/di/providers.dart';

class DisciplinumBottomNavBar extends ConsumerWidget {
  final int currentIndex;
  final Color? glassColor;
  final Color? borderColor;
  final Color? activeIconColor;
  final Color? inactiveIconColor;
  final Color? activeIndicatorColor;
  final Color? shadowColor;

  const DisciplinumBottomNavBar({
    super.key,
    required this.currentIndex,
    this.glassColor,
    this.borderColor,
    this.activeIconColor,
    this.inactiveIconColor,
    this.activeIndicatorColor,
    this.shadowColor,
  });

  void _onItemTap(BuildContext context, WidgetRef ref, int index) {
    HapticFeedback.lightImpact();
    final currentRoute = ModalRoute.of(context)?.settings.name;

    if (index == 0 && currentRoute != AppRouter.home) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.home,
        (route) => route.isFirst,
      );
    } else if (index == 1) {
      if (currentRoute == AppRouter.profile) return;
      final authService = ref.read(authServiceProvider);
      if (authService.isAuthenticated) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.profile,
          (route) => route.isFirst,
        );
      } else {
        Navigator.pushNamed(context, AppRouter.auth);
      }
    } else if (index == 2) {
      // --- Rota da Lojinha ---
      if (currentRoute != AppRouter.shop) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRouter.shop, (route) => route.isFirst);
      }
    } else if (index == 3 && currentRoute != AppRouter.settings) {
      // Configurações agora é índice 3
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.settings,
        (route) => route.isFirst,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    // Cores ajustadas para Glassmorphism (com fallback para parâmetros)
    final effectiveGlassColor = glassColor ??
        colorScheme.surfaceContainerHighest.withValues(alpha: 0.85);
    final effectiveBorderColor =
        borderColor ?? colorScheme.outline.withValues(alpha: 0.5);
    final effectiveActiveIconColor = activeIconColor ?? colorScheme.onSurface;
    final effectiveInactiveIconColor =
        inactiveIconColor ?? colorScheme.onSurface.withValues(alpha: 0.5);
    final effectiveActiveIndicatorColor = activeIndicatorColor ??
        colorScheme.surfaceContainerHighest.withValues(alpha: 0.9);
    final effectiveShadowColor =
        shadowColor ?? Colors.black.withValues(alpha: 0.7);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: effectiveGlassColor,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: effectiveBorderColor,
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: effectiveShadowColor,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // --- Ícone de início ---
                _buildIconItem(
                  context,
                  ref,
                  index: 0,
                  icon: Icons.home_rounded,
                  isActive: currentIndex == 0,
                  activeIndicatorColor: effectiveActiveIndicatorColor,
                  activeIconColor: effectiveActiveIconColor,
                  inactiveIconColor: effectiveInactiveIconColor,
                ),
                // --- Ícone de perfil ---
                _buildIconItem(
                  context,
                  ref,
                  index: 1,
                  icon: Icons.person_rounded,
                  isActive: currentIndex == 1,
                  activeIndicatorColor: effectiveActiveIndicatorColor,
                  activeIconColor: effectiveActiveIconColor,
                  inactiveIconColor: effectiveInactiveIconColor,
                ),
                // --- Ícone de loja ---
                _buildIconItem(
                  context,
                  ref,
                  index: 2,
                  assetPath: 'assets/icons/icone_carrinho_compra.png',
                  isActive: currentIndex == 2,
                  activeIndicatorColor: effectiveActiveIndicatorColor,
                  activeIconColor: effectiveActiveIconColor,
                  inactiveIconColor: effectiveInactiveIconColor,
                ),
                // --- Ícone de configurações ---
                _buildIconItem(
                  context,
                  ref,
                  index: 3,
                  icon: Icons.settings_rounded,
                  isActive: currentIndex == 3,
                  activeIndicatorColor: effectiveActiveIndicatorColor,
                  activeIconColor: effectiveActiveIconColor,
                  inactiveIconColor: effectiveInactiveIconColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconItem(
    BuildContext context,
    WidgetRef ref, {
    required int index,
    IconData? icon,
    String? assetPath,
    required bool isActive,
    required Color activeIndicatorColor,
    required Color activeIconColor,
    required Color inactiveIconColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTap(context, ref, index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: double.infinity,
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOutQuart,
            height: 48,
            width: isActive ? 64 : 48,
            decoration: BoxDecoration(
              color: isActive ? activeIndicatorColor : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              // Verifica se tem assetPath, senão usa o Icon
              child: assetPath != null
                  ? Image.asset(
                      assetPath,
                      width: 24, // Tamanho similar ao do Icon padrão
                      height: 24,
                      // PNG obedece ao tema (branco/preto)
                      // Se o PNG for colorido e quiser manter as cores originais, remova esta linha:
                      color: isActive ? activeIconColor : inactiveIconColor,
                      fit: BoxFit.contain,
                    )
                  : Icon(
                      icon,
                      color: isActive ? activeIconColor : inactiveIconColor,
                      size: 26,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
