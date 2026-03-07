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

  Widget _buildListItem(String text, TextStyle? style) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 14,
            color: isDark ? const Color(0xFF6366F1) : const Color(0xFF10B981),
          ),
          const SizedBox(width: 10),
          Text(text, style: style),
        ],
      ),
    );
  }

  Widget _buildMedal(String assetPath, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 32,
          width: 32,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                  : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.blueGrey)
                    .withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
            border: Border.all(
              color:
                  (isDark ? const Color(0xFF6366F1) : const Color(0xFF10B981))
                      .withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Image.asset(assetPath, fit: BoxFit.contain),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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
                      mainAxisAlignment: index == 2 ? MainAxisAlignment.start : MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (index == 2) const SizedBox(height: 80),
                        if (index != 2) const Spacer(flex: 1),

                        // --- ÁREA DO ASSET (Expandida) ---
                        Builder(builder: (context) {
                          if (index == 2) {
                            // Última tela - Container simples
                            return Container(
                              height: 160,
                              alignment: Alignment.topCenter,
                              child: Image.asset(
                                'assets/warning1.png',
                                height: 140,
                                width: 140,
                                fit: BoxFit.contain,
                              ),
                            );
                          } else {
                            // Páginas 0 e 1 - Expanded normal
                            return Expanded(
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
                                  } else {
                                    return Center(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            // Medalhas
                                            const Text(
                                              'Medalhas',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF6366F1),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            GridView.count(
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              crossAxisCount: 4,
                                              mainAxisSpacing: 12,
                                              crossAxisSpacing: 12,
                                              childAspectRatio: 1,
                                              children: [
                                                _buildMedal('assets/medal_bronze.png', 'Bronze'),
                                                _buildMedal('assets/medal_silver.png', 'Prata'),
                                                _buildMedal('assets/medal_gold.png', 'Ouro'),
                                                _buildMedal('assets/medal_diamond.png', 'Diamante'),
                                              ],
                                            ),
                                            const SizedBox(height: 1),
                                            // Insígnias
                                            const Text(
                                              'Insígnias',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF6366F1),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            GridView.count(
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              crossAxisCount: 4,
                                              mainAxisSpacing: 12,
                                              crossAxisSpacing: 12,
                                              childAspectRatio: 1,
                                              children: [
                                                _buildMedal('assets/insignias/escudo_madeira.png', 'Madeira'),
                                                _buildMedal('assets/insignias/escudo_ferro.png', 'Ferro'),
                                                _buildMedal('assets/insignias/escudo_aluminio.png', 'Alumínio'),
                                                _buildMedal('assets/insignias/escudo_bronze.png', 'Bronze'),
                                                _buildMedal('assets/insignias/escudo_latao.png', 'Latão'),
                                                _buildMedal('assets/insignias/escudo_prata.png', 'Prata'),
                                                _buildMedal('assets/insignias/escudo_ouro.png', 'Ouro'),
                                                _buildMedal('assets/insignias/escudo_diamante.png', 'Diamante'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                }),
                              ),
                            );
                          }
                        }),

                        const SizedBox(height: 8),

                        // --- ÁREA DO TÍTULO ---
                        Align(
                          alignment: Alignment.center,
                          child: Builder(builder: (context) {
                            String pageTitle = '';
                            if (index == 0) {
                              pageTitle = 'Disciplina, foco e bons hábitos';
                            } else if (index == 1) {
                              pageTitle = 'Gamificação pra incentivar seu progresso';
                            } else {
                              pageTitle = 'Atenção!';
                            }

                            return Text(
                              pageTitle,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 30,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFFFFFFFF)
                                    : const Color(0xFF1F2937),
                                letterSpacing: -0.8,
                                height: 1.2,
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 8),

                        // --- ÁREA DA DESCRIÇÃO ---
                        Align(
                          alignment: Alignment.topCenter,
                          child: Builder(builder: (context) {
                            final bodyStyle =
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF94A3B8).withValues(alpha: 0.9)
                                  : const Color(0xFF4B5563).withValues(alpha: 0.85),
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
                                    textAlign: TextAlign.center,
                                    style: bodyStyle,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Este app pode te ajudar a:',
                                    textAlign: TextAlign.center,
                                    style: bodyStyle?.copyWith(
                                        fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 20),
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
                                        _buildListItem('Evitar conteúdo adulto',
                                            bodyStyle),
                                        _buildListItem(
                                            'Evitar procrastinação', bodyStyle),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.add_circle_outline_rounded,
                                              size: 16,
                                              color: (Theme.of(context).brightness == Brightness.dark
                                                      ? const Color(0xFF6366F1)
                                                      : const Color.fromARGB(
                                                          255, 32, 32, 32))
                                                  .withValues(alpha: 0.8),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'E muito mais!',
                                              style: bodyStyle?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: Theme.of(context).brightness == Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                          ],
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.star_rounded,
                                          color: Colors.amber, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Recompensas Fictícias',
                                        style: bodyStyle?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
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
                                        _buildListItem(
                                            'Atinga metas de evolução',
                                            bodyStyle),
                                        _buildListItem(
                                            'Mantenha sua disciplina viva',
                                            bodyStyle),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            Colors.red.withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.warning_amber_rounded,
                                            color: Colors.red, size: 20),
                                        const SizedBox(width: 12),
                                        Flexible(
                                          child: Text(
                                            'Atenção:\nse quebrar a sequência em algum módulo, o progresso naquele módulo é zerado.',
                                            style: bodyStyle?.copyWith(
                                              color: Theme.of(context).brightness == Brightness.dark
                                                  ? Colors.red[300]
                                                  : Colors.red[700],
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
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
                                          'Este app é uma ferramenta\nde apoio à disciplina a aos bons hábitos,\nele não foi feito e nem tem a intenção de substituir o acompanhamento de um profissional de saúde ou terapeuta.\n Use-o com responsabilidade e sabedoria.\n\n',
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
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

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
