import 'dart:async';
import 'package:disciplinum/core/storage/local_storage_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/events/event_bus.dart';
import 'package:uuid/uuid.dart';

/// Evento emitido quando o countdown é iniciado
class CountdownStartedEvent extends AppEvent {
  final String packageName;
  final int duration;
  final String moduleId;
  
  CountdownStartedEvent({
    required this.packageName,
    required this.duration,
    required this.moduleId,
  }) : super(data: {
    'package_name': packageName,
    'duration': duration,
    'module_id': moduleId,
  });
}

/// Evento emitido a cada segundo do countdown
class CountdownTickEvent extends AppEvent {
  final String packageName;
  final int remainingSeconds;
  final String moduleId;
  
  CountdownTickEvent({
    required this.packageName,
    required this.remainingSeconds,
    required this.moduleId,
  }) : super(data: {
    'package_name': packageName,
    'remaining_seconds': remainingSeconds,
    'module_id': moduleId,
  });
}

/// Evento emitido quando o countdown expira
class CountdownExpiredEvent extends AppEvent {
  final String packageName;
  final String moduleId;
  
  CountdownExpiredEvent({
    required this.packageName,
    required this.moduleId,
  }) : super(data: {
    'package_name': packageName,
    'module_id': moduleId,
  });
}

/// Estado ativo de um countdown
class ActiveCountdown {
  final String id;
  final String packageName;
  final String moduleId;
  final int startTime;
  final int duration;
  int elapsedSeconds;
  
  ActiveCountdown({
    required this.id,
    required this.packageName,
    required this.moduleId,
    required this.startTime,
    required this.duration,
    required this.elapsedSeconds,
  });

  /// Tempo restante em segundos
  int get remainingSeconds => duration - elapsedSeconds;
  
  /// Verifica se expirou
  bool get isExpired => remainingSeconds <= 0;
  
  /// Converte para Map para persistência
  Map<String, dynamic> toJson() => {
    'id': id,
    'packageName': packageName,
    'moduleId': moduleId,
    'startTime': startTime,
    'duration': duration,
    'elapsedSeconds': elapsedSeconds,
  };
  
  /// Cria do Map persistido
  factory ActiveCountdown.fromJson(Map<String, dynamic> json) => ActiveCountdown(
    id: json['id'],
    packageName: json['packageName'],
    moduleId: json['moduleId'],
    startTime: json['startTime'],
    duration: json['duration'],
    elapsedSeconds: json['elapsedSeconds'] ?? 0,
  );
}

/// Serviço robusto de countdown com persistência e recuperação de estado
class CountdownService {
  static const String _activeCountdownsKey = 'active_countdowns';
  
  final LocalStorageService _storage;
  final Map<String, ActiveCountdown> _activeCountdowns = {};
  final Map<String, Timer> _timers = {};
  
  CountdownService(this._storage) {
    _loadActiveCountdowns();
  }
  
  /// Carrega countdowns ativos do storage
  Future<void> _loadActiveCountdowns() async {
    try {
      final data = await _storage.getJson(_activeCountdownsKey);
      if (data != null && data['countdowns'] != null) {
        final List<dynamic> jsonList = data['countdowns'];
        for (final item in jsonList) {
          final countdown = ActiveCountdown.fromJson(item);
          _activeCountdowns[countdown.id] = countdown;
          
          // Se não expirou, restaura o timer
          if (!countdown.isExpired) {
            _startTimer(countdown);
          }
        }
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar countdowns ativos', error: e);
    }
  }
  
  /// Salva countdowns ativos no storage
  Future<void> _saveActiveCountdowns() async {
    try {
      final jsonList = _activeCountdowns.values.map((c) => c.toJson()).toList();
      await _storage.saveJson(_activeCountdownsKey, {'countdowns': jsonList});
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar countdowns ativos', error: e);
    }
  }
  
  /// Inicia um countdown para um app específico
  String startCountdown({
    required String packageName,
    required int durationSeconds,
    required String moduleId,
  }) {
    // Cancela countdown existente para este app
    cancelCountdown(packageName);
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = const Uuid().v4();
    
    final countdown = ActiveCountdown(
      id: id,
      packageName: packageName,
      moduleId: moduleId,
      startTime: now,
      duration: durationSeconds,
      elapsedSeconds: 0,
    );
    
    _activeCountdowns[id] = countdown;
    _saveActiveCountdowns();
    _startTimer(countdown);
    
    LoggerService.instance.i('Countdown iniciado: $packageName - ${durationSeconds}s');
    
    return id;
  }
  
  /// Inicia o timer interno para um countdown
  void _startTimer(ActiveCountdown countdown) {
    _timers[countdown.id] = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final elapsed = (now - countdown.startTime) ~/ 1000;
        
        // Atualiza elapsed
        countdown.elapsedSeconds = elapsed;
        
        if (countdown.isExpired) {
          _onCountdownExpired(countdown);
        } else {
          _onCountdownTick(countdown);
        }
      },
    );
  }
  
  /// Cancela um countdown ativo
  void cancelCountdown(String packageName) {
    final countdown = _activeCountdowns.values
        .where((c) => c.packageName == packageName)
        .firstOrNull;
    
    if (countdown != null) {
      _timers[countdown.id]?.cancel();
      _timers.remove(countdown.id);
      _activeCountdowns.remove(countdown.id);
      _saveActiveCountdowns();
      
      LoggerService.instance.i('Countdown cancelado: $packageName');
    }
  }
  
  /// Obtém countdown ativo para um app
  ActiveCountdown? getActiveCountdown(String packageName) {
    return _activeCountdowns.values
        .where((c) => c.packageName == packageName)
        .firstOrNull;
  }
  
  /// Verifica se há countdown ativo para um app
  bool hasActiveCountdown(String packageName) {
    return getActiveCountdown(packageName) != null;
  }
  
  /// Lista todos os countdowns ativos
  List<ActiveCountdown> getAllActiveCountdowns() {
    return _activeCountdowns.values.toList();
  }
  
  /// Limpa todos os countdowns expirados
  void cleanupExpiredCountdowns() {
    final expired = _activeCountdowns.values.where((c) => c.isExpired).toList();
    
    for (final countdown in expired) {
      _timers[countdown.id]?.cancel();
      _timers.remove(countdown.id);
      _activeCountdowns.remove(countdown.id);
    }
    
    if (expired.isNotEmpty) {
      _saveActiveCountdowns();
      LoggerService.instance.i('Removidos ${expired.length} countdowns expirados');
    }
  }
  
  /// Emitido quando o countdown expira
  void _onCountdownExpired(ActiveCountdown countdown) {
    _timers[countdown.id]?.cancel();
    _timers.remove(countdown.id);
    _activeCountdowns.remove(countdown.id);
    _saveActiveCountdowns();
    
    // Emitir evento global
    EventBus.instance.emit(CountdownExpiredEvent(
      packageName: countdown.packageName,
      moduleId: countdown.moduleId,
    ));
    
    LoggerService.instance.w('Countdown expirou: ${countdown.packageName}');
  }
  
  /// Emitido a cada segundo do countdown
  void _onCountdownTick(ActiveCountdown countdown) {
    // Atualiza elapsed no storage
    _saveActiveCountdowns();
    
    // Emitir evento global
    EventBus.instance.emit(CountdownTickEvent(
      packageName: countdown.packageName,
      remainingSeconds: countdown.remainingSeconds,
      moduleId: countdown.moduleId,
    ));
    
    LoggerService.instance.d('Countdown tick: ${countdown.packageName} - ${countdown.remainingSeconds}s restantes');
  }
  
  /// Libera todos os recursos
  void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _activeCountdowns.clear();
  }
}
