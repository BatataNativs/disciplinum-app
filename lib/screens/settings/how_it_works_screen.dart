import 'package:flutter/material.dart';

class HowItWorksScreen extends StatefulWidget {
  const HowItWorksScreen({super.key});

  @override
  State<HowItWorksScreen> createState() => _HowItWorksScreenState();
}

class _HowItWorksScreenState extends State<HowItWorksScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final int _totalPages = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLastPage = _currentPage == _totalPages - 1;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          'Como funciona',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _totalPages,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          _buildHeader(index, theme),
                          const SizedBox(height: 24),
                          _buildContent(index, theme),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Dots
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
                    boxShadow: _currentPage == index
                        ? [
                            BoxShadow(
                              color: (isDark
                                      ? const Color(0xFF6366F1)
                                      : const Color.fromARGB(255, 34, 34, 34))
                                  .withValues(alpha: 0.9),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : [],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Botão Ação
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark
                              ? const Color(0xFF6366F1)
                              : const Color.fromARGB(255, 16, 16, 17))
                          .withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FilledButton(
                  onPressed: () {
                    if (isLastPage) {
                      Navigator.pop(context);
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
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isLastPage ? 'Entendi' : 'Próximo',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedal(String assetPath) {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 1,
          )
        ],
      ),
      child: Image.asset(assetPath, fit: BoxFit.contain),
    );
  }

  Widget _buildHeader(int index, ThemeData theme) {
    // Variáveis para configurar o que será exibido
    Widget? visualContent;
    String title = '';
    final isDark = theme.brightness == Brightness.dark;

    switch (index) {
      case 0:
        title = 'Monitoramento de apps selecionados';
        // Emoji '👁️'
        visualContent = const Padding(
          padding: EdgeInsets.only(bottom: 0),
          child: Text('👁️', style: TextStyle(fontSize: 70)),
        );
        break;

      case 1:
        title = 'Seu progresso';
        // Linha com as medalhas
        visualContent = SizedBox(
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMedal('assets/medal_bronze.png'),
              _buildMedal('assets/medal_silver.png'),
              _buildMedal('assets/medal_gold.png'),
              _buildMedal('assets/medal_diamond.png'),
            ],
          ),
        );
        break;

      case 2:
        title = '🚨 Atenção a essas regras:';
        // Imagem de warning
        visualContent = Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: SizedBox(
            height: 80,
            width: 80,
            child: Image.asset(
              'assets/warning2.png',
              fit: BoxFit.contain,
            ),
          ),
        );
        break;
    }

    return Column(
      children: [
        if (visualContent != null) visualContent,
        const SizedBox(height: 16),
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1F2937),
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildContent(int index, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final styleBase = theme.textTheme.bodyLarge?.copyWith(
      height: 1.5,
      fontSize: 12,
      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563),
    );

    final styleBold =
        styleBase?.copyWith(fontWeight: FontWeight.bold, fontSize: 12);

    switch (index) {
      case 0: // Monitoramento
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'O Disciplinum tem módulos categorizados que funcionam te mandando notificações contextualizadas, seja detectando se os apps (selecionados por VOCÊ) estão abertos, seja em horários específicos (também selecionados por VOCÊ), para te ajudar a criar disciplina.',
              style: styleBase,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 16),
            Text('Os módulos (e seus funcionamentos) são:', style: styleBold),
            const SizedBox(height: 8),
            _buildListItem(
                '1. Parar de fumar',
                'Selecione horários que mais costumam te dar vontade (horários próximos às refeições, por exemplo) para receber alertas.',
                styleBase,
                styleBold),
            _buildListItem(
                '2. Compulsão alimentar',
                'Selecione seus apps de delivery para receber alertas quando os abrir.',
                styleBase,
                styleBold),
            _buildListItem(
                '3. Manter dieta',
                'Selecione horários para receber alertas (30 minutos antes, pra dar tempo de preparar ou esquentar sua refeição), a fim de não pular refeições e manter a dieta.',
                styleBase,
                styleBold),
            _buildListItem(
                '4. Controlar gastos',
                'Selecione seus apps de compras online para receber alertas quando os abrir.',
                styleBase,
                styleBold),
            _buildListItem(
                '5. Foco e produtividade',
                'Selecione uma faixa de tempo para receber alertas se abrir um app que você selecionar (ex: redes sociais), para manter o foco e a produtividade.',
                styleBase,
                styleBold),
            _buildListItem(
                '6. Evitar conteúdo adulto',
                'Selecione seus navegadores ou outros apps que possam te levar a conteúdo adulto, e receba alertas quando os abrir.',
                styleBase,
                styleBold),
            Text(
              'Mais módulos em breve!',
              style: styleBase?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Dicas:', style: styleBold),
            const SizedBox(height: 8),
            _buildBulletItem(
                'Você pode selecionar mais de um app para cada módulo (e ter mais de um módulo ativado), para receber alertas quando abrir qualquer um deles e/ou nos horários selecionados.',
                styleBase),
            _buildBulletItem(
                'Você pode ir em Configurações e marcar o "Pausar notificações temporariamente" para desativar temporariamente os alertas, caso realmente precise usar um app selecionado sem receber alertas.',
                styleBase),
          ],
        );
      case 1: // Progresso
        return Column(
          children: [
            Text(
              'Como forma de incentivo, o app possui medalhas, insígnias, troféus e etc (FICTÍCIOS) que são concedidos quando você atinge certos níveis e metas de progresso.',
              style: styleBase,
              textAlign: TextAlign.center,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '\nAs medalhas disponíveis são:',
                style: styleBase,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildBadgeInfo(
                    '🥉 Bronze', '3 dias', styleBase?.copyWith(fontSize: 13)),
                _buildBadgeInfo(
                    '🥈 Prata', '5 dias', styleBase?.copyWith(fontSize: 13)),
                _buildBadgeInfo(
                    '🥇 Ouro', '7 dias', styleBase?.copyWith(fontSize: 13)),
                _buildBadgeInfo('💎 Diamante', '10 dias',
                    styleBase?.copyWith(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Dentro de cada módulo, você pode ver seu progresso atual e quanto falta para alcançar um próximo nível ou marco, tudo pra te incentivar a continuar disciplinado!.',
              style: styleBase,
              textAlign: TextAlign.justify,
            ),
          ],
        );
      case 2: // Regras
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 4),
                  Text(
                    '➜ Se você desativar um módulo, seu progresso naquele módulo é reiniciado',
                    style: styleBase?.copyWith(fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    '➜ Em caso de uso de um app selecionado por você para ter o uso monitorado, você terá 30 segundos para fechá-lo. Se permanecer por mais tempo, o seu progresso reinicia! (a gamificação das medalhas, insígnias, troféus, etc, serão resetada)',
                    style: styleBase?.copyWith(fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildListItem(String title, String description, TextStyle? baseStyle,
      TextStyle? boldStyle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: RichText(
        textAlign: TextAlign.justify,
        text: TextSpan(
          style: baseStyle,
          children: [
            TextSpan(text: '$title\n', style: boldStyle),
            TextSpan(text: description),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletItem(String text, TextStyle? style) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
              child: Text(text, style: style, textAlign: TextAlign.justify)),
        ],
      ),
    );
  }

  Widget _buildBadgeInfo(String title, String days, TextStyle? style) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.2)),
      ),
      child: Text('$title: $days',
          style: style?.copyWith(fontWeight: FontWeight.w600)),
    );
  }
}
