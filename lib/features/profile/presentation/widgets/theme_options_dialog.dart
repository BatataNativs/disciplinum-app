import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/core/theme/app_theme.dart';
import 'package:disciplinum/features/profile/presentation/widgets/dark_mode_purchase_dialog.dart';
import 'package:disciplinum/features/profile/presentation/widgets/pink_theme_purchase_dialog.dart';
import 'package:disciplinum/features/profile/presentation/widgets/halloween_theme_purchase_dialog.dart';

/// Dialog de seleção de temas usando sistema de múltiplos temas
/// 
/// Usa Theme.of(context) para acessar cores do tema atual
/// Não usa verificação de modo escuro - usa AppTheme enum para controle
class ThemeOptionsDialog extends ConsumerWidget {
  const ThemeOptionsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeController = ref.read(themeControllerProvider.notifier);
    final currentTheme = ref.watch(themeControllerProvider);
    final iap = ref.read(iapServiceProvider.notifier);
    
    // Usar Theme.of(context) para acessar cores do tema
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Helper que delega ao IAP para verificar se tema está desbloqueado
    bool isThemeUnlocked(AppTheme theme) => iap.isThemeUnlocked(theme);

    return Dialog(
      backgroundColor: Colors.transparent,
      alignment: const Alignment(0, -0.2),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: colorScheme.surface, // Usa cor do tema
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título
              Row(
                children: [
                  Icon(Icons.palette_rounded, color: colorScheme.onSurface),
                  const SizedBox(width: 12),
                  Text(
                    'Temas',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Opção Claro (Gratuito)
              _buildThemeOption(
                context: context,
                title: AppTheme.light.displayName,
                isSelected: currentTheme == AppTheme.light,
                onTap: () async {
                  final navigator = Navigator.of(context);
                  if (currentTheme != AppTheme.light) {
                    await themeController.setTheme(AppTheme.light);
                  }
                  navigator.pop();
                },
              ),
              const SizedBox(height: 12),

              // Opção Escuro (IAP)
              _buildThemeOption(
                context: context,
                title: AppTheme.dark.displayName,
                isSelected: currentTheme == AppTheme.dark,
                onTap: () async {
                  final navigator = Navigator.of(context);
                  if (currentTheme != AppTheme.dark) {
                    if (isThemeUnlocked(AppTheme.dark)) {
                      await themeController.setTheme(AppTheme.dark);
                      navigator.pop();
                    } else {
                      navigator.pop();
                      _showDarkModePurchaseDialog(context);
                    }
                  } else {
                    navigator.pop();
                  }
                },
                showLock: !isThemeUnlocked(AppTheme.dark),
              ),
              const SizedBox(height: 12),

              // Opção Rosa (IAP)
              _buildThemeOption(
                context: context,
                title: AppTheme.pink.displayName,
                isSelected: currentTheme == AppTheme.pink,
                onTap: () async {
                  final navigator = Navigator.of(context);
                  if (currentTheme != AppTheme.pink) {
                    if (isThemeUnlocked(AppTheme.pink)) {
                      await themeController.setTheme(AppTheme.pink);
                      navigator.pop();
                    } else {
                      navigator.pop();
                      _showPinkThemePurchaseDialog(context);
                    }
                  } else {
                    navigator.pop();
                  }
                },
                showLock: !isThemeUnlocked(AppTheme.pink),
              ),
              const SizedBox(height: 12),

              // Opção Halloween (IAP)
              _buildThemeOption(
                context: context,
                title: AppTheme.halloween.displayName,
                isSelected: currentTheme == AppTheme.halloween,
                onTap: () async {
                  final navigator = Navigator.of(context);
                  if (currentTheme != AppTheme.halloween) {
                    if (isThemeUnlocked(AppTheme.halloween)) {
                      await themeController.setTheme(AppTheme.halloween);
                      navigator.pop();
                    } else {
                      navigator.pop();
                      _showHalloweenThemePurchaseDialog(context);
                    }
                  } else {
                    navigator.pop();
                  }
                },
                showLock: !isThemeUnlocked(AppTheme.halloween),
              ),

              const SizedBox(height: 24),

              // Botão Fechar
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Fechar',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    bool isComingSoon = false,
    bool showLock = false,
  }) {
    // Usar tema do contexto
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isComingSoon ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Radio button imitado
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outline,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.primary,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isComingSoon
                            ? colorScheme.onSurface.withValues(alpha: 0.5)
                            : colorScheme.onSurface,
                        fontStyle:
                            isComingSoon ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                    if (isComingSoon) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '(Disponível em breve)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                            fontStyle: FontStyle.italic,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (showLock && !isComingSoon)
                Icon(
                  Icons.lock_outline_rounded,
                  size: 18,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDarkModePurchaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const DarkModePurchaseDialog(),
    );
  }

  void _showPinkThemePurchaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const PinkThemePurchaseDialog(),
    );
  }

  void _showHalloweenThemePurchaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const HalloweenThemePurchaseDialog(),
    );
  }
}
