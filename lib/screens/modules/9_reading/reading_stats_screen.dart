import 'package:disciplinum/models/9_reading/reading_model.dart';
import 'package:disciplinum/services/9_reading/reading_service.dart';
import 'package:disciplinum/widgets/home/neon_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ReadingStatsScreen extends StatelessWidget {
  const ReadingStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Estatísticas de Leitura 📊'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
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
          // Garante que não fica atrás da AppBar transparente/status bar
          child: Selector<ReadingService, _ReadingStatsVm>(
            selector: (_, service) => _ReadingStatsVm.fromService(service),
            shouldRebuild: (prev, next) => prev != next,
            builder: (context, vm, child) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildTotalBooksSection(vm, isDark),
                  const SizedBox(height: 24),
                  _buildWeeklyChartSection(vm, isDark),
                  const SizedBox(height: 24),
                  _buildThemesSection(vm, isDark),
                  const SizedBox(height: 32),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTotalBooksSection(_ReadingStatsVm vm, bool isDark) {
    final completedCount = vm.completedCount;
    final lastBookTitle = vm.lastCompletedBookTitle;

    return NeonCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.library_books,
                  color: const Color(0xFF6366F1), size: 28),
              const SizedBox(width: 10),
              Text(
                'Total de Livros Lidos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$completedCount',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6366F1),
              height: 1.0,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.history_edu,
                      color: Color(0xFF6366F1), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Último livro concluído',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lastBookTitle ?? 'Nenhum ainda',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildWeeklyChartSection(_ReadingStatsVm vm, bool isDark) {
    final weeklyData = vm.weeklyData;
    final sortedDates = vm.sortedDates;
    final totalPagesWeek = vm.totalPagesWeek;
    final dailyAverage = vm.dailyAverage;
    final maxY = vm.maxY;

    return NeonCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: const Color(0xFF6366F1), size: 24),
              const SizedBox(width: 8),
              Text(
                'Aproveitamento Semanal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Páginas lidas nos últimos 7 dias',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 24),

          // Gráfico
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) =>
                        isDark ? Colors.grey[800]! : Colors.blueGrey,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()} pág',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value >= sortedDates.length) {
                          return const SizedBox.shrink();
                        }
                        final date = sortedDates[value.toInt()];
                        // Dia da semana simplificado (Seg, Ter...)
                        final dayName = DateFormat('EEE', 'pt_BR').format(date);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            dayName.replaceAll(
                                '.', ''), // Remove ponto se houver
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: sortedDates.asMap().entries.map((entry) {
                  final index = entry.key;
                  final date = entry.value;
                  final value = weeklyData[date]?.toDouble() ?? 0.0;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        color: const Color(0xFF6366F1),
                        width: 16,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.03),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 24),
          // Resumo do Gráfico
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildChartSummaryItem(
                  'Média diária', dailyAverage.toStringAsFixed(1), isDark),
              _buildChartSummaryItem(
                  'Total na semana', totalPagesWeek.toString(), isDark),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildChartSummaryItem(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildThemesSection(_ReadingStatsVm vm, bool isDark) {
    final stats = vm.themeStats;

    return NeonCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_outlined,
                  color: const Color(0xFF6366F1), size: 24),
              const SizedBox(width: 8),
              Text(
                'Temas Preferidos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (stats.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Leia alguns livros para descobrir seus temas!',
                  style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black45),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stats.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = stats[index];
                final theme = item['theme'] as ReadingTheme;
                final count = item['count'] as int;
                final percent = item['percent'] as double;

                return Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          theme.label,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$count ${count == 1 ? "livro" : "livros"} (${(percent * 100).toStringAsFixed(0)}%)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent,
                        backgroundColor: isDark
                            ? Colors.white10
                            : Colors.black.withValues(alpha: 0.05),
                        valueColor: AlwaysStoppedAnimation<Color>(theme.color),
                        minHeight: 8,
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _ReadingStatsVm {
  final int completedCount;
  final String? lastCompletedBookTitle;
  final Map<DateTime, int> weeklyData;
  final List<DateTime> sortedDates;
  final int totalPagesWeek;
  final double dailyAverage;
  final double maxY;
  final List<Map<String, dynamic>> themeStats;

  const _ReadingStatsVm({
    required this.completedCount,
    required this.lastCompletedBookTitle,
    required this.weeklyData,
    required this.sortedDates,
    required this.totalPagesWeek,
    required this.dailyAverage,
    required this.maxY,
    required this.themeStats,
  });

  factory _ReadingStatsVm.fromService(ReadingService service) {
    final completedCount = service.completedBooks.length;
    final lastBookTitle = service.lastCompletedBook?.title;

    final weeklyData = service.getWeeklyReadPages();
    final sortedDates = weeklyData.keys.toList()..sort();

    final totalPagesWeek = weeklyData.values.fold(0, (sum, val) => sum + val);
    final dailyAverage = totalPagesWeek / 7;

    final int maxValue = weeklyData.isEmpty
        ? 0
        : weeklyData.values.reduce((a, b) => a > b ? a : b);
    final maxY = (maxValue * 1.2).clamp(10.0, double.infinity);

    final themeStats = service.getThemeStats();

    return _ReadingStatsVm(
      completedCount: completedCount,
      lastCompletedBookTitle: lastBookTitle,
      weeklyData: weeklyData,
      sortedDates: sortedDates,
      totalPagesWeek: totalPagesWeek,
      dailyAverage: dailyAverage,
      maxY: maxY,
      themeStats: themeStats,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _ReadingStatsVm &&
        other.completedCount == completedCount &&
        other.lastCompletedBookTitle == lastCompletedBookTitle &&
        other.totalPagesWeek == totalPagesWeek &&
        other.dailyAverage == dailyAverage &&
        other.maxY == maxY &&
        _mapEquals(other.weeklyData, weeklyData) &&
        _listEquals(other.sortedDates, sortedDates) &&
        _themeStatsEquals(other.themeStats, themeStats);
  }

  @override
  int get hashCode => Object.hash(
        completedCount,
        lastCompletedBookTitle,
        totalPagesWeek,
        dailyAverage,
        maxY,
        weeklyData.length,
        sortedDates.length,
        themeStats.length,
      );

  static bool _mapEquals(Map<DateTime, int> a, Map<DateTime, int> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      final otherValue = b[entry.key];
      if (otherValue != entry.value) return false;
    }
    return true;
  }

  static bool _listEquals(List<DateTime> a, List<DateTime> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _themeStatsEquals(
      List<Map<String, dynamic>> a, List<Map<String, dynamic>> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      final ai = a[i];
      final bi = b[i];
      if (ai['theme'] != bi['theme']) return false;
      if (ai['count'] != bi['count']) return false;
      if (ai['percent'] != bi['percent']) return false;
    }
    return true;
  }
}
