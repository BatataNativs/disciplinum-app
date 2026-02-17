import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:disciplinum/services/3_diet/meal_tracking_service.dart';

class MealStreakScreen extends StatefulWidget {
  final List<TimeOfDay> scheduledTimes;
  const MealStreakScreen({super.key, required this.scheduledTimes});

  @override
  State<MealStreakScreen> createState() => _MealStreakScreenState();
}

class _MealStreakScreenState extends State<MealStreakScreen> {
  List<MealRecord> _todayMeals = [];
  List<DaySummary> _history = [];
  int _streak = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final service = MealTrackingService.instance;
    final meals = await service.getTodayMeals(widget.scheduledTimes);
    final history = await service.getHistory(days: 7);
    final streak = await service.getCurrentStreak();

    if (mounted) {
      setState(() {
        _todayMeals = meals;
        _history = history;
        _streak = streak;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Refeições'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDark
                  ? const Color.fromARGB(255, 0, 0, 0)
                  : const Color.fromARGB(255, 230, 235, 255),
              isDark
                  ? const Color.fromARGB(255, 10, 15, 30)
                  : const Color.fromARGB(255, 255, 255, 255),
            ],
          ),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStreakCard(isDark),
                      const SizedBox(height: 20),
                      _buildTodaySection(isDark),
                      const SizedBox(height: 20),
                      _buildHistorySection(isDark),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildStreakCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _streak > 0
              ? [const Color(0xFF6366F1), const Color(0xFF818CF8)]
              : [Colors.grey.shade600, Colors.grey.shade500],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (_streak > 0 ? const Color(0xFF6366F1) : Colors.grey)
                .withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            _streak > 0 ? Icons.local_fire_department : Icons.restaurant,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            '$_streak',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            _streak == 1 ? 'dia mantendo sua dieta' : 'dias mantendo sua dieta',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          if (_streak == 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Responda às notificações para começar!',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTodaySection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hoje',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        if (_todayMeals.isEmpty)
          _buildEmptyState(isDark, 'Nenhum horário configurado')
        else
          ...(_todayMeals.map((meal) => _buildMealTile(meal, isDark))),
      ],
    );
  }

  Widget _buildMealTile(MealRecord meal, bool isDark) {
    Color dotColor;
    IconData statusIcon;
    String statusText;

    switch (meal.status) {
      case MealStatus.done:
        dotColor = const Color(0xFF22C55E);
        statusIcon = Icons.check_circle;
        statusText = 'Feita';
        break;
      case MealStatus.missed:
        dotColor = const Color(0xFFEF4444);
        statusIcon = Icons.cancel;
        statusText = 'Não feita';
        break;
      case MealStatus.pending:
        dotColor = isDark ? Colors.grey.shade600 : Colors.grey.shade400;
        statusIcon = Icons.radio_button_unchecked;
        statusText = 'Pendente';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: dotColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statusIcon, color: dotColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Refeição das ${meal.time}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 13,
                    color: dotColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (meal.status == MealStatus.pending)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildQuickAction(
                  icon: Icons.check,
                  color: const Color(0xFF22C55E),
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    await MealTrackingService.instance
                        .recordMeal(meal.time, done: true);
                    _loadData();
                  },
                ),
                const SizedBox(width: 8),
                _buildQuickAction(
                  icon: Icons.close,
                  color: const Color(0xFFEF4444),
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    await MealTrackingService.instance
                        .recordMeal(meal.time, done: false);
                    _loadData();
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildHistorySection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Últimos 7 dias',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        if (_history.isEmpty)
          _buildEmptyState(isDark, 'Nenhum registro encontrado')
        else
          ...(_history.reversed.map((day) => _buildDayTile(day, isDark))),
      ],
    );
  }

  Widget _buildDayTile(DaySummary day, bool isDark) {
    final isToday = _isToday(day.date);
    final dateStr =
        isToday ? 'Hoje' : DateFormat('EEEE, d/MM', 'pt_BR').format(day.date);

    final successColor = const Color(0xFF22C55E);
    final failColor = const Color(0xFFEF4444);
    final statusColor = day.isSuccessful ? successColor : failColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.4),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              dateStr,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Text(
            '${day.doneMeals}/${day.totalMeals}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            day.isSuccessful ? Icons.check_circle_outline : Icons.warning_amber,
            size: 16,
            color: statusColor,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 40,
            color: isDark ? Colors.white24 : Colors.black12,
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
