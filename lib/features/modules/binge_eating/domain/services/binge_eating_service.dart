import 'dart:convert';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/storage/objectbox_preferences_repository.dart';
import 'package:disciplinum/features/modules/binge_eating/domain/entities/binge_habit.dart';
import 'package:flutter/material.dart';

/// Configurações de controle de compulsão alimentar
class BingeEatingConfig {
  final bool isEnabled;
  final DateTime? blockedUntil;
  final String? blockReason;
  final int dailyLimitMinutes;
  final bool requirePassword;
  final List<String> triggerFoods;
  final List<String> copingStrategies;
  final bool enableNotifications;
  final TimeOfDay reminderTime;

  const BingeEatingConfig({
    required this.isEnabled,
    this.blockedUntil,
    this.blockReason,
    this.dailyLimitMinutes = 60,
    this.requirePassword = false,
    this.triggerFoods = const [],
    this.copingStrategies = const [],
    this.enableNotifications = true,
    this.reminderTime = const TimeOfDay(hour: 20, minute: 0),
  });

  Map<String, dynamic> toMap() {
    return {
      'isEnabled': isEnabled,
      'blockedUntil': blockedUntil?.toIso8601String(),
      'blockReason': blockReason,
      'dailyLimitMinutes': dailyLimitMinutes,
      'requirePassword': requirePassword,
      'triggerFoods': triggerFoods,
      'copingStrategies': copingStrategies,
      'enableNotifications': enableNotifications,
      'reminderTime': '${reminderTime.hour}:${reminderTime.minute}',
    };
  }

  factory BingeEatingConfig.fromMap(Map<String, dynamic> map) {
    return BingeEatingConfig(
      isEnabled: map['isEnabled'] ?? false,
      blockedUntil: map['blockedUntil'] != null 
          ? DateTime.parse(map['blockedUntil'])
          : null,
      blockReason: map['blockReason'],
      dailyLimitMinutes: map['dailyLimitMinutes'] ?? 60,
      requirePassword: map['requirePassword'] ?? false,
      triggerFoods: List<String>.from(map['triggerFoods'] ?? []),
      copingStrategies: List<String>.from(map['copingStrategies'] ?? []),
      enableNotifications: map['enableNotifications'] ?? true,
      reminderTime: _parseTimeOfDay(map['reminderTime'] ?? '20:00'),
    );
  }

  static TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  BingeEatingConfig copyWith({
    bool? isEnabled,
    DateTime? blockedUntil,
    String? blockReason,
    int? dailyLimitMinutes,
    bool? requirePassword,
    List<String>? triggerFoods,
    List<String>? copingStrategies,
    bool? enableNotifications,
    TimeOfDay? reminderTime,
  }) {
    return BingeEatingConfig(
      isEnabled: isEnabled ?? this.isEnabled,
      blockedUntil: blockedUntil ?? this.blockedUntil,
      blockReason: blockReason ?? this.blockReason,
      dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
      requirePassword: requirePassword ?? this.requirePassword,
      triggerFoods: triggerFoods ?? this.triggerFoods,
      copingStrategies: copingStrategies ?? this.copingStrategies,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}

/// Episódio de compulsão alimentar
class BingeEpisode {
  final String id;
  final DateTime timestamp;
  final int severity; // 1-10
  final List<String> triggerFoods;
  final String? trigger;
  final int durationMinutes;
  final String? notes;
  final Map<String, dynamic> context;

  BingeEpisode({
    required this.id,
    required this.timestamp,
    required this.severity,
    required this.triggerFoods,
    this.trigger,
    required this.durationMinutes,
    this.notes,
    this.context = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'severity': severity,
      'triggerFoods': triggerFoods,
      'trigger': trigger,
      'durationMinutes': durationMinutes,
      'notes': notes,
      'context': context,
    };
  }

  factory BingeEpisode.fromMap(Map<String, dynamic> map) {
    return BingeEpisode(
      id: map['id'],
      timestamp: DateTime.parse(map['timestamp']),
      severity: map['severity'],
      triggerFoods: List<String>.from(map['triggerFoods'] ?? []),
      trigger: map['trigger'],
      durationMinutes: map['durationMinutes'] ?? 0,
      notes: map['notes'],
      context: Map<String, dynamic>.from(map['context'] ?? {}),
    );
  }
}

/// Service principal para gerenciamento de compulsão alimentar
class BingeEatingService {
  static const String _configKey = 'binge_eating_config';
  static const String _habitKey = 'binge_habit_data';
  static const String _episodesKey = 'binge_episodes';

  final ObjectBoxPreferencesRepository _repository;

  late BingeEatingConfig _config;
  BingeHabit? _habit;
  List<BingeEpisode> _episodes = [];

  BingeEatingService(this._repository) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadConfig();
    _habit = await _loadHabit();
    _episodes = await _loadEpisodes();
  }

  // Getters
  BingeEatingConfig get config => _config;
  BingeHabit? get habit => _habit;
  List<BingeEpisode> get episodes => List.unmodifiable(_episodes);
  bool get isEnabled => _config.isEnabled;

  // Configuração
  Future<void> updateConfig(BingeEatingConfig newConfig) async {
    _config = newConfig;
    await _repository.setString(_configKey, jsonEncode(newConfig.toMap()));
    LoggerService.instance.i('BingeEatingConfig atualizado');
  }

  // Controle do hábito
  Future<void> startControl() async {
    final now = DateTime.now();
    _habit = BingeHabit(
      userId: 'current_user',
      startDate: now,
      currentStreak: 0,
      totalEpisodes: 0,
      episodesThisMonth: 0,
      averageSeverity: 0.0,
    );
    await _saveHabit();
    LoggerService.instance.i('Controle de compulsão alimentar iniciado');
  }

  Future<void> stopControl() async {
    _habit = null;
    await _repository.remove(_habitKey);
    LoggerService.instance.i('Controle de compulsão alimentar parado');
  }

  // Gerenciamento de episódios
  Future<void> recordEpisode(BingeEpisode episode) async {
    _episodes.add(episode);
    await _saveEpisodes();
    
    // Atualizar hábito se existir
    if (_habit != null) {
      _habit = _updateHabitWithEpisode(_habit!, episode);
      await _saveHabit();
    }
    
    LoggerService.instance.i('Episódio de compulsão registrado: ${episode.id}');
  }

  Future<void> deleteEpisode(String episodeId) async {
    _episodes.removeWhere((e) => e.id == episodeId);
    await _saveEpisodes();
    
    // Recalcular hábito
    if (_habit != null) {
      _habit = _recalculateHabit(_habit!);
      await _saveHabit();
    }
    
    LoggerService.instance.i('Episódio removido: $episodeId');
  }

  // Análise e estatísticas
  Map<String, dynamic> getStatistics() {
    if (_habit == null) return {};
    
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);
    
    final episodesThisMonth = _episodes
        .where((e) => e.timestamp.isAfter(thisMonth))
        .length;
    
    final last30Days = _episodes
        .where((e) => e.timestamp.isAfter(now.subtract(const Duration(days: 30))))
        .toList();
    
    final averageSeverity = last30Days.isEmpty 
        ? 0.0 
        : last30Days.map((e) => e.severity).reduce((a, b) => a + b) / last30Days.length;
    
    final mostCommonTrigger = _getMostCommonTrigger(last30Days);
    
    return {
      'currentStreak': _habit!.currentStreak,
      'totalEpisodes': _habit!.totalEpisodes,
      'episodesThisMonth': episodesThisMonth,
      'averageSeverity': averageSeverity,
      'recoveryRate': _habit!.recoveryRate,
      'daysSinceLastEpisode': _habit!.daysSinceLastEpisode,
      'mostCommonTrigger': mostCommonTrigger,
      'motivationalMessage': _habit!.getMotivationalMessage(),
      'nextMilestone': _habit!.getNextMilestone(),
    };
  }

  // Recomendações personalizadas
  List<String> getRecommendations() {
    final stats = getStatistics();
    final recommendations = <String>[];
    
    if (stats['currentStreak'] == 0) {
      recommendations.add('Concentre-se em passar o primeiro dia. Cada jornada começa com um passo!');
    } else if (stats['currentStreak'] < 7) {
      recommendations.add('Você está indo bem! Mantenha o foco nos primeiros 7 dias.');
    }
    
    if (stats['averageSeverity'] > 7) {
      recommendations.add('Considere procurar ajuda profissional. Episódios severos merecem atenção especial.');
    }
    
    if (stats['mostCommonTrigger'] != null) {
      recommendations.add('Fique atento ao gatilho mais comum: ${stats['mostCommonTrigger']}');
    }
    
    if (_config.copingStrategies.isNotEmpty) {
      recommendations.add('Lembre-se das suas estratégias: ${_config.copingStrategies.take(2).join(', ')}');
    }
    
    return recommendations;
  }

  // Métodos privados
  Future<void> _loadConfig() async {
    try {
      final data = await _repository.getString(_configKey);
      if (data == null || data.isEmpty) {
        _config = const BingeEatingConfig(isEnabled: false);
        return;
      }
      _config = BingeEatingConfig.fromMap(jsonDecode(data));
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar config: $e');
      _config = const BingeEatingConfig(isEnabled: false);
    }
  }

  Future<BingeHabit?> _loadHabit() async {
    try {
      final data = await _repository.getString(_habitKey);
      if (data == null || data.isEmpty) return null;
      
      final map = jsonDecode(data);
      return BingeHabit(
        userId: map['userId'],
        startDate: map['startDate'] != null ? DateTime.parse(map['startDate']) : null,
        currentStreak: map['currentStreak'] ?? 0,
        totalEpisodes: map['totalEpisodes'] ?? 0,
        episodesThisMonth: map['episodesThisMonth'] ?? 0,
        averageSeverity: (map['averageSeverity'] ?? 0.0).toDouble(),
      );
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar hábito: $e');
      return null;
    }
  }

  Future<List<BingeEpisode>> _loadEpisodes() async {
    try {
      final data = await _repository.getString(_episodesKey);
      if (data == null || data.isEmpty) return [];
      
      final List<dynamic> list = jsonDecode(data);
      return list.map((e) => BingeEpisode.fromMap(e)).toList();
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar episódios: $e');
      return [];
    }
  }

  Future<void> _saveHabit() async {
    if (_habit == null) {
      await _repository.remove(_habitKey);
    } else {
      final map = {
        'userId': _habit!.userId,
        'startDate': _habit!.startDate?.toIso8601String(),
        'currentStreak': _habit!.currentStreak,
        'totalEpisodes': _habit!.totalEpisodes,
        'episodesThisMonth': _habit!.episodesThisMonth,
        'averageSeverity': _habit!.averageSeverity,
      };
      await _repository.setString(_habitKey, jsonEncode(map));
    }
  }

  Future<void> _saveEpisodes() async {
    final list = _episodes.map((e) => e.toMap()).toList();
    await _repository.setString(_episodesKey, jsonEncode(list));
  }

  BingeHabit _updateHabitWithEpisode(BingeHabit habit, BingeEpisode episode) {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);
    
    final episodesThisMonth = _episodes
        .where((e) => e.timestamp.isAfter(thisMonth))
        .length;
    
    final last30Days = _episodes
        .where((e) => e.timestamp.isAfter(now.subtract(const Duration(days: 30))))
        .toList();
    
    final averageSeverity = last30Days.isEmpty 
        ? 0.0 
        : last30Days.map((e) => e.severity).reduce((a, b) => a + b) / last30Days.length;
    
    return habit.copyWith(
      lastEpisode: episode.timestamp,
      totalEpisodes: _episodes.length,
      episodesThisMonth: episodesThisMonth,
      averageSeverity: averageSeverity,
    );
  }

  BingeHabit _recalculateHabit(BingeHabit habit) {
    final now = DateTime.now();
    
    // Recalcular streak baseado nos episódios
    int currentStreak = 0;
    DateTime? lastEpisode;
    
    if (_episodes.isNotEmpty) {
      final sortedEpisodes = List<BingeEpisode>.from(_episodes)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      lastEpisode = sortedEpisodes.first.timestamp;
      
      // Calcular dias desde o último episódio
      final daysSinceLast = now.difference(lastEpisode).inDays;
      
      // Se não teve episódio hoje, verificar se o último episódio foi hoje
      final today = DateTime(now.year, now.month, now.day);
      final lastEpisodeDate = DateTime(
        lastEpisode.year,
        lastEpisode.month,
        lastEpisode.day,
      );
      
      if (lastEpisodeDate.isBefore(today)) {
        currentStreak = daysSinceLast;
      }
    } else {
      // Se não há episódios, usar o streak original
      currentStreak = habit.currentStreak;
    }
    
    // Recalcular outras estatísticas
    final thisMonth = DateTime(now.year, now.month, 1);
    final episodesThisMonth = _episodes
        .where((e) => e.timestamp.isAfter(thisMonth))
        .length;
    
    final last30Days = _episodes
        .where((e) => e.timestamp.isAfter(now.subtract(const Duration(days: 30))))
        .toList();
    
    final averageSeverity = last30Days.isEmpty 
        ? 0.0 
        : last30Days.map((e) => e.severity).reduce((a, b) => a + b) / last30Days.length;
    
    return habit.copyWith(
      currentStreak: currentStreak,
      lastEpisode: lastEpisode,
      totalEpisodes: _episodes.length,
      episodesThisMonth: episodesThisMonth,
      averageSeverity: averageSeverity,
    );
  }

  String? _getMostCommonTrigger(List<BingeEpisode> episodes) {
    if (episodes.isEmpty) return null;
    
    final triggerCounts = <String, int>{};
    
    for (final episode in episodes) {
      if (episode.trigger != null) {
        triggerCounts[episode.trigger!] = (triggerCounts[episode.trigger!] ?? 0) + 1;
      }
    }
    
    if (triggerCounts.isEmpty) return null;
    
    return triggerCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}
