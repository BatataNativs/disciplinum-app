import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/app_router.dart';
import 'package:disciplinum/models/niche.dart';
import 'package:disciplinum/widgets/home/neon_card.dart';
import 'package:disciplinum/widgets/home/bottom_nav_bar.dart';
import 'package:disciplinum/misc/system_stuff/theme_controller.dart';
import 'package:disciplinum/services/iap/iap_service.dart';
import 'package:disciplinum/services/permissions/usage_stats/permission_service.dart';

class HomeScreenGuest extends StatefulWidget {
  const HomeScreenGuest({super.key});

  @override
  State<HomeScreenGuest> createState() => _HomeScreenGuestState();
}

class _HomeScreenGuestState extends State<HomeScreenGuest> {
  void _mostrarDialogoLoja() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.credit_card_outlined,
                color: Color.fromARGB(255, 27, 10, 211)),
            SizedBox(width: 8),
            Text('Recurso Pago ⚠️'),
          ],
        ),
        content: const Text(
          'O Dark Mode é um recurso pago (compra única).\n\n'
          'Ao adquirir o Dark Mode, o botão de alternância funcionará. Deseja comprar agora?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Depois'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              final iapService =
                  Provider.of<IapService>(context, listen: false);
              iapService.buyByProductId(IapService.productIdDarkMode);
            },
            child: const Text('Comprar agora!'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNicheTap(Niche niche) async {
    HapticFeedback.lightImpact();

    bool isUsageGranted = await PermissionService.hasUsagePermission();

    if (!isUsageGranted && mounted) {
      await PermissionService.ensurePermissions(context, forceUsage: true);
      return;
    }

    if (!mounted) return;

    Navigator.pushNamed(
      context,
      AppRouter.nicheDetail,
      arguments: niche,
    );
  }

  Widget _buildNicheCard(Niche niche, bool isDark, TextTheme textTheme) {
    return NeonCard(
      onTap: () => _handleNicheTap(niche),
      contentOpacity: 1.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.scale(
            scale: niche.scale,
            child:
                Image.asset(niche.iconPath, height: 100, fit: BoxFit.contain),
          ),
          const SizedBox(height: 8),
          Text(
            niche.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              niche.homePhrase,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: isDark
                    ? Colors.white60
                    : const Color.fromARGB(201, 0, 0, 0),
                fontSize: 9.5,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final niches = NicheRepository.getAll();
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDark ? Colors.black : const Color.fromARGB(255, 255, 255, 255),
              isDark ? Colors.black : const Color.fromARGB(255, 255, 255, 255)
            ],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              top: -180,
              right: -180,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6366F1)
                      .withValues(alpha: isDark ? 0.05 : 0.02),
                ),
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 0),
                SizedBox(height: MediaQuery.of(context).padding.top + 12),
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        height: 60,
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        children: [
                          Text(
                            'Disciplinum',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.3,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 1.2
                                ..color = isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 0, 0, 0),
                                Color.fromARGB(255, 67, 67, 67)
                              ],
                            ).createShader(bounds),
                            blendMode: BlendMode.srcIn,
                            child: Text(
                              'Disciplinum',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.3,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: PageView.builder(
                      scrollDirection: Axis.vertical,
                      padEnds: false,
                      controller: PageController(
                        viewportFraction: 0.28,
                      ),
                      itemCount: (niches.length / 2).ceil(),
                      itemBuilder: (context, rowIndex) {
                        final int firstIndex = rowIndex * 2;
                        final int secondIndex = firstIndex + 1;

                        return Row(
                          children: [
                            Expanded(
                              child: firstIndex < niches.length
                                  ? Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: _buildNicheCard(niches[firstIndex],
                                          isDark, textTheme),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                            Expanded(
                              child: secondIndex < niches.length
                                  ? Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: _buildNicheCard(
                                          niches[secondIndex],
                                          isDark,
                                          textTheme),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              right: 10,
              child: Consumer<ThemeController>(
                builder: (context, theme, _) {
                  return GestureDetector(
                    onTap: () {
                      final iap =
                          Provider.of<IapService>(context, listen: false);
                      if (theme.isDarkMode) {
                        theme.toggleTheme();
                      } else {
                        if (iap.isDarkModeUnlocked) {
                          theme.toggleTheme();
                        } else {
                          _mostrarDialogoLoja();
                        }
                      }
                    },
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: FittedBox(
                        child: Icon(
                          theme.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const DisciplinumBottomNavBar(currentIndex: 0),
    );
  }
}
