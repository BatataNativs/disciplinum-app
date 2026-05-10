import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:disciplinum/features/modules/diet/domain/entities/meal_entry_entity.dart';
import 'package:disciplinum/features/modules/diet/presentation/providers/meal_tracking_provider.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

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
    
    // Gerar nomes baseados no período do dia
    final mealNames = widget.scheduledTimes.map((time) {
      if (time.hour >= 0 && time.hour < 6) {
        return 'Refeição da madrugada';
      } else if (time.hour >= 6 && time.hour < 12) {
        return 'Refeição da manhã';
      } else if (time.hour >= 12 && time.hour < 18) {
        return 'Refeição da tarde';
      } else {
        return 'Refeição da noite';
      }
    }).toList();
    
    await notifier.createDefaultMealsForDay(widget.scheduledTimes, mealNames);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(mealTrackingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Refeições'),
        centerTitle: true,
      ),
      body: Container(
        color: colorScheme.surface,
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
                      _buildStreakCard(colorScheme, state.streak),
                      const SizedBox(height: 20),
                      _buildTodaySection(colorScheme, state.todayMeals),
                      const SizedBox(height: 20),
                      _buildHistorySection(colorScheme, state.history),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildStreakCard(ColorScheme colorScheme, int streak) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.9),
            colorScheme.primary.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
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

  Widget _buildTodaySection(ColorScheme colorScheme, List<MealEntryEntity> meals) {
    // Agrupar refeições por período do dia
    final Map<String, List<MealEntryEntity>> mealsByPeriod = {
      'Manhã': [],
      'Tarde': [],
      'Noite': [],
      'Madrugada': [],
    };

    for (final meal in meals) {
      final hour = meal.plannedTime.hour;
      String period;
      if (hour >= 0 && hour < 6) {
        period = 'Madrugada';
      } else if (hour >= 6 && hour < 12) {
        period = 'Manhã';
      } else if (hour >= 12 && hour < 18) {
        period = 'Tarde';
      } else {
        period = 'Noite';
      }
      mealsByPeriod[period]!.add(meal);
    }

    // Ordenar horários dentro de cada período
    for (final period in mealsByPeriod.keys) {
      mealsByPeriod[period]!.sort((a, b) => a.plannedTime.hour.compareTo(b.plannedTime.hour));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hoje',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        if (meals.isEmpty)
          _buildEmptyState(colorScheme, 'Nenhum horário configurado')
        else
          ...mealsByPeriod.entries.where((entry) => entry.value.isNotEmpty).map((entry) {
            final period = entry.key;
            final periodMeals = entry.value;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título do período
                Text(
                  '$period:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                // Horários do período
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: periodMeals.map((meal) => _buildCompactMealTile(meal, colorScheme)).toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          }),
      ],
    );
  }

  Widget _buildCompactMealTile(MealEntryEntity meal, ColorScheme colorScheme) {
    final bool isPending = !meal.wasCompleted;
    final bool isDone = meal.wasCompleted && meal.wasOnTime;
    final bool isMissed = meal.wasCompleted && !meal.wasOnTime;
    
    final timeStr = '${meal.plannedTime.hour.toString().padLeft(2, '0')}:${meal.plannedTime.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Horário
          Text(
            timeStr,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          
          // Status - sempre visível
          if (isDone)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: const Color(0xFF22C55E),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Feito',
                    style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xFF22C55E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else if (isMissed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule,
                    color: const Color(0xFFF59E0B),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Fora',
                    style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xFFF59E0B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF6B7280).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.radio_button_unchecked,
                    color: const Color(0xFF6B7280),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Pendente',
                    style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          
          // Botões de ação (apenas se pendente)
          if (isPending) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () async {
                try {
                  final notifier = ref.read(mealTrackingProvider.notifier);
                  await notifier.recordMeal(
                    TimeOfDay(hour: meal.plannedTime.hour, minute: meal.plannedTime.minute),
                    done: true,
                  );
                  // Forçar atualização da UI
                  if (mounted) {
                    ref.invalidate(mealTrackingProvider);
                    setState(() {});
                  }
                } catch (e) {
                  LoggerService.instance.e('Erro ao registrar refeição como feita: $e');
                }
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () async {
                try {
                  final notifier = ref.read(mealTrackingProvider.notifier);
                  await notifier.recordMeal(
                    TimeOfDay(hour: meal.plannedTime.hour, minute: meal.plannedTime.minute),
                    done: false,
                  );
                  // Forçar atualização da UI
                  if (mounted) {
                    ref.invalidate(mealTrackingProvider);
                    setState(() {});
                  }
                } catch (e) {
                  LoggerService.instance.e('Erro ao registrar refeição como não feita: $e');
                }
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  
  
  Widget _buildHistorySection(ColorScheme colorScheme, List<DaySummary> history) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Últimos 7 dias',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        if (history.isEmpty)
          _buildEmptyState(colorScheme, 'Nenhum registro encontrado')
        else
          ...(history.reversed.map((day) => _buildDayTile(day, colorScheme))),
      ],
    );
  }

  Widget _buildDayTile(DaySummary day, ColorScheme colorScheme) {
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
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
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
                color: colorScheme.onSurface,
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

  Widget _buildEmptyState(ColorScheme colorScheme, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 40,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
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
