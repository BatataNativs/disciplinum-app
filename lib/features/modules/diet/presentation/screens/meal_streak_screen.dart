import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:disciplinum/features/modules/diet/domain/entities/meal_entry_entity.dart';
import 'package:disciplinum/features/modules/diet/presentation/providers/meal_tracking_provider.dart';

class MealStreakScreen extends ConsumerStatefulWidget {
  final List<TimeOfDay> scheduledTimes;
  const MealStreakScreen({super.key, required this.scheduledTimes});

  @override
  ConsumerState<MealStreakScreen> createState() => _MealStreakScreenState();
}

class _MealStreakScreenState extends ConsumerState<MealStreakScreen> {
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final notifier = ref.read(mealTrackingProvider.notifier);
    final names = ['Café da manhã', 'Lanche da manhã', 'Almoço', 'Lanche da tarde', 'Jantar', 'Ceia'];
    final mealNames = names.sublist(0, widget.scheduledTimes.length.clamp(1, names.length));
    await notifier.createDefaultMealsForDay(widget.scheduledTimes, mealNames);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(mealTrackingProvider);

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
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => ref.read(mealTrackingProvider.notifier).loadData(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStreakCard(isDark, state.streak),
                      const SizedBox(height: 20),
                      _buildTodaySection(isDark, state.todayMeals),
                      const SizedBox(height: 20),
                      _buildHistorySection(isDark, state.history),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildStreakCard(bool isDark, int streak) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: streak > 0
              ? [const Color(0xFF6366F1), const Color(0xFF818CF8)]
              : [Colors.grey.shade600, Colors.grey.shade500],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (streak > 0 ? const Color(0xFF6366F1) : Colors.grey)
                .withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            streak > 0 ? Icons.local_fire_department : Icons.restaurant,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            '$streak',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            streak == 1 ? 'dia mantendo sua dieta' : 'dias mantendo sua dieta',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          if (streak == 0)
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

  Widget _buildTodaySection(bool isDark, List<MealEntryEntity> meals) {
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
        if (meals.isEmpty)
          _buildEmptyState(isDark, 'Nenhum horário configurado')
        else
          ...(meals.map((meal) => _buildMealTile(meal, isDark))),
      ],
    );
  }

  Widget _buildMealTile(MealEntryEntity meal, bool isDark) {
    final bool isPending = !meal.wasCompleted;
    final bool isDone = meal.wasCompleted && meal.wasOnTime;
    final bool isMissed = meal.wasCompleted && !meal.wasOnTime;
    
    Color dotColor;
    IconData statusIcon;
    String statusText;

    if (isDone) {
      dotColor = const Color(0xFF22C55E);
      statusIcon = Icons.check_circle;
      statusText = 'Feita no horário';
    } else if (isMissed) {
      dotColor = const Color(0xFFF59E0B);
      statusIcon = Icons.access_time;
      statusText = 'Feita fora do horário';
    } else if (!meal.wasCompleted) {
      dotColor = isDark ? Colors.grey.shade600 : Colors.grey.shade400;
      statusIcon = Icons.radio_button_unchecked;
      statusText = 'Pendente';
    } else {
      dotColor = const Color(0xFFEF4444);
      statusIcon = Icons.cancel;
      statusText = 'Não feita';
    }

    final timeStr = '${meal.plannedTime.hour.toString().padLeft(2, '0')}:${meal.plannedTime.minute.toString().padLeft(2, '0')}';

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
                  meal.mealName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  'Horário: $timeStr',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : Colors.black54,
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
          if (isPending)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildQuickAction(
                  icon: Icons.check,
                  color: const Color(0xFF22C55E),
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    await ref.read(mealTrackingProvider.notifier).recordMeal(
                      TimeOfDay(hour: meal.plannedTime.hour, minute: meal.plannedTime.minute),
                      done: true,
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildQuickAction(
                  icon: Icons.close,
                  color: const Color(0xFFEF4444),
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    await ref.read(mealTrackingProvider.notifier).recordMeal(
                      TimeOfDay(hour: meal.plannedTime.hour, minute: meal.plannedTime.minute),
                      done: false,
                    );
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

  Widget _buildHistorySection(bool isDark, List<DaySummary> history) {
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
        if (history.isEmpty)
          _buildEmptyState(isDark, 'Nenhum registro encontrado')
        else
          ...(history.reversed.map((day) => _buildDayTile(day, isDark))),
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
