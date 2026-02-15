import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:disciplinum/app_router.dart';

import 'package:flutter/gestures.dart';
import '../settings/how_it_works_screen.dart';

class OnboardingScreen extends StatefulWidget {
  // Parâmetro opcional para saber se é modo de revisão (vindo das configurações)
  final bool isReviewMode;

  const OnboardingScreen({
    super.key,
    this.isReviewMode = false,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 3;

  Widget _buildMedal(String assetPath, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Simpler shadow or none for clean look
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                spreadRadius: 1,
              )
            ],
          ),
          child: Image.asset(assetPath, fit: BoxFit.contain),
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
    final prefs = await SharedPreferences.getInstance();
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
    final isDark = theme.brightness == Brightness.dark;

    final shouldSkip = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(
          'Pular explicação?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
          ),
        ),
        content: RichText(
          text: TextSpan(
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF424242),
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
                  color: isDark
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
    final isDark = theme.brightness == Brightness.dark;
    final isLastPage = _currentPage == _totalPages - 1;

    // Definição dos textos baseados no modo
    final String skipButtonText = widget.isReviewMode ? 'Voltar' : 'Pular';
    final String finishButtonText =
        widget.isReviewMode ? 'Entendi' : 'Entrar no App';

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
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
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(flex: 1),
                        // --- ÁREA DO ASSET (Expandida) ---
                        Expanded(
                          flex: 7,
                          child: Center(
                            child: Builder(builder: (context) {
                              if (index == 0) {
                                return UnconstrainedBox(
                                  child: Image.asset(
                                    'assets/disciplinado.png',
                                    height: 200,
                                    width: 200,
                                    fit: BoxFit.contain,
                                  ),
                                );
                              } else if (index == 1) {
                                return Center(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        _buildMedal('assets/medal_bronze.png',
                                            'Bronze'),
                                        const SizedBox(width: 16),
                                        _buildMedal(
                                            'assets/medal_silver.png', 'Prata'),
                                        const SizedBox(width: 16),
                                        _buildMedal(
                                            'assets/medal_gold.png', 'Ouro'),
                                        const SizedBox(width: 16),
                                        _buildMedal('assets/medal_diamond.png',
                                            'Diamante'),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                return Image.asset(
                                  'assets/warning1.png',
                                  height: 250,
                                  width: 250,
                                  fit: BoxFit.contain,
                                );
                              }
                            }),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // --- ÁREA DO TÍTULO ---
                        Align(
                          alignment: Alignment.center,
                          child: Builder(builder: (context) {
                            String pageTitle = '';
                            if (index == 0) {
                              pageTitle = 'Disciplina e Foco';
                            } else if (index == 1) {
                              pageTitle =
                                  'Gamificação de incentivo ao seu progresso';
                            } else {
                              pageTitle = 'Atenção!';
                            }

                            return Text(
                              pageTitle,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 28,
                                color: isDark
                                    ? const Color(0xFFFFFFFF)
                                    : const Color(0xFF1F2937),
                                letterSpacing: -0.5,
                                height: 1.1,
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 16),

                        // --- ÁREA DA DESCRIÇÃO ---
                        Align(
                          alignment: Alignment.topCenter,
                          child: Builder(builder: (context) {
                            final bodyStyle =
                                theme.textTheme.bodyLarge?.copyWith(
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF4B5563),
                              height: 1.5,
                              fontSize: 16,
                            );

                            if (index == 0) {
                              return RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: bodyStyle,
                                  text:
                                      'Transforme seus hábitos diários e seja mais disciplinado!\n\n'
                                      'Este app pode te ajudar a:\n'
                                      '• Evitar compras impulsivas\n'
                                      '• Manter o foco em atividades\n'
                                      '• Parar de fumar\n'
                                      '• Evitar conteúdo adulto\n'
                                      '• Evitar procrastinação\n'
                                      '• E muito mais!',
                                ),
                              );
                            } else if (index == 1) {
                              return RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: bodyStyle,
                                  children: [
                                    const TextSpan(
                                      text:
                                          'Conquiste medalhas, insígnias e troféus ',
                                    ),
                                    const TextSpan(
                                      text: '(FICTÍCIOS)',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(
                                      text:
                                          ' ao atingir metas e marcos de progresso. Uma forma lúdica de se motivar e evoluir.',
                                    ),
                                  ],
                                ),
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
                                          'Este app é uma ferramenta de apoio à disciplina, não substitui acompanhamento profissional.\n\n'
                                          'E, caso queira saber um pouco mais sobre como funciona antes de continuar,\nclique ',
                                    ),
                                    TextSpan(
                                      text: 'aqui',
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
                        const Spacer(flex: 2),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Indicadores de Página (Dots)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _totalPages,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 32 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? (isDark
                            ? const Color(0xFF6366F1)
                            : const Color.fromARGB(255, 23, 23, 23))
                        : (isDark
                            ? const Color(0xFF6366F1).withValues(alpha: 0.2)
                            : const Color.fromARGB(255, 36, 36, 36)
                                .withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Botões de Navegação
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Row(
                children: [
                  // Botão Pular / Voltar
                  if (!isLastPage || widget.isReviewMode)
                    Expanded(
                      child: TextButton(
                        onPressed: _handleSkipAction,
                        style: TextButton.styleFrom(
                          foregroundColor: (isDark
                                  ? const Color(0xFFFFFFFF)
                                  : const Color(0xFF1F2937))
                              .withValues(alpha: 0.7),
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

                  const SizedBox(width: 16),

                  // Botão Principal (Próximo / Entrar)
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (isDark
                                    ? const Color(0xFF6366F1)
                                    : const Color.fromARGB(255, 16, 16, 17))
                                .withValues(alpha: 0.3), // Sombra suavizada
                            blurRadius: 12,
                            offset: const Offset(0, 4),
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
                          backgroundColor: isDark
                              ? const Color(0xFF6366F1)
                              : const Color.fromARGB(255, 32, 32, 32),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(36),
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
      ),
    );
  }
}
