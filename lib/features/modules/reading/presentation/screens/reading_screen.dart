import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/features/modules/reading/presentation/screens/my_shelf_screen.dart';
import 'package:disciplinum/features/modules/reading/presentation/screens/reading_settings_screen.dart';
import 'package:disciplinum/features/modules/reading/presentation/screens/reading_stats_screen.dart';
import 'package:disciplinum/features/modules/reading/presentation/screens/reading_notifications_screen.dart';
import 'package:disciplinum/features/modules/reading/presentation/widgets/add_book_dialog.dart';
import 'package:disciplinum/shared/widgets/dialogs/deactivate_module_dialog.dart';
import 'dart:async';

class ReadingScreen extends ConsumerStatefulWidget {
  final String? heroTag;
  final int initialTabIndex;

  const ReadingScreen({
    super.key,
    this.heroTag,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends ConsumerState<ReadingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gamification = ref.watch(gamificationServiceProvider);
    final isActive = gamification.isModuleActive(NicheId.reading);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Leitura'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
        actions: [
          IconButton(
            icon: Icon(
              isActive ? Icons.toggle_on : Icons.toggle_off,
              color: isActive ? Colors.green : Colors.grey,
            ),
            onPressed: () => _toggleModule(!isActive),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReadingSettingsScreen()),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Como Funciona', icon: Icon(Icons.info)),
            Tab(text: 'Meus Livros', icon: Icon(Icons.book)),
            Tab(text: 'Estatísticas', icon: Icon(Icons.bar_chart)),
            Tab(text: 'Notificações', icon: Icon(Icons.notifications)),
          ],
          labelColor: isDark ? Colors.white : Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHowItWorksTab(),
          const MyShelfScreen(),
          const ReadingStatsScreen(),
          const ReadingNotificationsScreen(),
        ],
      ),
      floatingActionButton: isActive
          ? FloatingActionButton.extended(
              onPressed: _showAddBookDialog,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Livro'),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildHowItWorksTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.book, size: 48, color: Colors.white),
                const SizedBox(height: 12),
                const Text(
                  'Módulo de Leitura',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Acompanhe seus livros e desenvolva o hábito da leitura',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildFeatureCard(
            icon: Icons.auto_stories,
            title: 'Acompanhamento de Livros',
            description: 'Adicione seus livros e acompanhe seu progresso de leitura',
            isDark: isDark,
          ),
          _buildFeatureCard(
            icon: Icons.trending_up,
            title: 'Estatísticas Detalhadas',
            description: 'Visualize suas métricas de leitura e evolução pessoal',
            isDark: isDark,
          ),
          _buildFeatureCard(
            icon: Icons.emoji_events,
            title: 'Gamificação',
            description: 'Ganhe pontos e conquistas ao atingir suas metas de leitura',
            isDark: isDark,
          ),
          _buildFeatureCard(
            icon: Icons.notifications,
            title: 'Lembretes Inteligentes',
            description: 'Receba notificações para manter o hábito da leitura',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleModule(bool isActive) async {
    final gamification = ref.read(gamificationServiceProvider);

    if (isActive) {
      final confirmed = await DeactivateModuleDialog.show(
        context: context,
        nicheId: NicheId.reading,
      );

      if (confirmed == true) {
        await gamification.stopModuleCycle(nicheId: NicheId.reading);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Módulo de Leitura desativado')),
          );
        }
      }
    } else {
      await gamification.startModuleCycle(nicheId: NicheId.reading);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Módulo de Leitura ativado!')),
        );
      }
    }
  }

  Future<void> _showAddBookDialog() async {
    await showDialog(
      context: context,
      builder: (context) => const AddBookDialog(),
    );
  }
}
