import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:disciplinum/core/theme/app_theme.dart';
import 'package:disciplinum/infrastructure/permissions/usage_stats/permission_service.dart';
import 'package:disciplinum/app/router/app_router.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/infrastructure/ads/consent_service.dart';
import 'package:disciplinum/infrastructure/ads/widgets/consent_dialog.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/models/common/niche_category.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/shared/repositories/niche_category_repository.dart';
import 'package:disciplinum/shared/components/navigation/bottom_nav_bar.dart';
import 'package:disciplinum/infrastructure/monitoring/installed_app_service.dart';
import 'package:disciplinum/features/modules/smoking/presentation/notifiers/smoking_gamification_notifier.dart'
    as smoking;
import 'package:disciplinum/features/modules/smoking/gamification/presentation/widgets/smoking_celebration_widget.dart';
import 'package:disciplinum/core/gamification/presentation/widgets/global_celebration_widget.dart';

// ============================================================================
// HOME SCREEN DESIGN SYSTEM
// ============================================================================

class HomeColors {
  static const primary = Color(0xFF6366F1);
  static const primaryLight = Color(0xFF818CF8);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
}

// ============================================================================
// ÍCONES MODERNOS POR NICHE
// ============================================================================

Map<int, FaIconData> nicheIcons = {
  1: FontAwesomeIcons.smoking,
  2: FontAwesomeIcons.utensils,
  3: FontAwesomeIcons.carrot,
  4: FontAwesomeIcons.moneyBillWave,
  5: FontAwesomeIcons.clock,
  6: FontAwesomeIcons.lock,
  7: FontAwesomeIcons.piggyBank,
  8: FontAwesomeIcons.calendarCheck,
  9: FontAwesomeIcons.bookOpen,
};

// ============================================================================
// PREMIUM WIDGETS PARA HOME SCREEN
// ============================================================================

class GlassMorphismCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;
  final bool hasGlow;
  final Color? glowColor;

  const GlassMorphismCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
    this.borderColor = const Color(0xFFE5E7EB),
    this.borderWidth = 1.0,
    this.hasGlow = false,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveGlowColor = glowColor ?? HomeColors.primary;

    return SizedBox(
      width: width,
      height: height,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor.withValues(alpha: 0.2),
            width: borderWidth,
          ),
          boxShadow: [
            if (hasGlow)
              BoxShadow(
                color: effectiveGlowColor.withValues(alpha: 0.15),
                blurRadius: 12,
                spreadRadius: 1,
                offset: Offset.zero,
              ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class PremiumHeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Color borderColor;

  const PremiumHeaderCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.leading,
    this.trailing,
    this.borderColor = HomeColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            borderColor,
            borderColor.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          color: colorScheme.surface,
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ModernNicheCard extends StatelessWidget {
  final Niche niche;
  final String heroTag;
  final bool isActive;

  const ModernNicheCard({
    super.key,
    required this.niche,
    required this.heroTag,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = _getNicheColor(niche.id);
    final glowColor = isActive ? HomeColors.success : accentColor;
    final customIcon = nicheIcons[niche.id] ?? FontAwesomeIcons.star;

    return Container(
      height: 195,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.surface,
        border: Border.all(
          color: isActive
              ? glowColor.withValues(alpha: 0.6)
              : accentColor.withValues(alpha: 0.25),
          width: isActive ? 1.8 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.2),
            blurRadius: 12,
            spreadRadius: 1.5,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onTap(context),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  SizedBox(
                    height: 100,
                    child: Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              glowColor.withValues(alpha: 0.15),
                              Colors.transparent,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: glowColor.withValues(alpha: 0.3),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: glowColor.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: Offset.zero,
                            ),
                          ],
                        ),
                        child: Center(
                          child: FaIcon(
                            customIcon,
                            size: 33,
                            color: glowColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    niche.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: colorScheme.onSurface,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        niche.homePhrase,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.55),
                          fontSize: 10.5,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                  if (isActive)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: glowColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: glowColor.withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          'ATIVO',
                          style: TextStyle(
                            color: glowColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9));
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

  void _onTap(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(
      context,
      AppRouter.nicheDetail,
      arguments: {'niche': niche, 'heroTag': heroTag},
    );
  }
}

class ModernEmptyStateCard extends StatelessWidget {
  const ModernEmptyStateCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 195,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.surface,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: HomeColors.primary.withValues(alpha: 0.08),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Nenhum módulo ativo',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Ative um módulo',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.60),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color accentColor;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.accentColor = HomeColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ],
    ).animate().slideX(begin: -0.1, duration: 400.ms);
  }
}

// ============================================================================
// HOME SCREEN
// ============================================================================

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  bool _permissionsChecked = false;
  bool _isSyncing = false;
  bool _consentDialogShown = false;
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      InstalledAppService().preload();
      _initializeConsentAndCheckSync();
    });
  }

  Future<void> _initializeConsentAndCheckSync() async {
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
    _checkAndPerformInitialSync();
  }

  Future<void> _checkAndPerformInitialSync({bool isLoginEvent = false}) async {
    if (!mounted) return;
    final route = ModalRoute.of(context);
    if (route == null || !route.isCurrent) return;
    if (_isSyncing) return;

    final authService = ref.read(authServiceProvider);
    final currentUserId = authService.currentUser?.id;
    if (currentUserId == null) return;

    final syncState = ref.read(initialSyncCompletedProvider.notifier);
    final checkResult = await syncState.checkShouldSync(currentUserId,
        isLoginEvent: isLoginEvent);
    if (!checkResult.shouldSync) {
      ref.read(initialSyncCompletedProvider.notifier).markSessionSynced();
      return;
    }

    await _performInitialSync(currentUserId);
  }

  Future<void> _performInitialSync(String userId) async {
    if (!mounted) return;
    setState(() => _isSyncing = true);

    try {
      final cloudSync = ref.read(cloudSyncServiceProvider);
      final success = await cloudSync.syncNow();

      if (!mounted) return;

      if (success) {
        ref.invalidate(activeModulesProvider);
        ref.invalidate(smoking.smokingGamificationNotifierProvider);
        await Future.delayed(const Duration(milliseconds: 500));
        final activeModules = ref.read(activeModulesProvider).valueOrNull ?? [];
        _showSnack(
            activeModules.isNotEmpty
                ? 'Dados sincronizados.'
                : 'Sincronização concluída, mas nenhum módulo ativo foi encontrado.',
            isSuccess: activeModules.isNotEmpty);
      } else {
        _showSnack(
            'Não foi possível sincronizar. Tente manualmente nas configurações.',
            isError: true);
      }
    } catch (e) {
      if (mounted) _showSnack('Erro ao sincronizar dados.', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
        await ref
            .read(initialSyncCompletedProvider.notifier)
            .markSynced(userId);
      }
    }
  }

  void _showSnack(String message,
      {bool isSuccess = false, bool isError = false}) {
    if (!mounted) return;
    final backgroundColor = isError
        ? Colors.red
        : (isSuccess ? const Color(0xFF10B981) : Colors.white);
    final foregroundColor =
        backgroundColor == Colors.white ? Colors.black87 : Colors.white;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(
            isError
                ? Icons.error_outline
                : (isSuccess ? Icons.cloud_done : Icons.cloud),
            color: foregroundColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(message, style: TextStyle(color: foregroundColor))),
        ]),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
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
    ref.listenManual(authServiceProvider, (previous, next) {
      final hadUser = previous?.currentUser != null;
      final hasUser = next.currentUser != null;
      if (!hadUser && hasUser) {
        ref.read(initialSyncCompletedProvider.notifier).resetSessionOnly();
        _checkAndPerformInitialSync(isLoginEvent: true);
      } else if (hadUser && !hasUser) {
        ref.read(initialSyncCompletedProvider.notifier).resetSessionOnly();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_permissionsChecked) return;
      final route = ModalRoute.of(context);
      if (route != null && route.isCurrent) {
        _permissionsChecked = true;
        _checkPendingMedals();
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

  Future<void> _checkPendingMedals() async {
    final pending = await ref.read(pendingMedalsProvider);
    if (pending.isNotEmpty) _showMedalDialog(pending.first);
  }

  void _showMedalDialog(String medalName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Nova Conquista! 🎉',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Image.asset('assets/logo.png', height: 100),
              const SizedBox(height: 16),
              Text('Você ganhou a medalha de $medalName!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              const Text('Continue assim para alcançar novos objetivos.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HomeColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
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

    return GlobalCelebrationWidget(
      child: SmokingCelebrationWidget(
        child: Scaffold(
          extendBody: true,
          backgroundColor: colorScheme.surface,
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
                            color:
                                colorScheme.primary.withValues(alpha: 0.14)))),
                Positioned(
                    top: 280,
                    left: -25,
                    child: Transform.rotate(
                        angle: -0.4,
                        child: Icon(Icons.filter_vintage,
                            size: 68,
                            color: colorScheme.secondary
                                .withValues(alpha: 0.12)))),
                Positioned(
                    bottom: 120,
                    right: -15,
                    child: Transform.rotate(
                        angle: 0.3,
                        child: Icon(Icons.spa,
                            size: 76,
                            color:
                                colorScheme.primary.withValues(alpha: 0.13)))),
                Positioned(
                    top: 45,
                    left: 60,
                    child: Transform.rotate(
                        angle: -0.2,
                        child: Icon(Icons.eco,
                            size: 42,
                            color: colorScheme.secondary
                                .withValues(alpha: 0.18)))),
                Positioned(
                    top: 200,
                    right: 80,
                    child: Transform.rotate(
                        angle: 0.7,
                        child: Icon(Icons.local_florist,
                            size: 38,
                            color:
                                colorScheme.primary.withValues(alpha: 0.20)))),
              ],
              // Decorações de Halloween 🎃
              if (isHalloweenTheme) ...[
                Positioned(
                    top: 60,
                    right: -15,
                    child: Transform.rotate(
                        angle: 0.2,
                        child: Text('🎃',
                            style: TextStyle(
                              fontSize: 78,
                              color:
                                  colorScheme.primary.withValues(alpha: 0.16),
                            )))),
                Positioned(
                    top: 250,
                    left: -20,
                    child: Transform.rotate(
                        angle: -0.3,
                        child: Icon(Icons.psychology, // Fantasma/mente
                            size: 72,
                            color: colorScheme.secondary
                                .withValues(alpha: 0.14)))),
                Positioned(
                    bottom: 100,
                    right: -10,
                    child: Transform.rotate(
                        angle: 0.4,
                        child: Icon(Icons.nightlight_round, // Lua/vampiro
                            size: 80,
                            color:
                                colorScheme.primary.withValues(alpha: 0.12)))),
                Positioned(
                    top: 120,
                    left: 70,
                    child: Transform.rotate(
                        angle: -0.1,
                        child: Icon(Icons.star, // Estrela
                            size: 48,
                            color: colorScheme.secondary
                                .withValues(alpha: 0.20)))),
                Positioned(
                    top: 350,
                    right: 90,
                    child: Transform.rotate(
                        angle: 0.5,
                        child: Text('🎃',
                            style: TextStyle(
                              fontSize: 44,
                              color:
                                  colorScheme.primary.withValues(alpha: 0.18),
                            )))),
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
                  // Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 16,
                        left: 20,
                        right: 20,
                        bottom: 16,
                      ),
                      child: PremiumHeaderCard(
                        title: 'Bem-vindo de volta!',
                        subtitle: 'Sua jornada de disciplina continua aqui',
                        leading: Image.asset('assets/logo.png', height: 48),
                        borderColor: HomeColors.primary,
                      ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1),
                    ),
                  ),

                  // Active Modules Section (agora mais para cima)
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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

              // Overlays
              if (_isSyncing)
                Positioned.fill(
                  child: AbsorbPointer(
                    absorbing: true,
                    child: Container(
                      color: Colors.black54,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 3),
                            const SizedBox(height: 20),
                            Text('Sincronizando dados...',
                                style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            Text(
                                'Aguarde enquanto recuperamos seus dados da nuvem',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: Colors.white70),
                                textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

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
                  heroTag: 'active_${niche.id}',
                  isActive: true,
                ),
              );
            }).toList(),
          ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
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
            final heroTag = '${category.idPrefix}_${niche.id}';
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
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 300.ms + (categoryIndex * 100).ms);
  }
}
