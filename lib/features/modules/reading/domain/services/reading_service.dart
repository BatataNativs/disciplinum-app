import 'dart:convert';
import 'package:disciplinum/core/storage/isar_preferences_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:disciplinum/features/modules/reading/domain/entities/reading_model.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/features/gamification/domain/entities/medal.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

class ReadingService {
  static const String _moduleId = 'reading';
  static const String _localKey = 'reading_data';
  static const String _streakKey = 'reading_streak_data';

  final IsarPreferencesRepository _prefs;
  final GamificationService _gamificationService;
  final SupabaseClient _supabase = Supabase.instance.client;

  ReadingService(this._prefs, this._gamificationService) {
    _loadData();
  }

  // Lista de livros
  List<ReadingBook> _books = [];
  List<ReadingBook> get books => List.unmodifiable(_books);

  // Gamificação Específica do Módulo
  int _currentStreak = 0;
  DateTime? _lastReadingDate;
  int get currentStreak => _currentStreak;

  // Medalhas conquistadas (apenas para exibição local ou envio para GamificationService)
  bool hasBronze = false;
  bool hasSilver = false;
  bool hasGold = false;
  bool hasDiamond = false;

  Future<void> _loadData() async {
    // 1. Carregar Livros
    final String? data = await _prefs.getString(_localKey);
    if (data != null) {
      try {
        final List<dynamic> decoded = jsonDecode(data);
        _books = decoded.map((e) => ReadingBook.fromJson(e)).toList();
      } catch (e) {
        LoggerService.instance.e('Erro ao carregar livros', error: e);
      }
    }

    // 2. Carregar Gamificação (Streak)
    final String? streakData = await _prefs.getString(_streakKey);
    if (streakData != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(streakData);
        _currentStreak = decoded['streak'] ?? 0;
        _lastReadingDate = decoded['last_reading_date'] != null
            ? DateTime.parse(decoded['last_reading_date'])
            : null;
        hasBronze = decoded['has_bronze'] ?? false;
        hasSilver = decoded['has_silver'] ?? false;
        hasGold = decoded['has_gold'] ?? false;
        hasDiamond = decoded['has_diamond'] ?? false;

        // Verifica se quebrou o streak ao carregar
        _validateStreakOnLoad();
      } catch (e) {
        LoggerService.instance.e('Erro ao carregar streak de leitura', error: e);
      }
    }

    // notifyListeners(); // Removido - ReadingService não estende ChangeNotifier
    _syncWithCloud();
  }

  Future<void> _validateStreakOnLoad() async {
    if (_lastReadingDate == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(
        _lastReadingDate!.year, _lastReadingDate!.month, _lastReadingDate!.day);

    final difference = today.difference(last).inDays;

    // Se a diferença for maior que 1 (ontem), perdeu o streak
    // Ex: Leu dia 1, hoje é dia 3. Diferença = 2. Perdeu.
    // Ex: Leu dia 1, hoje é dia 2. Diferença = 1. Mantém (ainda não leu hoje).
    // Ex: Leu dia 1, hoje é dia 1. Diferença = 0. Mantém.
    if (difference > 1) {
      _currentStreak = 0;
      await _saveStreakData();
      // notifyListeners(); // Removido - ReadingService não estende ChangeNotifier
    }
  }

  Future<void> _saveAllLocal() async {
    // Livros
    final encoded = jsonEncode(_books.map((b) => b.toJson()).toList());
    await _prefs.setString(_localKey, encoded);

    // Streak
    await _saveStreakData();

    // Cloud Sync (fire and forget)
    _syncToCloud();
  }

  Future<void> _saveStreakData() async {
    final data = {
      'streak': _currentStreak,
      'last_reading_date': _lastReadingDate?.toIso8601String(),
      'has_bronze': hasBronze,
      'has_silver': hasSilver,
      'has_gold': hasGold,
      'has_diamond': hasDiamond,
    };
    await _prefs.setString(_streakKey, jsonEncode(data));
  }

  Future<void> _syncToCloud() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final cloudData = {
        'books': _books.map((b) => b.toJson()).toList(),
        'streak_data': {
          'streak': _currentStreak,
          'last_reading_date': _lastReadingDate?.toIso8601String(),
          'has_bronze': hasBronze,
          'has_silver': hasSilver,
          'has_gold': hasGold,
          'has_diamond': hasDiamond,
        }
      };

      await _supabase.from('user_module_settings').upsert({
        'user_id': userId,
        'module_id': _moduleId,
        'module_data': cloudData,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id, module_id');
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar leitura na nuvem', error: e);
    }
  }

  Future<void> _syncWithCloud() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('user_module_settings')
          .select()
          .eq('user_id', userId)
          .eq('module_id', _moduleId)
          .maybeSingle();

      if (response != null && response['module_data'] != null) {
        final cloudJson = response['module_data'];
        final Map<String, dynamic> decoded =
            cloudJson is String ? jsonDecode(cloudJson) : cloudJson;

        if (decoded['books'] != null) {
          _books = (decoded['books'] as List)
              .map((e) => ReadingBook.fromJson(e))
              .toList();
        }

        if (decoded['streak_data'] != null) {
          final s = decoded['streak_data'];
          _currentStreak = s['streak'] ?? 0;
          _lastReadingDate = s['last_reading_date'] != null
              ? DateTime.parse(s['last_reading_date'])
              : null;
          hasBronze = s['has_bronze'] ?? false;
          hasSilver = s['has_silver'] ?? false;
          hasGold = s['has_gold'] ?? false;
          hasDiamond = s['has_diamond'] ?? false;
        }

        // Salvar localmente para manter sincronia
        final encoded = jsonEncode(_books.map((b) => b.toJson()).toList());
        await _prefs.setString(_localKey, encoded);
        await _saveStreakData();
        // notifyListeners(); // Removido - ReadingService não estende ChangeNotifier
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao sincronizar leitura (load)', error: e);
    }
  }

  // ===========================================
  // MÉTODOS DE AÇÃO
  // ===========================================

  Future<void> addBook({
    required String title,
    required int totalPages,
    required ReadingTheme theme,
    String? author,
  }) async {
    final book = ReadingBook(
      id: const Uuid().v4(),
      title: title,
      totalPages: totalPages,
      theme: theme,
      author: author,
      createdAt: DateTime.now(),
    );
    _books.add(book);
    await _saveAllLocal();
    // notifyListeners(); // Removido - ReadingService não estende ChangeNotifier
  }

  Future<void> updateProgress(String bookId, int newPageCount) async {
    final index = _books.indexWhere((b) => b.id == bookId);
    if (index == -1) return;

    final book = _books[index];
    if (newPageCount < 0) return;
    // Permite "corrigir" para menos, mas o log registrará a posição absoluta.

    final newLog = ReadingLog(
      date: DateTime.now(),
      pageNumber: newPageCount,
    );

    final updatedLogs = List<ReadingLog>.from(book.logs)..add(newLog);

    // Verifica conclusão
    DateTime? completedAt = book.completedAt;
    if (newPageCount >= book.totalPages && !book.isCompleted) {
      completedAt = DateTime.now();
    } else if (newPageCount < book.totalPages) {
      completedAt = null; // Reabriu o livro
    }

    _books[index] = book.copyWith(
      currentPage: newPageCount,
      logs: updatedLogs,
      completedAt: completedAt,
    );

    // Atualiza Streak se houve progresso positivo (simulação simples: qualquer update conta como atividade se for no dia)
    // Para ser rigoroso: só conta se newPageCount > anterior.
    if (newPageCount > book.currentPage || newPageCount <= book.totalPages) {
      // Assume que interagiu com o livro
      await _updateStreak();
    }

    await _saveAllLocal();
    // notifyListeners(); // Removido - ReadingService não estende ChangeNotifier
  }

  Future<void> deleteBook(String bookId) async {
    _books.removeWhere((b) => b.id == bookId);
    await _saveAllLocal();
    // notifyListeners(); // Removido - ReadingService não estende ChangeNotifier
  }

  Future<void> updateBook({
    required String bookId,
    required String title,
    String? author,
    required int totalPages,
    required ReadingTheme theme,
  }) async {
    final index = _books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      _books[index] = _books[index].copyWith(
        title: title,
        author: author,
        totalPages: totalPages,
        theme: theme,
      );
      await _saveAllLocal();
      // notifyListeners(); // Removido - ReadingService não estende ChangeNotifier
    }
  }

  // ===========================================
  // LÓGICA DE GAMIFICAÇÃO
  // ===========================================

  Future<void> _updateStreak() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_lastReadingDate == null) {
      // Primeira vez
      _currentStreak = 1;
      _lastReadingDate = now;
    } else {
      final last = DateTime(_lastReadingDate!.year, _lastReadingDate!.month,
          _lastReadingDate!.day);

      final diff = today.difference(last).inDays;

      if (diff == 0) {
        // Já leu hoje, não muda o streak
        _lastReadingDate = now; // Atualiza timestamp para log
      } else if (diff == 1) {
        // Leu ontem, incrementa!
        _currentStreak++;
        _lastReadingDate = now;
        await _checkMedals();
      } else {
        // Quebrou o streak (maior que 1 dia)
        _currentStreak = 1; // Reinicia hoje
        _lastReadingDate = now;
      }
    }

    await _saveStreakData();
  }

  Future<void> _checkMedals() async {
    // 3, 5, 7, 10
    if (_currentStreak >= 3 && !hasBronze) {
      hasBronze = true;
      _gamificationService
          .awardMedal(NicheId.reading, GamificationMedal.bronze);
    }
    if (_currentStreak >= 5 && !hasSilver) {
      hasSilver = true;
      _gamificationService
          .awardMedal(NicheId.reading, GamificationMedal.prata);
    }
    if (_currentStreak >= 7 && !hasGold) {
      hasGold = true;
      _gamificationService
          .awardMedal(NicheId.reading, GamificationMedal.ouro);
    }
    if (_currentStreak >= 10 && !hasDiamond) {
      hasDiamond = true;
      _gamificationService
          .awardMedal(NicheId.reading, GamificationMedal.diamante);
    }
  }

  // ===========================================
  // NOTIFICAÇÕES
  // ===========================================

  Future<TimeOfDay?> getSavedNotificationTime() async {
    final h = await _prefs.getInt('reading_notification_hour');
    final m = await _prefs.getInt('reading_notification_minute');
    if (h != null && m != null) {
      return TimeOfDay(hour: h, minute: m);
    }
    return null;
  }

  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    // Salvar preferência
    await _prefs.setInt('reading_notification_hour', time.hour);
    await _prefs.setInt('reading_notification_minute', time.minute);

    // ID base para leitura: 9000

    await NotificationService.scheduleDailyNotification(
      id: 9000,
      time: time,
      title: 'Hora da leitura diária! 📚',
      body: 'Vamos viajar mais um pouco no mundo dos livros?',
      payload: 'reading',
      actions: [
        const AndroidNotificationAction(
          'reading_log',
          'Inserir progresso',
          showsUserInterface: true,
          cancelNotification: true,
        ),
        const AndroidNotificationAction(
          'reading_skip',
          'Não vou ler hoje',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );
  }

  Future<void> cancelDailyReminder() async {
    await _prefs.remove('reading_notification_hour');
    await _prefs.remove('reading_notification_minute');
    await NotificationService.cancelNotification(9000);
    // notifyListeners(); // Removido - ReadingService não estende ChangeNotifier
  }
  // ===========================================
  // ESTATÍSTICAS
  // ===========================================

  List<ReadingBook> get completedBooks =>
      _books.where((b) => b.isCompleted).toList();

  ReadingBook? get lastCompletedBook {
    final completed = completedBooks;
    if (completed.isEmpty) return null;
    completed.sort((a, b) {
      // Ordena decrescente por data de conclusão
      final dateA = a.completedAt ?? a.createdAt;
      final dateB = b.completedAt ?? b.createdAt;
      return dateB.compareTo(dateA);
    });
    return completed.first;
  }

  /// Retorna um Map com os últimos 7 dias e a quantidade de páginas lidas em cada um.
  /// Chave: DateTime (apenas data, sem hora)
  /// Valor: Total de páginas lidas naquele dia (somando todos os livros)
  Map<DateTime, int> getWeeklyReadPages() {
    final Map<DateTime, int> dailyPages = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Inicializa os últimos 7 dias com 0
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      dailyPages[date] = 0;
    }

    for (final book in _books) {
      // Ordena logs por data
      final sortedLogs = List<ReadingLog>.from(book.logs)
        ..sort((a, b) => a.date.compareTo(b.date));

      if (sortedLogs.isEmpty) continue;

      // Para cada dia do gráfico, calcula o progresso
      // Progresso no dia D = (Páginas no final de D) - (Páginas no final de D-1)
      for (final date in dailyPages.keys) {
        final logsUntilToday = sortedLogs.where((l) {
          final lDate = DateTime(l.date.year, l.date.month, l.date.day);
          return lDate.isAtSameMomentAs(date) || lDate.isBefore(date);
        }).toList();

        final logsBeforeToday = sortedLogs.where((l) {
          final lDate = DateTime(l.date.year, l.date.month, l.date.day);
          return lDate.isBefore(date);
        }).toList();

        int pagesToday = 0;
        if (logsUntilToday.isNotEmpty) {
          pagesToday = logsUntilToday.last.pageNumber;
        }

        int pagesBefore = 0;
        if (logsBeforeToday.isNotEmpty) {
          pagesBefore = logsBeforeToday.last.pageNumber;
        }

        final delta = pagesToday - pagesBefore;
        if (delta > 0) {
          dailyPages[date] = (dailyPages[date] ?? 0) + delta;
        }
      }
    }

    return dailyPages;
  }

  /// Retorna estatísticas de temas.
  /// Lista de Maps: {'theme': ReadingTheme, 'count': int, 'percent': double}
  List<Map<String, dynamic>> getThemeStats() {
    if (_books.isEmpty) return [];

    final total = _books.length;
    final Map<ReadingTheme, int> counts = {};

    for (final book in _books) {
      counts[book.theme] = (counts[book.theme] ?? 0) + 1;
    }

    final stats = counts.entries.map((e) {
      return {
        'theme': e.key,
        'count': e.value,
        'percent': e.value / total,
      };
    }).toList();

    // Ordena do mais frequente para o menos frequente
    stats.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

    return stats;
  }
}
