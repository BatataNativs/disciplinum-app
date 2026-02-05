// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:disciplinum/models/8_procrastination/procrastination_model.dart';
import 'package:disciplinum/services/8_procrastination/procrastination_service.dart';

/// Dialog de criação/edição de tarefa estilo Google Tasks
class TaskCreationDialog extends StatefulWidget {
  final ProcrastinationService service;
  final String listId;
  final ProcrastinationTask? taskToEdit;

  const TaskCreationDialog({
    super.key,
    required this.service,
    required this.listId,
    this.taskToEdit,
  });

  static Future<bool?> show(
    BuildContext context, {
    required ProcrastinationService service,
    required String listId,
    ProcrastinationTask? taskToEdit,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TaskCreationDialog(
        service: service,
        listId: listId,
        taskToEdit: taskToEdit,
      ),
    );
  }

  @override
  State<TaskCreationDialog> createState() => _TaskCreationDialogState();
}

class _TaskCreationDialogState extends State<TaskCreationDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _titleFocus = FocusNode();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  TaskRepetition _repetition = TaskRepetition.none;
  RepetitionConfig? _repetitionConfig;

  bool get isEditing => widget.taskToEdit != null;

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      _titleController.text = widget.taskToEdit!.title;
      _descController.text = widget.taskToEdit!.description ?? '';
      _selectedDate = widget.taskToEdit!.scheduledDate;
      if (widget.taskToEdit!.startTime != null) {
        _startTime = TimeOfDay.fromDateTime(widget.taskToEdit!.startTime!);
      }
      if (widget.taskToEdit!.endTime != null) {
        _endTime = TimeOfDay.fromDateTime(widget.taskToEdit!.endTime!);
      }
      _repetition = widget.taskToEdit!.repetition;
      _repetitionConfig = widget.taskToEdit!.repetitionConfig;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campo título
          TextField(
            controller: _titleController,
            focusNode: _titleFocus,
            autofocus: true,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'Nova tarefa',
              hintStyle: TextStyle(
                color: isDark ? Colors.white54 : Colors.black38,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),

          const SizedBox(height: 8),

          // Campo descrição
          TextField(
            controller: _descController,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            decoration: InputDecoration(
              hintText: 'descrição',
              hintStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.black26,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),

          const SizedBox(height: 16),

          // Ícones de ação e botão salvar
          Row(
            children: [
              // Ícone de data/hora
              _buildActionIcon(
                icon: Icons.access_time_outlined,
                isActive: _selectedDate != null || _startTime != null,
                onTap: _showDateTimeDialog,
              ),

              const Spacer(),

              // Botão Salvar
              TextButton(
                onPressed: _saveTask,
                child: Text(
                  'Salvar',
                  style: TextStyle(
                    color: _titleController.text.isNotEmpty
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          // Mostra data/hora selecionadas
          if (_selectedDate != null || _startTime != null) ...[
            const SizedBox(height: 8),
            _buildSelectedDateTime(isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 24,
          color: isActive
              ? Theme.of(context).primaryColor
              : (isDark ? Colors.white54 : Colors.black38),
        ),
      ),
    );
  }

  Widget _buildSelectedDateTime(bool isDark) {
    final parts = <String>[];

    if (_selectedDate != null) {
      parts.add(DateFormat('dd/MM/yyyy').format(_selectedDate!));
    }

    if (_startTime != null && _endTime != null) {
      parts
          .add('${_startTime!.format(context)} - ${_endTime!.format(context)}');
    } else if (_startTime != null) {
      parts.add(_startTime!.format(context));
    }

    if (_repetition != TaskRepetition.none) {
      parts.add(_repetition.label);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.event,
            size: 16,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              parts.join(' • '),
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = null;
                _startTime = null;
                _endTime = null;
                _repetition = TaskRepetition.none;
                _repetitionConfig = null;
              });
            },
            child: Icon(
              Icons.close,
              size: 16,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  void _showDateTimeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _DateTimePickerDialog(
        initialDate: _selectedDate,
        initialStartTime: _startTime,
        initialEndTime: _endTime,
        initialRepetition: _repetition,
        initialRepetitionConfig: _repetitionConfig,
        onConfirm: (date, startTime, endTime, repetition, config) {
          setState(() {
            _selectedDate = date;
            _startTime = startTime;
            _endTime = endTime;
            _repetition = repetition;
            _repetitionConfig = config;
          });
        },
      ),
    );
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) return;

    HapticFeedback.mediumImpact();

    DateTime? startDt;
    DateTime? endDt;

    final baseDate = _selectedDate ?? DateTime.now();

    if (_startTime != null) {
      startDt = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        _startTime!.hour,
        _startTime!.minute,
      );
    }
    if (_endTime != null) {
      endDt = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        _endTime!.hour,
        _endTime!.minute,
      );
    }

    if (isEditing) {
      final updated = widget.taskToEdit!.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        scheduledDate: _selectedDate,
        startTime: startDt,
        endTime: endDt,
        repetition: _repetition,
        repetitionConfig: _repetitionConfig,
      );
      widget.service.updateTaskInList(widget.listId, updated);
    } else {
      final task = ProcrastinationTask(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        scheduledDate: _selectedDate,
        startTime: startDt,
        endTime: endDt,
        listId: widget.listId,
        repetition: _repetition,
        repetitionConfig: _repetitionConfig,
      );
      widget.service.addTaskToList(widget.listId, task);
    }

    Navigator.pop(context, true);
  }
}

/// Dialog de seleção de data/hora estilo Google Tasks
class _DateTimePickerDialog extends StatefulWidget {
  final DateTime? initialDate;
  final TimeOfDay? initialStartTime;
  final TimeOfDay? initialEndTime;
  final TaskRepetition initialRepetition;
  final RepetitionConfig? initialRepetitionConfig;
  final void Function(
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    TaskRepetition repetition,
    RepetitionConfig? config,
  ) onConfirm;

  const _DateTimePickerDialog({
    this.initialDate,
    this.initialStartTime,
    this.initialEndTime,
    this.initialRepetition = TaskRepetition.none,
    this.initialRepetitionConfig,
    required this.onConfirm,
  });

  @override
  State<_DateTimePickerDialog> createState() => _DateTimePickerDialogState();
}

class _DateTimePickerDialogState extends State<_DateTimePickerDialog> {
  late DateTime _focusedMonth;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  TaskRepetition _repetition = TaskRepetition.none;
  RepetitionConfig? _repetitionConfig;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _focusedMonth = widget.initialDate ?? DateTime.now();
    _startTime = widget.initialStartTime;
    _endTime = widget.initialEndTime;
    _repetition = widget.initialRepetition;
    _repetitionConfig = widget.initialRepetitionConfig;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header do calendário
              _buildCalendarHeader(isDark),

              const SizedBox(height: 8),

              // Calendário
              _buildCalendar(isDark),

              const SizedBox(height: 16),

              // Botões de hora
              Row(
                children: [
                  Expanded(
                    child: _buildTimeButton(
                      label: _startTime != null
                          ? _startTime!.format(context)
                          : 'Definir hora',
                      icon: Icons.access_time,
                      onTap: () => _selectTime(isStart: true),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTimeButton(
                      label: _endTime != null
                          ? _endTime!.format(context)
                          : 'Definir intervalo',
                      icon: Icons.timelapse,
                      onTap: () => _selectTime(isStart: false),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Repetição
              _buildRepetitionButton(isDark),

              const SizedBox(height: 16),

              // Botões de ação
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      widget.onConfirm(
                        _selectedDate,
                        _startTime,
                        _endTime,
                        _repetition,
                        _repetitionConfig,
                      );
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Concluído',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarHeader(bool isDark) {
    final monthYear =
        DateFormat('MMMM \'de\' yyyy', 'pt_BR').format(_focusedMonth);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () {
            setState(() {
              _focusedMonth = DateTime(
                _focusedMonth.year,
                _focusedMonth.month - 1,
              );
            });
          },
        ),
        Text(
          monthYear,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.chevron_right,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () {
            setState(() {
              _focusedMonth = DateTime(
                _focusedMonth.year,
                _focusedMonth.month + 1,
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildCalendar(bool isDark) {
    final firstDayOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = domingo
    final daysInMonth = lastDayOfMonth.day;

    final days = <Widget>[];

    // Header dias da semana
    const weekDays = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
    for (final day in weekDays) {
      days.add(
        Center(
          child: Text(
            day,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ),
      );
    }

    // Espaços vazios antes do primeiro dia
    for (int i = 0; i < firstWeekday; i++) {
      days.add(const SizedBox());
    }

    // Dias do mês
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final isSelected = _selectedDate != null &&
          _selectedDate!.year == date.year &&
          _selectedDate!.month == date.month &&
          _selectedDate!.day == date.day;
      final isToday = DateTime.now().year == date.year &&
          DateTime.now().month == date.month &&
          DateTime.now().day == date.day;

      days.add(
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedDate = date);
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF6366F1).withValues(alpha: 0.8)
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: isToday && !isSelected
                  ? Border.all(color: const Color(0xFF6366F1))
                  : null,
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      childAspectRatio: 1,
      children: days,
    );
  }

  Widget _buildTimeButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepetitionButton(bool isDark) {
    return InkWell(
      onTap: _showRepetitionDialog,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.repeat,
              size: 20,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _repetition == TaskRepetition.none
                    ? 'Repetição'
                    : _repetition.label,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime({required bool isStart}) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (_startTime ?? TimeOfDay.now())
          : (_endTime ?? _startTime ?? TimeOfDay.now()),
    );

    if (time != null) {
      setState(() {
        if (isStart) {
          _startTime = time;
        } else {
          _endTime = time;
        }
      });
    }
  }

  void _showRepetitionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _RepetitionDialog(
        initialRepetition: _repetition,
        initialConfig: _repetitionConfig,
        selectedDate: _selectedDate ?? DateTime.now(),
        onConfirm: (repetition, config) {
          setState(() {
            _repetition = repetition;
            _repetitionConfig = config;
          });
        },
      ),
    );
  }
}

/// Dialog de configuração de repetição estilo Google Tasks
class _RepetitionDialog extends StatefulWidget {
  final TaskRepetition initialRepetition;
  final RepetitionConfig? initialConfig;
  final DateTime selectedDate;
  final void Function(TaskRepetition, RepetitionConfig?) onConfirm;

  const _RepetitionDialog({
    required this.initialRepetition,
    this.initialConfig,
    required this.selectedDate,
    required this.onConfirm,
  });

  @override
  State<_RepetitionDialog> createState() => _RepetitionDialogState();
}

class _RepetitionDialogState extends State<_RepetitionDialog> {
  late int _interval;
  late String _unit;
  late List<int> _weekDays;
  late DateTime _startDate;
  String _endMode = 'never'; // 'never', 'date', 'occurrences'
  DateTime? _endDate;
  int _occurrences = 10;

  @override
  void initState() {
    super.initState();
    _interval = widget.initialConfig?.interval ?? 1;
    _unit = widget.initialConfig?.unit ?? 'week';
    _weekDays =
        widget.initialConfig?.weekDays ?? [widget.selectedDate.weekday % 7];
    _startDate = widget.initialConfig?.startDate ?? widget.selectedDate;
    _endDate = widget.initialConfig?.endDate;
    _occurrences = widget.initialConfig?.occurrences ?? 10;

    if (widget.initialConfig?.endDate != null) {
      _endMode = 'date';
    } else if (widget.initialConfig?.occurrences != null) {
      _endMode = 'occurrences';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Repete',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _confirm,
                    child: Text(
                      'Concluído',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Intervalo: "Cada X semana/dia/mês"
              Text(
                'Cada',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Campo número
                  Container(
                    width: 60,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? Colors.white24 : Colors.black12,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: TextEditingController(text: '$_interval'),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (val) {
                        _interval = int.tryParse(val) ?? 1;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Dropdown unidade
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark ? Colors.white24 : Colors.black12,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: _unit,
                        isExpanded: true,
                        underline: const SizedBox(),
                        dropdownColor:
                            isDark ? const Color(0xFF3D3D3D) : Colors.white,
                        items: const [
                          DropdownMenuItem(value: 'day', child: Text('dia')),
                          DropdownMenuItem(
                              value: 'week', child: Text('semana')),
                          DropdownMenuItem(value: 'month', child: Text('mês')),
                          DropdownMenuItem(value: 'year', child: Text('ano')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _unit = val);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),

              // Dias da semana (se unidade for semana)
              if (_unit == 'week') ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(7, (index) {
                    final days = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
                    final isSelected = _weekDays.contains(index);

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          if (isSelected && _weekDays.length > 1) {
                            _weekDays.remove(index);
                          } else if (!isSelected) {
                            _weekDays.add(index);
                          }
                        });
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF6366F1).withValues(alpha: 0.8)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF6366F1)
                                : (isDark ? Colors.white24 : Colors.black12),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            days[index],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : Colors.black54),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Início
              Text(
                'Início',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectStartDate,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark ? Colors.white24 : Colors.black12,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    DateFormat('d \'de\' MMMM', 'pt_BR').format(_startDate),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Término
              Text(
                'Término',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
              const SizedBox(height: 12),

              // Opção: Nunca
              _buildEndOption(
                'Nunca',
                'never',
                isDark,
              ),

              const SizedBox(height: 8),

              // Opção: Em data
              Row(
                children: [
                  Radio<String>(
                    value: 'date',
                    groupValue: _endMode,
                    onChanged: (val) => setState(() => _endMode = val!),
                  ),
                  const Text('Em'),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() => _endMode = 'date');
                        _selectEndDate();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark ? Colors.white24 : Colors.black12,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _endDate != null
                              ? DateFormat('d \'de\' MMMM', 'pt_BR')
                                  .format(_endDate!)
                              : 'Selecionar data',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Opção: Após X ocorrências
              Row(
                children: [
                  Radio<String>(
                    value: 'occurrences',
                    groupValue: _endMode,
                    onChanged: (val) => setState(() => _endMode = val!),
                  ),
                  const Text('Após'),
                  const SizedBox(width: 12),
                  Container(
                    width: 60,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? Colors.white24 : Colors.black12,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: TextEditingController(text: '$_occurrences'),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onTap: () => setState(() => _endMode = 'occurrences'),
                      onChanged: (val) {
                        _occurrences = int.tryParse(val) ?? 10;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ocorrências',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEndOption(String label, String value, bool isDark) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: _endMode,
          onChanged: (val) => setState(() => _endMode = val!),
        ),
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  void _confirm() {
    TaskRepetition repetition;
    RepetitionConfig? config;

    if (_interval == 1 && _unit == 'day') {
      repetition = TaskRepetition.daily;
    } else if (_interval == 1 && _unit == 'week') {
      repetition = TaskRepetition.weekly;
    } else if (_interval == 1 && _unit == 'month') {
      repetition = TaskRepetition.monthly;
    } else if (_interval == 1 && _unit == 'year') {
      repetition = TaskRepetition.yearly;
    } else {
      repetition = TaskRepetition.custom;
    }

    config = RepetitionConfig(
      interval: _interval,
      unit: _unit,
      weekDays: _unit == 'week' ? _weekDays : null,
      startDate: _startDate,
      endDate: _endMode == 'date' ? _endDate : null,
      occurrences: _endMode == 'occurrences' ? _occurrences : null,
    );

    widget.onConfirm(repetition, config);
    Navigator.pop(context);
  }
}
