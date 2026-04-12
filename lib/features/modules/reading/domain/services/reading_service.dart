import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/storage/objectbox_preferences_repository.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/features/modules/reading/data/repositories/reading_repository.dart';
import 'package:disciplinum/features/modules/reading/domain/entities/reading_model.dart';
import 'package:disciplinum/core/database/entities/reading_book_entity.dart';
import 'package:disciplinum/features/modules/reading/gamification/data/repositories/reading_gamification_repository.dart';
import 'package:disciplinum/features/modules/reading/gamification/domain/entities/reading_gamification_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';

/// Serviço principal para gerenciamento de leitura - VERSÃO RIVERPOD
class ReadingService {
  final ReadingRepository _repository;
  final ReadingGamificationRepository _gamificationRepository;
  final dynamic _gamificationService; // Tipo dinâmico para evitar dependência circular
  late final ObjectBoxPreferencesRepository _prefs;

  List<ReadingBook> _books = [];
  int _currentStreak = 0;
  DateTime? _lastReadingDate;
  ReadingGamificationEntity? _gamificationEntity;

  ReadingService(this._repository, this._gamificationRepository, [this._gamificationService]) {
    _prefs = ObjectBoxPreferencesRepository(ObjectBoxService.instance.store);
    _loadData();
  }

  // GETTERS
  List<ReadingBook> get books => List.unmodifiable(_books);
  int get currentStreak => _currentStreak;
  DateTime? get lastReadingDate => _lastReadingDate;

  List<ReadingBook> get completedBooks =>
      _books.where((b) => b.isCompleted).toList();

  ReadingBook? get lastCompletedBook {
    final completed = completedBooks;
    if (completed.isEmpty) return null;
    completed.sort((a, b) {
      final dateA = a.completedAt ?? a.createdAt;
      final dateB = b.completedAt ?? b.createdAt;
      return dateB.compareTo(dateA);
    });
    return completed.first;
  }

  // MÉTODOS DE AÇÃO
  Future<void> addBook({
    required String title,
    required int totalPages,
    required ReadingTheme theme,
    String? author,
  }) async {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
    final entity = ReadingBookEntity.create(
      userId: userId,
      title: title,
      author: author ?? '',
      totalPages: totalPages,
      theme: theme,
    );
    
    await _repository.saveBook(entity);
    await _loadBooks();
  }

  Future<void> updateProgress(String bookId, int newPageCount) async {
    final id = int.tryParse(bookId);
    if (id == null) return;

    final entity = await _repository.getBook(id);
    if (entity == null) return;

    final updatedEntity = entity.updateProgress(newPageCount);
    
    // Atualiza logs no additionalData
    final List<dynamic> currentLogs = entity.additionalData != null 
        ? jsonDecode(entity.additionalData!)['logs'] ?? []
        : [];
    
    currentLogs.add({
      'timestamp': DateTime.now().toIso8601String(),
      'pageNumber': newPageCount,
    });

    final finalEntity = updatedEntity.copyWith(
      additionalData: jsonEncode({'logs': currentLogs}),
      isCompleted: newPageCount >= entity.totalPages,
      completedDate: (newPageCount >= entity.totalPages && !entity.isCompleted) 
          ? DateTime.now() 
          : (newPageCount < entity.totalPages ? null : entity.completedDate),
    );

    await _repository.saveBook(finalEntity);
    
    // Atualiza Streak se houve progresso positivo
    await _updateStreak();

    await _loadBooks();
  }

  Future<void> updateBook({
    required String bookId,
    required String title,
    String? author,
    int? currentPage,
    int? totalPages,
    ReadingTheme? theme,
  }) async {
    final id = int.tryParse(bookId);
    if (id == null) return;

    final entity = await _repository.getBook(id);
    if (entity == null) return;

    final updatedEntity = entity.copyWith(
      title: title,
      author: author ?? entity.author,
      currentPage: currentPage ?? entity.currentPage,
      totalPages: totalPages ?? entity.totalPages,
      theme: theme ?? entity.theme,
      updatedAt: DateTime.now(),
    );

    await _repository.saveBook(updatedEntity);
    await _loadBooks();
  }

  Future<void> deleteBook(String bookId) async {
    final id = int.tryParse(bookId);
    if (id == null) return;
    
    await _repository.deleteBook(id);
    await _loadBooks();
  }

  // MÉTODOS PRIVADOS
  Future<void> _loadData() async {
    await _loadBooks();
    await _loadStreak();
  }

  Future<void> _loadBooks() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'default_user';
      final entities = await _repository.getBooks(userId);
      _books = entities.map((e) {
        final List<ReadingLog> logs = [];
        if (e.additionalData != null) {
          try {
            final data = jsonDecode(e.additionalData!);
            final List<dynamic> logData = data['logs'] ?? [];
            logs.addAll(logData.map((l) => ReadingLog.fromJson(l)).toList());
          } catch (_) {}
        }

        return ReadingBook(
          id: e.id.toString(),
          title: e.title,
          author: e.author,
          totalPages: e.totalPages,
          currentPage: e.currentPage,
          theme: e.theme,
          createdAt: e.createdAt,
          completedAt: e.completedDate,
          logs: logs,
        );
      }).toList();
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar livros: $e');
    }
  }

  Future<void> _loadStreak() async {
    try {
      final entity = await _gamificationRepository.getReadingState();
      if (entity != null) {
        _gamificationEntity = entity;
        _currentStreak = entity.consecutiveDays;
        _lastReadingDate = entity.lastReadingDate;
      } else {
        _gamificationEntity = ReadingGamificationEntity();
        _currentStreak = 0;
        _lastReadingDate = null;
      }
      
      // Sincroniza com o GamificationService global para exibição em medalhas etc
      _syncToGlobalGamification();
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar streak de leitura: $e');
    }
  }

  Future<void> _updateStreak() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _gamificationEntity ??= ReadingGamificationEntity()..startDate = today;

    if (_lastReadingDate == null) {
      _currentStreak = 1;
      _lastReadingDate = today;
    } else {
      final lastDate = DateTime(
        _lastReadingDate!.year,
        _lastReadingDate!.month,
        _lastReadingDate!.day,
      );

      final difference = today.difference(lastDate).inDays;

      if (difference == 0) {
        return;
      } else if (difference == 1) {
        _currentStreak++;
      } else {
        _currentStreak = 1;
      }

      _lastReadingDate = today;
    }

    _gamificationEntity!.consecutiveDays = _currentStreak;
    _gamificationEntity!.lastReadingDate = _lastReadingDate;
    _gamificationEntity!.touch();

    await _gamificationRepository.saveReadingState(_gamificationEntity!);
    
    _syncToGlobalGamification();
  }

  void _syncToGlobalGamification() {
    if (_gamificationService != null) {
      _gamificationService.updateConsecutiveDaysSync(NicheId.reading.id, _currentStreak);
    }
  }

  /// Obtém o horário de notificação salvo
  Future<TimeOfDay> getSavedNotificationTime() async {
    // Implementado usando IsarPreferencesRepository
    final hour = await _prefs.getInt('reading_notification_hour') ?? 20;
    final minute = await _prefs.getInt('reading_notification_minute') ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Agenda lembrete diário
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    // Implementado usando NotificationService
    await NotificationService.scheduleDailyNotification(
      id: 3001, // ID único para reading
      time: time,
      body: 'Hora da sua leitura diária! 📚',
      title: 'Lembrete de Leitura',
      payload: 'reading_reminder',
    );
    
    // Salva o horário configurado
    await _prefs.setInt('reading_notification_hour', time.hour);
    await _prefs.setInt('reading_notification_minute', time.minute);
    
    final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    LoggerService.instance.i('Daily reminder scheduled for $timeString');
  }

  /// Cancela lembrete diário
  Future<void> cancelDailyReminder() async {
    // Implementado usando NotificationService
    await NotificationService.cancelNotification(3001);
    LoggerService.instance.i('Daily reminder cancelled');
  }
}
