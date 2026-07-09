import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ============================================================================
// DISCIPLINUM DESIGN SYSTEM (Reutilizado do onboarding_screen.dart)
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
// REUSABLE WIDGETS (Reutilizados do onboarding_screen.dart)
// ============================================================================

class ScrollDownArrow extends StatelessWidget {
  const ScrollDownArrow({super.key});

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

// ============================================================================
// HOW IT WORKS SCREEN (Reformulado no padrão Disciplinum)
// ============================================================================

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
    final isLastPage = _currentPage == _totalPages - 1;

    return Scaffold(
      backgroundColor: DisciplinumColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    'Como funciona',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: DisciplinumColors.onBackground,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
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
                          : Colors.white.withValues(alpha: 0.3),
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
            ),
            const SizedBox(height: 8),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
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
              child: NeonButton(
                width: double.infinity,
                text: isLastPage ? 'Entendi' : 'Próximo',
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
                icon: !isLastPage ? Icons.arrow_forward_rounded : null,
              ).animate().scale(
                    begin: const Offset(0.95, 0.95),
                    duration: 300.ms,
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
        return _buildFunctionalityPage();
      case 1:
        return _buildGamificationPage();
      case 2:
        return _buildRulesPage();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFunctionalityPage() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Header
                PremiumGlassCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  borderRadius: 14,
                  borderColor: DisciplinumColors.primary,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: DisciplinumColors.primary
                                  .withValues(alpha: 0.1),
                              border: Border.all(
                                color: DisciplinumColors.primary,
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: DisciplinumColors.detoxPrimary
                                  .withValues(alpha: 0.1),
                              border: Border.all(
                                color: DisciplinumColors.detoxPrimary,
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.phone_android_rounded,
                              color: DisciplinumColors.detoxPrimary,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Funcionamento do app Disciplinum',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: DisciplinumColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bloqueio inteligente de apps',
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

                const SizedBox(height: 20),

                // Description
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'O Disciplinum ajuda você a manter hábitos saudáveis através de um sistema de bloqueio inteligente de apps.\n'
                    'A principal funcionalidade do app (presente em mais de um dos módulos) é o bloqueio de apps:\n'
                    'Quando você tenta abrir um app que configurou para ter sua abertura monitorada, uma tela de bloqueio é exibida,'
                    'te dando opção de Voltar (mantendo seu progresso) ou Continuar (quebrando o ciclo, reiniciando sua gamificação e suas estatísticas daquele módulo).',
                    style: TextStyle(
                      color: DisciplinumColors.onSurfaceVariant,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                const SizedBox(height: 16),

                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Este sistema é baseado na técnica de "interrupção do comportamento" - aquela pausa entre o impulso e a ação que pode fazer toda a diferença para quem quer mudar hábitos.',
                    style: TextStyle(
                      color: DisciplinumColors.onSurfaceVariant,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

                const SizedBox(height: 16),
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'As vezes que você abriu um app que está configurado para ter sua abertura monitorada são registradas no histórico e nas estatísticas do módulo, para acompanhamento.',
                    style: TextStyle(
                      color: DisciplinumColors.onSurfaceVariant,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

                const SizedBox(height: 16),

                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Cada módulo é independente, com sua própria gamificação (medalhas e insígnias), estatísticas e configurações. Você pode ativar quantos módulos quiser simultaneamente.',
                    style: TextStyle(
                      color: DisciplinumColors.onSurfaceVariant,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

                const SizedBox(height: 16),

                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: DisciplinumColors.onSurfaceVariant,
                        fontSize: 14,
                        height: 1.6,
                      ),
                      children: [
                        const TextSpan(
                          text:
                              'O app usa o serviço de Acessibilidade do Android (você precisa dar permissão) para detectar quando apps monitorados são abertos. ',
                        ),
                        TextSpan(
                          text:
                              'Isso é feito de forma segura e respeitando sua privacidade',
                          style: TextStyle(
                            color: DisciplinumColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(
                          text:
                              ' - não há coleta de dados pessoais, apenas é feita a detecção de abertura dos apps que você mesmo escolheu monitorar.',
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 500.ms),

                const SizedBox(height: 20),

                // Modules section
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
                      'Módulos disponíveis',
                      style: TextStyle(
                        color: DisciplinumColors.onBackground,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms, delay: 600.ms),

                const SizedBox(height: 12),

                // Modules list
                GlassCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _buildModuleItem(
                        icon: Icons.smoking_rooms,
                        title: 'Parar de Fumar',
                        description:
                            'Sistema de check-in diário, lembretes motivacionais e exercícios de respiração. Exibe estatísticas de economia financeira projetada e benefícios à saúde',
                        delay: 700.ms,
                      ),
                      _buildModuleItem(
                        icon: Icons.monetization_on,
                        title: 'Controle de Gastos',
                        description:
                            'Bloqueio de apps de compras (Shopee, Mercado Livre, etc.) e lembretes sobre gastos fixos',
                        delay: 800.ms,
                      ),
                      _buildModuleItem(
                        icon: Icons.timer,
                        title: 'Foco e Produtividade',
                        description:
                            'Bloqueio de apps durante períodos de foco configurados, '
                            'para auxiliar você a se manter focado nos seus objetivos.',
                        delay: 900.ms,
                      ),
                      _buildModuleItem(
                        icon: Icons.apple,
                        title: 'Manter Dieta',
                        description:
                            'Lembretes de refeições com antecedência de 30 min, suficiente pra você preparar ou esquentar sua refeição, '
                            'ajudando a manter a constância e foco na dieta',
                        delay: 1000.ms,
                      ),
                      _buildModuleItem(
                        icon: Icons.lock,
                        title: 'Jejum 18+',
                        description:
                            'Bloqueio de navegadores e apps que possam exibir conteúdo adulto, '
                            'para auxiliar quem deseja se abster de tais conteúdos ou ter um maior controle sobre o consumo.',
                        delay: 1100.ms,
                      ),
                      _buildModuleItem(
                        icon: Icons.access_time,
                        title: 'Evitar Procrastinação',
                        description:
                            'Crie listas de tarefas, adicione notas, defina lembretes e acompanhe seu progresso, '
                            'ajudando você a vencer a procrastinação.',
                        delay: 1200.ms,
                      ),
                      _buildModuleItem(
                        icon: Icons.menu_book,
                        title: 'Leitura',
                        description:
                            'Registre os livros que está lendo e forme uma espécie de estante virtual '
                            'com progresso de páginas lidas e restantes.',
                        delay: 1300.ms,
                      ),
                      _buildModuleItem(
                        icon: Icons.fastfood,
                        title: 'Compulsão Alimentar',
                        description:
                            'Bloqueio de apps de delivery (iFood, Rappi, etc.) '
                            'para te ajudar a ter maior controle sobre sua alimentação, '
                            'evitando gastos desnecessários e compulsão alimentar.',
                        delay: 1400.ms,
                      ),
                      _buildModuleItem(
                        icon: Icons.phone_android,
                        title: 'Jejum Digital',
                        description:
                            'Tenha um controle inteligente do uso de redes sociais e demais aplicativos,\n'
                            'com gestão configurável de tempo individual por aplicativo, além de gráficos de uso para acompanhamento.',
                        delay: 1500.ms,
                      ),
                      _buildModuleItem(
                        icon: Icons.savings,
                        title: 'Desafio da Poupança',
                        description:
                            'Defina metas de economia e acompanhe seu progresso com um sistema visual intuitivo de quadradinhos que representam os aportes. '
                            'Saiba exatamente quanto você já tem economizado e quanto falta para atingir suas metas. '
                            'Uma ótima maneira de acompanhar o progresso visualmente.',
                        delay: 1600.ms,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 700.ms),

                const SizedBox(height: 16),

                // Additional features section
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
                      'Outros recursos',
                      style: TextStyle(
                        color: DisciplinumColors.onBackground,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms, delay: 1700.ms),

                const SizedBox(height: 12),

                // Additional features list
                GlassCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _buildModuleItem(
                        icon: Icons.receipt_long,
                        title: 'Contas Fixas',
                        description:
                            'Cadastro de contas mensais com lembretes de vencimento',
                        delay: 1800.ms,
                      ),
                      _buildModuleItem(
                        icon: Icons.palette,
                        title: 'Temas Personalizados',
                        description:
                            'Escolha entre tema Claro, Dark, Halloween e Rosa\n (novos temas podem surgir!)',
                        delay: 1900.ms,
                      ),
                      _buildModuleItem(
                        icon: Icons.analytics,
                        title: 'Estatísticas Detalhadas',
                        description:
                            'Acompanhe sua evolução com dados e gráficos',
                        delay: 2000.ms,
                      ),
                      _buildModuleItem(
                        icon: Icons.cloud,
                        title: 'Backup na Nuvem',
                        description: 'Seus dados sincronizados com segurança',
                        delay: 2100.ms,
                      ),
                      _buildModuleItem(
                        icon: Icons.notifications_off,
                        title: 'Pausa de Notificações',
                        description:
                            'Pause temporariamente sem perder progresso',
                        delay: 2200.ms,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 1800.ms),

                const SizedBox(height: 24),
              ],
            ),
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
                const SizedBox(height: 16),

                // Header
                PremiumGlassCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  borderRadius: 14,
                  borderColor: DisciplinumColors.detoxPrimary,
                  child: Column(
                    children: [
                      Text(
                        'Sistema de Conquistas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: DisciplinumColors.detoxPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Medalhas e Insígnias (fictícias)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: DisciplinumColors.detoxPrimary
                              .withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1),

                const SizedBox(height: 20),

                // Description
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Conquiste insígnias e medalhas conforme mantém sua disciplina!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: DisciplinumColors.onSurfaceVariant,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ],
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
                ).animate().fadeIn(duration: 400.ms, delay: 800.ms),

                const SizedBox(height: 12),

                // Insignias list
                PremiumGlassCard(
                  padding: const EdgeInsets.all(12),
                  borderColor: DisciplinumColors.primary,
                  borderRadius: 12,
                  child: Column(
                    children: [
                      _buildMedalItem(
                        assetPath:
                            'assets/gamification/insignias/focus/madeira.png',
                        title: 'Madeira',
                        delay: 900.ms,
                      ),
                      _buildMedalItem(
                        assetPath:
                            'assets/gamification/insignias/focus/ferro.png',
                        title: 'Ferro',
                        delay: 1000.ms,
                      ),
                      _buildMedalItem(
                        assetPath:
                            'assets/gamification/insignias/focus/aluminio.png',
                        title: 'Alumínio',
                        delay: 1100.ms,
                      ),
                      _buildMedalItem(
                        assetPath:
                            'assets/gamification/insignias/focus/bronze.png',
                        title: 'Bronze',
                        delay: 1200.ms,
                      ),
                      _buildMedalItem(
                        assetPath:
                            'assets/gamification/insignias/focus/latao.png',
                        title: 'Latão',
                        delay: 1300.ms,
                      ),
                      _buildMedalItem(
                        assetPath:
                            'assets/gamification/insignias/focus/prata.png',
                        title: 'Prata',
                        delay: 1400.ms,
                      ),
                      _buildMedalItem(
                        assetPath:
                            'assets/gamification/insignias/focus/ouro.png',
                        title: 'Ouro',
                        delay: 1500.ms,
                      ),
                      _buildMedalItem(
                        assetPath:
                            'assets/gamification/insignias/focus/diamante.png',
                        title: 'Diamante',
                        delay: 1600.ms,
                      ),
                      _buildMedalItem(
                        assetPath:
                            'assets/gamification/insignias/focus/disciplinum.png',
                        title: 'Disciplinum',
                        delay: 1700.ms,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 900.ms),

                const SizedBox(height: 16),

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
                      'Medalhas de Progresso',
                      style: TextStyle(
                        color: DisciplinumColors.onBackground,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

                const SizedBox(height: 12),

                // Medals list
                PremiumGlassCard(
                  padding: const EdgeInsets.all(12),
                  borderColor: DisciplinumColors.detoxPrimary,
                  borderRadius: 12,
                  child: Column(
                    children: [
                      _buildMedalItem(
                        assetPath:
                            'assets/gamification/medals/smoking/bronze.png',
                        title: 'Bronze',
                        delay: 400.ms,
                      ),
                      _buildMedalItem(
                        assetPath:
                            'assets/gamification/medals/smoking/silver.png',
                        title: 'Prata',
                        delay: 500.ms,
                      ),
                      _buildMedalItem(
                        assetPath:
                            'assets/gamification/medals/smoking/gold.png',
                        title: 'Ouro',
                        delay: 600.ms,
                      ),
                      _buildMedalItem(
                        assetPath:
                            'assets/gamification/medals/smoking/diamond.png',
                        title: 'Diamante',
                        delay: 700.ms,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

                const SizedBox(height: 24),

                Text(
                  '⚠️ Atenção: não há recompensas físicas, monetárias - ou de qualquer natureza - no mundo real'
                  ' com o uso do app que não sejam a possível criação e manutenção de bons'
                  ' hábitos, a atenuação de maus hábitos e a consequente melhoria do seu bem-estar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: DisciplinumColors.error,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
              ],
            ),
          ),
        ),
        const ScrollDownArrow(),
      ],
    );
  }

  Widget _buildRulesPage() {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),

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

              const SizedBox(height: 24),

              // Title
              PremiumGlassCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                borderRadius: 14,
                borderColor: DisciplinumColors.error,
                child: Text(
                  'Regras Importantes',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: DisciplinumColors.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms),

              const SizedBox(height: 24),

              // Rule 1
              PremiumGlassCard(
                padding: const EdgeInsets.all(16),
                borderColor: DisciplinumColors.error,
                borderRadius: 12,
                child: Column(
                  children: [
                    Icon(
                      Icons.restart_alt_rounded,
                      color: DisciplinumColors.error,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Reinício do progresso e da gamificação',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: DisciplinumColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'O descumprimento do uso programado de algum módulo, ou a desativação de um deles, fará com que o progresso daquele módulo seja zerado. '
                      'Como insentivo à tentativa inicial de criar disciplina, a insignia "Madeira", que é a primeira insignia, obtida ao ativar um módulo, '
                      'permanece com o usuário mesmo que ele tenha seu progresso reiniciado/zerado pelas razões citadas anteriormente.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: DisciplinumColors.onSurfaceVariant,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

              const SizedBox(height: 16),

              // Rule 2
              PremiumGlassCard(
                padding: const EdgeInsets.all(16),
                borderColor: DisciplinumColors.primary,
                borderRadius: 12,
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: DisciplinumColors.primary,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vários módulos habilitados',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: DisciplinumColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Você pode habilitar vários módulos ao mesmo tempo, mas lembre-se que cada módulo tem sua própria estatística e gamificação.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: DisciplinumColors.onSurfaceVariant,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 600.ms),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModuleItem({
    required IconData icon,
    required String title,
    required String description,
    required Duration delay,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: DisciplinumColors.glassMedium,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: DisciplinumColors.primary.withValues(alpha: 0.3),
                width: 0.8,
              ),
            ),
            child: Icon(icon, color: DisciplinumColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: DisciplinumColors.onBackground,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: DisciplinumColors.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: delay);
  }

  Widget _buildMedalItem({
    String? emoji,
    String? assetPath,
    required String title,
    required Duration delay,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (assetPath != null)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: DisciplinumColors.glassMedium,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: DisciplinumColors.primary.withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              child: Image.asset(assetPath, fit: BoxFit.contain),
            )
          else
            Text(
              emoji!,
              style: const TextStyle(fontSize: 24),
            ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: DisciplinumColors.onBackground,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: delay);
  }
}
