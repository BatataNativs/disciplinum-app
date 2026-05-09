import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/theme/app_theme.dart';
import 'package:disciplinum/app/router/app_router.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/models/common/niche_category.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/shared/repositories/niche_category_repository.dart';
import 'package:disciplinum/infrastructure/permissions/usage_stats/permission_service.dart';

import 'package:disciplinum/shared/components/navigation/bottom_nav_bar.dart';
import 'package:disciplinum/infrastructure/monitoring/installed_app_service.dart';

class HomeScreenGuest extends ConsumerStatefulWidget {
  const HomeScreenGuest({super.key});

  @override
  ConsumerState<HomeScreenGuest> createState() => _HomeScreenGuestState();
}

class _HomeScreenGuestState extends ConsumerState<HomeScreenGuest>
    with WidgetsBindingObserver {
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
      }
    });
  }

  Future<void> _handleNicheTap(Niche niche, String heroTag) async {
    HapticFeedback.lightImpact();

    if (!mounted) return;

    Navigator.pushNamed(
      context,
      AppRouter.nicheDetail,
      arguments: {'niche': niche, 'heroTag': heroTag},
    );
  }

  /// Cores modernas por categoria de nicho
  Color _getNicheColor(int nicheId) {
    switch (nicheId) {
      // Saúde & Bem-estar - Verde esmeralda
      case 1: // smoking
      case 2: // bingeEating
      case 3: // diet
        return const Color(0xFF10B981);
      // Produtividade - Azul royal
      case 8: // procrastination
      case 5: // focus
        return const Color(0xFF3B82F6);
      // Finanças - Âmbar/Dourado
      case 4: // spending
      case 7: // moneySavingChallenge
        return const Color(0xFFF59E0B);
      // Conteúdo Adulto - Roxo vibrante
      case 6: // adultContent
        return const Color(0xFF8B5CF6);
      // Leitura - Coral/Laranja suave
      case 9: // reading
        return const Color(0xFFF97316);
      default:
        return const Color(0xFF6366F1);
    }
  }

  // Glow suave para cards ativos - mais elegante e menos intenso
  static const Color _activeGlowColor = Color(0xFF22C55E); // Verde mais suave
  static const double _activeBlurRadius = 8.0;
  static const double _activeSpreadRadius = 1.0;

  Widget _buildNicheCard(
      Niche niche, ColorScheme colorScheme, TextTheme textTheme, String heroTag,
      {bool isActive = false}) {
    final theme = Theme.of(context);
    final accentColor = _getNicheColor(niche.id);
    
    return SizedBox(
      height: 195,
      child: GestureDetector(
        onTap: () => _handleNicheTap(niche, heroTag),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isActive
                  ? [
                      theme.brightness == Brightness.dark
                          ? colorScheme.surface.withValues(alpha: 0.95)
                          : colorScheme.surface,
                      theme.brightness == Brightness.dark
                          ? _activeGlowColor.withValues(alpha: 0.2)
                          : _activeGlowColor.withValues(alpha: 0.06),
                    ]
                  : [
                      theme.brightness == Brightness.dark
                          ? colorScheme.surface.withValues(alpha: 0.9)
                          : colorScheme.surface,
                      theme.brightness == Brightness.dark
                          ? Colors.black.withValues(alpha: 0.3)
                          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    ],
            ),
            border: Border.all(
              color: isActive
                  ? _activeGlowColor.withValues(alpha: theme.brightness == Brightness.dark ? 0.8 : 0.5)
                  : accentColor.withValues(alpha: theme.brightness == Brightness.dark ? 0.6 : 0.25),
              width: isActive ? (theme.brightness == Brightness.dark ? 2.5 : 1.5) : (theme.brightness == Brightness.dark ? 2 : 1.5),
            ),
            boxShadow: isActive
                ? [
                    // Glow mais intenso no tema escuro
                    BoxShadow(
                      color: _activeGlowColor.withValues(alpha: theme.brightness == Brightness.dark ? 0.5 : 0.25),
                      blurRadius: theme.brightness == Brightness.dark ? 16 : _activeBlurRadius,
                      spreadRadius: theme.brightness == Brightness.dark ? 3 : _activeSpreadRadius,
                    ),
                    BoxShadow(
                      color: theme.brightness == Brightness.dark
                          ? Colors.black.withValues(alpha: 0.5)
                          : Colors.black.withValues(alpha: 0.08),
                      blurRadius: theme.brightness == Brightness.dark ? 14 : 6,
                      spreadRadius: theme.brightness == Brightness.dark ? 2 : 0,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [
                    // Sombra intensa no tema escuro
                    BoxShadow(
                      color: accentColor.withValues(alpha: theme.brightness == Brightness.dark ? 0.35 : 0.15),
                      blurRadius: theme.brightness == Brightness.dark ? 20 : 12,
                      spreadRadius: theme.brightness == Brightness.dark ? 2 : 0,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: theme.brightness == Brightness.dark
                          ? Colors.black.withValues(alpha: 0.6)
                          : Colors.black.withValues(alpha: 0.08),
                      blurRadius: theme.brightness == Brightness.dark ? 16 : 8,
                      spreadRadius: theme.brightness == Brightness.dark ? 2 : -2,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Container com altura fixa para garantir que todos os ícones fiquem alinhados
              SizedBox(
                height: 100,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? _activeGlowColor.withValues(alpha: theme.brightness == Brightness.dark ? 0.25 : 0.12)
                          : accentColor.withValues(alpha: theme.brightness == Brightness.dark ? 0.2 : 0.12),
                      border: isActive
                          ? Border.all(
                              color: _activeGlowColor.withValues(alpha: theme.brightness == Brightness.dark ? 0.5 : 0.35),
                              width: theme.brightness == Brightness.dark ? 1.5 : 1,
                            )
                          : (theme.brightness == Brightness.dark
                              ? Border.all(
                                  color: accentColor.withValues(alpha: 0.4),
                                  width: 1.5,
                                )
                              : null),
                    ),
                    child: Transform.scale(
                      scale: niche.scale,
                      child: Hero(
                        tag: heroTag,
                        child: niche.isEmojiIcon
                            ? Text(
                                niche.iconPath,
                                style: const TextStyle(fontSize: 42),
                              )
                            : Image.asset(
                                niche.iconPath,
                                height: 48,
                                fit: BoxFit.contain,
                              ),
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
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: colorScheme.onSurface,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    niche.homePhrase,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: isActive ? 0.6 : 0.55),
                      fontSize: 10,
                      height: 1.2,
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final categories = NicheCategoryRepository.getCategories();
    final allCategories = List<NicheCategory>.from(categories);
    final currentTheme = ref.watch(themeControllerProvider);
    final isPinkTheme = currentTheme == AppTheme.pink;

    return Scaffold(
      extendBody: true,
      body: Container(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.black : colorScheme.surface,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // --- FLORES DECORATIVAS NO PLANO DE FUNDO (tema rosa) ---
            if (isPinkTheme) ...[
              // == FLORES GRANDES (60-80) ==
              Positioned(
                top: 80,
                right: -10,
                child: Transform.rotate(
                  angle: 0.6,
                  child: Icon(
                    Icons.local_florist,
                    size: 72,
                    color: colorScheme.primary.withValues(alpha: 0.14),
                  ),
                ),
              ),
              Positioned(
                top: 280,
                left: -25,
                child: Transform.rotate(
                  angle: -0.4,
                  child: Icon(
                    Icons.filter_vintage,
                    size: 68,
                    color: colorScheme.secondary.withValues(alpha: 0.12),
                  ),
                ),
              ),
              Positioned(
                bottom: 120,
                right: -15,
                child: Transform.rotate(
                  angle: 0.3,
                  child: Icon(
                    Icons.spa,
                    size: 76,
                    color: colorScheme.primary.withValues(alpha: 0.13),
                  ),
                ),
              ),
              // == FLORES MÉDIAS (30-45) ==
              Positioned(
                top: 45,
                left: 60,
                child: Transform.rotate(
                  angle: -0.2,
                  child: Icon(
                    Icons.eco,
                    size: 42,
                    color: colorScheme.secondary.withValues(alpha: 0.18),
                  ),
                ),
              ),
              Positioned(
                top: 200,
                right: 80,
                child: Transform.rotate(
                  angle: 0.7,
                  child: Icon(
                    Icons.local_florist,
                    size: 38,
                    color: colorScheme.primary.withValues(alpha: 0.20),
                  ),
                ),
              ),
              Positioned(
                top: 480,
                left: 45,
                child: Transform.rotate(
                  angle: -0.6,
                  child: Icon(
                    Icons.spa,
                    size: 35,
                    color: colorScheme.secondary.withValues(alpha: 0.16),
                  ),
                ),
              ),
              Positioned(
                bottom: 320,
                right: 65,
                child: Transform.rotate(
                  angle: 0.5,
                  child: Icon(
                    Icons.filter_vintage,
                    size: 40,
                    color: colorScheme.primary.withValues(alpha: 0.15),
                  ),
                ),
              ),
              // == FLORES PEQUENAS (15-25) - Originais ==
              Positioned(
                top: 100,
                left: 30,
                child: Transform.rotate(
                  angle: -0.3,
                  child: Icon(
                    Icons.local_florist,
                    size: 28,
                    color: colorScheme.primary.withValues(alpha: 0.22),
                  ),
                ),
              ),
              Positioned(
                top: 160,
                left: 70,
                child: Transform.rotate(
                  angle: 0.5,
                  child: Icon(
                    Icons.filter_vintage,
                    size: 22,
                    color: colorScheme.secondary.withValues(alpha: 0.18),
                  ),
                ),
              ),
              Positioned(
                top: 120,
                right: 40,
                child: Transform.rotate(
                  angle: 0.4,
                  child: Icon(
                    Icons.spa,
                    size: 26,
                    color: colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
              ),
              Positioned(
                top: 350,
                left: 20,
                child: Transform.rotate(
                  angle: 0.8,
                  child: Icon(
                    Icons.filter_vintage,
                    size: 24,
                    color: colorScheme.primary.withValues(alpha: 0.16),
                  ),
                ),
              ),
              Positioned(
                top: 400,
                right: 30,
                child: Transform.rotate(
                  angle: -0.4,
                  child: Icon(
                    Icons.local_florist,
                    size: 26,
                    color: colorScheme.secondary.withValues(alpha: 0.2),
                  ),
                ),
              ),
              Positioned(
                bottom: 250,
                left: 50,
                child: Transform.rotate(
                  angle: -0.5,
                  child: Icon(
                    Icons.eco,
                    size: 20,
                    color: colorScheme.secondary.withValues(alpha: 0.15),
                  ),
                ),
              ),
              Positioned(
                bottom: 200,
                right: 40,
                child: Transform.rotate(
                  angle: 0.6,
                  child: Icon(
                    Icons.spa,
                    size: 24,
                    color: colorScheme.primary.withValues(alpha: 0.18),
                  ),
                ),
              ),
              // == FLORES PEQUENAS EXTRA ==
              Positioned(
                top: 550,
                left: 100,
                child: Transform.rotate(
                  angle: 0.9,
                  child: Icon(
                    Icons.eco,
                    size: 18,
                    color: colorScheme.primary.withValues(alpha: 0.12),
                  ),
                ),
              ),
              Positioned(
                top: 650,
                right: 60,
                child: Transform.rotate(
                  angle: -0.7,
                  child: Icon(
                    Icons.filter_vintage,
                    size: 22,
                    color: colorScheme.secondary.withValues(alpha: 0.16),
                  ),
                ),
              ),
              Positioned(
                top: 750,
                left: 25,
                child: Transform.rotate(
                  angle: 0.4,
                  child: Icon(
                    Icons.local_florist,
                    size: 16,
                    color: colorScheme.primary.withValues(alpha: 0.14),
                  ),
                ),
              ),
              Positioned(
                bottom: 80,
                left: 90,
                child: Transform.rotate(
                  angle: -0.3,
                  child: Icon(
                    Icons.filter_vintage,
                    size: 20,
                    color: colorScheme.secondary.withValues(alpha: 0.13),
                  ),
                ),
              ),
            ],
            Positioned(
              top: -180,
              right: -180,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6366F1)
                      .withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.08 : 0.04),
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
                      // Versão neon do título quando usuário tem tema especial desbloqueado
                      Consumer(
                        builder: (context, ref, child) {
                          final iapState = ref.watch(iapServiceProvider);
                          final hasSpecialTheme = iapState.isDarkModeUnlocked ||
                              iapState.isPinkThemeUnlocked ||
                              iapState.isHalloweenThemeUnlocked;

                          if (!hasSpecialTheme) {
                            return Text(
                              'Disciplinum',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                                letterSpacing: 1.3,
                                color: colorScheme.onSurface,
                              ),
                            );
                          }

                          // Versão neon com efeito de brilho
                          return _buildNeonTitle(textTheme);
                        },
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Modo convidado',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(
                        top: 10, bottom: 100, left: 16, right: 16),
                    itemCount: allCategories.length + 1,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 32),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Consumer(
                          builder: (context, ref, child) {
                            final activeModulesAsync = ref.watch(activeModulesProvider);
                            final activeModules = activeModulesAsync.valueOrNull ?? [];
                            return _buildActiveModulesSection(
                                activeModules, colorScheme, textTheme);
                          },
                        );
                      }

                      final category = allCategories[index - 1];
                      return _buildCategorySection(
                          category, colorScheme, textTheme);
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
      NicheCategory category, ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        // Usar Wrap para layout de duas colunas como nos módulos ativos
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: category.nicheIds.map((nicheId) {
            final niche = NicheRepository.getById(nicheId);
            final heroTag = 'guest_${category.idPrefix}_${niche.id}';
            
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 44) / 2, // Largura exata para 2 colunas
              child: _buildNicheCard(
                niche,
                colorScheme,
                textTheme,
                heroTag,
                isActive: false,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActiveModulesSection(
      List<NicheId> activeNiches, ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Módulos Ativos',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        if (activeNiches.isEmpty)
          _buildEmptyStateCard(colorScheme, textTheme)
        else
          // Usar Wrap para layout de duas colunas
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: activeNiches.map((nicheId) {
              final niche = NicheRepository.getById(nicheId);
              return SizedBox(
                width: (MediaQuery.of(context).size.width - 44) / 2, // Largura exata para 2 colunas
                child: _buildNicheCard(
                  niche,
                  colorScheme,
                  textTheme,
                  'guest_active_${niche.id}',
                  isActive: true,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildEmptyStateCard(ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 195,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary.withValues(alpha: 0.08),
                    ),
                    child: Icon(
                      Icons.add_circle_outline,
                      size: 36,
                      color: colorScheme.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Ative um módulo',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sem módulos ativos',
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Expanded(child: SizedBox()),
      ],
    );
  }

  /// Constrói o título com efeito neon brilhante
  Widget _buildNeonTitle(TextTheme textTheme) {
    const neonColor = Color(0xFF00FFFF); // Ciano neon
    const neonGlow = Color(0xFF00CCCC); // Brilho mais suave

    return Stack(
      children: [
        // Camada de brilho externo (glow)
        Text(
          'Disciplinum',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: 1.3,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = neonGlow.withValues(alpha: 0.5),
            shadows: [
              Shadow(
                color: neonColor.withValues(alpha: 0.8),
                blurRadius: 20,
                offset: const Offset(0, 0),
              ),
              Shadow(
                color: neonColor.withValues(alpha: 0.6),
                blurRadius: 40,
                offset: const Offset(0, 0),
              ),
              Shadow(
                color: neonGlow.withValues(alpha: 0.4),
                blurRadius: 60,
                offset: const Offset(0, 0),
              ),
            ],
          ),
        ),
        // Camada de contorno neon
        Text(
          'Disciplinum',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: 1.3,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..color = neonColor,
          ),
        ),
        // Texto principal preenchido
        Text(
          'Disciplinum',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: 1.3,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
