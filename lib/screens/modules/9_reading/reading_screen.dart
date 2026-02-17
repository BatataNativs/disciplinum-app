import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/screens/modules/9_reading/my_shelf_screen.dart';
import 'package:disciplinum/screens/modules/9_reading/reading_settings_screen.dart';
import 'package:disciplinum/screens/modules/9_reading/reading_stats_screen.dart';
import 'package:disciplinum/screens/modules/9_reading/widgets/add_book_dialog.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/widgets/9_reading/my_progress_reading.dart';
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
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDark ? Colors.black : const Color.fromARGB(255, 226, 229, 251),
              isDark ? Colors.black : const Color.fromARGB(255, 255, 255, 255),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header com título
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Leitura',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              // Segmented Control (2 opções)
              _buildSegmentedControl(isDark),

              // Conteúdo
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildHowItWorks(context),
                    // Aba da Estante + Botões
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Adicione livros e ative o módulo para começar:",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Minha Estante:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Expanded(child: MyShelfScreen()),
                        _buildBottomButtons(isDark, isActive),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedControl(bool isDark) {
    return Padding(
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
          unselectedLabelColor: isDark ? Colors.white60 : Colors.black45,
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
            Tab(text: 'Leitura'),
          ],
        ),
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
                  icon: Icons.auto_stories_rounded,
                  title: 'Em "+ Livro", adicione os livros',
                  content:
                      'Adicione os livros que você está lendo ou planeja ler, em seguida, ative o módulo (após adicionar o primeiro livro).\n'
                      'É preenchido nome do livro, autor (opcional), número de páginas e tema.',
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  isDark,
                  icon: Icons.notifications_outlined,
                  title: 'Em "Notificações", configure lembretes',
                  content:
                      'Defina horários para ser lembrado de cultivar seu hábito de leitura e manter sua mente ativa todos os dias. \n'
                      'E o app registra as páginas lidas para atualizar seu progresso, conforme você informa o quanto leu.',
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  isDark,
                  icon: Icons.bar_chart_rounded,
                  title: 'Em "Estatísticas", veja sua evolução',
                  content:
                      'Acompanhe sua sequência de leitura e acompanhe seu progresso no módulo.',
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: _buildActionButton(
              icon: Icons.rocket_launch_rounded,
              label: 'Começar',
              color: const Color(0xFF6366F1),
              isDark: isDark,
              onTap: () {
                _tabController.animateTo(1);
              },
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
                  label: 'Livro',
                  color: const Color(0xFF6366F1),
                  isDark: isDark,
                  onTap: () {
                    AddBookDialog.show(context);
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
                  color: const Color(0xFF6366F1),
                  isDark: isDark,
                  onTap: _showStatsMenu,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: isDark
              ? color.withValues(alpha: 0.15)
              : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.3 : 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatsMenu() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estatísticas e Opções',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            _buildMenuTile(
              icon: Icons.bar_chart_rounded,
              label: 'Estatísticas de leitura',
              color: Colors.teal,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReadingStatsScreen()),
                );
              },
            ),
            _buildMenuTile(
              icon: Icons.bar_chart_rounded,
              label: 'Meu progresso',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyProgressReading()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: isDark ? Colors.white30 : Colors.black26,
        ),
        onTap: onTap,
      ),
    );
  }

  Future<void> _toggleModule(bool isActive) async {
    final gamification =
        Provider.of<GamificationService>(context, listen: false);

    if (isActive) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Desativar módulo?'),
          content: const Text(
              'Ao desativar, seu progresso de medalhas será pausado.\n\nDeseja continuar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sim, desativar'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        if (!mounted) return;
        HapticFeedback.heavyImpact();

        gamification.stopModuleCycle(nicheId: NicheId.reading);
        gamification.resetMedals(
          NicheId.reading,
          deactivate: true,
          notificationTitle: 'Módulo Desativado',
          notificationBody:
              'Seu progresso de leitura foi zerado e o módulo desativado.',
        );
        _tabController.animateTo(0);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Módulo desativado — Você não receberá mais alertas'),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red.withValues(alpha: 0.95),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
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
