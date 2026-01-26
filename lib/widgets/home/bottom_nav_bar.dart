import 'dart:ui'; // Necessário para o ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/app_router.dart';
import 'package:disciplinum/services/auth/auth_service.dart';

class DisciplinumBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const DisciplinumBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  void _onItemTap(BuildContext context, int index) {
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
      final authService = Provider.of<AuthService>(context, listen: false);
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
      // --- NOVO: Rota da Lojinha ---
      // Verifique se a rota 'AppRouter.shop' existe ou use o nome string direto por enquanto
      // Exemplo: Navigator.pushNamed(context, '/lojinha');
      if (currentRoute != '/lojinha') {
        // Ajuste para a constante do seu AppRouter se tiver
        // Como ainda vamos criar a tela, estou assumindo que você criará a rota '/lojinha' ou similar
        // Se quiser navegar direto sem rota nomeada enquanto não cria:
        // Navigator.push(context, MaterialPageRoute(builder: (_) => const LojinhaScreen()));

        // Mas seguindo seu padrão de rotas nomeadas:
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Cores ajustadas para Glassmorphism
    final glassColor = isDark
        ? const Color(0xFF171717).withValues(alpha: 0.85)
        : const Color.fromARGB(255, 222, 222, 222).withValues(alpha: 0.85);

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.7)
        : Colors.black.withValues(alpha: 0.7);

    final activeIconColor = isDark
        ? const Color.fromARGB(255, 0, 0, 0)
        : const Color.fromARGB(255, 255, 255, 255);
    final inactiveIconColor = isDark ? Colors.white54 : Colors.black45;

    final activeIndicatorColor = isDark
        ? Colors.white.withValues(alpha: 0.9)
        : const Color.fromARGB(255, 36, 36, 36).withValues(alpha: 0.9);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: glassColor,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: borderColor,
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.7),
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
                  activeIndicatorColor: activeIndicatorColor,
                  activeIconColor: activeIconColor,
                  inactiveIconColor: inactiveIconColor,
                ),
                _buildIconItem(
                  context,
                  index: 1,
                  icon: Icons.person_rounded,
                  isActive: currentIndex == 1,
                  activeIndicatorColor: activeIndicatorColor,
                  activeIconColor: activeIconColor,
                  inactiveIconColor: inactiveIconColor,
                ),
                // --- NOVO ÍCONE: LOJINHA ---
                _buildIconItem(
                  context,
                  index: 2,
                  icon: Icons.shopping_bag_rounded, // ou local_mall_rounded
                  isActive: currentIndex == 2,
                  activeIndicatorColor: activeIndicatorColor,
                  activeIconColor: activeIconColor,
                  inactiveIconColor: inactiveIconColor,
                ),
                // --- FIM NOVO ÍCONE ---
                _buildIconItem(
                  context,
                  index: 3, // Configurações agora é 3
                  icon: Icons.settings_rounded,
                  isActive: currentIndex == 3,
                  activeIndicatorColor: activeIndicatorColor,
                  activeIconColor: activeIconColor,
                  inactiveIconColor: inactiveIconColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required bool isActive,
    required Color activeIndicatorColor,
    required Color activeIconColor,
    required Color inactiveIconColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTap(context, index),
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
            child: Icon(
              icon,
              color: isActive ? activeIconColor : inactiveIconColor,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
