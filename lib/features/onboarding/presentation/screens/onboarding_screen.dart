import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:disciplinum/app/router/app_router.dart';
import 'package:disciplinum/features/settings/presentation/screens/how_it_works_screen.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/core/storage/objectbox_preferences_repository.dart';

// ============================================================================
// DISCIPLINUM DESIGN SYSTEM
// ============================================================================

class DisciplinumColors {
  static const primary = Color.fromARGB(255, 103, 205, 243);
  static const primaryDark = Color.fromARGB(255, 76, 179, 210);
  static const primaryLight = Color.fromARGB(255, 145, 221, 243);

  static const background = Color(0xFF0A0A0A);
  static const surface = Color(0xFF1A1A1A);
  static const surfaceLight = Color(0xFF2A2A2A);

  static const onBackground = Colors.white;
  static const onSurface = Colors.white;
  static final onSurfaceVariant = Colors.white.withValues(alpha: 0.7);

  static const error = Color(0xFFFF4444);
  static const warning = Color(0xFFFFA500);

  static const detoxPrimary = Color(0xFF8B5CF6);
  static const detoxSecondary = Color(0xFF6366F1);

  static final glassLight = Colors.white.withValues(alpha: 0.05);
  static final glassMedium = Colors.white.withValues(alpha: 0.1);
  static final glassBorder = Colors.white.withValues(alpha: 0.15);
}

// ============================================================================
// REUSABLE WIDGETS
// ============================================================================

class ScrollDownArrow extends StatelessWidget {
  const ScrollDownArrow({super.key});
// seta aponta para baixo para indicar que tem mais conteúdo para baixo
  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 24,
      bottom: 24,
      child: Icon(
        Icons.arrow_downward_rounded,
        color: const Color.fromARGB(116, 255, 255, 255),
        size: 32,
      )
          .animate(onPlay: (controller) => controller.repeat())
          .fadeIn(duration: 500.ms)
          .slideY(
              begin: 0, end: 0.2, duration: 500.ms, curve: Curves.easeInOut),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;
  final Color backgroundColor;
  final bool useBlur;

  GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 16,
    Color? borderColor,
    this.borderWidth = 1,
    Color? backgroundColor,
    this.useBlur = false,
  })  : borderColor = borderColor ?? DisciplinumColors.glassBorder,
        backgroundColor = backgroundColor ?? DisciplinumColors.surfaceLight;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: child,
    );

    if (useBlur) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: content,
        ),
      );
    }
    return content;
  }
}

class PremiumGlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;
  final Color backgroundColor;

  const PremiumGlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 20,
    this.borderColor = DisciplinumColors.primary,
    this.borderWidth = 1.5,
    this.backgroundColor = DisciplinumColors.background,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Container(
        padding: EdgeInsets.all(borderWidth),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              borderColor,
              borderColor.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(borderRadius + borderWidth),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: padding,
            color: backgroundColor,
            child: child,
          ),
        ),
      ),
    );
  }
}

class NeonButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? width;
  final double height;
  final Color backgroundColor;
  final Color textColor;
  final Color glowColor;
  final double borderRadius;
  final bool disabled;

  const NeonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.width,
    this.height = 56,
    this.backgroundColor = DisciplinumColors.primary,
    this.textColor = Colors.black,
    this.glowColor = DisciplinumColors.primary,
    this.borderRadius = 14,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: glowColor,
                  blurRadius: 12,
                  offset: Offset.zero,
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: textColor, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
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

class NeonProgressIndicator extends StatelessWidget {
  final double progress;
  final double height;
  final Color backgroundColor;
  final Color progressColor;
  final double borderRadius;

  NeonProgressIndicator({
    super.key,
    required this.progress,
    this.height = 4,
    Color? backgroundColor,
    this.progressColor = DisciplinumColors.primary,
    this.borderRadius = 2,
  }) : backgroundColor = backgroundColor ?? Colors.white.withValues(alpha: 0.1);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0, 1),
        child: Container(
          decoration: BoxDecoration(
            color: progressColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}

class DisciplineMedal extends StatelessWidget {
  final String assetPath;
  final String label;
  final String milestone;
  final Color accentColor;

  const DisciplineMedal({
    super.key,
    required this.assetPath,
    required this.label,
    required this.milestone,
    this.accentColor = DisciplinumColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: DisciplinumColors.surfaceLight.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.16),
            DisciplinumColors.surfaceLight.withValues(alpha: 0.5),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.4),
                  blurRadius: 14,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Image.asset(assetPath, fit: BoxFit.contain),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: DisciplinumColors.onBackground,
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.3),
                width: 0.8,
              ),
            ),
            child: Text(
              milestone,
              style: TextStyle(
                color: accentColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class DisciplineInsignia extends StatelessWidget {
  final String assetPath;
  final String label;
  final Color accentColor;
  final bool isSupreme;

  const DisciplineInsignia({
    super.key,
    required this.assetPath,
    required this.label,
    this.accentColor = DisciplinumColors.primary,
    this.isSupreme = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: DisciplinumColors.surfaceLight.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accentColor.withValues(alpha: isSupreme ? 0.7 : 0.28),
          width: isSupreme ? 1.5 : 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accentColor.withValues(alpha: isSupreme ? 0.22 : 0.12),
            DisciplinumColors.surfaceLight.withValues(alpha: 0.5),
          ],
        ),
        boxShadow: isSupreme
            ? [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.25),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.35),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Image.asset(assetPath, fit: BoxFit.contain),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: isSupreme
                  ? DisciplinumColors.primaryLight
                  : DisciplinumColors.onBackground,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              shadows: isSupreme
                  ? [
                      Shadow(
                        color: accentColor.withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ]
                  : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class FeatureTile extends StatelessWidget {
  final String text;

  const FeatureTile({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: DisciplinumColors.glassLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: DisciplinumColors.primary.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize
            .min, // Garante que o Row ocupe apenas o espaço necessário
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: DisciplinumColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: DisciplinumColors.primary,
                width: 1.2,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.check_rounded,
                size: 12,
                color: DisciplinumColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 7),
          Flexible(
            // Usar Flexible para permitir que o texto ocupe o espaço disponível
            child: Text(
              text,
              style: const TextStyle(
                color: DisciplinumColors.onSurface,
                fontWeight: FontWeight.w500,
                fontSize: 11,
                height: 1.1,
              ),
              maxLines: 2,
              overflow: TextOverflow
                  .ellipsis, // Adicionado para evitar transbordamento
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingModuleItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _OnboardingModuleItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class _OnboardingModuleCard extends StatelessWidget {
  final _OnboardingModuleItem item;

  const _OnboardingModuleCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: DisciplinumColors.surfaceLight.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.color.withValues(alpha: 0.25),
          width: 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            item.color.withValues(alpha: 0.12),
            DisciplinumColors.surfaceLight.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: item.color.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: 15,
                ),
              ),
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: item.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: item.color.withValues(alpha: 0.6),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            item.title,
            style: const TextStyle(
              color: DisciplinumColors.onBackground,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Text(
              item.description,
              style: TextStyle(
                color: DisciplinumColors.onSurfaceVariant,
                fontSize: 9.5,
                height: 1.18,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ONBOARDING SCREEN
// ============================================================================

class OnboardingScreen extends ConsumerStatefulWidget {
  final bool isReviewMode;

  const OnboardingScreen({
    super.key,
    this.isReviewMode = false,
  });

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  int _currentPage = 0;
  static const int _totalPages = 4;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    if (widget.isReviewMode) {
      if (mounted) Navigator.pop(context);
      return;
    }
    if (!mounted) return;
    try {
      final prefs =
          ObjectBoxPreferencesRepository(ObjectBoxService.instance.store);
      await prefs.setBool('seen_onboarding', true);
    } catch (_) {}
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      AppRouter.auth,
      arguments: 1, // 1 = Criar Conta
    );
  }

  Future<void> _handleSkipAction() async {
    if (widget.isReviewMode) {
      if (mounted) Navigator.pop(context);
      return;
    }
    await _confirmSkip();
  }

  Future<void> _confirmSkip() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final shouldSkip = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          'Pular explicação?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        content: RichText(
          text: TextSpan(
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            children: [
              const TextSpan(
                text: 'POR FAVOR',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                children: [
                  TextSpan(
                    text:
                        ', leia até o final. \nHá avisos importantes sobre o propósito do app e seu funcionamento.\n\n',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  TextSpan(
                    text: 'Deseja mesmo pular?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: const Text('Sim, pular mesmo'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, false),
            style: FilledButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 0, 0, 0),
              foregroundColor: Colors.white,
            ),
            child: const Text('Ok, continuar vendo'),
          ),
        ],
      ),
    );
    if (shouldSkip == true) {
      await _finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastPage = _currentPage == _totalPages - 1;
    final skipButtonText = widget.isReviewMode ? 'Voltar' : 'Pular';
    final finishButtonText = widget.isReviewMode ? 'Entendi' : 'Entrar no App';

    return Scaffold(
      backgroundColor: DisciplinumColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with progress indicator
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  NeonProgressIndicator(
                    progress: (_currentPage + 1) / _totalPages,
                    height: 4,
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    progressColor: DisciplinumColors.primary,
                  ).animate().slideX(begin: -1, duration: 500.ms),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _totalPages,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? DisciplinumColors.primary
                              : theme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ).animate().scale(
                            begin: _currentPage == index
                                ? const Offset(0.8, 0.8)
                                : const Offset(1, 1),
                            duration: 300.ms,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _totalPages,
                itemBuilder: (context, index) => _buildPage(index),
              ),
            ),

            // Bottom navigation
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: DisciplinumColors.background,
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (!isLastPage || widget.isReviewMode)
                    TextButton(
                      onPressed: _handleSkipAction,
                      child: Text(
                        skipButtonText,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    const Spacer(),
                  const SizedBox(width: 85),
                  Expanded(
                    child: NeonButton(
                      text: isLastPage ? finishButtonText : 'Próximo',
                      onPressed: () {
                        if (isLastPage) {
                          _finishOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      icon: !isLastPage ? Icons.arrow_forward_ios_sharp : null,
                    ).animate().scale(
                          begin: const Offset(0.95, 0.95),
                          duration: 300.ms,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return _buildWelcomePage();
      case 1:
        return _buildModulesOverviewPage();
      case 2:
        return _buildGamificationPage();
      case 3:
        return _buildWarningPage();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWelcomePage() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Hero image
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: DisciplinumColors.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/opening/disciplinado.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1.05, 1.05),
                    duration: 600.ms,
                    curve: Curves.easeInOut,
                  ),

              const SizedBox(height: 12),

              // Title
              Text(
                'Disciplina, foco e bons hábitos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: DisciplinumColors.onBackground,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  shadows: [
                    Shadow(
                      color: DisciplinumColors.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),

              const SizedBox(height: 6),

              // Subtitle
              Text(
                'Transforme seus hábitos diários\ne seja mais disciplinado!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: DisciplinumColors.onSurfaceVariant,
                  height: 1.4,
                  fontSize: 15,
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 100.ms),

              const SizedBox(height: 12),

              // Digital Detox highlight
              PremiumGlassCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                borderRadius: 14,
                borderColor: DisciplinumColors.detoxPrimary,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.phone_android_rounded,
                      color: const Color.fromARGB(255, 210, 196, 244),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'Este app é um aliado para seus hábitos',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 210, 196, 244),
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

              const SizedBox(height: 12),

              // Features list
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12), // Reduzi o padding horizontal
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ele pode te ajudar a:',
                        style: TextStyle(
                          color: DisciplinumColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 14,
                        runSpacing: 10,
                        children: const [
                          FeatureTile(text: 'Evitar compras impulsivas'),
                          FeatureTile(text: 'Juntar dinheiro'),
                          FeatureTile(text: 'Focar em tarefas produtivas'),
                          FeatureTile(text: 'Parar de fumar'),
                          FeatureTile(text: 'Evitar conteúdo adulto'),
                          FeatureTile(text: 'Controlar uso do celular'),
                          FeatureTile(text: 'Parar de procrastinar'),
                          FeatureTile(text: 'Evitar fast food'),
                          FeatureTile(text: 'Manter dieta'),
                          FeatureTile(text: 'Manter e organizar leitura'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              DisciplinumColors.primary.withValues(alpha: 0.2),
                              DisciplinumColors.primary.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: 16,
                              color: DisciplinumColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'E muito mais!',
                                style: TextStyle(
                                  color: DisciplinumColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().shimmer(duration: 2000.ms, delay: 1000.ms),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModulesOverviewPage() {
    final modules = const [
      _OnboardingModuleItem(
        title: 'Jejum Digital',
        description: 'Controle seu tempo de tela e bloqueie apps indesejados',
        icon: Icons.phone_android_rounded,
        color: Color(0xFF06B6D4),
      ),
      _OnboardingModuleItem(
        title: 'Foco e Produtividade',
        description: 'Aumente seu foco e sua produtividade evitando distrações',
        icon: Icons.bolt_rounded,
        color: Color(0xFF6366F1),
      ),
      _OnboardingModuleItem(
        title: 'Parar de Fumar',
        description:
            'Controle de dias sem fumar, dinheiro economizado e benefícios à saúde',
        icon: Icons.smoke_free_rounded,
        color: Color(0xFF10B981),
      ),
      _OnboardingModuleItem(
        title: 'Controle de Gastos',
        description: 'Evite compras por impulso e controle suas contas',
        icon: Icons.account_balance_wallet_rounded,
        color: Color(0xFFEF4444),
      ),
      _OnboardingModuleItem(
        title: 'Desafio da Poupança',
        description:
            'Crie metas visuais para ajudar a alcançar seus objetivos financeiros',
        icon: Icons.savings_rounded,
        color: Color(0xFF14B8A6),
      ),
      _OnboardingModuleItem(
        title: 'Manter Dieta',
        description: 'Lembretes de refeições para manter o controle alimentar',
        icon: Icons.restaurant_rounded,
        color: Color(0xFFF59E0B),
      ),
      _OnboardingModuleItem(
        title: 'Compulsão Alimentar',
        description:
            'Bloqueie apps de delivery e tenha mais controle sobre sua alimentação',
        icon: Icons.no_meals_rounded,
        color: Color(0xFFEC4899),
      ),
      _OnboardingModuleItem(
        title: 'Evitar Procrastinação',
        description:
            'Organize suas tarefas, estabeleça rotinas e aumente sua produtividade',
        icon: Icons.task_alt_rounded,
        color: Color(0xFF3B82F6),
      ),
      _OnboardingModuleItem(
        title: 'Leitura',
        description:
            'Organize sua estante virtual e acompanhe seu progresso de leitura',
        icon: Icons.menu_book_rounded,
        color: Color(0xFFF97316),
      ),
      _OnboardingModuleItem(
        title: 'Jejum 18+',
        description:
            'Bloqueie conteúdo adulto, monitore dias de abstinência e mantenha o foco',
        icon: Icons.shield_rounded,
        color: Color(0xFF8B5CF6),
      ),
    ];

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Badge pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: DisciplinumColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: DisciplinumColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.dashboard_customize_rounded,
                      size: 13,
                      color: DisciplinumColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '10 MÓDULOS DE AUTOCONTROLE',
                      style: TextStyle(
                        color: DisciplinumColors.primary,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),

              const SizedBox(height: 10),

              // Title
              Text(
                'Tudo o que você precisa em um só app',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: DisciplinumColors.onBackground,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  shadows: [
                    Shadow(
                      color: DisciplinumColors.primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 450.ms, delay: 50.ms),

              const SizedBox(height: 4),

              // Subtitle
              Text(
                'Conheça as áreas que o Disciplinum te ajuda a dominar:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: DisciplinumColors.onSurfaceVariant,
                  fontSize: 12.5,
                  height: 1.3,
                ),
              ).animate().fadeIn(duration: 450.ms, delay: 100.ms),

              const SizedBox(height: 12),

              // Content: Modules Grid
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.58,
                        ),
                        itemCount: modules.length,
                        itemBuilder: (context, index) {
                          final item = modules[index];
                          return _OnboardingModuleCard(item: item)
                              .animate()
                              .fadeIn(
                                duration: 350.ms,
                                delay: (120 + (index * 25)).ms,
                              )
                              .slideY(
                                begin: 0.08,
                                duration: 350.ms,
                                delay: (120 + (index * 25)).ms,
                              );
                        },
                      ),

                      const SizedBox(height: 10),

                      // Bottom tip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: DisciplinumColors.surfaceLight
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: DisciplinumColors.glassBorder,
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.tune_rounded,
                              size: 15,
                              color: DisciplinumColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Você escolhe e ativa somente os módulos que quiser usar.',
                                style: TextStyle(
                                  color: DisciplinumColors.onSurfaceVariant,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const ScrollDownArrow(),
      ],
    );
  }

  Widget _buildGamificationPage() {
    return Stack(
      children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),

                // Title
                PremiumGlassCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  borderRadius: 14,
                  borderColor: DisciplinumColors.primary,
                  child: Column(
                    children: [
                      Icon(
                        Icons.emoji_events_rounded,
                        color: DisciplinumColors.primary,
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gamificação',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: DisciplinumColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Seu Progresso em Medalhas e Insígnias',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                              DisciplinumColors.primary.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1),

                const SizedBox(height: 14),

                // Description
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: DisciplinumColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: DisciplinumColors.primary.withValues(alpha: 0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    'À medida que você mantém sua disciplina, ganha recompensas fictícias que representam seu progresso no app.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: DisciplinumColors.onSurfaceVariant,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 150.ms),

                const SizedBox(height: 18),

                // Insignias section header
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: DisciplinumColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Insígnias',
                      style: TextStyle(
                        color: DisciplinumColors.onBackground,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: DisciplinumColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color:
                              DisciplinumColors.primary.withValues(alpha: 0.25),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        '9 Insígnias',
                        style: TextStyle(
                          color: DisciplinumColors.primary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms, delay: 250.ms),

                const SizedBox(height: 12),

                // Insignias Grid (3x3 - 9 Insígnias com assets ampliados)
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  childAspectRatio: 0.92,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: [
                    DisciplineInsignia(
                      assetPath:
                          'assets/gamification/insignias/smoking/madeira.png',
                      label: 'Madeira',
                      accentColor: const Color(0xFFA07248),
                    ).animate().fadeIn(duration: 350.ms, delay: 300.ms),
                    DisciplineInsignia(
                      assetPath:
                          'assets/gamification/insignias/smoking/ferro.png',
                      label: 'Ferro',
                      accentColor: const Color(0xFF94A3B8),
                    ).animate().fadeIn(duration: 350.ms, delay: 350.ms),
                    DisciplineInsignia(
                      assetPath:
                          'assets/gamification/insignias/smoking/aluminio.png',
                      label: 'Alumínio',
                      accentColor: const Color(0xFFA5B4FC),
                    ).animate().fadeIn(duration: 350.ms, delay: 400.ms),
                    DisciplineInsignia(
                      assetPath:
                          'assets/gamification/insignias/smoking/bronze.png',
                      label: 'Bronze',
                      accentColor: const Color(0xFFD97706),
                    ).animate().fadeIn(duration: 350.ms, delay: 450.ms),
                    DisciplineInsignia(
                      assetPath:
                          'assets/gamification/insignias/smoking/latao.png',
                      label: 'Latão',
                      accentColor: const Color(0xFFFBBF24),
                    ).animate().fadeIn(duration: 350.ms, delay: 500.ms),
                    DisciplineInsignia(
                      assetPath:
                          'assets/gamification/insignias/smoking/prata.png',
                      label: 'Prata',
                      accentColor: const Color(0xFFE2E8F0),
                    ).animate().fadeIn(duration: 350.ms, delay: 550.ms),
                    DisciplineInsignia(
                      assetPath:
                          'assets/gamification/insignias/smoking/ouro.png',
                      label: 'Ouro',
                      accentColor: const Color(0xFFFFB703),
                    ).animate().fadeIn(duration: 350.ms, delay: 600.ms),
                    DisciplineInsignia(
                      assetPath:
                          'assets/gamification/insignias/smoking/diamante.png',
                      label: 'Diamante',
                      accentColor: const Color(0xFF38BDF8),
                    ).animate().fadeIn(duration: 350.ms, delay: 650.ms),
                    DisciplineInsignia(
                      assetPath:
                          'assets/gamification/insignias/smoking/disciplinum.png',
                      label: 'Disciplinum',
                      accentColor: DisciplinumColors.primary,
                      isSupreme: true,
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                          begin: const Offset(0.97, 0.97),
                          end: const Offset(1.03, 1.03),
                          duration: 3000.ms,
                          curve: Curves.easeInOut,
                        )
                        .fadeIn(duration: 350.ms, delay: 20.ms),
                  ],
                ),

                const SizedBox(height: 20),

                // Medals section header
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: DisciplinumColors.detoxPrimary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Medalhas',
                      style: TextStyle(
                        color: DisciplinumColors.onBackground,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: DisciplinumColors.detoxPrimary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: DisciplinumColors.detoxPrimary
                              .withValues(alpha: 0.25),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        '4 Marcos',
                        style: TextStyle(
                          color: DisciplinumColors.detoxPrimary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms, delay: 750.ms),

                const SizedBox(height: 12),

                // Medals Grid (2x2 - 4 Medalhas Grandes e Detalhadas)
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 0.98,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  children: [
                    DisciplineMedal(
                      assetPath:
                          'assets/gamification/medals/smoking/bronze.png',
                      label: 'Bronze',
                      milestone: '1ª Conquista',
                      accentColor: const Color(0xFFCD7F32),
                    ).animate().fadeIn(duration: 450.ms, delay: 800.ms),
                    DisciplineMedal(
                      assetPath:
                          'assets/gamification/medals/smoking/silver.png',
                      label: 'Prata',
                      milestone: '2ª Conquista',
                      accentColor: const Color(0xFFCBD5E1),
                    ).animate().fadeIn(duration: 450.ms, delay: 850.ms),
                    DisciplineMedal(
                      assetPath: 'assets/gamification/medals/smoking/gold.png',
                      label: 'Ouro',
                      milestone: '3ª Conquista',
                      accentColor: const Color(0xFFFFD700),
                    ).animate().fadeIn(duration: 450.ms, delay: 900.ms),
                    DisciplineMedal(
                      assetPath:
                          'assets/gamification/medals/smoking/diamond.png',
                      label: 'Diamante',
                      milestone: '4ª Conquista',
                      accentColor: const Color(0xFF00E5FF),
                    ).animate().fadeIn(duration: 450.ms, delay: 950.ms),
                  ],
                ),

                const SizedBox(height: 16),

                // Bottom note
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color:
                        DisciplinumColors.surfaceLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: DisciplinumColors.glassBorder,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 16,
                        color: DisciplinumColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Mantenha a sua disciplina ativa para desbloquear cada uma dessas conquistas no app!',
                          style: TextStyle(
                            color: DisciplinumColors.onSurfaceVariant,
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 1000.ms),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        const ScrollDownArrow(),
      ],
    );
  }

  Widget _buildWarningPage() {
    final warningMessages = [
      ('Este app é uma ferramenta de apoio'),
      ('à disciplina e aos bons hábitos.'),
      ('Ele não substitui o acompanhamento'),
      ('de um profissional de saúde ou terapeuta.'),
      ('Use-o com responsabilidade e sabedoria,'),
      ('como ferramenta de controle, incentivo e'),
      ('motivação.'),
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Warning icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: DisciplinumColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
                border: Border.all(
                  color: DisciplinumColors.error,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: DisciplinumColors.error.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: Offset.zero,
                  ),
                ],
              ),
              child: Icon(
                Icons.warning_rounded,
                size: 50,
                color: DisciplinumColors.error,
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1.05, 1.05),
                  duration: 600.ms,
                  curve: Curves.easeInOut,
                ),

            const SizedBox(height: 32),

            // Title
            Text(
              'Atenção!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: DisciplinumColors.onBackground,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(duration: 600.ms),

            const SizedBox(height: 32),

            // Warning content with icons
            Column(
              children: warningMessages.map((msg) {
                final index = warningMessages.indexOf(msg);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          msg,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: DisciplinumColors.onSurfaceVariant,
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: (200 + index * 100).ms),
                );
              }).toList(),
            ),

            const SizedBox(height: 18),

            // Warning content container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: DisciplinumColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: DisciplinumColors.onSurfaceVariant,
                    height: 1.6,
                  ),
                  children: [
                    const TextSpan(
                        text: 'Para saber em detalhes como o app funciona, '),
                    TextSpan(
                      text: 'clique aqui',
                      style: TextStyle(
                        color: DisciplinumColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HowItWorksScreen(),
                            ),
                          );
                        },
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
