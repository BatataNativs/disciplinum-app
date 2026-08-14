import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:disciplinum/core/storage/objectbox_preferences_repository.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/app/router/app_router.dart';
import 'package:disciplinum/features/settings/presentation/screens/how_it_works_screen.dart';

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
  final double size;
  final Color borderColor;

  const DisciplineMedal({
    super.key,
    required this.assetPath,
    required this.label,
    this.size = 40,
    this.borderColor = DisciplinumColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size + 12,
          height: size + 12,
          padding: EdgeInsets.all(size * 0.15),
          decoration: BoxDecoration(
            color: DisciplinumColors.glassMedium,
            borderRadius: BorderRadius.circular(size * 0.3),
            border:
                Border.all(color: borderColor.withValues(alpha: 0.3), width: 1),
          ),
          child: Image.asset(assetPath, fit: BoxFit.contain),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: DisciplinumColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class DisciplineInsignia extends StatelessWidget {
  final String assetPath;
  final String label;
  final double size;
  final Color borderColor;

  const DisciplineInsignia({
    super.key,
    required this.assetPath,
    required this.label,
    this.size = 32,
    this.borderColor = DisciplinumColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size + 8,
          height: size + 8,
          padding: EdgeInsets.all(size * 0.12),
          decoration: BoxDecoration(
            color: DisciplinumColors.glassMedium,
            borderRadius: BorderRadius.circular(size * 0.25),
            border: Border.all(
                color: borderColor.withValues(alpha: 0.3), width: 0.8),
          ),
          child: Image.asset(assetPath, fit: BoxFit.contain),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: DisciplinumColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
            fontSize: 10,
          ),
        ),
      ],
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

class DashboardStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;

  const DashboardStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.iconColor = DisciplinumColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DisciplinumColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: DisciplinumColors.onBackground,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: DisciplinumColors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: DisciplinumColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Exemplo',
                  style: TextStyle(
                    color: DisciplinumColors.primary,
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AppCategoryIcon extends StatelessWidget {
  final dynamic icon;
  final String label;
  final bool isSelected;

  const AppCategoryIcon({
    super.key,
    required this.icon,
    required this.label,
    this.isSelected = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isSelected
                ? DisciplinumColors.detoxPrimary.withValues(alpha: 0.15)
                : DisciplinumColors.glassMedium,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? DisciplinumColors.detoxPrimary
                  : DisciplinumColors.glassBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: FaIcon(icon,
                size: 22,
                color: isSelected
                    ? DisciplinumColors.detoxPrimary
                    : Colors.white.withValues(alpha: 0.7)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: DisciplinumColors.onSurfaceVariant,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
          decoration: BoxDecoration(
            color: DisciplinumColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            'Exemplo',
            style: TextStyle(
              color: DisciplinumColors.primary,
              fontSize: 7,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class BlockScreenMockup extends StatelessWidget {
  const BlockScreenMockup({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DisciplinumColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DisciplinumColors.detoxPrimary.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color:
                  const Color.fromARGB(255, 239, 27, 27).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.block,
              size: 28,
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'App não liberado',
            style: TextStyle(
              color: DisciplinumColors.onBackground,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Seu jejum digital está ativo',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: DisciplinumColors.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '2h 30m restantes',
              style: TextStyle(
                color: const Color.fromARGB(255, 234, 232, 238),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
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
    final prefs =
        ObjectBoxPreferencesRepository(ObjectBoxService.instance.store);
    await prefs.setBool('seen_onboarding', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRouter.welcome);
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
        return _buildModuleExamplePage();
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

  Widget _buildModuleExamplePage() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Title
              PremiumGlassCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                borderRadius: 12,
                borderColor: const Color.fromARGB(255, 92, 218, 246),
                child: Text(
                  'Exemplo de funcionamento de um dos módulos',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 228, 226, 233),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1),

              const SizedBox(height: 16),

              // Warning badge
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 46, 139, 193)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color.fromARGB(255, 220, 214, 233),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: DisciplinumColors.detoxPrimary,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Módulo Jejum Digital (Bloqueio de Apps)',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 179, 174, 191),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Block screen mockup
                      const BlockScreenMockup()
                          .animate()
                          .fadeIn(duration: 2500.ms, delay: 500.ms),

                      const SizedBox(height: 16),

                      Text(
                        'Quando você tentar abrir um app bloqueado, uma tela aparecerá\nlembrando-o do seu compromisso com a disciplina.\n\n'
                        'Os módulos possuem indicadores de funcionamento, pra você acompanhar tudo. Como no exemplo abaixo:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: DisciplinumColors.onSurfaceVariant,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

                      const SizedBox(height: 16),

                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: DashboardStatCard(
                              value: '5',
                              label: 'Apps',
                              icon: Icons.apps_rounded,
                              iconColor: DisciplinumColors.detoxPrimary,
                            ).animate().fadeIn(duration: 500.ms, delay: 500.ms),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DashboardStatCard(
                              value: 'Ativo',
                              label: 'Status',
                              icon: Icons.check_circle_rounded,
                              iconColor: DisciplinumColors.primary,
                            ).animate().fadeIn(duration: 500.ms, delay: 600.ms),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DashboardStatCard(
                              value: '27',
                              label: 'Dias',
                              icon: Icons.calendar_today_rounded,
                              iconColor: DisciplinumColors.detoxSecondary,
                            ).animate().fadeIn(duration: 500.ms, delay: 700.ms),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Monitored apps section
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
                          const SizedBox(width: 12),
                          Text(
                            'Apps monitorados (exemplos)',
                            style: TextStyle(
                              color: DisciplinumColors.onBackground,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms, delay: 800.ms),

                      const SizedBox(height: 12),

                      // Apps grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 4,
                        childAspectRatio: 0.65,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        children: [
                          AppCategoryIcon(
                              icon: FontAwesomeIcons.instagram,
                              label: 'Instagram',
                              isSelected: true),
                          AppCategoryIcon(
                              icon: FontAwesomeIcons.facebook,
                              label: 'Facebook',
                              isSelected: true),
                          AppCategoryIcon(
                              icon: FontAwesomeIcons.reddit,
                              label: 'Reddit',
                              isSelected: true),
                          AppCategoryIcon(
                              icon: FontAwesomeIcons.robot,
                              label: 'ChatGPT',
                              isSelected: true),
                        ],
                      ).animate().fadeIn(duration: 600.ms, delay: 900.ms),

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
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

                const SizedBox(height: 16),

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
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                const SizedBox(height: 20),

                // Insignias section
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
                    const SizedBox(width: 12),
                    Text(
                      'Insígnias',
                      style: TextStyle(
                        color: DisciplinumColors.onBackground,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

                const SizedBox(height: 12),

                // Insignias Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  childAspectRatio: 0.75,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  children: [
                    DisciplineInsignia(
                      assetPath:
                          'assets/gamification/insignias/smoking/madeira.png',
                      label: 'Madeira',
                      borderColor: DisciplinumColors.primary,
                    ).animate().fadeIn(duration: 500.ms, delay: 400.ms),
                    DisciplineInsignia(
                      assetPath:
                          'assets/gamification/insignias/smoking/ferro.png',
                      label: 'Ferro',
                      borderColor: DisciplinumColors.primary,
                    ).animate().fadeIn(duration: 500.ms, delay: 500.ms),
                    DisciplineInsignia(
                      assetPath:
                          'assets/gamification/insignias/smoking/aluminio.png',
                      label: 'Alumínio',
                      borderColor: DisciplinumColors.primary,
                    ).animate().fadeIn(duration: 500.ms, delay: 600.ms),
                    DisciplineInsignia(
                      assetPath:
                          'assets/gamification/insignias/smoking/bronze.png',
                      label: 'Bronze',
                      borderColor: DisciplinumColors.primary,
                    ).animate().fadeIn(duration: 500.ms, delay: 700.ms),
                    DisciplineInsignia(
                      assetPath:
                          'assets/gamification/insignias/smoking/latao.png',
                      label: 'Latão',
                      borderColor: DisciplinumColors.primary,
                    ).animate().fadeIn(duration: 500.ms, delay: 800.ms),
                    DisciplineInsignia(
                      assetPath:
                          'assets/gamification/insignias/smoking/prata.png',
                      label: 'Prata',
                      borderColor: DisciplinumColors.primary,
                    ).animate().fadeIn(duration: 500.ms, delay: 900.ms),
                    DisciplineInsignia(
                      assetPath:
                          'assets/gamification/insignias/smoking/ouro.png',
                      label: 'Ouro',
                      borderColor: DisciplinumColors.primary,
                    ).animate().fadeIn(duration: 500.ms, delay: 1000.ms),
                    DisciplineInsignia(
                      assetPath:
                          'assets/gamification/insignias/smoking/diamante.png',
                      label: 'Diamante',
                      borderColor: DisciplinumColors.primary,
                    ).animate().fadeIn(duration: 500.ms, delay: 1100.ms),
                  ],
                ),

                const SizedBox(height: 1),

                // Disciplinum insignia
                Center(
                  child: PremiumGlassCard(
                    padding: const EdgeInsets.all(16),
                    borderRadius: 18,
                    borderColor: DisciplinumColors.primary,
                    child: DisciplineMedal(
                      assetPath:
                          'assets/gamification/insignias/smoking/disciplinum.png',
                      label: 'Disciplinum',
                      size: 44,
                      borderColor: DisciplinumColors.primary,
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1.05, 1.05),
                        duration: 600.ms,
                        curve: Curves.easeInOut,
                      ),
                ),

                const SizedBox(height: 20),

                // Medals section
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
                    const SizedBox(width: 12),
                    Text(
                      'Medalhas',
                      style: TextStyle(
                        color: DisciplinumColors.onBackground,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms, delay: 1200.ms),

                const SizedBox(height: 12),

                // Medals Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  children: [
                    DisciplineMedal(
                      assetPath:
                          'assets/gamification/medals/smoking/bronze.png',
                      label: 'Bronze',
                      borderColor: DisciplinumColors.detoxPrimary,
                      size: 40,
                    ).animate().fadeIn(duration: 500.ms, delay: 1300.ms),
                    DisciplineMedal(
                      assetPath:
                          'assets/gamification/medals/smoking/silver.png',
                      label: 'Prata',
                      borderColor: DisciplinumColors.detoxSecondary,
                      size: 40,
                    ).animate().fadeIn(duration: 500.ms, delay: 1400.ms),
                    DisciplineMedal(
                      assetPath: 'assets/gamification/medals/smoking/gold.png',
                      label: 'Ouro',
                      borderColor: DisciplinumColors.primary,
                      size: 40,
                    ).animate().fadeIn(duration: 500.ms, delay: 1500.ms),
                    DisciplineMedal(
                      assetPath:
                          'assets/gamification/medals/smoking/diamond.png',
                      label: 'Diamante',
                      borderColor: DisciplinumColors.primary,
                      size: 40,
                    ).animate().fadeIn(duration: 500.ms, delay: 1600.ms),
                  ],
                ),

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
