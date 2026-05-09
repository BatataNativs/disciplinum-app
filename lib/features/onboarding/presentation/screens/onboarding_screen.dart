import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/storage/objectbox_preferences_repository.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/app/router/app_router.dart';
import 'package:disciplinum/features/settings/presentation/screens/how_it_works_screen.dart';
import 'package:disciplinum/core/theme/app_theme.dart';
import 'package:disciplinum/core/di/providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  // Parâmetro opcional para saber se é modo de revisão (vindo das configurações)
  final bool isReviewMode;

  const OnboardingScreen({
    super.key,
    this.isReviewMode = false,
  });

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 3;

  Widget _buildListItem(String text, TextStyle? style) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: theme.brightness == Brightness.dark
                    ? [
                        colorScheme.primary.withValues(alpha: 0.3),
                        colorScheme.secondary.withValues(alpha: 0.15),
                      ]
                    : [
                        colorScheme.primary.withValues(alpha: 0.9),
                        colorScheme.primary.withValues(alpha: 0.6),
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary
                      .withValues(alpha: theme.brightness == Brightness.dark ? 0.3 : 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.check_circle_rounded,
              size: 16,
              color: theme.brightness == Brightness.dark 
                  ? colorScheme.primary.withValues(alpha: 0.8)
                  : colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: style?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedalLarge(String assetPath, String label) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 50,
          width: 50,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: theme.brightness == Brightness.dark
                  ? [
                      colorScheme.surface.withValues(alpha: 0.8),
                      colorScheme.surface.withValues(alpha: 0.9),
                    ]
                  : [
                      colorScheme.surface.withValues(alpha: 0.9),
                      colorScheme.surface.withValues(alpha: 0.7),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.brightness == Brightness.dark 
                    ? Colors.black.withValues(alpha: 0.15)
                    : Colors.blueGrey.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ],
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Image.asset(assetPath, fit: BoxFit.contain),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildMedal(String assetPath, String label) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 32,
          width: 32,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: theme.brightness == Brightness.dark
                  ? [
                      colorScheme.surface.withValues(alpha: 0.8),
                      colorScheme.surface.withValues(alpha: 0.9),
                    ]
                  : [
                      colorScheme.surface.withValues(alpha: 0.9),
                      colorScheme.surface.withValues(alpha: 0.7),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.brightness == Brightness.dark 
                    ? Colors.black.withValues(alpha: 0.15)
                    : Colors.blueGrey.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ],
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Image.asset(assetPath, fit: BoxFit.contain),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Future<void> _finishOnboarding() async {
    // Se for modo de revisão, apenas fecha a tela
    if (widget.isReviewMode) {
      if (mounted) Navigator.pop(context);
      return;
    }

    // Fluxo normal: salva preferência e navega
    final prefs =
        ObjectBoxPreferencesRepository(ObjectBoxService.instance.store);
    await prefs.setBool('seen_onboarding', true);

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, AppRouter.welcome);
  }

  Future<void> _handleSkipAction() async {
    // Se for modo de revisão, o botão "Pular" age como "Voltar"
    if (widget.isReviewMode) {
      if (mounted) Navigator.pop(context);
      return;
    }

    // Fluxo normal: Pergunta se quer pular
    await _confirmSkip();
  }

  Future<void> _confirmSkip() async {
    final theme = Theme.of(context);

    final shouldSkip = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: theme.brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(
          'Pular explicação?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.brightness == Brightness.dark ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
          ),
        ),
        content: RichText(
          text: TextSpan(
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.brightness == Brightness.dark ? const Color(0xFFB0B0B0) : const Color(0xFF424242),
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
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFFB0B0B0)
                      : const Color(0xFF424242),
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
              backgroundColor: const Color.fromARGB(
                  255, 0, 0, 0), // Altere esta cor conforme necessário
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

    // Definição dos textos baseados no modo
    final String skipButtonText = widget.isReviewMode ? 'Voltar' : 'Pular';
    final String finishButtonText =
        widget.isReviewMode ? 'Entendi' : 'Entrar no App';

    final currentTheme = ref.watch(themeControllerProvider);
    final isPinkTheme = currentTheme == AppTheme.pink;

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // --- FLORES DECORATIVAS NO PLANO DE FUNDO (tema rosa) ---
            if (isPinkTheme) ...[
              // == FLORES GRANDES (60-80) ==
              Positioned(
                top: 30,
                right: -20,
                child: Transform.rotate(
                  angle: 0.6,
                  child: Icon(
                    Icons.local_florist,
                    size: 82,
                    color: Colors.pink.withValues(alpha: 0.12),
                  ),
                ),
              ),
              Positioned(
                top: 200,
                left: -25,
                child: Transform.rotate(
                  angle: -0.4,
                  child: Icon(
                    Icons.filter_vintage,
                    size: 76,
                    color: Colors.pinkAccent.withValues(alpha: 0.10),
                  ),
                ),
              ),
              Positioned(
                bottom: 200,
                right: -15,
                child: Transform.rotate(
                  angle: 0.3,
                  child: Icon(
                    Icons.spa,
                    size: 84,
                    color: Colors.pink.withValues(alpha: 0.11),
                  ),
                ),
              ),
              // == FLORES MÉDIAS (30-45) ==
              Positioned(
                top: 80,
                left: 50,
                child: Transform.rotate(
                  angle: -0.2,
                  child: Icon(
                    Icons.eco,
                    size: 46,
                    color: Colors.pinkAccent.withValues(alpha: 0.16),
                  ),
                ),
              ),
              Positioned(
                top: 180,
                right: 60,
                child: Transform.rotate(
                  angle: 0.7,
                  child: Icon(
                    Icons.local_florist,
                    size: 42,
                    color: Colors.pink.withValues(alpha: 0.18),
                  ),
                ),
              ),
              Positioned(
                bottom: 350,
                left: 30,
                child: Transform.rotate(
                  angle: -0.6,
                  child: Icon(
                    Icons.spa,
                    size: 40,
                    color: Colors.pinkAccent.withValues(alpha: 0.14),
                  ),
                ),
              ),
              Positioned(
                bottom: 280,
                right: 50,
                child: Transform.rotate(
                  angle: 0.5,
                  child: Icon(
                    Icons.filter_vintage,
                    size: 44,
                    color: Colors.pink.withValues(alpha: 0.13),
                  ),
                ),
              ),
              // == FLORES PEQUENAS (15-28) ==
              Positioned(
                top: 140,
                left: 20,
                child: Transform.rotate(
                  angle: -0.3,
                  child: Icon(
                    Icons.local_florist,
                    size: 28,
                    color: Colors.pink.withValues(alpha: 0.22),
                  ),
                ),
              ),
              Positioned(
                top: 250,
                right: 30,
                child: Transform.rotate(
                  angle: 0.4,
                  child: Icon(
                    Icons.spa,
                    size: 24,
                    color: Colors.pinkAccent.withValues(alpha: 0.18),
                  ),
                ),
              ),
              Positioned(
                top: 400,
                left: 60,
                child: Transform.rotate(
                  angle: 0.8,
                  child: Icon(
                    Icons.filter_vintage,
                    size: 22,
                    color: Colors.pink.withValues(alpha: 0.14),
                  ),
                ),
              ),
              Positioned(
                bottom: 150,
                left: 80,
                child: Transform.rotate(
                  angle: -0.5,
                  child: Icon(
                    Icons.eco,
                    size: 20,
                    color: Colors.pinkAccent.withValues(alpha: 0.15),
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                right: 70,
                child: Transform.rotate(
                  angle: 0.6,
                  child: Icon(
                    Icons.local_florist,
                    size: 26,
                    color: Colors.pink.withValues(alpha: 0.17),
                  ),
                ),
              ),
            ],
            // --- CONTEÚDO PRINCIPAL ---
            Column(
              children: [
            // Cards deslizantes
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _totalPages,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: index == 2
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (index == 2) const SizedBox(height: 80),
                        if (index == 0) const Spacer(flex: 1),

                        // --- ÁREA DO ASSET (Expandida) ---
                        Builder(builder: (context) {
                          if (index == 2) {
                            // Última tela - Container simples
                            return Container(
                              height: 160,
                              alignment: Alignment.topCenter,
                              child: Image.asset(
                                'assets/opening/warning1.png',
                                height: 140,
                                width: 140,
                                fit: BoxFit.contain,
                              ),
                            );
                          } else {
                            // Páginas 0 e 1 - Expanded normal
                            return Expanded(
                              flex: 8,
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Builder(builder: (context) {
                                  if (index == 0) {
                                    return Image.asset(
                                      'assets/opening/disciplinado.png',
                                      height: 380,
                                      width: 380,
                                      fit: BoxFit.contain,
                                    );
                                  } else {
                                    return Center(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // Título movido para cima do container
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: Theme.of(context).brightness == Brightness.dark
                                                      ? [
                                                          const Color(
                                                                  0xFF6366F1)
                                                              .withValues(
                                                                  alpha: 0.1),
                                                          const Color(
                                                                  0xFF8B5CF6)
                                                              .withValues(
                                                                  alpha: 0.05),
                                                          Colors.transparent,
                                                        ]
                                                      : [
                                                          const Color(
                                                                  0xFFDBEAFE)
                                                              .withValues(
                                                                  alpha: 0.6),
                                                          const Color(
                                                                  0xFFF0F9FF)
                                                              .withValues(
                                                                  alpha: 0.3),
                                                          Colors.transparent,
                                                        ],
                                                ),
                                              ),
                                              child: Text(
                                                'Gamificação pra incentivar seu progresso',
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineMedium
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 24,
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? const Color(0xFFFFFFFF)
                                                      : const Color(0xFF1F2937),
                                                  letterSpacing: -0.8,
                                                  height: 1.2,
                                                  shadows: [
                                                    Shadow(
                                                      color: (Theme.of(context).brightness == Brightness.dark
                                                              ? const Color(
                                                                  0xFF6366F1)
                                                              : const Color(
                                                                  0xFF3B82F6))
                                                          .withValues(
                                                              alpha: Theme.of(context).brightness == Brightness.dark
                                                                  ? 0.4
                                                                  : 0.25),
                                                      offset:
                                                          const Offset(0, 2),
                                                      blurRadius: 8,
                                                    ),
                                                    Shadow(
                                                      color: (Theme.of(context).brightness == Brightness.dark
                                                              ? const Color(
                                                                  0xFF6366F1)
                                                              : const Color(
                                                                  0xFF60A5FA))
                                                          .withValues(
                                                              alpha: Theme.of(context).brightness == Brightness.dark
                                                                  ? 0.2
                                                                  : 0.15),
                                                      offset:
                                                          const Offset(0, 4),
                                                      blurRadius: 16,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: Theme.of(context).brightness == Brightness.dark
                                                      ? [
                                                          const Color(
                                                                  0xFF1E293B)
                                                              .withValues(
                                                                  alpha: 0.8),
                                                          const Color(
                                                                  0xFF0F172A)
                                                              .withValues(
                                                                  alpha: 0.9),
                                                        ]
                                                      : [
                                                          const Color(
                                                              0xFFFFFFFF),
                                                          const Color(
                                                              0xFFF8FAFC),
                                                        ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: (Theme.of(context).brightness == Brightness.dark
                                                            ? Colors.black
                                                            : const Color(
                                                                0xFF64748B))
                                                        .withValues(
                                                            alpha: Theme.of(context).brightness == Brightness.dark
                                                                ? 0.4
                                                                : 0.12),
                                                    blurRadius: 20,
                                                    offset: const Offset(0, 6),
                                                    spreadRadius: 2,
                                                  ),
                                                  BoxShadow(
                                                    color: (Theme.of(context).brightness == Brightness.dark
                                                            ? const Color(
                                                                0xFF6366F1)
                                                            : const Color(
                                                                0xFF3B82F6))
                                                        .withValues(
                                                            alpha: Theme.of(context).brightness == Brightness.dark
                                                                ? 0.1
                                                                : 0.06),
                                                    blurRadius: 30,
                                                    offset: const Offset(0, 4),
                                                    spreadRadius: -4,
                                                  ),
                                                ],
                                                border: Border.all(
                                                  color: (Theme.of(context).brightness == Brightness.dark
                                                          ? const Color(
                                                              0xFF334155)
                                                          : const Color(
                                                              0xFFE2E8F0))
                                                      .withValues(
                                                          alpha: Theme.of(context).brightness == Brightness.dark
                                                              ? 0.5
                                                              : 0.8),
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  // Badge Medalhas
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12,
                                                        vertical: 6),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: Theme.of(context).brightness == Brightness.dark
                                                            ? [
                                                                const Color(
                                                                        0xFFF59E0B)
                                                                    .withValues(
                                                                        alpha:
                                                                            0.2),
                                                                const Color(
                                                                        0xFFD97706)
                                                                    .withValues(
                                                                        alpha:
                                                                            0.1),
                                                              ]
                                                            : [
                                                                const Color(
                                                                        0xFFFEF3C7)
                                                                    .withValues(
                                                                        alpha:
                                                                            0.8),
                                                                const Color(
                                                                        0xFFFDE68A)
                                                                    .withValues(
                                                                        alpha:
                                                                            0.5),
                                                              ],
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                      border: Border.all(
                                                        color: (Theme.of(context).brightness == Brightness.dark
                                                                ? const Color(
                                                                    0xFFF59E0B)
                                                                : const Color(
                                                                    0xFFD97706))
                                                            .withValues(
                                                                alpha: Theme.of(context).brightness == Brightness.dark
                                                                    ? 0.4
                                                                    : 0.3),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      'Medalhas',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xFFD97706),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Wrap(
                                                    spacing: 12,
                                                    runSpacing: 6,
                                                    alignment:
                                                        WrapAlignment.center,
                                                    children: [
                                                      _buildMedalLarge(
                                                          'assets/gamification/medals/smoking/bronze.png',
                                                          'Bronze'),
                                                      _buildMedalLarge(
                                                          'assets/gamification/medals/smoking/silver.png',
                                                          'Prata'),
                                                      _buildMedalLarge(
                                                          'assets/gamification/medals/smoking/gold.png',
                                                          'Ouro'),
                                                      _buildMedalLarge(
                                                          'assets/gamification/medals/smoking/diamond.png',
                                                          'Diamante'),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 12),
                                                  // Badge Insígnias
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12,
                                                        vertical: 6),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: Theme.of(context).brightness == Brightness.dark
                                                            ? [
                                                                const Color(
                                                                        0xFF6366F1)
                                                                    .withValues(
                                                                        alpha:
                                                                            0.2),
                                                                const Color(
                                                                        0xFF8B5CF6)
                                                                    .withValues(
                                                                        alpha:
                                                                            0.1),
                                                              ]
                                                            : [
                                                                const Color(
                                                                        0xFFDBEAFE)
                                                                    .withValues(
                                                                        alpha:
                                                                            0.8),
                                                                const Color(
                                                                        0xFFF0F9FF)
                                                                    .withValues(
                                                                        alpha:
                                                                            0.5),
                                                              ],
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                      border: Border.all(
                                                        color: (Theme.of(context).brightness == Brightness.dark
                                                                ? const Color(
                                                                    0xFF6366F1)
                                                                : const Color(
                                                                    0xFF3B82F6))
                                                            .withValues(
                                                                alpha: Theme.of(context).brightness == Brightness.dark
                                                                    ? 0.4
                                                                    : 0.3),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      'Insígnias',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xFF6366F1),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  // Primeira fileira: 8 insígnias
                                                  Wrap(
                                                    spacing: 6,
                                                    runSpacing: 6,
                                                    alignment:
                                                        WrapAlignment.center,
                                                    children: [
                                                      _buildMedal(
                                                          'assets/gamification/insignias/smoking/madeira.png',
                                                          'Madeira'),
                                                      _buildMedal(
                                                          'assets/gamification/insignias/smoking/ferro.png',
                                                          'Ferro'),
                                                      _buildMedal(
                                                          'assets/gamification/insignias/smoking/aluminio.png',
                                                          'Alumínio'),
                                                      _buildMedal(
                                                          'assets/gamification/insignias/smoking/bronze.png',
                                                          'Bronze'),
                                                      _buildMedal(
                                                          'assets/gamification/insignias/smoking/latao.png',
                                                          'Latão'),
                                                      _buildMedal(
                                                          'assets/gamification/insignias/smoking/prata.png',
                                                          'Prata'),
                                                      _buildMedal(
                                                          'assets/gamification/insignias/smoking/ouro.png',
                                                          'Ouro'),
                                                      _buildMedal(
                                                          'assets/gamification/insignias/smoking/diamante.png',
                                                          'Diamante'),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  // Disciplinum sozinha embaixo com destaque
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: Theme.of(context).brightness == Brightness.dark
                                                            ? [
                                                                const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        208,
                                                                        244,
                                                                        252)
                                                                    .withValues(
                                                                        alpha:
                                                                            0.15),
                                                                const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        255,
                                                                        255,
                                                                        255)
                                                                    .withValues(
                                                                        alpha:
                                                                            0.08),
                                                              ]
                                                            : [
                                                                const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        208,
                                                                        244,
                                                                        252)
                                                                    .withValues(
                                                                        alpha:
                                                                            0.15),
                                                                const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        255,
                                                                        255,
                                                                        255)
                                                                    .withValues(
                                                                        alpha:
                                                                            0.08),
                                                              ],
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                        color: (Theme.of(context).brightness == Brightness.dark
                                                                ? const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    16,
                                                                    143,
                                                                    185)
                                                                : const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    16,
                                                                    131,
                                                                    185))
                                                            .withValues(
                                                                alpha: Theme.of(context).brightness == Brightness.dark
                                                                    ? 0.4
                                                                    : 0.3),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: _buildMedal(
                                                        'assets/gamification/insignias/smoking/disciplinum.png',
                                                        'Disciplinum'),
                                                  ), // Container
                                                ], // Column children
                                              ), // Column
                                            ), // Container
                                          ], // Column children
                                        ), // Column
                                      ), // SingleChildScrollView
                                    ); // Center
                                  }
                                }),
                              ),
                            );
                          }
                        }),

                        const SizedBox(height: 12),

                        // --- ÁREA DO TÍTULO ---
                        Align(
                          alignment: Alignment.center,
                          child: Builder(builder: (context) {
                            String pageTitle = '';
                            if (index == 0) {
                              pageTitle = 'Disciplina, foco e bons hábitos';
                            } else if (index == 1) {
                              pageTitle =
                                  'Gamificação pra incentivar seu progresso';
                            } else {
                              pageTitle = 'Atenção!';
                            }

                            // Não mostrar título na área do título para página 1 (ele será mostrado na área do asset)
                            if (index == 1) {
                              return const SizedBox.shrink();
                            }

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: Theme.of(context).brightness == Brightness.dark
                                      ? [
                                          const Color(0xFF6366F1)
                                              .withValues(alpha: 0.1),
                                          const Color(0xFF8B5CF6)
                                              .withValues(alpha: 0.05),
                                          Colors.transparent,
                                        ]
                                      : [
                                          const Color(0xFFDBEAFE)
                                              .withValues(alpha: 0.6),
                                          const Color(0xFFF0F9FF)
                                              .withValues(alpha: 0.3),
                                          Colors.transparent,
                                        ],
                                ),
                              ),
                              child: Text(
                                pageTitle,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 24,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFFFFFFFF)
                                      : const Color(0xFF1F2937),
                                  letterSpacing: -0.8,
                                  height: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: (Theme.of(context).brightness == Brightness.dark
                                              ? const Color(0xFF6366F1)
                                              : const Color(0xFF3B82F6))
                                          .withValues(
                                              alpha: Theme.of(context).brightness == Brightness.dark ? 0.4 : 0.25),
                                      offset: const Offset(0, 2),
                                      blurRadius: 8,
                                    ),
                                    Shadow(
                                      color: (Theme.of(context).brightness == Brightness.dark
                                              ? const Color(0xFF6366F1)
                                              : const Color(0xFF60A5FA))
                                          .withValues(
                                              alpha: Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.15),
                                      offset: const Offset(0, 4),
                                      blurRadius: 16,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 4),

                        // --- ÁREA DA DESCRIÇÃO ---
                        Align(
                          alignment: Alignment.topCenter,
                          child: Builder(builder: (context) {
                            final bodyStyle =
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? const Color(0xFF94A3B8)
                                              .withValues(alpha: 0.9)
                                          : const Color(0xFF4B5563)
                                              .withValues(alpha: 0.85),
                                      height: 1.4,
                                      fontSize: 15,
                                      letterSpacing: 0.1,
                                    );

                            if (index == 0) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Transforme seus hábitos diários\ne seja mais disciplinado!',
                                    textAlign: TextAlign.left,
                                    style: bodyStyle?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? const Color(0xFFE2E8F0)
                                          : const Color(0xFF374151),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: Theme.of(context).brightness == Brightness.dark
                                            ? [
                                                const Color.fromARGB(255, 155, 37, 37)
                                                    .withValues(alpha: 0.15),
                                                const Color(0xFF8B5CF6)
                                                    .withValues(alpha: 0.08),
                                              ]
                                            : [
                                                const Color(0xFFDBEAFE)
                                                    .withValues(alpha: 0.8),
                                                const Color(0xFFF0F9FF)
                                                    .withValues(alpha: 0.5),
                                              ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: (Theme.of(context).brightness == Brightness.dark
                                                ? const Color(0xFF6366F1)
                                                : const Color(0xFF3B82F6))
                                            .withValues(
                                                alpha: Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      'Este app pode te ajudar a:',
                                      textAlign: TextAlign.center,
                                      style: bodyStyle?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: Theme.of(context).brightness == Brightness.dark
                                            ? const Color(0xFF818CF8)
                                            : const Color(0xFF1D4ED8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // Bloco de itens com alinhamento à esquerda, mas centralizado no eixo X
                                  IntrinsicWidth(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildListItem(
                                            'Evitar compras impulsivas',
                                            bodyStyle),
                                        _buildListItem(
                                            'Juntar dinheiro', bodyStyle),
                                        _buildListItem(
                                            'Focar em tarefas produtivas',
                                            bodyStyle),
                                        _buildListItem(
                                            'Parar de fumar', bodyStyle),
                                        _buildListItem('Jejum 18+', bodyStyle),
                                        _buildListItem('Jejum Digital', bodyStyle),
                                        _buildListItem(
                                            'Evitar procrastinação', bodyStyle),
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: Theme.of(context).brightness == Brightness.dark
                                                  ? [
                                                      const Color(0xFF10B981)
                                                          .withValues(
                                                              alpha: 0.15),
                                                      const Color(0xFF34D399)
                                                          .withValues(
                                                              alpha: 0.08),
                                                    ]
                                                  : [
                                                      const Color(0xFFD1FAE5)
                                                          .withValues(
                                                              alpha: 0.8),
                                                      const Color(0xFFECFDF5)
                                                          .withValues(
                                                              alpha: 0.5),
                                                    ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: (Theme.of(context).brightness == Brightness.dark
                                                      ? const Color(0xFF10B981)
                                                      : const Color(0xFF10B981))
                                                  .withValues(
                                                      alpha:
                                                          Theme.of(context).brightness == Brightness.dark ? 0.4 : 0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'E muito mais!',
                                                  textAlign: TextAlign.center,
                                                  style: bodyStyle?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 14,
                                                    color: Theme.of(context).brightness == Brightness.dark
                                                        ? const Color(0xFF34D399)
                                                        : const Color(0xFF047857),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            } else if (index == 1) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 2),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: Theme.of(context).brightness == Brightness.dark
                                            ? [
                                                const Color(0xFFF59E0B)
                                                    .withValues(alpha: 0.15),
                                                const Color(0xFFD97706)
                                                    .withValues(alpha: 0.08),
                                              ]
                                            : [
                                                const Color(0xFFFEF3C7)
                                                    .withValues(alpha: 0.6),
                                                const Color(0xFFFDE68A)
                                                    .withValues(alpha: 0.3),
                                              ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: (Theme.of(context).brightness == Brightness.dark
                                                ? const Color(0xFFF59E0B)
                                                : const Color(0xFFD97706))
                                            .withValues(
                                                alpha: Theme.of(context).brightness == Brightness.dark ? 0.4 : 0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.warning_rounded,
                                            color: Colors.amber, size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Recompensas Fictícias*',
                                          style: bodyStyle?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  IntrinsicWidth(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildListItem(
                                            'Conquiste medalhas, insígnias e troféus',
                                            bodyStyle),
                                        _buildListItem(
                                            'Motive-se visualmente', bodyStyle),
                                        _buildListItem('Acompanhe sua evolução',
                                            bodyStyle),
                                        _buildListItem(
                                            'Mantenha sua disciplina viva e constante!',
                                            bodyStyle),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              // Página 2: Atenção
                              return RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: bodyStyle,
                                  children: [
                                    const TextSpan(
                                      text:
                                          'Este app é uma ferramenta de apoio à disciplina e aos bons hábitos.\n\nEle não substitui (e nem tem a intenção de substituir) o acompanhamento de um profissional de saúde ou terapeuta, na sua busca por tratamento real e homologado.\n\n',
                                    ),
                                    const TextSpan(
                                      text:
                                          'Use-o com responsabilidade e sabedoria, como uma ferramente de controle, incentivo e motivação.\n\n',
                                    ),
                                    const TextSpan(
                                      text:
                                          'Para saber em detalhes\ncomo o app funciona, ',
                                    ),
                                    TextSpan(
                                      text: 'clique aqui',
                                      style: const TextStyle(
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.blueAccent,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const HowItWorksScreen()),
                                          );
                                        },
                                    ),
                                    const TextSpan(text: '.'),
                                  ],
                                ),
                              );
                            }
                          }),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Indicadores de Página (Dots)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _totalPages,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: _currentPage == index ? 36 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? (Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF6366F1)
                            : const Color.fromARGB(255, 23, 23, 23))
                        : (Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF6366F1).withValues(alpha: 0.25)
                            : const Color.fromARGB(255, 36, 36, 36)
                                .withValues(alpha: 0.25)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Botões de Navegação
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
              child: Row(
                children: [
                  // Botão Pular / Voltar
                  if (!isLastPage || widget.isReviewMode)
                    Expanded(
                      child: TextButton(
                        onPressed: _handleSkipAction,
                        style: TextButton.styleFrom(
                          foregroundColor: (Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFFFFFFFF)
                                  : const Color(0xFF1F2937))
                              .withValues(alpha: 0.8),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          skipButtonText,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                      ),
                    )
                  else
                    const Spacer(),

                  const SizedBox(width: 20),

                  // Botão Principal (Próximo / Entrar)
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: (Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF6366F1)
                                    : const Color.fromARGB(255, 16, 16, 17))
                                .withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: FilledButton(
                        onPressed: () {
                          if (isLastPage) {
                            _finishOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.fastOutSlowIn,
                            );
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF6366F1)
                              : const Color.fromARGB(255, 32, 32, 32),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isLastPage ? finishButtonText : 'Próximo',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (!isLastPage) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 20),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  ),
);
  }
}
