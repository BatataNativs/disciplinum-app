import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/screens/modules/9_reading/my_shelf_screen.dart';
import 'package:disciplinum/screens/modules/9_reading/reading_settings_screen.dart';
import 'package:disciplinum/screens/modules/9_reading/reading_stats_screen.dart';
import 'package:disciplinum/screens/modules/9_reading/widgets/add_book_dialog.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/widgets/home/glowing_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ReadingScreen extends StatefulWidget {
  final String? heroTag;
  final int initialTabIndex;

  const ReadingScreen({
    super.key,
    this.heroTag,
    this.initialTabIndex = 0, // Default para Como Funciona
  });

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gamification = Provider.of<GamificationService>(context);
    final isActive = gamification.isModuleActive(NicheId.reading);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leitura'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                height: 44,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: const Color(0xFF6366F1),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor:
                      isDark ? Colors.white60 : Colors.black45,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.3,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Como funciona'),
                    Tab(text: 'Minha Estante'),
                  ],
                ),
              )),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHowItWorks(context),
                // Aba da Estante + Botões
                Column(
                  children: [
                    const Expanded(child: MyShelfScreen()),
                    _buildBottomButtons(isDark, isActive),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(
                  isDark,
                  icon: Icons.menu_book_rounded,
                  title: 'O que é este módulo?',
                  content:
                      'O módulo de Leitura ajuda você a cultivar o hábito de ler diariamente. '
                      'Registre seus livros, acompanhe o progresso e mantenha sua mente ativa!',
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  isDark,
                  icon: Icons.auto_stories,
                  title: 'Minha Estante',
                  content:
                      'Adicione os livros que você está lendo ou planeja ler. '
                      'Ao iniciar uma leitura, registre as páginas lidas para atualizar seu progresso.',
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  isDark,
                  icon: Icons.local_fire_department,
                  title: 'Progresso Diário',
                  content: 'Mantenha a chama acesa! 🔥\n'
                      'Leia todos os dias para aumentar seu "streak".\n'
                      '💡 Dica: Configure o lembrete para um horário que você esteja em casa, como antes de dormir.',
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  isDark,
                  icon: Icons.emoji_events,
                  title: 'Conquistas',
                  content:
                      'Ganhe medalhas exclusivas ao manter sua sequência de leitura:\n\n'
                      '🥉 Bronze: 3 dias seguidos\n'
                      '🥈 Prata: 5 dias seguidos\n'
                      '🥇 Ouro: 7 dias seguidos\n'
                      '💎 Diamante: 10 dias ou mais!',
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        // Botão Começar restaurado
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: GlowingButton(
              text: 'Começar',
              color: const Color(0xFF6366F1),
              onPressed: () {
                _tabController.animateTo(1);
              },
              borderRadius: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons(bool isDark, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Linha superior: + Livro | Notificações
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.add,
                  label: '+ Livro',
                  color: const Color(0xFF6366F1),
                  isDark: isDark,
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (_) => const AddBookDialog());
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.notifications_outlined,
                  label: 'Notificações',
                  color: Colors.amber,
                  isDark: isDark,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReadingSettingsScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Linha inferior: Estatísticas | Ativar/Desativar módulo
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.bar_chart_rounded,
                  label: 'Estatísticas',
                  color: Colors.teal,
                  isDark: isDark,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const ReadingStatsScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: isActive ? Icons.power_settings_new : Icons.power_off,
                  label: isActive ? 'Desativar módulo' : 'Ativar módulo',
                  color: isActive ? Colors.red : Colors.green,
                  isDark: isDark,
                  isDestructive: isActive,
                  onTap: () => _toggleModule(isActive),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isDestructive
              ? color.withValues(alpha: 0.12)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.95)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDestructive
                ? color.withValues(alpha: 0.4)
                : (isDark
                    ? Colors.white10
                    : Colors.black.withValues(alpha: 0.05)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDestructive
                      ? color
                      : (isDark ? Colors.white70 : Colors.black54),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleModule(bool isActive) {
    final gamification =
        Provider.of<GamificationService>(context, listen: false);

    if (isActive) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Desativar módulo?'),
          content: const Text(
              'Ao desativar, seu progresso de medalhas será pausado.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                gamification.stopModuleCycle(nicheId: NicheId.reading);
                Navigator.pop(ctx);
              },
              child:
                  const Text('Desativar', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } else {
      gamification.startModuleCycle(nicheId: NicheId.reading);
    }
  }

  Widget _buildInfoCard(
    bool isDark, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      // ... same as before
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF6366F1), size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
