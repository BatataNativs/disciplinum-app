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
import 'package:disciplinum/core/di/user_choices_provider.dart';
import 'package:disciplinum/infrastructure/ads/consent_service.dart';
import 'package:disciplinum/infrastructure/ads/widgets/consent_dialog.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/models/common/niche_category.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/shared/repositories/niche_category_repository.dart';
import 'package:disciplinum/shared/components/navigation/bottom_nav_bar.dart';
import 'package:disciplinum/infrastructure/monitoring/installed_app_service.dart';
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
  2: FontAwesomeIcons.pizzaSlice,
  3: FontAwesomeIcons.utensils,
  4: FontAwesomeIcons.wallet,
  5: FontAwesomeIcons.hourglassHalf,
  6: FontAwesomeIcons.userSecret,
  7: FontAwesomeIcons.piggyBank,
  8: FontAwesomeIcons.calendarCheck,
  9: FontAwesomeIcons.bookOpen,
  10: FontAwesomeIcons.mobileScreen,
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
    final effectiveGlowColor = glowColor ?? HomeColors.primary;

    return SizedBox(
      width: width,
      height: height,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: theme.cardColor,
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

class PremiumHeaderCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentTheme = ref.watch(themeControllerProvider);
    final isPinkTheme = currentTheme == AppTheme.pink;
    final isHalloweenTheme = currentTheme == AppTheme.halloween;

    final List<Color> gradientColors;
    final Color shadowColor;
    final Color fillColor;

    if (isPinkTheme) {
      gradientColors = const [Color(0xFFEC4899), Color(0xFFF9A8D4)];
      shadowColor = const Color(0xFFEC4899);
      fillColor = const Color(0xFFFFF0F5);
    } else if (isHalloweenTheme) {
      gradientColors = const [Color(0xFFE0E0E0), Color(0xFFBDBDBD)];
      shadowColor = const Color(0xFF9E9E9E);
      fillColor = const Color(0xFF2D2D2D);
    } else {
      gradientColors = [borderColor, borderColor.withValues(alpha: 0.6)];
      shadowColor = borderColor;
      fillColor = theme.cardColor;
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
  final bool isHidden;
  final VoidCallback? onVisibilityToggle;

  const ModernNicheCard({
    super.key,
    required this.niche,
    required this.heroTag,
    this.isActive = false,
    this.isHidden = false,
    this.onVisibilityToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isHalloweenTheme = theme.primaryColor == const Color(0xFFFF6D00);
    final textColor = isHalloweenTheme ? Colors.black : colorScheme.onSurface;
    final accentColor = _getNicheColor(niche.id);
    final glowColor = isActive ? HomeColors.success : accentColor;
    final customIcon = nicheIcons[niche.id] ?? FontAwesomeIcons.star;
    final cardBorderColor = isHidden
        ? accentColor.withValues(alpha: 0.18)
        : (isActive
            ? glowColor.withValues(alpha: 0.6)
            : accentColor.withValues(alpha: 0.25));

    return AnimatedOpacity(
      opacity: isHidden ? 0.72 : 1.0,
      duration: const Duration(milliseconds: 180),
      child: Container(
        height: 195,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: theme.cardColor,
          border: Border.all(
            color: cardBorderColor,
            width: isActive ? 1.8 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: isHidden ? 0.16 : 0.3),
              blurRadius: 24,
              spreadRadius: 1.5,
              offset: const Offset(0, 10),
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
            child: Stack(
              children: [
                // InkWell cobrindo todo o card para navegar
                Positioned.fill(
                  child: InkWell(
                    onTap: () => _onTap(context),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                // Conteúdo visual (ignora toques para que passem ao InkWell de fundo)
                IgnorePointer(
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
                                color: isHalloweenTheme ? Colors.black : null,
                                gradient: isHalloweenTheme
                                    ? null
                                    : LinearGradient(
                                        colors: [
                                          glowColor.withValues(alpha: 0.15),
                                          Colors.transparent,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                border: Border.all(
                                  color: isHalloweenTheme
                                      ? glowColor.withValues(alpha: 0.7)
                                      : glowColor.withValues(alpha: 0.3),
                                  width: isHalloweenTheme ? 1.8 : 1.2,
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
                            color: textColor,
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
                                color: textColor.withValues(
                                    alpha: isHalloweenTheme ? 0.75 : 0.55),
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
                        if (isHidden)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.08),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                'OCULTO',
                                style: TextStyle(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.7),
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
                // Botão de visibilidade explícito no topo do Stack (não exibir se o módulo estiver ativo)
                if (onVisibilityToggle != null && !isActive)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: IconButton(
                      icon: Icon(
                        isHidden
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        size: 20,
                        color: isHidden ? HomeColors.success : Colors.grey[400],
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        onVisibilityToggle!();
                      },
                      tooltip: isHidden ? 'Exibir' : 'Ocultar',
                    ),
                  ),
              ],
            ),
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
        // módulos: Cigarro, Compulsão Alimentar, Dieta
        return const Color.fromARGB(255, 203, 64, 13);
      case 8:
      case 5:
        // módulos: Foco e Produtividade, Evitar Procrastinação
        return const Color.fromARGB(255, 61, 136, 11);
      case 4:
      case 7:
        // módulos financeiros
        return const Color.fromARGB(255, 32, 85, 233);
      case 6:
        // módulo: Jejum 18+
        return const Color.fromARGB(255, 96, 96, 97);
      case 9:
        // módulo: Leitura
        return const Color.fromARGB(255, 12, 167, 167);
      case 10:
        //  módulo: Jejum Digital
        return const Color.fromARGB(255, 12, 167, 167);
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
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
    );
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

class _HiddenModulesPrompt extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onTap;

  const _HiddenModulesPrompt({
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.45,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.visibility_rounded,
                size: 20,
                color: colorScheme.onSurface.withValues(alpha: 0.65),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isExpanded
                      ? 'Ocultar módulos ocultados'
                      : 'Exibir módulos ocultados',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
              ),
              Icon(
                isExpanded
                    ? Icons.expand_less_rounded
                    : Icons.chevron_right_rounded,
                size: 20,
                color: colorScheme.onSurface.withValues(alpha: 0.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HiddenModulesSection extends StatelessWidget {
  final List<NicheId> hiddenModules;
  final Future<void> Function(NicheId nicheId, bool isVisible)
      onToggleVisibility;

  const _HiddenModulesSection({
    required this.hiddenModules,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: hiddenModules.map((nicheId) {
            final niche = NicheRepository.getById(nicheId);

            return SizedBox(
              width: (MediaQuery.of(context).size.width - 52) / 2,
              child: ModernNicheCard(
                niche: niche,
                heroTag: 'hidden_${niche.id}',
                isHidden: true,
                onVisibilityToggle: () {
                  onToggleVisibility(nicheId, true);
                },
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  bool _permissionsChecked = false;
  bool _consentDialogShown = false;
  bool _showHiddenModules = false;
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
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

  String _moduleVisibilityKey(NicheId nicheId) => nicheId.name;

  bool _isModuleHidden(
      NicheId nicheId, Map<String, bool> moduleVisibility) {
    return moduleVisibility[_moduleVisibilityKey(nicheId)] == false;
  }

Future<void> _toggleModuleVisibility(NicheId nicheId, bool isVisible) async {
    
    await ref
        .read(userChoicesControllerProvider)
        .updateModuleVisibility(_moduleVisibilityKey(nicheId), isVisible);
        
    ref.invalidate(userChoicesProvider); 
}

  @override
  Widget build(BuildContext context) {
    final categories = NicheCategoryRepository.getCategories();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentTheme = ref.watch(themeControllerProvider);
    final isPinkTheme = currentTheme == AppTheme.pink;
    final isHalloweenTheme = currentTheme == AppTheme.halloween;
    final userChoicesAsync = ref.watch(userChoicesProvider);
    final moduleVisibility =
        userChoicesAsync.valueOrNull?.moduleVisibility ?? const <String, bool>{};
    final hiddenModules = NicheId.values
        .where((nicheId) => _isModuleHidden(nicheId, moduleVisibility))
        .toList();

    debugPrint('📱 [HomeScreen] Build chamado! Mapa de visibilidade atual: $moduleVisibility');

    return GlobalCelebrationWidget(
      child: SmokingCelebrationWidget(
        child: Container(
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
                if (isPinkTheme) ...[
                  Positioned(
                      top: 80,
                      right: -10,
                      child: Transform.rotate(
                          angle: 0.6,
                          child: Icon(Icons.local_florist,
                              size: 72,
                              color: colorScheme.primary
                                  .withValues(alpha: 0.14)))),
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
                              color: colorScheme.primary
                                  .withValues(alpha: 0.13)))),
                ],
                if (isHalloweenTheme) ...[
                  Positioned(
                      top: 60,
                      right: -15,
                      child: Transform.rotate(
                          angle: 0.2,
                          child: const Opacity(
                              opacity: 0.15,
                              child:
                                  Text('🎃', style: TextStyle(fontSize: 78))))),
                  Positioned(
                      top: 250,
                      left: -20,
                      child: Transform.rotate(
                          angle: -0.3,
                          child: const Opacity(
                              opacity: 0.15,
                              child:
                                  Text('👻', style: TextStyle(fontSize: 72))))),
                ],
                CustomScrollView(
                  slivers: [
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
                        )
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .slideY(begin: -0.1),
                      ),
                    ),
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
                            return _buildActiveModulesSection(
                              activeModules,
                              hiddenModules,
                              moduleVisibility,
                            );
                          },
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final category = categories[index];
                            return _buildCategorySection(
                              category,
                              index,
                              hiddenModules,
                              moduleVisibility,
                            );
                          },
                          childCount: categories.length,
                        ),
                      ),
                    ),
                    if (hiddenModules.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                          child: _HiddenModulesPrompt(
                            isExpanded: _showHiddenModules,
                            onTap: () {
                              setState(() {
                                _showHiddenModules = !_showHiddenModules;
                              });
                            },
                          ),
                        ),
                      ),
                    if (_showHiddenModules && hiddenModules.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                          child: _HiddenModulesSection(
                            hiddenModules: hiddenModules,
                            onToggleVisibility: _toggleModuleVisibility,
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ],
            ),
            bottomNavigationBar:
                const DisciplinumBottomNavBar(currentIndex: 0),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveModulesSection(
    List<NicheId> activeNiches,
    List<NicheId> hiddenModules,
    Map<String, bool> moduleVisibility,
  ) {
    final visibleActiveNiches = activeNiches
        .where((nicheId) => !hiddenModules.contains(nicheId))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Módulos Ativos',
          subtitle: 'Seus módulos em andamento',
          accentColor: HomeColors.success,
        ),
        const SizedBox(height: 12),
        if (visibleActiveNiches.isEmpty)
          const ModernEmptyStateCard()
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: visibleActiveNiches.map((nicheId) {
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
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildCategorySection(
    NicheCategory category,
    int categoryIndex,
    List<NicheId> hiddenModules,
    Map<String, bool> moduleVisibility,
  ) {
    final visibleNicheIds = category.nicheIds
        .where((nicheId) => !hiddenModules.contains(nicheId))
        .toList();

    if (visibleNicheIds.isEmpty) {
      return const SizedBox.shrink();
    }

    final firstNiche = visibleNicheIds.isNotEmpty
        ? NicheRepository.getById(visibleNicheIds.first)
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
          children: visibleNicheIds.map((nicheId) {
            final niche = NicheRepository.getById(nicheId);
            final heroTag = '${category.idPrefix}_${niche.id}';
            final isCurrentlyHidden =
                moduleVisibility[_moduleVisibilityKey(nicheId)] == false;

            return SizedBox(
              width: (MediaQuery.of(context).size.width - 52) / 2,
              child: ModernNicheCard(
                niche: niche,
                heroTag: heroTag,
                isActive: false,
                isHidden: isCurrentlyHidden,
                onVisibilityToggle: () {
                  _toggleModuleVisibility(nicheId, isCurrentlyHidden);
                },
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
      ],
    ).animate().fadeIn(duration: 300.ms, delay: 3.ms + (categoryIndex * 50).ms);
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
      case 10:
        return const Color(0xFF06B6D4);
      default:
        return HomeColors.primary;
    }
  }
}