import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/features/profile/presentation/widgets/dark_mode_purchase_dialog.dart';

class ThemeOptionsDialog extends ConsumerWidget {
  const ThemeOptionsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeController = ref.read(themeControllerProvider.notifier);
    final iap = ref.watch(iapServiceProvider);
    final isDark = themeController.isDarkMode;

    return Dialog(
      backgroundColor: Colors.transparent,
      alignment: const Alignment(0, -0.2),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color.fromARGB(255, 30, 30, 40),
                    const Color.fromARGB(255, 15, 15, 20),
                  ]
                : [
                    Colors.white,
                    const Color.fromARGB(255, 230, 235, 240),
                  ],
          ),
          border: Border.all(
            color: isDark
                ? const Color.fromARGB(164, 255, 255, 255)
                : Colors.black12,
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
                  Icon(Icons.palette_rounded,
                      color: isDark ? Colors.white : Colors.black87),
                  const SizedBox(width: 12),
                  Text(
                    'Temas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Opção Claro
              _buildThemeOption(
                title: 'Tema Claro',
                isSelected: !isDark,
                onTap: () {
                  if (isDark) {
                    themeController.toggleTheme();
                  }
                  Navigator.pop(context);
                },
                isDark: isDark,
              ),
              const SizedBox(height: 12),

              // Opção Escuro
              _buildThemeOption(
                title: 'Tema Escuro',
                isSelected: isDark,
                onTap: () {
                  if (!isDark) {
                    if (iap.isDarkModeUnlocked) {
                      themeController.toggleTheme();
                    } else {
                      Navigator.pop(context);
                      _showDarkModePurchaseDialog(context);
                    }
                  } else {
                    Navigator.pop(context);
                  }
                },
                isDark: isDark,
                showLock: !iap.isDarkModeUnlocked,
              ),
              const SizedBox(height: 12),

              // Opção Rosa
              _buildThemeOption(
                title: 'Tema Rosa',
                isSelected: false,
                isComingSoon: true,
                onTap: () {},
                isDark: isDark,
              ),
              const SizedBox(height: 12),

              // Opção Halloween
              _buildThemeOption(
                title: 'Tema Halloween',
                isSelected: false,
                isComingSoon: true,
                onTap: () {},
                isDark: isDark,
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black54,
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
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    bool isComingSoon = false,
    bool showLock = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isComingSoon ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? Colors.white24 : Colors.black12)
                : (isDark
                    ? Colors.white10
                    : Colors.black.withValues(alpha: 0.05)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? (isDark ? Colors.white54 : Colors.black38)
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
                        ? (isDark ? Colors.white : Colors.black87)
                        : (isDark ? Colors.white38 : Colors.black38),
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
                            color: isDark ? Colors.white : Colors.black87,
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isComingSoon
                            ? (isDark ? Colors.white38 : Colors.black38)
                            : (isDark ? Colors.white : Colors.black87),
                        fontStyle:
                            isComingSoon ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                    if (isComingSoon) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '(Disponível em breve)',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white38 : Colors.black38,
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
                Icon(Icons.lock_outline_rounded,
                    size: 18, color: isDark ? Colors.white54 : Colors.black54),
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
}
