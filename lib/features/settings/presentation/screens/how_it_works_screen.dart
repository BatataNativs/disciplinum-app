import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLastPage = _currentPage == _totalPages - 1;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close,
                        color: colorScheme.onSurface),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    'Como funciona',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // PageView
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
                        children: [
                          const SizedBox(height: 20),
                          _buildHeader(index, Theme.of(context)),
                          const SizedBox(height: 24),
                          _buildContent(index, Theme.of(context)),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Indicadores de Página
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _totalPages,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? colorScheme.primary
                          : colorScheme.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // Botão
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (isLastPage) {
                      Navigator.pop(context);
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isLastPage ? 'Entendi' : 'Próximo',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

  Widget _buildHeader(int index, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    switch (index) {
      case 0:
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', width: 80, height: 80),
                const SizedBox(width: 16),
                Image.asset('assets/icons/app_monitoring.png',
                    width: 60, height: 60),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Funcionamento do app Disciplinum',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      case 1:
        return Column(
          children: [
            const Text('🥇🏆🥈🎖️🥉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'Sistema de Conquistas',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      case 2:
        return Column(
          children: [
            Icon(
              Icons.warning_rounded,
              size: 80,
              color: colorScheme.error,
            ),
            const SizedBox(height: 2),
            Text(
              'Regras Importantes',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildContent(int index, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurface.withValues(alpha: 0.7),
      height: 1.5,
    );

    switch (index) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'O Disciplinum ajuda você a manter hábitos saudáveis através de um sistema de bloqueio inteligente de apps. Quando você tenta abrir um app que configurou para ser monitorado, uma tela de bloqueio é exibida por alguns segundos, te dando tempo de refletir antes de continuar.\n\n'
              'Este sistema é baseado na técnica de "interrupção do comportamento" - aquela pausa entre o impulso e a ação que pode fazer toda a diferença para quem quer mudar hábitos.\n\n'
              'Cada módulo é independente, com sua própria gamificação (medalhas e insígnias), estatísticas e configurações. Você pode ativar quantos módulos quiser simultaneamente.\n\n'
              'O app usa o serviço de Acessibilidade do Android (com sua permissão) para detectar quando apps monitorados são abertos. Isso é feito de forma segura e respeitando sua privacidade - não há coleta de dados pessoais, apenas a detecção dos apps que você mesmo escolheu monitorar.\n\n'
              'Além do bloqueio de apps, o app oferece:'
              '\n• Sistema de lembretes personalizáveis'
              '\n• Cadastro de contas fixas com alertas de vencimento'
              '\n• Timer Pomodoro para foco'
              '\n• Estatísticas detalhadas de progresso'
              '\n• Sincronização de dados na nuvem'
              '\n• Temas personalizados (Azul, Rosa ou Escuro)\n',
            ),
            const SizedBox(height: 16),
            // Container branco para módulos
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Módulos disponíveis:',
                    style: textStyle?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildModuleItemDark(
                      '🚭 Parar de Fumar',
                      'Bloqueio de apps de venda de cigarro e estatísticas de economia/saúde'),
                  _buildModuleItemDark(
                      '💰 Controle de Gastos',
                      'Bloqueio de apps de compras (Shopee, Mercado Livre, etc.)'),
                  _buildModuleItemDark(
                      '🎯 Foco e Produtividade',
                      'Timer Pomodoro e bloqueio de apps durante períodos de foco'),
                  _buildModuleItemDark(
                      '🍎 Manter Dieta',
                      'Lembretes de refeições com antecedência'),
                  _buildModuleItemDark(
                      '🔒 Jejum 18+',
                      'Bloqueio de navegadores e apps com conteúdo adulto'),
                  _buildModuleItemDark(
                      '⏰ Evitar Procrastinação',
                      'Lembretes personalizáveis e sistema de notas'),
                  _buildModuleItemDark(
                      '📚 Leitura',
                      'Estante virtual com progresso de páginas e estatísticas'),
                  _buildModuleItemDark(
                      '🍔 Compulsão Alimentar',
                      'Bloqueio de apps de delivery (iFood, Uber Eats, etc.)'),
                  _buildModuleItemDark(
                      '📱 Jejum Digital',
                      'Controle inteligente do uso de redes sociais e apps'),
                  _buildModuleItemDark(
                      '🏦 Desafio da Poupança',
                      'Metas de economia com acompanhamento visual (quadradinhos)'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Container branco para recursos extras
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Outros recursos:',
                    style: textStyle?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildModuleItemDark(
                      '📑 Contas Fixas',
                      'Cadastro de contas mensais com lembretes de vencimento'),
                  _buildModuleItemDark(
                      '🎨 Temas Personalizados',
                      'Escolha entre tema Azul, Rosa e Escuro'),
                  _buildModuleItemDark(
                      '📊 Estatísticas Detalhadas',
                      'Acompanhe sua evolução com dados e gráficos'),
                  _buildModuleItemDark(
                      '☁️ Backup na Nuvem',
                      'Seus dados sincronizados com segurança'),
                  _buildModuleItemDark(
                      '🔕 Pausa de Notificações',
                      'Pause temporariamente sem perder progresso'),
                ],
              ),
            ),
          ],
        );
      case 1:
        return Column(
          children: [
            Text(
              'Conquiste medalhas e insígnias mantendo sua disciplina!',
              style: textStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Medalhas
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🏅 Medalhas de Progresso',
                      style: textStyle?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSecondaryContainer,
                      )),
                  const SizedBox(height: 12),
                  _buildMedalItem('🥉 Bronze', 'Bronze', null, colorScheme, true),
                  _buildMedalItem('🥈 Prata', 'Prata', null, colorScheme, true),
                  _buildMedalItem('🥇 Ouro', 'Ouro', null, colorScheme, true),
                  _buildMedalItem('💎 Diamante', 'Diamante', null, colorScheme, true),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Insígnias
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.primary.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🛡️ Insígnias',
                      style: textStyle?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      )),
                  const SizedBox(height: 12),
                  _buildMedalItem('Madeira', 'Madeira',
                      'assets/gamification/insignias/focus/madeira.png', colorScheme, false),
                  _buildMedalItem('Ferro', 'Ferro',
                      'assets/gamification/insignias/focus/ferro.png', colorScheme, false),
                  _buildMedalItem('Alumínio', 'Alumínio',
                      'assets/gamification/insignias/focus/aluminio.png', colorScheme, false),
                  _buildMedalItem('Bronze', 'Bronze',
                      'assets/gamification/insignias/focus/bronze.png', colorScheme, false),
                  _buildMedalItem('Latão', 'Latão',
                      'assets/gamification/insignias/focus/latao.png', colorScheme, false),
                  _buildMedalItem('Prata', 'Prata',
                      'assets/gamification/insignias/focus/prata.png', colorScheme, false),
                  _buildMedalItem('Ouro', 'Ouro',
                      'assets/gamification/insignias/focus/ouro.png', colorScheme, false),
                  _buildMedalItem('Diamante', 'Diamante',
                      'assets/gamification/insignias/focus/diamante.png', colorScheme, false),
                  _buildMedalItem('Disciplinum', 'Disciplinum',
                      'assets/gamification/insignias/focus/disciplinum.png', colorScheme, false),
                ],
              ),
            ),
          ],
        );
      case 2:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.error.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: colorScheme.error, size: 32),
                  const SizedBox(height: 2),
                  Text(
                    'Progresso Reiniciado',
                    style: textStyle?.copyWith(
                        fontWeight: FontWeight.bold, color: colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ao desativar um módulo, seu progresso naquele módulo será zerado.',
                    style: textStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.tertiaryContainer.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: colorScheme.tertiary.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  Icon(Icons.lightbulb_rounded,
                      color: colorScheme.tertiary, size: 24),
                  const SizedBox(height: 2),
                  Text(
                    'Dica:',
                    style: textStyle?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.tertiary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use a pausa temporária de notificações, ("Pausar notificações" em Configurações, quando precisar usar um app monitorado sem interromper seu progresso (sem desativar o módulo).'
                    'Lembre-se de usar isso somente quando extremamente necessário e raramente.',
                    style: textStyle?.copyWith(fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  Icon(Icons.check_circle_outline_rounded,
                      color: colorScheme.secondary, size: 32),
                  const SizedBox(height: 2),
                  Text(
                    'Vários módulos habilitados',
                    style: textStyle?.copyWith(
                        fontWeight: FontWeight.bold, color: colorScheme.onSecondaryContainer),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Você pode habilitar vários módulos ao mesmo tempo, mas lembre-se que cada módulo tem sua própria estatística e gamificação.',
                    style: textStyle?.copyWith(fontWeight: FontWeight.w500),
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

  Widget _buildMedalItem(String title, String description,
      [String? assetPath, ColorScheme? colorScheme, bool isEmoji = false]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          if (assetPath != null)
            Image.asset(assetPath, width: 20, height: 20)
          else
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isEmoji 
                    ? null 
                    : (colorScheme?.onSurface ?? Colors.black),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme?.onSurface.withValues(alpha: 0.8) ?? Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleItemDark(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: Colors.black.withValues(alpha: 0.6))),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text: ': $description',
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.7),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
