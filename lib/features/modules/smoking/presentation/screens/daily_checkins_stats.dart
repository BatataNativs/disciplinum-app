import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';

class DailyCheckinsStats extends ConsumerStatefulWidget {
  const DailyCheckinsStats({super.key});

  @override
  ConsumerState<DailyCheckinsStats> createState() => _DailyCheckinsStatsState();
}

class _DailyCheckinsStatsState extends ConsumerState<DailyCheckinsStats> {
  bool _isLoading = true;
  Set<String> _checkinDates = {};

  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dates = await ref.read(smokingCheckinServiceProvider).loadCheckins();
    if (mounted) {
      setState(() {
        _checkinDates = dates
            .map((d) =>
                '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}')
            .toSet();
        _isLoading = false;
      });
    }
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool _isCheckin(DateTime d) => _checkinDates.contains(_dateKey(d));

  void _prevMonth() => setState(() {
        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      });

  void _nextMonth() {
    final next = DateTime(_currentMonth.year, _currentMonth.month + 1);
    if (next
        .isBefore(DateTime(DateTime.now().year, DateTime.now().month + 1))) {
      setState(() => _currentMonth = next);
    }
  }

  int get _totalCheckins => _checkinDates.length;

  int get _currentStreak {
    int streak = 0;
    DateTime day = DateTime.now();
    while (true) {
      if (_isCheckin(day)) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  int get _longestStreak {
    if (_checkinDates.isEmpty) return 0;
    final sorted = _checkinDates.toList()..sort();
    int longest = 1;
    int current = 1;
    for (int i = 1; i < sorted.length; i++) {
      final prev = DateTime.parse(sorted[i - 1]);
      final curr = DateTime.parse(sorted[i]);
      if (curr.difference(prev).inDays == 1) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 1;
      }
    }
    return longest;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surface,
            colorScheme.surfaceContainerHighest,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Check-ins Diários',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _buildStatsRow(),
                      const SizedBox(height: 24),
                      _buildCalendar(),
                      const SizedBox(height: 24),
                      _buildLegend(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard(
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF22C55E),
          label: 'Total',
          value: _totalCheckins.toString(),
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.local_fire_department_rounded,
          color: const Color(0xFFF97316),
          label: 'Sequência atual',
          value: _currentStreak.toString(),
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.military_tech_rounded,
          color: const Color(0xFFEAB308),
          label: 'Recorde',
          value: _longestStreak.toString(),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    final colorScheme = Theme.of(context).colorScheme;
    final monthName = _monthName(_currentMonth.month);
    final year = _currentMonth.year;
    final daysInMonth =
        DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final firstWeekday =
        DateTime(_currentMonth.year, _currentMonth.month, 1).weekday % 7;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Navegação mês
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _navButton(Icons.chevron_left_rounded, _prevMonth),
              Text(
                '$monthName $year',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
              _navButton(
                  Icons.chevron_right_rounded,
                  _nextMonth,
                ),
            ],
          ),
          const SizedBox(height: 20),
          // Cabeçalho dias da semana
          Row(
            children: ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb']
                .map(
                  (d) => Expanded(
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          // Grid do calendário
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: firstWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < firstWeekday) return const SizedBox.shrink();
              final day = index - firstWeekday + 1;
              final date =
                  DateTime(_currentMonth.year, _currentMonth.month, day);
              final isToday = _isSameDay(date, DateTime.now());
              final hasCheckin = _isCheckin(date);
              final isFuture = date.isAfter(DateTime.now());

              return _buildDayCell(
                day: day,
                isToday: isToday,
                hasCheckin: hasCheckin,
                isFuture: isFuture,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _navButton(IconData icon, VoidCallback? onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: onTap != null ? 0.5 : 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: onTap != null
              ? colorScheme.onSurface.withValues(alpha: 0.7)
              : colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildDayCell({
    required int day,
    required bool isToday,
    required bool hasCheckin,
    required bool isFuture,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    const checkinColor = Color(0xFF22C55E);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hasCheckin
            ? checkinColor.withValues(alpha: 0.18)
            : isToday
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                : Colors.transparent,
        border: Border.all(
          color: hasCheckin
              ? checkinColor
              : isToday
                  ? colorScheme.outline.withValues(alpha: 0.3)
                  : Colors.transparent,
          width: hasCheckin ? 2 : 1.5,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '$day',
            style: TextStyle(
              fontSize: 13,
              fontWeight:
                  hasCheckin || isToday ? FontWeight.bold : FontWeight.normal,
              color: hasCheckin
                  ? checkinColor
                  : isFuture
                      ? colorScheme.onSurface.withValues(alpha: 0.3)
                      : colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          if (hasCheckin)
            Positioned(
              bottom: 3,
              child: Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: checkinColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF22C55E).withValues(alpha: 0.18),
            border: Border.all(color: const Color(0xFF22C55E), width: 2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Dia sem fumar confirmado',
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _monthName(int month) {
    const names = [
      '',
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ];
    return names[month];
  }
}
