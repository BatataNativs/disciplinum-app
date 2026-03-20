import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';

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

    final shouldRemove = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Remover horário'),
            content: Text('Deseja remover o horário $formatted?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Remover',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            isDark ? Colors.black : const Color.fromARGB(255, 226, 229, 251),
            isDark ? Colors.black : const Color.fromARGB(255, 255, 255, 255)
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(widget.args.title ?? 'Horários',
              style: TextStyle(color: textColor)),
          iconTheme: IconThemeData(color: textColor),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Defina seus horários',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _times.length,
                  itemBuilder: (context, index) {
                    final time = _times[index];
                    return GestureDetector(
                      onLongPress: () => _removeTimeWithConfirm(index),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        // Alterei para garantir contraste, mas mantendo seu estilo
                        color: isDark ? Colors.grey[900] : Colors.black,
                        child: ListTile(
                          onTap: () => _pickTime(index),
                          title: Text(
                            _formatTime(time),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18, // Aumentei um pouco a fonte
                            ),
                          ),
                          // --- AQUI ESTÁ A MUDANÇA ---
                          trailing: IconButton(
                            tooltip: 'Excluir horário',
                            // Ícone de lixeira mais evidente e VERMELHO
                            icon: const Icon(
                              Icons.delete_forever_rounded,
                              color: Colors.redAccent,
                              size: 28,
                            ),
                            onPressed: () => _removeTimeWithConfirm(index),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FloatingActionButton(
                heroTag: 'back_btn',
                onPressed: () => Navigator.pop(context),
                backgroundColor: isDark
                    ? Colors.grey[800]
                    : const Color.fromARGB(255, 164, 176, 244),
                child: Icon(Icons.arrow_back,
                    color: isDark ? Colors.white : Colors.black),
              ),
              if (_times.length < widget.args.maxSlots)
                FloatingActionButton(
                  heroTag: 'add_btn',
                  onPressed: _addTime,
                  backgroundColor: const Color.fromARGB(255, 20, 49, 181),
                  child: const Icon(Icons.add, color: Colors.white),
                )
              else
                const SizedBox(width: 56),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        bottomNavigationBar: const SizedBox(height: 40),
      ),
    );
  }
}
