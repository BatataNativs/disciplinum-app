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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLastPage = _currentPage == _totalPages - 1;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    'Como funciona',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
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
                          _buildHeader(index, theme),
                          const SizedBox(height: 24),
                          _buildContent(index, theme),
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
                          ? const Color(0xFF6366F1)
                          : Colors.grey.withValues(alpha: 0.3),
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
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
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
    final isDark = theme.brightness == Brightness.dark;
    
    switch (index) {
      case 0:
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image(image: AssetImage('assets/logo.png'), width: 80, height: 80),
                Image(image: AssetImage('assets/icons/app_monitoring.png'), width: 60, height: 60),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Funcionamento do app Disciplinum',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
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
                color: isDark ? Colors.white : Colors.black,
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
              color: Colors.red,
            ),
            const SizedBox(height: 2),
            Text(
              'Regras Importantes',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
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
    final isDark = theme.brightness == Brightness.dark;
    final textStyle = theme.textTheme.bodyMedium?.copyWith(
      color: isDark ? Colors.white70 : Colors.black87,
      height: 1.5,
    );

    switch (index) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'O Disciplinum monitora apps selecionados POR VOCÊ ao configurar um módulo e te envia notificação de alerta para você sair deles em até 30 segundos se você os abrir.\n\n'
              'Esse monitoramento é feito de forma segura e respeitando sua privacidade - apenas os apps que você selecionar são monitorados. Não há vigilância contínua da sua tela ou coleta desnecessária de dados não necessários para o funcionamento do app nesse aspecto. O gatilho é a abertura do app pré-configurado por você.\n\n'
              'Você pode escolher quantos apps quiser para cada módulo, e usar quantos módulos quiser ao mesmo tempo.\n\n'
              'Cada módulo tem suas próprias configurações, gatilhos de funcionamento e particularidades, permitindo que você gerencie diferentes aspectos da sua vida de forma independente.\n\n'
              'O tal monitoramento de abertura de apps selecionados é apenas uma das funcionalidades do app. Também tem gestão de gastos fixos (contas, aluguel, etc.) que você registrar no app (valores e vencimentos) e receber lembretes para pagamento.\n\n'
              'Ainda sobre finanças, tem também um módulo de "Desafio da Poupança", que é para criação e acompanhamento de metas, onde você pode registrar metas de valores a juntar e acompanhar seu progresso.\n\n'
              'Tem módulo para você registrar livros que está lendo, quantas páginas leu por dia, quanto falta, ver estatísticas sobre seus hábitos de leitura e acompanhar seu progresso.\n\n'
              'Há módulo pra te ajudar a parar de fumar também. Neste módulo, você insere o quanto gasta com cigarro, data pra começar a ficar sem fumar, e cria estatísticas do quanto você pode economizar e quanto melhorou - ou pode melhorar - sua saúde geral.',
            ),
            const SizedBox(height: 16),
            Text(
              'Módulos disponíveis no momento:',
              style: textStyle?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildModuleItem('🚭 Parar de Fumar', 'Alertas e incentivo em horários críticos. Além de estatísticas de economia financeira gerada e saúde', textStyle),
            _buildModuleItem('💰 Controle de Gastos', 'Monitore apps de compras e seja orientado a sair se os abrir', textStyle),
            _buildModuleItem('🎯 Foco e Produtividade', 'Evite distrações, não abrindo apps selecionados durante período de foco definido', textStyle),
            _buildModuleItem('🍎 Manter Dieta', 'Lembretes para refeições (30 minutos antes, pra você ter tempo de aprontar ou esquentar sua refeição)', textStyle),
            _buildModuleItem('🔒 Evitar Conteúdo Adulto', 'Ajuda a evitar consumo de conteúdo adulto, **bloqueando acesso** a conteúdo adulto', textStyle),
            _buildModuleItem('⏰ Evitar Procrastinação', 'Organização e gestão de tempo. Te ajudando a se organizar com lembretes, notas e alarmes', textStyle),
            _buildModuleItem('📚 Leitura', 'Estimular o hábito da leitura e organização de livros. O módulo tem uma "estante" pra você ir alimentando com os livros que está lendo (nome, autor, quantidade de páginas..), e vai vendo o quanto já leu, o quanto falta, estatísticas sobre sues gostos e preferências, etc.', textStyle),
            _buildModuleItem('🍔 Compulsão Alimentar', 'Ajuda a evitar fastfoods e deliveries por impulso, monitorando apps de delivery e te orientando a sair se os abrir', textStyle),
            _buildModuleItem('🐖 Desafio da Poupança', 'Forma divertida de aprender a economizar dinheiro. Você cria meta de valor que quer juntar, e um prazo. Aí você vai inserindo no app informações sobre seus aportes em alguma conta ou "cofrinho" de algum app de banco e vê, num sistema de quadradinhos em linhas e colunas de fácil visualização, e vai acompanhando o quanto já juntou, o quanto falta, e projeções de tempo necessário para você atingir a meta ', textStyle),
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
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🏅 Medalhas de Progresso', style: textStyle?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildMedalItem('🥉 Bronze', '3 dias sem falhar'),
                  _buildMedalItem('🥈 Prata', '7 dias consecutivos'),
                  _buildMedalItem('🥇 Ouro', '14 dias de disciplina'),
                  _buildMedalItem('💎 Diamante', '30 dias imbatível'),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Insígnias
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🛡️ Insígnias', style: textStyle?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildMedalItem('Madeira', 'Ao configurar e ativar o módulo', 'assets/insignias/escudo_madeira.png'),
                  _buildMedalItem('Ferro', 'Primeiro dia de foco', 'assets/insignias/escudo_ferro.png'),
                  _buildMedalItem('Alumínio', 'Iniciando consistência', 'assets/insignias/escudo_aluminio.png'),
                  _buildMedalItem('Bronze', 'Dedicado à disciplina', 'assets/insignias/escudo_bronze.png'),
                  _buildMedalItem('Latão', 'Avançando com foco', 'assets/insignias/escudo_latao.png'),
                  _buildMedalItem('Prata', 'Controle e maestria', 'assets/insignias/escudo_prata.png'),
                  _buildMedalItem('Ouro', 'Enorme disciplina', 'assets/insignias/escudo_ouro.png'),
                  _buildMedalItem('Diamante', 'Lendário e inabalável', 'assets/insignias/escudo_diamante.png'),
                  _buildMedalItem('Disciplinum', 'Supremo absoluto', 'assets/insignias/escudo_disciplinum.png'),
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
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.timer_rounded, color: Colors.orange, size: 32),
                  const SizedBox(height: 2),
                  Text(
                    'Janela de 30 Segundos',
                    style: textStyle?.copyWith(fontWeight: FontWeight.bold, color: Colors.orange),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ao abrir um app monitorado, você terá 30 segundos para fechá-lo. Se permanecer aberto, seu progresso será reiniciado.',
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
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
                  const SizedBox(height: 2),
                  Text(
                    'Progresso Reiniciado',
                    style: textStyle?.copyWith(fontWeight: FontWeight.bold, color: Colors.red),
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

                        Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.lightbulb_rounded, color: const Color(0xFF6366F1), size: 24),
                  const SizedBox(height: 2),
                  Text(
                    'Dica:',
                    style: textStyle?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF6366F1)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use a pausa temporária de notificações, ("Pausar notificações" em Configurações, quando precisar usar um app monitorado sem interromper seu progresso (sem desativar o módulo).'
                    'Lembre-se de usar isso somente quando extremamente necessário e raramente. Pois, usar o app com isso ligado permanentemente foge do propósito do aplicativo, e é uma forma de atrasar sua autorregulação e disciplina.',
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
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.schedule_rounded, color: Colors.green, size: 32),
                  const SizedBox(height: 2),
                  Text(
                    'Dias de Tolerância (sobre check-in diário)',
                    style: textStyle?.copyWith(fontWeight: FontWeight.bold, color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Para te ajudar a manter a disciplina, o app te dá alguns dias de tolerância quando você não consegue fazer o check-in diário (via notificação de algum módulo):\n\n'
                    '• Menos de 7 dias de disciplina: 1 dia de tolerância\n'
                    '• Entre 7 e 29 dias: 2 dias de tolerância\n'
                    '• Entre 30 e 99 dias: 3 dias de tolerância\n'
                    '• 100 dias ou mais: 5 dias de tolerância\n\n'
                    'Se você ficar sem fazer o check-in diário além desses dias, seu progresso na gamificação e nas estatísticas daquele módulo será reiniciado. Use a seu favor!',
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

  Widget _buildModuleItem(String title, String description, TextStyle? style) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: style),
          Expanded(
            child: Text(
              '$title: $description',
              style: style,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedalItem(String title, String description, [String? assetPath]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          if (assetPath != null)
            Image.asset(assetPath, width: 20, height: 20)
          else
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
