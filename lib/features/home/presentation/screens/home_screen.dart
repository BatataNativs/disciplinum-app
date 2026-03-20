import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:confetti/confetti.dart';
import 'package:disciplinum/infrastructure/permissions/usage_stats/permission_service.dart';
import 'package:disciplinum/app/router/app_router.dart';

import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';

import 'package:disciplinum/shared/components/navigation/bottom_nav_bar.dart';
import 'package:disciplinum/infrastructure/monitoring/installed_app_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  bool _permissionsChecked = false;
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      InstalledAppService().preload();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      PermissionService.verifyPermissionAfterReturn(context);
      _checkPendingMedals();
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

        // Verifica medalhas pendentes assim que a tela monta
        _checkPendingMedals();

        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;

        await PermissionService.ensurePermissions(context);

        if (mounted) {
          bool isAccessibilityGranted =
              await PermissionService.hasAccessibilityPermission();
          if (isAccessibilityGranted && mounted) {
            final gamification = ref.read(gamificationServiceProvider);
            await gamification.restoreMonitoringSession();
          }
        }
      }
    });
  }

  void _checkPendingMedals() {
    final gamification = ref.read(gamificationServiceProvider);
    final pending = gamification.pendingMedals;

    if (pending.isNotEmpty) {
      // Pega a primeira e mostra
      final medalData = pending.first;
      _showMedalDialog(medalData);
    }
  }

  void _showMedalDialog(Map<String, dynamic> medalData) {
    showDialog(
      context: context,
      barrierDismissible: false, // Força clicar no OK
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Nova Conquista! 🎉',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Image.asset(
                medalData['medal_asset'], // Ex: assets/medal_gold.png
                height: 100,
              ),
              const SizedBox(height: 16),
              Text(
                'Você ganhou a medalha de ${medalData['medal_name']}!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Continue assim para alcançar novos objetivos.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // Consome e tenta mostrar próxima se houver
                    ref.read(gamificationServiceProvider).consumePendingMedal(medalData);
                    Navigator.of(ctx).pop();

                    // Pequeno delay para animação de fechar e abrir a próxima
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (mounted) _checkPendingMedals();
                    });
                  },
                  child: const Text('Incrível!',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleNicheTap(Niche niche, String heroTag) async {
    HapticFeedback.lightImpact();

    bool isAccessibilityGranted =
        await PermissionService.hasAccessibilityPermission();

    if (!isAccessibilityGranted && mounted) {
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
    return GestureDetector(
      onTap: () => _handleNicheTap(niche, heroTag),
      child: Material(
        color: Colors.transparent,
        elevation: 20,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
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
                      const Color.fromARGB(255, 230, 235, 255),
                    ],
            ),
            border: Border.all(
              color: isDark
                  ? const Color.fromARGB(164, 255, 255, 255)
                  : Colors.black,
              width: 1,
            ),
          ),
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
                      child: niche.isEmojiIcon
                          ? Text(
                              niche.iconPath,
                              style: const TextStyle(fontSize: 48),
                            )
                          : Image.asset(
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
                  color: isDark ? Colors.white : Colors.black87,
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = NicheRepository.getAllNiches();
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
                      if (isDark)
                        Text(
                          'Disciplinum',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                            letterSpacing: 1.3,
                            color: Colors.white,
                          ),
                        )
                      else
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
                                  ..color = Colors.black,
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
                  child: Builder(
                    builder: (context) {
                      final allCategories =
                          List<Niche>.from(categories);

                      return ListView.separated(
                        padding: const EdgeInsets.only(
                            top: 10, bottom: 100, left: 16, right: 16),
                        itemCount: allCategories.length + 1,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 32),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Consumer(
                              builder: (context, ref, child) {
                                final activeModules = ref.watch(gamificationServiceProvider.select((s) => s.diasConsecutivosByModule.keys.toList()));
                                return _buildActiveModulesSection(
                                  activeModules, isDark, textTheme);
                              },
                            );
                          }

                          final category = allCategories[index - 1];
                          return _buildCategorySection(category, isDark, textTheme);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const DisciplinumBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildCategorySection(
      Niche category, bool isDark, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.name,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              SizedBox(
                width: 150,
                child: _buildNicheCard(
                  NicheRepository.getById(category.nicheId), 
                  isDark, 
                  textTheme, 
                  '${category.nicheId}_${category.id}'
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveModulesSection(
      List<NicheId> activeNiches, bool isDark, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(width: 8),
            Text(
              '✅ Módulos Ativos',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 210,
          child: activeNiches.isEmpty
              ? _buildEmptyStateCard(isDark, textTheme)
              : ListView.separated(
                  clipBehavior: Clip.none,
                  scrollDirection: Axis.horizontal,
                  itemCount: activeNiches.length,
                  separatorBuilder: (context, i) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final nicheId = activeNiches[i];
                    final niche = NicheRepository.getById(nicheId);
                    final heroTag = 'active_${niche.id}';

                    return SizedBox(
                      width: 150,
                      child: _buildNicheCard(niche, isDark, textTheme, heroTag),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyStateCard(bool isDark, TextTheme textTheme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 150,
        height: 195,
        child: Material(
          color: Colors.transparent,
          elevation: 20,
          shadowColor: Colors.black.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
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
                        const Color.fromARGB(255, 230, 235, 255),
                      ],
              ),
              border: Border.all(
                color: isDark
                    ? const Color.fromARGB(164, 255, 255, 255)
                    : Colors.black,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: SizedBox.expand(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '🚫',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sem módulos ativos',
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? const Color.fromARGB(85, 255, 255, 255)
                          : Colors.black45,
                      fontSize: 12,
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
