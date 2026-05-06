import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/objectbox.g.dart';

/// Serviço principal para gerenciamento do banco ObjectBox
/// 
/// IMPLEMENTAÇÃO OFICIAL ObjectBox PARA MULTI-ISOLATE:
/// - ObjectBox roda no nível NATIVO/PROCESSO (uma única instância nativa)
/// - Todos os isolates Dart compartilham a MESMA store nativa
/// - Cada isolate Dart tem sua própria instância Dart Store que aponta para a mesma store nativa
/// - Use Store.attach() para conectar a uma store já aberta em outro isolate
/// 
/// Documentação: https://docs.objectbox.io/getting-started
/// GitHub Issue: https://github.com/objectbox/objectbox-dart/issues/436
class ObjectBoxService {
  static ObjectBoxService? _instance;
  static ObjectBoxService get instance => _instance ??= ObjectBoxService._internal();
  
  ObjectBoxService._internal();

  Store? _store;
  bool _isInitialized = false;
  String? _currentStorePath;
  bool _isAttachedStore = false;

  /// Inicializa o banco de dados ObjectBox
  /// 
  /// EM BACKGROUND TASKS:
  /// - Se a store principal já estiver aberta (pelo app), usa Store.attach()
  /// - Isso conecta ao MESMO banco nativo, garantindo sincronização total
  /// - Transações são sincronizadas automaticamente entre isolates
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final dbPath = (await getApplicationDocumentsDirectory()).path;
      final mainDirectory = Directory('$dbPath/objectbox');
      final mainPath = mainDirectory.path;
      
      if (!mainDirectory.existsSync()) {
        mainDirectory.createSync(recursive: true);
      }

      // VERIFICA SE A STORE JÁ ESTÁ ABERTA NO PATH PRINCIPAL
      // Store.isOpen() verifica no nível NATIVO se há uma store aberta neste path
      final bool isStoreAlreadyOpen = Store.isOpen(mainPath);
      
      if (isStoreAlreadyOpen) {
        // STORE JÁ ABERTA (app principal está rodando)
        // Usa Store.attach() para conectar à store nativa existente
        // Ambos os isolates verão os MESMOS dados em tempo real
        _store = Store.attach(
          getObjectBoxModel(),
          mainPath,
        );
        _isAttachedStore = true;
        _currentStorePath = mainPath;
        _isInitialized = true;
        
        LoggerService.instance.i('✅ ObjectBox CONNECTED via Store.attach() - Sincronização total ativa');
        LoggerService.instance.i('   Path: $_currentStorePath');
        LoggerService.instance.i('   Store nativa compartilhada entre app e background task');
      } else {
        // STORE NÃO ESTÁ ABERTA (app fechado ou primeira inicialização)
        // Cria uma nova store normalmente
        _store = Store(
          getObjectBoxModel(),
          directory: mainPath,
        );
        _isAttachedStore = false;
        _currentStorePath = mainPath;
        _isInitialized = true;
        
        LoggerService.instance.i('✅ ObjectBox database initialized successfully');
        LoggerService.instance.i('   Path: $_currentStorePath');
        LoggerService.instance.i('   Nova store criada (app principal ou background isolada)');
      }
    } catch (e, stackTrace) {
      LoggerService.instance.e('❌ Failed to initialize ObjectBox database', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Verifica se a store atual é uma store "attached" (conectada a outra)
  bool get isAttachedStore => _isAttachedStore;

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
