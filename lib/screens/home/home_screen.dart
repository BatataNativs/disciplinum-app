import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/services/permissions/usage_stats/permission_service.dart';
import 'package:disciplinum/app_router.dart';

import 'package:disciplinum/models/niche.dart';

import 'package:disciplinum/widgets/home/neon_card.dart';
import 'package:disciplinum/widgets/home/bottom_nav_bar.dart';
import 'package:disciplinum/misc/system_stuff/theme_controller.dart';
import 'package:disciplinum/services/iap/iap_service.dart';
import 'package:disciplinum/misc/system_stuff/installed_app_service.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _permissionsChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      InstalledAppService().preload();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      PermissionService.verifyPermissionAfterReturn(context);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_permissionsChecked) return;
      final route = ModalRoute.of(context);
      if (route != null && route.isCurrent) {
        _permissionsChecked = true;

        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;

        await PermissionService.ensurePermissions(context);

        if (mounted) {
          bool isUsageGranted = await PermissionService.hasUsagePermission();
          if (isUsageGranted && mounted) {
            final gamification =
                Provider.of<GamificationService>(context, listen: false);
            await gamification.restoreMonitoringSession();
          }
        }
      }
    });
  }

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

  Future<void> _handleNicheTap(Niche niche, String heroTag) async {
    HapticFeedback.lightImpact();

    bool isUsageGranted = await PermissionService.hasUsagePermission();

    if (!isUsageGranted && mounted) {
      await PermissionService.ensurePermissions(context, forceUsage: true);
      return;
    }

    if (!mounted) return;

    // Se for stopSmoking, mantemos a lógica (mas agora passando heroTag se quiser,
    // embora o AppRouter para stopSmoking use pushNamed direto sem args no case 'stopSmoking'
    // Mas para consistência, vamos usar a rota detalhada se for possível, ou ajustar.
    // O AppRouter tem um case específico para NicheId.smoking dentro do nicheDetail.
    // Então vamos usar nicheDetail para tudo para aproveitar a heroTag.

    Navigator.pushNamed(
      context,
      AppRouter.nicheDetail,
      arguments: {'niche': niche, 'heroTag': heroTag},
    );
  }

  Widget _buildNicheCard(
      Niche niche, bool isDark, TextTheme textTheme, String heroTag) {
    return NeonCard(
      onTap: () => _handleNicheTap(niche, heroTag),
      contentOpacity: 1.0,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Container com altura fixa para garantir que todos os ícones fiquem alinhados
          // horizontalmente, independente do número de linhas do texto abaixo.
          SizedBox(
            height: 110,
            child: Center(
              child: Transform.scale(
                scale: niche.scale,
                child: Hero(
                  tag: heroTag,
                  child: Image.asset(
                    niche.iconPath,
                    height: 60, // Aumentado tamanho base
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Área de texto com altura flexível mas alinhada
          Text(
            niche.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
              color: isDark ? Colors.white : Colors.black,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                niche.homePhrase,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontSize: 9.5,
                  height: 1.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = NicheCategoryRepository.getCategories();
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
                SizedBox(height: MediaQuery.of(context).padding.top + 12),
                Center(
                  child: Column(
                    children: [
                      RepaintBoundary(
                        child: Image.asset(
                          'assets/logo.png',
                          height: 60,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        children: [
                          Text(
                            'Disciplinum',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
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
                                fontSize: 24,
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
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(
                        top: 10, bottom: 100, left: 16, right: 16),
                    itemCount: categories.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 32),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.title,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height:
                                210, // Aumentado para acomodar ícones maiores
                            child: ListView.separated(
                              clipBehavior: Clip.none,
                              scrollDirection: Axis.horizontal,
                              itemCount: category.nicheIds.length,
                              separatorBuilder: (context, i) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, i) {
                                final nicheId = category.nicheIds[i];
                                final niche = NicheRepository.getById(nicheId);
                                // Gera heroTag única: prefixo_id
                                final heroTag =
                                    '${category.idPrefix}_${niche.id}';

                                return SizedBox(
                                  width: 150,
                                  child: _buildNicheCard(
                                      niche, isDark, textTheme, heroTag),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              right: 10,
              child: Consumer<ThemeController>(
                builder: (context, themeController, child) {
                  final isDark = themeController.isDarkMode;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (isDark) {
                        themeController.toggleTheme();
                      } else {
                        final iapService =
                            Provider.of<IapService>(context, listen: false);
                        if (iapService.isDarkModeUnlocked) {
                          themeController.toggleTheme();
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
                          isDark ? Icons.light_mode : Icons.dark_mode,
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
