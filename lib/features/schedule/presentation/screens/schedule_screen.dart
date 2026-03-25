import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/shared/widgets/shared_widgets.dart';

class ScheduleScreenArgs {
  final int maxSlots;
  final List<TimeOfDay> initialTimes;
  final void Function(List<TimeOfDay>) onChanged;
  final int nicheId;
  final String? title;

  ScheduleScreenArgs({
    required this.maxSlots,
    required this.initialTimes,
    required this.onChanged,
    required this.nicheId,
    this.title,
  });
}

class ScheduleScreen extends ConsumerStatefulWidget {
  final ScheduleScreenArgs args;
  const ScheduleScreen({super.key, required this.args});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  late List<TimeOfDay> _times;
  bool _loading = true;
  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    _loadTimes();
  }

  Future<void> _loadTimes() async {
    final prefs = ref.read(preferencesServiceProvider);
    _isGuest = await prefs.isGuestMode();

    if (_isGuest) {
      final guestTimes = await prefs.loadUserNicheTimes(
          nicheId: widget.args.nicheId);

      if (guestTimes.isNotEmpty) {
        _times = guestTimes
            .map((t) => TimeOfDay(hour: t.hour, minute: t.minute))
            .toList();
      } else {
        _times = List.from(widget.args.initialTimes);
      }
    } else {
      final userTimes = await ref.read(cloudSyncServiceProvider).loadUserNicheTimes(
          nicheId: widget.args.nicheId);

      if (userTimes.isNotEmpty) {
        _times = userTimes
            .map((t) => TimeOfDay(hour: t.hour, minute: t.minute))
            .toList();
      } else {
        _times = List.from(widget.args.initialTimes);
      }
    }

    _times.sort(_compareTimeOfDay);

    setState(() {
      _loading = false;
    });

    if (_times.isEmpty) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _addTime(initial: true));
    }
  }

  Future<void> _saveTimes() async {
    if (_isGuest) {
      final prefs = ref.read(preferencesServiceProvider);
      await prefs.removeAllTimesForNiche(
          nicheId: widget.args.nicheId);

      for (final t in _times) {
        await prefs.addUserNicheTime(
          nicheId: widget.args.nicheId,
          hour: t.hour,
          minute: t.minute,
        );
      }
    } else {
      final cloudSync = ref.read(cloudSyncServiceProvider);
      await cloudSync.removeAllTimesForNiche(
          nicheId: widget.args.nicheId);

      for (final t in _times) {
        await cloudSync.addUserNicheTime(
          nicheId: widget.args.nicheId,
          hour: t.hour,
          minute: t.minute,
        );
      }
    }

    widget.args.onChanged(_times);
  }

  int _compareTimeOfDay(TimeOfDay a, TimeOfDay b) {
    final aMinutes = a.hour * 60 + a.minute;
    final bMinutes = b.hour * 60 + b.minute;
    return aMinutes.compareTo(bMinutes);
  }

  Future<void> _pickTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _times[index],
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _times[index] = picked;
        _times.sort(_compareTimeOfDay);
      });

      await _saveTimes();
    }
  }

  Future<void> _addTime({bool initial = false}) async {
    if (_times.length >= widget.args.maxSlots) return;

    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: now,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _times.add(picked);
        _times.sort(_compareTimeOfDay);
      });

      await _saveTimes();
    } else if (initial && _times.isEmpty && mounted) {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _removeTimeWithConfirm(int index) async {
    final formatted = _formatTime(_times[index]);

    final shouldRemove = await AppDialog.showConfirmation(
      context: context,
      title: 'Remover Horário',
      content: 'Deseja remover o horário $formatted?',
      confirmText: 'Remover',
      cancelText: 'Cancelar',
      isDangerous: true,
    ) ?? false;

    if (!shouldRemove) return;

    if (_isGuest) {
      await ref.read(preferencesServiceProvider).removeUserNicheTime(
        nicheId: widget.args.nicheId,
        hour: _times[index].hour,
        minute: _times[index].minute,
      );
    } else {
      await ref.read(cloudSyncServiceProvider).removeUserNicheTime(
        nicheId: widget.args.nicheId,
        hour: _times[index].hour,
        minute: _times[index].minute,
      );
    }

    setState(() {
      _times.removeAt(index);
      _times.sort(_compareTimeOfDay);
    });

    await _saveTimes();
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getTimeDescription(TimeOfDay time) {
    final hour = time.hour;
    if (hour < 6) return 'Madrugada';
    if (hour < 12) return 'Manhã';
    if (hour < 18) return 'Tarde';
    return 'Noite';
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule,
            size: 64,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhum horário configurado',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque no botão + para adicionar seu primeiro horário',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeList(bool isDark) {
    return ListView.builder(
      itemCount: _times.length,
      itemBuilder: (context, index) {
        final time = _times[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            ),
          ),
          child: ListTile(
            onTap: () => _pickTime(index),
            leading: Icon(
              Icons.access_time,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            title: Text(
              _formatTime(time),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              _getTimeDescription(time),
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 12,
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
              onPressed: () => _removeTimeWithConfirm(index),
              tooltip: 'Remover horário',
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActions(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FloatingActionButton(
            onPressed: () => Navigator.pop(context),
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
            child: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          if (_times.length < widget.args.maxSlots)
            FloatingActionButton(
              onPressed: _addTime,
              backgroundColor: isDark ? const Color(0xFF6366F1) : const Color(0xFF6366F1),
              child: const Icon(Icons.add, color: Colors.white),
            )
          else
            const SizedBox(width: 56),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_loading) {
      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          widget.args.title ?? 'Horários',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configure seus horários',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_times.length} de ${widget.args.maxSlots} horários configurados',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _times.isEmpty
                  ? _buildEmptyState(isDark)
                  : _buildTimeList(isDark),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActions(isDark),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
