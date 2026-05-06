import 'dart:async';
import 'package:disciplinum/core/background/background_achievement_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Agrupa uma lista por uma chave extraída de cada elemento
Map<K, List<V>> groupBy<V, K>(List<V> list, K Function(V) keyExtractor) {
  final map = <K, List<V>>{};
  for (final element in list) {
    final key = keyExtractor(element);
    map.putIfAbsent(key, () => <V>[]).add(element);
  }
  return map;
}

/// Modelo de notificação de conquista pendente
class PendingAchievementNotification {
  final String moduleName;
  final String achievementType;
  final String title;
  final String body;
  final String achievementId;
  final DateTime timestamp;

  PendingAchievementNotification({
    required this.moduleName,
    required this.achievementType,
    required this.title,
    required this.body,
    required this.achievementId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() =>
      'PendingAchievementNotification(module: $moduleName, type: $achievementType, id: $achievementId)';
}

/// Notificador que agrupa múltiplas conquistas em uma única notificação
/// 
/// Usado pelo WorkManager para evitar spam de notificações quando o usuário
/// desbloqueia múltiplas conquistas simultaneamente (ex: insígnia + medalha)
class BatchedAchievementNotifier {
  static final BatchedAchievementNotifier _instance =
      BatchedAchievementNotifier._internal();
  factory BatchedAchievementNotifier() => _instance;
  BatchedAchievementNotifier._internal();

  final List<PendingAchievementNotification> _pendingNotifications = [];
  bool _isFlushing = false;

  /// Adiciona uma notificação à fila
  void queueNotification({
    required String moduleName,
    required String achievementType,
    required String title,
    required String body,
    required String achievementId,
  }) {
    _pendingNotifications.add(PendingAchievementNotification(
      moduleName: moduleName,
      achievementType: achievementType,
      title: title,
      body: body,
      achievementId: achievementId,
    ));

    LoggerService.instance.d(
        'Notificação enfileirada: $moduleName - $achievementType');
  }

  /// Envia todas as notificações pendentes
  /// 
  /// Se houver apenas uma notificação, envia normalmente.
  /// Se houver múltiplas, agrupa em notificação batch.
  Future<void> flush() async {
    if (_pendingNotifications.isEmpty || _isFlushing) return;

    _isFlushing = true;

    try {
      if (_pendingNotifications.length == 1) {
        // Notificação única - comportamento padrão
        final notification = _pendingNotifications.first;
        await _showSingleNotification(notification);
      } else {
        // Múltiplas conquistas - batching inteligente
        await _showBatchedNotification();
      }
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao enviar notificações batch',
          error: e, stackTrace: stackTrace);
    } finally {
      _pendingNotifications.clear();
      _isFlushing = false;
    }
  }

  /// Envia uma notificação única
  Future<void> _showSingleNotification(PendingAchievementNotification notification) async {
    await BackgroundAchievementService.showAchievementNotification(
      title: notification.title,
      body: notification.body,
      achievementId: notification.achievementId,
    );

    LoggerService.instance.i(
        'Notificação única enviada: ${notification.moduleName}');
  }

  /// Envia notificação agrupada de múltiplas conquistas
  Future<void> _showBatchedNotification() async {
    // Agrupa por módulo
    final byModule = groupBy(
      _pendingNotifications,
      (n) => n.moduleName,
    );

    // Verifica se é o caso especial: insígnia + medalha do mesmo módulo
    if (byModule.length == 1 && _hasInsigniaAndMedal(_pendingNotifications)) {
      await _showCombinedInsigniaMedalNotification(byModule.keys.first);
    } else {
      // Resumo genérico de múltiplas conquistas
      await _showSummaryNotification(byModule);
    }
  }

  /// Verifica se a lista contém tanto insígnia quanto medalha
  bool _hasInsigniaAndMedal(List<PendingAchievementNotification> notifications) {
    final hasInsignia = notifications.any((n) => 
        n.achievementType.toLowerCase().contains('insignia') ||
        n.achievementType.toLowerCase().contains('disciplinum'));
    final hasMedal = notifications.any((n) => 
        n.achievementType.toLowerCase().contains('medal'));
    return hasInsignia && hasMedal;
  }

  /// Notificação combinada de insígnia + medalha
  Future<void> _showCombinedInsigniaMedalNotification(String moduleName) async {
    final insignia = _pendingNotifications.firstWhere(
      (n) => n.achievementType.toLowerCase().contains('insignia') ||
             n.achievementType.toLowerCase().contains('disciplinum'),
      orElse: () => _pendingNotifications.first,
    );

    final medal = _pendingNotifications.firstWhere(
      (n) => n.achievementType.toLowerCase().contains('medal'),
      orElse: () => _pendingNotifications.first,
    );

    // Extrai o nome da insígnia/medalha do body ou achievementId
    final insigniaName = _extractAchievementName(insignia);
    final medalName = _extractAchievementName(medal);

    await BackgroundAchievementService.showAchievementNotification(
      title: '🏆 Conquista Dupla!',
      body: '$moduleName: $insigniaName + $medalName!',
      achievementId: 'combined_${insignia.achievementId}_${medal.achievementId}',
    );

    LoggerService.instance.i(
        'Notificação combinada enviada: $moduleName - insígnia + medalha');
  }

  /// Notificação resumida de múltiplas conquistas
  Future<void> _showSummaryNotification(
      Map<String, List<PendingAchievementNotification>> byModule) async {
    final entries = byModule.entries.toList();
    
    // Monta o resumo
    final summaryParts = <String>[];
    for (var i = 0; i < entries.length && i < 3; i++) {
      final module = entries[i].key;
      final achievements = entries[i].value;
      final firstAchievement = achievements.first;
      
      // Extrai informação relevante do body
      final info = _extractKeyInfo(firstAchievement);
      summaryParts.add('$module: $info');
    }

    var body = summaryParts.join(' | ');
    final remaining = entries.length - 3;
    if (remaining > 0) {
      body += ' | +$remaining mais...';
    }

    await BackgroundAchievementService.showAchievementNotification(
      title: '🎉 Múltiplas Conquistas!',
      body: body,
      achievementId: 'batch_${DateTime.now().millisecondsSinceEpoch}',
    );

    LoggerService.instance.i(
        'Notificação batch enviada: ${entries.length} módulos');
  }

  /// Extrai o nome da conquista do achievementId ou body
  String _extractAchievementName(PendingAchievementNotification notification) {
    // Tenta extrair do achievementId (formato: module_name_type)
    final parts = notification.achievementId.split('_');
    if (parts.length >= 3) {
      return parts.sublist(1).join(' ').toUpperCase();
    }
    // Fallback para o body
    return notification.body.split('!').first;
  }

  /// Extrai informação chave da conquista para o resumo
  String _extractKeyInfo(PendingAchievementNotification notification) {
    // Para streaks
    if (notification.body.contains('dia') || notification.body.contains('day')) {
      final match = RegExp(r'(\d+)').firstMatch(notification.body);
      if (match != null) {
        return '${match.group(1)} dias';
      }
    }
    
    // Para sessões/horas de foco
    if (notification.body.contains('sessão') || notification.body.contains('sessões')) {
      final match = RegExp(r'(\d+)').firstMatch(notification.body);
      if (match != null) {
        return '${match.group(1)} sessões';
      }
    }
    
    if (notification.body.contains('hora') || notification.body.contains('horas')) {
      final match = RegExp(r'(\d+)').firstMatch(notification.body);
      if (match != null) {
        return '${match.group(1)}h';
      }
    }
    
    // Para economia
    if (notification.achievementId.contains('moneysaving') || 
        notification.body.contains('R\$')) {
      final match = RegExp(r'R\$\s*(\d+)').firstMatch(notification.body);
      if (match != null) {
        return 'R\$${match.group(1)}';
      }
    }

    // Default: retorna o body truncado
    return notification.body.length > 20 
        ? '${notification.body.substring(0, 20)}...' 
        : notification.body;
  }

  /// Retorna quantidade de notificações pendentes (para testes)
  int get pendingCount => _pendingNotifications.length;

  /// Limpa notificações pendentes sem enviar (para testes)
  void clear() {
    _pendingNotifications.clear();
    _isFlushing = false;
  }
}
