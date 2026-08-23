import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/objectbox.g.dart';

// Entities
import 'package:disciplinum/core/database/entities/user_module_state.dart';
import 'package:disciplinum/core/database/entities/gamification_progress.dart';
import 'package:disciplinum/core/database/entities/reading_book_entity.dart';
import 'package:disciplinum/core/storage/entities/daily_checkin_entity.dart';
import 'package:disciplinum/core/storage/entities/user_choices_entity.dart';

/// Versão do formato de backup — incrementar se a estrutura mudar.
const int _kBackupVersion = 1;

/// Resultado de uma operação de backup ou restore.
class BackupResult {
  final bool success;
  final String? errorMessage;
  final String? filePath;

  const BackupResult._({required this.success, this.errorMessage, this.filePath});

  factory BackupResult.ok({String? filePath}) =>
      BackupResult._(success: true, filePath: filePath);

  factory BackupResult.error(String message) =>
      BackupResult._(success: false, errorMessage: message);
}

/// Serviço responsável por exportar/importar todos os dados do app em JSON.
///
/// Estratégia de exportação:
/// - Lê todas as boxes relevantes do ObjectBox
/// - Serializa cada entidade manualmente (sem reflexão)
/// - Salva como um arquivo .json compartilhável
///
/// Estratégia de importação:
/// - Usuário escolhe o arquivo via file_picker
/// - Valida versão e estrutura
/// - Limpa os dados locais existentes (merge não é suportado)
/// - Restaura cada entidade de volta ao ObjectBox
class LocalBackupService {
  final Store _store;

  LocalBackupService(this._store);

  // ─────────────────────────────────────────────────────────────────────────
  // EXPORT
  // ─────────────────────────────────────────────────────────────────────────

  /// Gera o JSON completo e compartilha via share sheet nativo.
  Future<BackupResult> exportAndShare() async {
    try {
      final json = await _buildBackupJson();
      final file = await _writeToTempFile(json);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json')],
          subject: 'Backup Disciplinum',
          text: 'Backup dos seus dados do Disciplinum',
        ),
      );
      LoggerService.instance.i('✅ Backup exportado via share sheet: ${file.path}');
      return BackupResult.ok(filePath: file.path);
    } catch (e, st) {
      LoggerService.instance.e('❌ Erro ao exportar backup', error: e, stackTrace: st);
      return BackupResult.error('Falha ao exportar: $e');
    }
  }

  /// Gera o JSON completo e salva em /Downloads (Android) ou Documents (iOS/outros).
  Future<BackupResult> exportToDevice() async {
    try {
      final json = await _buildBackupJson();
      final file = await _writeToDownloadsFile(json);
      LoggerService.instance.i('✅ Backup salvo em: ${file.path}');
      return BackupResult.ok(filePath: file.path);
    } catch (e, st) {
      LoggerService.instance.e('❌ Erro ao salvar backup', error: e, stackTrace: st);
      return BackupResult.error('Falha ao salvar: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // IMPORT
  // ─────────────────────────────────────────────────────────────────────────

  /// Abre o file picker para o usuário escolher um arquivo de backup JSON,
  /// valida e restaura os dados.
  Future<BackupResult> importFromDevice() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Selecionar backup do Disciplinum',
      );

      if (file == null) {
        return BackupResult.error('Nenhum arquivo selecionado.');
      }

      final path = file.path;
      if (path == null) {
        return BackupResult.error('Caminho do arquivo inválido.');
      }

      final content = await File(path).readAsString();
      return _restoreFromJson(content);
    } catch (e, st) {
      LoggerService.instance.e('❌ Erro ao importar backup', error: e, stackTrace: st);
      return BackupResult.error('Falha ao importar: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // INTERNAL — BUILD
  // ─────────────────────────────────────────────────────────────────────────

  Future<String> _buildBackupJson() async {
    final store = _store;

    final moduleStates = store.box<UserModuleState>().getAll();
    final gamification = store.box<GamificationProgress>().getAll();
    final books = store.box<ReadingBookEntity>().getAll();
    final checkins = store.box<DailyCheckin>().getAll();
    final userChoices = store.box<UserChoicesEntity>().getAll();

    final payload = {
      'version': _kBackupVersion,
      'exported_at': DateTime.now().toIso8601String(),
      'app': 'disciplinum',
      'data': {
        'module_states': moduleStates.map(_serializeModuleState).toList(),
        'gamification': gamification.map(_serializeGamification).toList(),
        'reading_books': books.map(_serializeBook).toList(),
        'daily_checkins': checkins.map(_serializeCheckin).toList(),
        'user_choices': userChoices.map(_serializeUserChoices).toList(),
      },
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // INTERNAL — SERIALIZERS
  // ─────────────────────────────────────────────────────────────────────────

  Map<String, dynamic> _serializeModuleState(UserModuleState e) => {
        'userId': e.userId,
        'nicheId': e.nicheId,
        'isModuleActive': e.isModuleActive,
        'consecutiveDays': e.consecutiveDays,
        'focusPeriodsRespected': e.focusPeriodsRespected,
        'maxMedal': e.maxMedal,
        'additionalData': e.additionalData,
        'lastAccessDate': e.lastAccessDate.toIso8601String(),
        'createdAt': e.createdAt.toIso8601String(),
        'updatedAt': e.updatedAt.toIso8601String(),
      };

  Map<String, dynamic> _serializeGamification(GamificationProgress e) => {
        'userId': e.userId,
        'nicheId': e.nicheId,
        'currentStreak': e.currentStreak,
        'bestStreak': e.bestStreak,
        'lastActivityDate': e.lastActivityDate.toIso8601String(),
        'unlockedAchievements': e.unlockedAchievements,
        'currentMedal': e.currentMedal,
        'additionalData': e.additionalData,
        'createdAt': e.createdAt.toIso8601String(),
        'updatedAt': e.updatedAt.toIso8601String(),
      };

  Map<String, dynamic> _serializeBook(ReadingBookEntity e) => {
        'userId': e.userId,
        'title': e.title,
        'author': e.author,
        'totalPages': e.totalPages,
        'currentPage': e.currentPage,
        'themeIndex': e.themeIndex,
        'coverUrl': e.coverUrl,
        'startDate': e.startDate?.toIso8601String(),
        'completedDate': e.completedDate?.toIso8601String(),
        'isCompleted': e.isCompleted,
        'notes': e.notes,
        'rating': e.rating,
        'additionalData': e.additionalData,
        'createdAt': e.createdAt.toIso8601String(),
        'updatedAt': e.updatedAt.toIso8601String(),
      };

  Map<String, dynamic> _serializeCheckin(DailyCheckin e) => {
        'nicheIdIndex': e.nicheIdIndex,
        'nicheIdDate': e.nicheIdDate,
        'dateStr': e.dateStr,
        'createdAt': e.createdAt.toIso8601String(),
      };

  Map<String, dynamic> _serializeUserChoices(UserChoicesEntity e) => {
        'userId': e.userId,
        'showEmail': e.showEmail,
        'showAvatar': e.showAvatar,
        'theme': e.theme,
        'notificationsEnabled': e.notificationsEnabled,
        'notificationTime': e.notificationTime,
        'language': e.language,
        'moduleVisibilityJson': e.moduleVisibilityJson,
        'version': e.version,
        'createdAt': e.createdAt.toIso8601String(),
        'updatedAt': e.updatedAt.toIso8601String(),
      };

  // ─────────────────────────────────────────────────────────────────────────
  // INTERNAL — RESTORE
  // ─────────────────────────────────────────────────────────────────────────

  Future<BackupResult> _restoreFromJson(String content) async {
    final Map<String, dynamic> payload;
    try {
      payload = jsonDecode(content) as Map<String, dynamic>;
    } catch (_) {
      return BackupResult.error('Arquivo inválido: não é um JSON válido.');
    }

    if (payload['app'] != 'disciplinum') {
      return BackupResult.error('Este arquivo não é um backup do Disciplinum.');
    }

    final version = payload['version'] as int? ?? 0;
    if (version > _kBackupVersion) {
      return BackupResult.error(
          'Backup criado em uma versão mais nova do app. Atualize o Disciplinum.');
    }

    final data = payload['data'] as Map<String, dynamic>? ?? {};

    final store = _store;

    // Limpa dados existentes e restaura
    store.runInTransaction(TxMode.write, () {
      _restoreModuleStates(store, data['module_states']);
      _restoreGamification(store, data['gamification']);
      _restoreBooks(store, data['reading_books']);
      _restoreCheckins(store, data['daily_checkins']);
      _restoreUserChoices(store, data['user_choices']);
    });

    LoggerService.instance.i('✅ Backup restaurado com sucesso (versão $version)');
    return BackupResult.ok();
  }

  void _restoreModuleStates(Store store, dynamic raw) {
    if (raw == null) return;
    final box = store.box<UserModuleState>();
    box.removeAll();
    for (final m in (raw as List)) {
      final e = UserModuleState();
      e.userId = m['userId'] as String? ?? '';
      e.nicheId = m['nicheId'] as int? ?? 0;
      e.isModuleActive = m['isModuleActive'] as bool? ?? false;
      e.consecutiveDays = m['consecutiveDays'] as int? ?? 0;
      e.focusPeriodsRespected = m['focusPeriodsRespected'] as int? ?? 0;
      e.maxMedal = m['maxMedal'] as String?;
      e.additionalData = m['additionalData'] as String?;
      e.lastAccessDate = _parseDate(m['lastAccessDate']);
      e.createdAt = _parseDate(m['createdAt']);
      e.updatedAt = _parseDate(m['updatedAt']);
      box.put(e);
    }
  }

  void _restoreGamification(Store store, dynamic raw) {
    if (raw == null) return;
    final box = store.box<GamificationProgress>();
    box.removeAll();
    for (final m in (raw as List)) {
      final e = GamificationProgress(
        userId: m['userId'] as String? ?? '',
        nicheId: m['nicheId'] as int? ?? 0,
        currentStreak: m['currentStreak'] as int? ?? 0,
        bestStreak: m['bestStreak'] as int? ?? 0,
        lastActivityDate: _parseDate(m['lastActivityDate']),
        unlockedAchievements: m['unlockedAchievements'] as String?,
        currentMedal: m['currentMedal'] as String?,
        additionalData: m['additionalData'] as String?,
        createdAt: _parseDate(m['createdAt']),
        updatedAt: _parseDate(m['updatedAt']),
      );
      box.put(e);
    }
  }

  void _restoreBooks(Store store, dynamic raw) {
    if (raw == null) return;
    final box = store.box<ReadingBookEntity>();
    box.removeAll();
    for (final m in (raw as List)) {
      final e = ReadingBookEntity();
      e.userId = m['userId'] as String? ?? '';
      e.title = m['title'] as String? ?? '';
      e.author = m['author'] as String? ?? '';
      e.totalPages = m['totalPages'] as int? ?? 0;
      e.currentPage = m['currentPage'] as int? ?? 0;
      e.themeIndex = m['themeIndex'] as int? ?? 0;
      e.coverUrl = m['coverUrl'] as String?;
      e.startDate = _parseDateOrNull(m['startDate']);
      e.completedDate = _parseDateOrNull(m['completedDate']);
      e.isCompleted = m['isCompleted'] as bool? ?? false;
      e.notes = m['notes'] as String?;
      e.rating = m['rating'] as int?;
      e.additionalData = m['additionalData'] as String?;
      e.createdAt = _parseDate(m['createdAt']);
      e.updatedAt = _parseDate(m['updatedAt']);
      box.put(e);
    }
  }

  void _restoreCheckins(Store store, dynamic raw) {
    if (raw == null) return;
    final box = store.box<DailyCheckin>();
    box.removeAll();
    for (final m in (raw as List)) {
      final e = DailyCheckin();
      e.nicheIdIndex = m['nicheIdIndex'] as int? ?? 0;
      e.nicheIdDate = m['nicheIdDate'] as String? ?? '';
      e.dateStr = m['dateStr'] as String? ?? '';
      e.createdAt = _parseDate(m['createdAt']);
      box.put(e);
    }
  }

  void _restoreUserChoices(Store store, dynamic raw) {
    if (raw == null) return;
    final box = store.box<UserChoicesEntity>();
    box.removeAll();
    for (final m in (raw as List)) {
      final e = UserChoicesEntity(
        userId: m['userId'] as String? ?? '',
        showEmail: m['showEmail'] as bool? ?? true,
        showAvatar: m['showAvatar'] as bool? ?? true,
        theme: m['theme'] as String? ?? 'system',
        notificationsEnabled: m['notificationsEnabled'] as bool? ?? true,
        notificationTime: m['notificationTime'] as String? ?? '09:00',
        language: m['language'] as String? ?? 'pt_BR',
        moduleVisibilityJson: m['moduleVisibilityJson'] as String? ?? '{}',
        version: m['version'] as int? ?? 1,
      )
        ..createdAt = _parseDate(m['createdAt'])
        ..updatedAt = _parseDate(m['updatedAt']);
      box.put(e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // INTERNAL — FILE HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  Future<File> _writeToTempFile(String json) async {
    final dir = await getTemporaryDirectory();
    final filename = _buildFilename();
    final file = File('${dir.path}/$filename');
    await file.writeAsString(json, flush: true);
    return file;
  }

  Future<File> _writeToDownloadsFile(String json) async {
    Directory dir;
    if (Platform.isAndroid) {
      // /storage/emulated/0/Download
      dir = Directory('/storage/emulated/0/Download');
      if (!dir.existsSync()) {
        dir = await getApplicationDocumentsDirectory();
      }
    } else {
      dir = await getApplicationDocumentsDirectory();
    }
    final filename = _buildFilename();
    final file = File('${dir.path}/$filename');
    await file.writeAsString(json, flush: true);
    return file;
  }

  String _buildFilename() {
    final stamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    return 'disciplinum_backup_$stamp.json';
  }

  DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    try {
      return DateTime.parse(value as String);
    } catch (_) {
      return DateTime.now();
    }
  }

  DateTime? _parseDateOrNull(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value as String);
    } catch (_) {
      return null;
    }
  }
}
