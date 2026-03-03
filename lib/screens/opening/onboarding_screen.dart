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
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                spreadRadius: 0,
                offset: const Offset(0, 4),
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
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(flex: 1),

                        // --- ÁREA DO ASSET (Expandida) ---
                        Expanded(
                          flex: 5,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Builder(builder: (context) {
                              if (index == 0) {
                                return Image.asset(
                                    'assets/disciplinado.png',
                                    height: 210,
                                    width: 210,
                                    fit: BoxFit.contain,
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
                                        const SizedBox(width: 20),
                                        _buildMedal(
                                            'assets/medal_silver.png', 'Prata'),
                                        const SizedBox(width: 20),
                                        _buildMedal(
                                            'assets/medal_gold.png', 'Ouro'),
                                        const SizedBox(width: 20),
                                        _buildMedal('assets/medal_diamond.png',
                                            'Diamante'),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                return Image.asset(
                                  'assets/warning1.png',
                                  height: 210,
                                  width: 210,
                                  fit: BoxFit.contain,
                                );
                              }
                            }),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // --- ÁREA DO TÍTULO ---
                        Align(
                          alignment: Alignment.center,
                          child: Builder(builder: (context) {
                            String pageTitle = '';
                            if (index == 0) {
                              pageTitle = 'Disciplina, foco e bons hábitos';
                            } else if (index == 1) {
                              pageTitle =
                                  'Gamificação e incentivos ao seu progresso';
                            } else {
                              pageTitle = 'Atenção!';
                            }

                            return Text(
                              pageTitle,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 30,
                                color: isDark
                                    ? const Color(0xFFFFFFFF)
                                    : const Color(0xFF1F2937),
                                letterSpacing: -0.8,
                                height: 1.2,
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
                                  ? const Color(0xFF94A3B8).withValues(alpha: 0.9)
                                  : const Color(0xFF4B5563).withValues(alpha: 0.85),
                              height: 1.4,
                              fontSize: 15,
                              letterSpacing: 0.1,
                            );

                            if (index == 0) {
                              return RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: bodyStyle,
                                  children: [
                                    const TextSpan(
                                      text: 'Transforme seus hábitos diários\ne seja mais disciplinado!\n',
                                    ),
                                    const TextSpan(
                                      text: 'Este app pode te ajudar a:\n',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    const TextSpan(text: '• Evitar compras impulsivas\n'),
                                    const TextSpan(text: '• Manter o foco em atividades produtivas\n'),
                                    const TextSpan(text: '• Parar de fumar\n'),
                                    const TextSpan(text: '• Evitar conteúdo adulto\n'),
                                    const TextSpan(text: '• Evitar procrastinação\n'),
                                    const TextSpan(
                                      text: '• E muito mais!',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              );
                            } else if (index == 1) {
                              return RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: bodyStyle,
                                  children: [
                                    const TextSpan(
                                      text: 'O app dispõe de medalhas, insígnias e troféus ',
                                    ),
                                    const TextSpan(
                                      text: '(FICTÍCIOS)',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: 'que você pode conquistar\n',
                                    ),
                                    const TextSpan(
                                      text: 'ao atingir metas e progresso.\n',
                                    ),
                                    const TextSpan(
                                      text: 'Forma lúdica de te motivar\na evoluir e manter consistência.\n',
                                      style: TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    const TextSpan(
                                      text: 'Ao quebrar sua sequência,\nseu progresso é zerado.',
                                      style: TextStyle(fontWeight: FontWeight.w500),
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
                                      text: 'Este app é uma ferramenta\nde apoio à disciplina,\nnão substitui acompanhamento.\n',
                                    ),
                                    const TextSpan(
                                      text: 'Para saber mais sobre\ncomo funciona, ',
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
                        const Spacer(flex: 1),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

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
                        ? (isDark
                            ? const Color(0xFF6366F1)
                            : const Color.fromARGB(255, 23, 23, 23))
                        : (isDark
                            ? const Color(0xFF6366F1).withValues(alpha: 0.25)
                            : const Color.fromARGB(255, 36, 36, 36)
                                .withValues(alpha: 0.25)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Botões de Navegação
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
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
                            color: (isDark
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
                          backgroundColor: isDark
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
      ),
    );
  }
}
