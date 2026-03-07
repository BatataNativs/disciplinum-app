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
            Image(image: AssetImage('assets/icons/app_monitoring.png'), width: 100, height: 100),
            const SizedBox(height: 16),
            Text(
              'Monitoramento de abertura de apps',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset('assets/medal_bronze.png', width: 40, height: 40),
                Image.asset('assets/medal_silver.png', width: 40, height: 40),
                Image.asset('assets/medal_gold.png', width: 40, height: 40),
                Image.asset('assets/medal_diamond.png', width: 40, height: 40),
              ],
            ),
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
            const SizedBox(height: 16),
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
              'E esse monitoramento é feito de forma segura e respeita sua privacidade - apenas os apps que você selecionar são monitorados. Não há vigilância contínua da sua tela ou coleta desnecessária de dados não necessários para o funcionamento do app nesse aspecto. O gatilho é a abertura do app pré-configurado por você.\n\n'
              'Você pode escolher quantos apps quiser para cada módulo, e usar quantos módulos quiser ao mesmo tempo.\n\n'
              'Cada módulo tem suas próprias configurações, gatilhos de funcionamento e particularidades, permitindo que você gerencie diferentes aspectos da sua vida de forma independente.\n\n'
              'O tal monitoramento de abertura de apps selecionados é apenas uma das funcionalidades do app. Também tem gestão de gastos fixos (contas, aluguel, etc.) que você registrar no app (valores e vencimentos) e receber lembretes para pagamento.\n'
              'Ainda sobre finanças, tem também um módulo de criação e acompanhamento de metas, onde você pode registrar metas de valores a juntar e acompanhar seu progresso.',
            ),
            const SizedBox(height: 16),
            Text(
              'Módulos disponíveis no momento:',
              style: textStyle?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildModuleItem('🚭 Parar de Fumar', 'Alertas em horários críticos', textStyle),
            _buildModuleItem('💰 Controle de Gastos', 'Monitore apps de compras', textStyle),
            _buildModuleItem('🎯 Foco e Produtividade', 'Evite distrações', textStyle),
            _buildModuleItem('🍎 Manter Dieta', 'Lembretes para refeições', textStyle),
            _buildModuleItem('🔒 Evitar Conteúdo Adulto', 'Ajuda a evitar consumo de conteúdo adulto', textStyle),
            _buildModuleItem('⏰ Evitar Procrastinação', 'Organização e gestão de tempo', textStyle),
            _buildModuleItem('📚 Leitura', 'Estimular o hábito da leitura e organização', textStyle),
            _buildModuleItem('🍔 Compulsão Alimentar', 'Ajuda a evitar fastfoods e deliveries por impulso', textStyle),
            _buildModuleItem('🐖 Desafio da Poupança', 'Forma divertida de aprender a economizar dinheiro', textStyle),
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
                  Text('🛡️ Insígnias Especiais', style: textStyle?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildMedalItem('🪵 Madeira', 'Ao configurar e ativar o módulo'),
                  _buildMedalItem('⚙️ Ferro', 'Primeiro dia de foco'),
                  _buildMedalItem('🔩 Alumínio', 'Iniciando consistência'),
                  _buildMedalItem('� Bronze', 'Dedicado à disciplina'),
                  _buildMedalItem('🔩 Latão', 'Avançando com foco'),
                  _buildMedalItem('🥈 Prata', 'Controle e maestria'),
                  _buildMedalItem('🥇 Ouro', 'Enorme disciplina'),
                  _buildMedalItem('💎 Diamante', 'Lendário e inabalável'),
                  _buildMedalItem('🏆 Disciplinum', 'Supremo absoluto'),
                ],
              ),
            ),
          ],
        );
      case 2:
        return Column(
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
                  Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    '⚠️ Progresso Reiniciado',
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
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.timer_rounded, color: Colors.orange, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    '⏱️ Janela de 30 Segundos',
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
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_rounded, color: const Color(0xFF6366F1), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Dica: Use a pausa temporária em Configurações quando precisar usar um app monitorado.',
                      style: textStyle?.copyWith(fontWeight: FontWeight.w500),
                    ),
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

  Widget _buildMedalItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
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
