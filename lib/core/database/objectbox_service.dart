import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/objectbox.g.dart';

/// Serviço principal para gerenciamento do banco ObjectBox
class ObjectBoxService {
  static ObjectBoxService? _instance;
  static ObjectBoxService get instance => _instance ??= ObjectBoxService._internal();
  
  ObjectBoxService._internal();

  Store? _store;
  bool _isInitialized = false;

  /// Inicializa o banco de dados ObjectBox
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final dbPath = (await getApplicationDocumentsDirectory()).path;
      final directory = Directory('$dbPath/objectbox');
      
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      _store = Store(
        getObjectBoxModel(),
        directory: directory.path,
      );
      
      _isInitialized = true;
      LoggerService.instance.i('ObjectBox database initialized successfully at: ${directory.path}');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Failed to initialize ObjectBox database', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Verifica se o banco está inicializado
  bool get isInitialized => _isInitialized;

  /// Obtém instância do store
  Store get store {
    if (!_isInitialized || _store == null) {
      throw StateError('ObjectBox database not initialized. Call initialize() first.');
    }
    return _store!;
  }

  /// Fecha o banco de dados
  void close() {
    _store?.close();
    _store = null;
    _isInitialized = false;
    LoggerService.instance.i('ObjectBox database closed');
  }
}
