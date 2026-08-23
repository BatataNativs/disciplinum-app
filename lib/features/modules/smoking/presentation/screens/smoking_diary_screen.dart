import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/core/utils/enhanced_snackbar_helper.dart';

class SmokingDiaryScreen extends ConsumerStatefulWidget {
  const SmokingDiaryScreen({super.key});

  @override
  ConsumerState<SmokingDiaryScreen> createState() => _SmokingDiaryScreenState();
}

class _SmokingDiaryScreenState extends ConsumerState<SmokingDiaryScreen> {
  late DateTime _selectedMonth;
  late DateTime _selectedDate;
  final TextEditingController _textController = TextEditingController();
  String? _selectedMood;
  bool _isLoading = true;
  Set<String> _datesWithEntries = {};

  final List<Map<String, String>> _moodOptions = [
    {'key': 'calm', 'label': 'Calmo', 'emoji': '😌'},
    {'key': 'anxious', 'label': 'Ansioso', 'emoji': '😰'},
    {'key': 'craving', 'label': 'Com Vontade de Fumar', 'emoji': '🔥'},
    {'key': 'angry', 'label': 'Irritado', 'emoji': '😡'},
    {'key': 'proud', 'label': 'Orgulhoso', 'emoji': '💪'},
    {'key': 'sad', 'label': 'Cansado/Desanimado', 'emoji': '😔'},
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
    _selectedDate = DateTime(now.year, now.month, now.day);
    _loadDiaryData();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  String _formatDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _loadDiaryData() async {
    setState(() => _isLoading = true);
    final diaryService = ref.read(smokingDiaryServiceProvider);
    final dates = await diaryService.getDatesWithEntries();

    final dateKey = _formatDateKey(_selectedDate);
    final entry = await diaryService.getEntryForDate(dateKey);

    if (mounted) {
      setState(() {
        _datesWithEntries = dates;
        _textController.text = entry?.text ?? '';
        _selectedMood = entry?.mood;
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDay(DateTime day) async {
    if (_formatDateKey(day) == _formatDateKey(_selectedDate)) return;

    HapticFeedback.selectionClick();
    setState(() {
      _selectedDate = day;
      _isLoading = true;
    });

    final diaryService = ref.read(smokingDiaryServiceProvider);
    final dateKey = _formatDateKey(day);
    final entry = await diaryService.getEntryForDate(dateKey);

    if (mounted) {
      setState(() {
        _textController.text = entry?.text ?? '';
        _selectedMood = entry?.mood;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveCurrentEntry() async {
    final text = _textController.text.trim();
    final dateKey = _formatDateKey(_selectedDate);
    final diaryService = ref.read(smokingDiaryServiceProvider);

    await diaryService.saveEntry(
      dateKey: dateKey,
      text: text,
      mood: _selectedMood,
    );

    HapticFeedback.mediumImpact();
    final dates = await diaryService.getDatesWithEntries();

    if (mounted) {
      setState(() {
        _datesWithEntries = dates;
      });
      FocusScope.of(context).unfocus();
      EnhancedSnackBarHelper.showSuccess(
        context,
        text.isEmpty ? 'Anotação removida' : 'Anotação salva com segurança!',
      );
    }
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
        1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final monthFormat = DateFormat('MMMM yyyy', 'pt_BR');
    final formattedMonth = monthFormat.format(_selectedMonth);
    final formattedSelectedDate = DateFormat("d 'de' MMMM", 'pt_BR').format(_selectedDate);

    final isToday = _formatDateKey(_selectedDate) == _formatDateKey(DateTime.now());

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Diário de Pensamentos'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveCurrentEntry,
            child: const Text(
              'Salvar',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF6366F1),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Calendário Mensal
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  children: [
                    // Seletor de Mês Compacto
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          icon: const Icon(Icons.chevron_left_rounded, size: 22),
                          onPressed: _previousMonth,
                        ),
                        Text(
                          formattedMonth[0].toUpperCase() + formattedMonth.substring(1),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          icon: const Icon(Icons.chevron_right_rounded, size: 22),
                          onPressed: _nextMonth,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Dias da Semana
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'].map((day) {
                        return SizedBox(
                          width: 32,
                          child: Text(
                            day,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 4),
                    // Grade dos Dias
                    _buildCalendarGrid(),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Área da Anotação do Dia
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.edit_note_rounded,
                              color: Color(0xFF6366F1),
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isToday ? 'Hoje ($formattedSelectedDate)' : formattedSelectedDate,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        if (_textController.text.isNotEmpty)
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                              color: colorScheme.error.withValues(alpha: 0.7),
                            ),
                            tooltip: 'Apagar anotação',
                            onPressed: () {
                              _textController.clear();
                              _selectedMood = null;
                              _saveCurrentEntry();
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Humor / Estado Emocional
                    Text(
                      'Como você está se sentindo?',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _moodOptions.map((m) {
                          final isSelected = _selectedMood == m['key'];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text('${m['emoji']} ${m['label']}'),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedMood = selected ? m['key'] : null;
                                });
                              },
                              selectedColor: const Color(0xFF6366F1).withValues(alpha: 0.15),
                              checkmarkColor: const Color(0xFF6366F1),
                              labelStyle: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? const Color(0xFF6366F1)
                                    : colorScheme.onSurface,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Campo de Texto Livre
                    _isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : TextField(
                            controller: _textController,
                            minLines: 5,
                            maxLines: 15,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Escreva o que estiver passando pela sua cabeça...\nDesabafe, anote a vontade de fumar, xingue se precisar, expresse sua vitória.',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: colorScheme.onSurface.withValues(alpha: 0.4),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: colorScheme.outline.withValues(alpha: 0.15),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: colorScheme.outline.withValues(alpha: 0.15),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFF6366F1),
                                  width: 1.5,
                                ),
                              ),
                              filled: true,
                              fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                            ),
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Selo de Privacidade
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      color: Color(0xFF10B981),
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '100% Privado e Seguro',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Suas anotações são pessoais, salvas apenas no seu aparelho e não são compartilhadas.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
    );
  }

  Widget _buildCalendarGrid() {
    final colorScheme = Theme.of(context).colorScheme;
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

    final startingWeekday = firstDayOfMonth.weekday % 7; // 0 = Domingo
    final daysInMonth = lastDayOfMonth.day;

    final List<Widget> dayWidgets = [];

    // Espaços vazios antes do primeiro dia
    for (int i = 0; i < startingWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 32, height: 30));
    }

    // Dias do mês
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
      final dateKey = _formatDateKey(date);
      final isSelected = _formatDateKey(date) == _formatDateKey(_selectedDate);
      final isToday = _formatDateKey(date) == _formatDateKey(DateTime.now());
      final hasEntry = _datesWithEntries.contains(dateKey);

      dayWidgets.add(
        GestureDetector(
          onTap: () => _selectDay(date),
          child: Container(
            width: 32,
            height: 30,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF6366F1)
                  : (isToday
                      ? const Color(0xFF6366F1).withValues(alpha: 0.15)
                      : Colors.transparent),
              shape: BoxShape.circle,
              border: isToday && !isSelected
                  ? Border.all(color: const Color(0xFF6366F1), width: 1.1)
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected || isToday
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? Colors.white
                        : colorScheme.onSurface,
                  ),
                ),
                if (hasEntry)
                  Positioned(
                    bottom: 2,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.white : const Color(0xFF10B981),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    // Completar última semana com espaços vazios para fechar a grade de 7
    while (dayWidgets.length % 7 != 0) {
      dayWidgets.add(const SizedBox(width: 32, height: 30));
    }

    // Dividir em semanas (linhas de 7 dias)
    final List<Widget> weekRows = [];
    for (int i = 0; i < dayWidgets.length; i += 7) {
      weekRows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: dayWidgets.sublist(i, i + 7),
          ),
        ),
      );
    }

    return Column(
      children: weekRows,
    );
  }
}