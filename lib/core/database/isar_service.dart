import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/database/entities/user_module_state.dart';
import 'package:disciplinum/core/database/entities/reading_book_entity.dart';
import 'package:disciplinum/core/database/entities/gamification_progress.dart';
import 'package:disciplinum/core/storage/entities/detection_session_entity.dart';
import 'package:disciplinum/core/storage/entities/monitoring_state_entity.dart';

/// Serviço principal para gerenciamento do banco Isar
class IsarService {
  static IsarService? _instance;
  static IsarService get instance => _instance ??= IsarService._internal();
  
  IsarService._internal();

  Isar? _isar;
  bool _isInitialized = false;

  /// Inicializa o banco de dados Isar
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final dbPath = (await getApplicationDocumentsDirectory()).path;

      _isar = await Isar.open(
        [
          UserModuleStateSchema,
          ReadingBookEntitySchema,
          GamificationProgressSchema,
          DetectionSessionSchema,     
          MonitoringStateSchema,      
        ],
        directory: dbPath,
      );
      
      _isInitialized = true;
      LoggerService.instance.i('Isar database initialized successfully at: $dbPath');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Failed to initialize Isar database', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Verifica se o banco está inicializado
  bool get isInitialized => _isInitialized;

  /// Obtém instância do banco
  Isar get database {
    if (!_isInitialized || _isar == null) {
      throw StateError('Isar database not initialized. Call initialize() first.');
    }
    return _isar!;
  }

  /// Getter para DetectionSessions
  IsarCollection<DetectionSession> get detectionSessions => database.detectionSessions; // ✅ DESCOMENTAR

  /// Getter para MonitoringStates  
  IsarCollection<MonitoringState> get monitoringStates => database.monitoringStates; // ✅ DESCOMENTAR

  /// Limpa todo o banco (apenas para desenvolvimento)
  Future<void> clearAll() async {
    if (!_isInitialized) return;

    try {
      await _isar!.writeTxn(() async {
        await _isar!.clear();
      });
      LoggerService.instance.i('Isar database cleared successfully');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Failed to clear database', error: e, stackTrace: stackTrace);
    }
  }

  /// Fecha o banco de dados
  Future<void> close() async {
    if (_isar != null) {
      await _isar!.close();
      _isar = null;
      _isInitialized = false;
      LoggerService.instance.i('Isar database closed');
    }
  }
}
