import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/theme/app_theme.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/shared/models/common/niche_category.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/shared/repositories/niche_category_repository.dart';
import 'package:disciplinum/infrastructure/permissions/usage_stats/permission_service.dart';
import 'package:disciplinum/infrastructure/ads/consent_service.dart';
import 'package:disciplinum/infrastructure/ads/widgets/consent_dialog.dart';
import 'package:disciplinum/shared/components/navigation/bottom_nav_bar.dart';
import 'package:disciplinum/infrastructure/monitoring/installed_app_service.dart';

// Reutiliza os widgets premium definidos em home_screen.dart
import 'package:disciplinum/features/home/presentation/screens/home_screen.dart';

class HomeScreenGuest extends ConsumerStatefulWidget {
  const HomeScreenGuest({super.key});

  @override
  ConsumerState<HomeScreenGuest> createState() => _HomeScreenGuestState();
}

class _HomeScreenGuestState extends ConsumerState<HomeScreenGuest>
    with WidgetsBindingObserver {
  bool _permissionsChecked = false;
  bool _consentDialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      InstalledAppService().preload();
      _initializeConsent();
    });
  }

  Future<void> _initializeConsent() async {
    await ConsentService.instance.initialize();
    final hasResponded =
        await ConsentService.instance.hasUserRespondedToConsent();

    if (!hasResponded && mounted) {
      final route = ModalRoute.of(context);
      if (route != null && route.isCurrent) {
        setState(() => _consentDialogShown = true);
        await showConsentDialog(context);
        if (mounted) setState(() => _consentDialogShown = false);
      }
    }
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
        final hasResponded =
            await ConsentService.instance.hasUserRespondedToConsent();
        if (!hasResponded && mounted && !_consentDialogShown) {
          setState(() => _consentDialogShown = true);
          await showConsentDialog(context);
          if (mounted) setState(() => _consentDialogShown = false);
        }
      }
    });
  }

  Color _getNicheColor(int nicheId) {
    switch (nicheId) {
      case 1:
      case 2:
      case 3:
        return const Color(0xFF10B981);
      case 8:
      case 5:
        return const Color(0xFF3B82F6);
      case 4:
      case 7:
        return const Color(0xFFF59E0B);
      case 6:
        return const Color(0xFF8B5CF6);
      case 9:
        return const Color(0xFFF97316);
      default:
        return HomeColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = NicheCategoryRepository.getCategories();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentTheme = ref.watch(themeControllerProvider);
    final isPinkTheme = currentTheme == AppTheme.pink;
    final isHalloweenTheme = currentTheme == AppTheme.halloween;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surface,
            colorScheme.surfaceContainerHighest,
          ],
        ),
      ),
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Flores (Tema Rosa)
            if (isPinkTheme) ...[
              Positioned(
                  top: 80,
                  right: -10,
                  child: Transform.rotate(
                      angle: 0.6,
                      child: Icon(Icons.local_florist,
                          size: 72,
                          color: colorScheme.primary.withValues(alpha: 0.14)))),
              Positioned(
                  top: 280,
                  left: -25,
                  child: Transform.rotate(
                      angle: -0.4,
                      child: Icon(Icons.filter_vintage,
                          size: 68,
                          color:
                              colorScheme.secondary.withValues(alpha: 0.12)))),
              Positioned(
                  bottom: 120,
                  right: -15,
                  child: Transform.rotate(
                      angle: 0.3,
                      child: Icon(Icons.spa,
                          size: 76,
                          color: colorScheme.primary.withValues(alpha: 0.13)))),
              Positioned(
                  top: 45,
                  left: 60,
                  child: Transform.rotate(
                      angle: -0.2,
                      child: Icon(Icons.eco,
                          size: 42,
                          color:
                              colorScheme.secondary.withValues(alpha: 0.18)))),
              Positioned(
                  top: 200,
                  right: 80,
                  child: Transform.rotate(
                      angle: 0.7,
                      child: Icon(Icons.local_florist,
                          size: 38,
                          color: colorScheme.primary.withValues(alpha: 0.20)))),
            ],
            // Decorações de Halloween 🎃
            if (isHalloweenTheme) ...[
              Positioned(
                  top: 60,
                  right: -15,
                  child: Transform.rotate(
                      angle: 0.2,
                      child: const Opacity(
                          opacity: 0.15,
                          child: Text('🎃', style: TextStyle(fontSize: 78))))),
              Positioned(
                  top: 250,
                  left: -20,
                  child: Transform.rotate(
                      angle: -0.3,
                      child: const Opacity(
                          opacity: 0.15,
                          child: Text('👻', style: TextStyle(fontSize: 72))))),
              Positioned(
                  bottom: 100,
                  right: -10,
                  child: Transform.rotate(
                      angle: 0.4,
                      child: const Opacity(
                          opacity: 0.15,
                          child: Text('🦇', style: TextStyle(fontSize: 80))))),
              Positioned(
                  top: 120,
                  left: 70,
                  child: Transform.rotate(
                      angle: -0.1,
                      child: const Opacity(
                          opacity: 0.15,
                          child:
                              Text('🕸️', style: TextStyle(fontSize: 48))))),
              Positioned(
                  top: 350,
                  right: 90,
                  child: Transform.rotate(
                      angle: 0.5,
                      child: const Opacity(
                          opacity: 0.15,
                          child:
                              Text('💀', style: TextStyle(fontSize: 44))))),
            ],

            // Background Circle
            Positioned(
              top: -180,
              right: -180,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withValues(alpha: 0.06),
                ),
              ),
            ),

            // Main Content
            CustomScrollView(
              slivers: [
                // Header — aviso de modo convidado
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 16,
                      left: 20,
                      right: 20,
                      bottom: 16,
                    ),
                    child: _GuestHeaderCard(),
                  ),
                ),

                // Active Modules Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    child: Consumer(
                      builder: (context, ref, child) {
                        final activeModulesAsync =
                            ref.watch(activeModulesProvider);
                        final activeModules =
                            activeModulesAsync.valueOrNull ?? [];
                        return _buildActiveModulesSection(activeModules);
                      },
                    ),
                  ),
                ),

                // Categories
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final category = categories[index];
                        return _buildCategorySection(category, index);
                      },
                      childCount: categories.length,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),

            // Overlay consent
            if (_consentDialogShown)
              Positioned.fill(
                child: AbsorbPointer(
                  absorbing: true,
                  child: Container(color: Colors.black54),
                ),
              ),
          ],
        ),
        bottomNavigationBar: const DisciplinumBottomNavBar(currentIndex: 0),
      ),
    );
  }

  Widget _buildActiveModulesSection(List<NicheId> activeNiches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Módulos Ativos',
          subtitle: 'Seus módulos em andamento',
          accentColor: HomeColors.success,
        ),
        const SizedBox(height: 12),
        if (activeNiches.isEmpty)
          const ModernEmptyStateCard()
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: activeNiches.map((nicheId) {
              final niche = NicheRepository.getById(nicheId);
              return SizedBox(
                width: (MediaQuery.of(context).size.width - 52) / 2,
                child: ModernNicheCard(
                  niche: niche,
                  heroTag: 'guest_active_${niche.id}',
                  isActive: true,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildCategorySection(NicheCategory category, int categoryIndex) {
    final firstNiche = category.nicheIds.isNotEmpty
        ? NicheRepository.getById(category.nicheIds.first)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        SectionHeader(
          title: category.title,
          accentColor: firstNiche != null
              ? _getNicheColor(firstNiche.id)
              : HomeColors.primary,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: category.nicheIds.map((nicheId) {
            final niche = NicheRepository.getById(nicheId);
            final heroTag = 'guest_${category.idPrefix}_${niche.id}';
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 52) / 2,
              child: ModernNicheCard(
                niche: niche,
                heroTag: heroTag,
                isActive: false,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Header exclusivo do modo convidado
// ---------------------------------------------------------------------------

class _GuestHeaderCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentTheme = ref.watch(themeControllerProvider);
    final isPinkTheme = currentTheme == AppTheme.pink;
    final isHalloweenTheme = currentTheme == AppTheme.halloween;

    // Cores da borda/gradiente externo
    final List<Color> gradientColors;
    final Color shadowColor;
    final Color fillColor;
    final Color iconColor;

    if (isPinkTheme) {
      gradientColors = const [Color(0xFFEC4899), Color(0xFFF9A8D4)];
      shadowColor = const Color(0xFFEC4899);
      fillColor = const Color(0xFFFFF0F5); // Rosa bem claro
      iconColor = const Color(0xFFEC4899);
    } else if (isHalloweenTheme) {
      gradientColors = const [Color(0xFFE0E0E0), Color(0xFFBDBDBD)];
      shadowColor = const Color(0xFF9E9E9E);
      fillColor = const Color(0xFF2D2D2D); // Grafite
      iconColor = const Color(0xFFE0E0E0);
    } else {
      // Claro / Dark: manter vermelho original
      gradientColors = const [Color(0xFFEF4444), Color(0xFFFF6B6B)];
      shadowColor = const Color(0xFFEF4444);
      fillColor = theme.cardColor;
      iconColor = const Color(0xFFEF4444);
    }

    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          color: fillColor,
          child: Row(
            children: [
              Image.asset('assets/logo.png', height: 48),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Modo Convidado',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sem salvamentos — crie uma conta para não perder seu progresso',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.person_outline_rounded,
                color: iconColor.withValues(alpha: 0.8),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
