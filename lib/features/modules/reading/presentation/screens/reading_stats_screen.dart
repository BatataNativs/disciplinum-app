import 'package:disciplinum/features/modules/reading/domain/entities/reading_model.dart';
import 'package:disciplinum/core/di/adapters/reading_service_adapter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';

class ReadingStatsScreen extends ConsumerStatefulWidget {
  const ReadingStatsScreen({super.key});

  @override
  ConsumerState<ReadingStatsScreen> createState() => _ReadingStatsScreenState();
}

class _ReadingStatsScreenState extends ConsumerState<ReadingStatsScreen> {
  @override
  void initState() {
    super.initState();
    // Carrega estatísticas iniciais
    _loadInitialStats();
  }

  void _loadInitialStats() {
    // Implementar carregamento inicial de estatísticas
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final readingAdapter = ref.watch(readingServiceAdapterProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            isDark ? const Color(0xFF0F172A) : const Color(0xFFEFF6FF),
            isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Estatísticas de Leitura',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        body: SafeArea(
          child: Consumer(
            builder: (context, ref, child) {
              final vm = _ReadingStatsVm.fromAdapter(readingAdapter);
              return _buildStatsContent(context, vm, isDark);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatsContent(BuildContext context, _ReadingStatsVm vm, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cards principais
          Row(
            children: [
              Expanded(child: _buildMainCard(vm.totalBooks, 'Total de Livros', Icons.book, isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildMainCard(vm.completedBooks, 'Concluídos', Icons.check_circle, isDark)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildMainCard(vm.totalPages, 'Páginas Totais', Icons.description, isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildMainCard(vm.readPages, 'Páginas Lidas', Icons.auto_stories, isDark)),
            ],
          ),
          const SizedBox(height: 24),

          // Progresso geral
          _buildProgressCard(vm.averageProgress, isDark),
          const SizedBox(height: 24),

          // Gráfico de progresso
          _buildProgressChart(vm, isDark),
          const SizedBox(height: 24),

          // Último livro concluído
          if (vm.lastBookTitle != null) _buildLastBookCard(vm.lastBookTitle!, isDark),

          // Estatísticas por tema
          _buildThemeStats(vm.themeStats, isDark),
        ],
      ),
    );
  }

  Widget _buildMainCard(int value, String title, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(height: 12),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(double progress, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progresso Geral',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(
            '${progress.toStringAsFixed(1)}% concluído',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart(_ReadingStatsVm vm, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribuição de Progresso',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: vm.completedBooks.toDouble(),
                    title: '${vm.completedBooks}',
                    color: Colors.green,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    value: (vm.totalBooks - vm.completedBooks).toDouble(),
                    title: '${vm.totalBooks - vm.completedBooks}',
                    color: Colors.grey,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
                centerSpaceRadius: 60,
                sectionsSpace: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastBookCard(String lastBookTitle, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Último Livro Concluído',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            lastBookTitle,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeStats(Map<ReadingTheme, int> themeStats, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Livros por Tema',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          ...themeStats.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: entry.key.color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.key.label,
                      style: TextStyle(
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                  ),
                  Text(
                    entry.value.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ReadingStatsVm {
  final int totalBooks;
  final int completedBooks;
  final int totalPages;
  final int readPages;
  final double averageProgress;
  final String? lastBookTitle;
  final Map<ReadingTheme, int> themeStats;

  _ReadingStatsVm({
    required this.totalBooks,
    required this.completedBooks,
    required this.totalPages,
    required this.readPages,
    required this.averageProgress,
    required this.lastBookTitle,
    required this.themeStats,
  });

  factory _ReadingStatsVm.fromAdapter(ReadingServiceAdapter adapter) {
    // Simulação de dados enquanto não temos acesso real
    final totalBooks = 5;
    final completedBooks = 2;
    final totalPages = 1200;
    final readPages = 480;
    final averageProgress = totalPages > 0 ? (readPages / totalPages) * 100 : 0.0;
    final lastBookTitle = 'O Senhor dos Anéis';
    
    final themeStats = <ReadingTheme, int>{
      ReadingTheme.ficcaoCientifica: 2,
      ReadingTheme.romance: 1,
      ReadingTheme.outros: 2,
    };

    return _ReadingStatsVm(
      totalBooks: totalBooks,
      completedBooks: completedBooks,
      totalPages: totalPages,
      readPages: readPages,
      averageProgress: averageProgress,
      lastBookTitle: lastBookTitle,
      themeStats: themeStats,
    );
  }
}
