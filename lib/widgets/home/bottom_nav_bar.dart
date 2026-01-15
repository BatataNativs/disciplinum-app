import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // Import necessário para o AuthService
import 'package:disciplinum/app_router.dart';
import 'package:disciplinum/services/auth/auth_service.dart'; // Import do seu serviço de auth

class DisciplinumBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const DisciplinumBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  void _onItemTap(BuildContext context, int index) {
    HapticFeedback.lightImpact();
    final currentRoute = ModalRoute.of(context)?.settings.name;

    // Lógica padronizada:
    // 0 = Home
    // 1 = Profile (com verificação de Auth)
    // 2 = Settings

    if (index == 0 && currentRoute != AppRouter.home) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.home,
        (route) => route.isFirst,
      );
    } else if (index == 1) {
      // --- ALTERAÇÃO AQUI: Verificação de Login ---

      // Se já estamos na tela de perfil, não faz nada
      if (currentRoute == AppRouter.profile) return;

      final authService = Provider.of<AuthService>(context, listen: false);

      if (authService.isAuthenticated) {
        // Usuário logado -> Vai para o Perfil
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.profile,
          (route) => route.isFirst,
        );
      } else {
        // Usuário NÃO logado -> Vai para Login/Criar Conta
        Navigator.pushNamed(
          context,
          AppRouter.auth, // Redireciona para a nova tela unificada
        );
      }
    } else if (index == 2 && currentRoute != AppRouter.settings) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.settings,
        (route) => route.isFirst,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? Colors.white : const Color(0xFF171717);
    final activeIconColor = isDark ? Colors.black : Colors.white;
    final inactiveIconColor = isDark
        ? Colors.black.withValues(alpha: 0.4)
        : Colors.white.withValues(alpha: 0.4);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 64, right: 64),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildIconItem(
              context,
              index: 0,
              icon: Icons.home_rounded,
              isActive: currentIndex == 0,
              activeColor: activeIconColor,
              inactiveColor: inactiveIconColor,
            ),
            _buildIconItem(
              context,
              index: 1,
              icon: Icons.person_rounded,
              isActive: currentIndex == 1,
              activeColor: activeIconColor,
              inactiveColor: inactiveIconColor,
            ),
            _buildIconItem(
              context,
              index: 2,
              icon: Icons.settings_rounded,
              isActive: currentIndex == 2,
              activeColor: activeIconColor,
              inactiveColor: inactiveIconColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    return GestureDetector(
      onTap: () => _onItemTap(context, index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48,
        width: 48,
        alignment: Alignment.center,
        decoration: isActive
            ? BoxDecoration(
                color: activeColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              )
            : null,
        child: Icon(
          icon,
          color: isActive ? activeColor : inactiveColor,
          size: 24,
        ),
      ),
    );
  }
}
