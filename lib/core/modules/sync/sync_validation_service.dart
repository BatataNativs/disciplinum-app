import 'package:package_info_plus/package_info_plus.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/storage/local_storage_service.dart';

/// Serviço que determina se a sincronização inicial deve ocorrer
/// 
/// A sincronização só deve acontecer nas seguintes situações:
/// 1. Nova build (debugging, profile, release)
/// 2. Nova instalação do app  
/// 3. Novo login (usuário diferente do último)
class SyncValidationService {
  static final SyncValidationService _instance = SyncValidationService._internal();
  factory SyncValidationService() => _instance;
  SyncValidationService._internal();

  final LoggerService _logger = LoggerService.instance;
  
  // Chaves de persistência
  static const String _kLastSyncedUserId = 'sync_last_user_id';
  static const String _kFirstRunComplete = 'sync_first_run_complete';
  static const String _kLastBuildSignature = 'sync_last_build_signature';
  static const String _kLastInstallTime = 'sync_last_install_time';

  /// Verifica se a sincronização deve ser executada
  /// 
  /// [currentUserId] - ID do usuário atualmente logado (pode ser null)
  /// [isLoginEvent] - true se esta verificação foi disparada por um evento de login
  ///                  (força sync mesmo que seja o mesmo usuário/build)
  Future<SyncCheckResult> shouldSync(String? currentUserId, {bool isLoginEvent = false}) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final storage = LocalStorageService.instance;
      
      // Dados do build atual
      final currentVersion = packageInfo.version;
      final currentBuild = packageInfo.buildNumber;
      final currentBuildSignature = '$currentVersion+$currentBuild';
      
      // Timestamp de instalação do APK (detecta flutter run, Play Store update, etc)
      final installTimeMillis = packageInfo.installTime?.millisecondsSinceEpoch ?? 0;
      final currentInstallTime = installTimeMillis.toString();
      
      _logger.d('🔍 Verificando necessidade de sync:');
      _logger.d('   - Usuário atual: $currentUserId');
      _logger.d('   - Versão atual: $currentVersion');
      _logger.d('   - Build atual: $currentBuild');
      _logger.d('   - Build signature: $currentBuildSignature');
      _logger.d('   - Install time: $installTimeMillis');
      _logger.d('   - É evento de login: $isLoginEvent');

      // Verificar se é primeira execução
      final isFirstRun = !(await storage.get<bool>(_kFirstRunComplete) ?? false);
      
      // Verificar mudança de build (versão ou build number)
      final lastBuildSignature = await storage.get<String>(_kLastBuildSignature);
      final isNewBuild = lastBuildSignature != currentBuildSignature;
      
      // Verificar nova instalação do APK (timestamp mudou = novo APK instalado)
      final lastInstallTime = await storage.get<String>(_kLastInstallTime);
      final isNewInstall = lastInstallTime != currentInstallTime && installTimeMillis > 0;
      
      // Verificar mudança de usuário
      final lastUserId = await storage.get<String>(_kLastSyncedUserId);
      final isNewUser = lastUserId == null || lastUserId != currentUserId;
      
      _logger.d('   - Último build: $lastBuildSignature');
      _logger.d('   - Último install time: $lastInstallTime');
      _logger.d('   - Último usuário: $lastUserId');
      _logger.d('   - É primeira execução: $isFirstRun');
      _logger.d('   - É nova build: $isNewBuild');
      _logger.d('   - É nova instalação: $isNewInstall');
      _logger.d('   - É novo usuário: $isNewUser');

      // Se for evento de login, sempre sincronizar (mesmo que mesmo usuário/build)
      if (isLoginEvent && currentUserId != null) {
        _logger.i('🔐 Sync necessária: Evento de login detectado (re-login ou novo login)');
        return SyncCheckResult.shouldSync(
          reason: SyncReason.userLogin,
          currentVersion: currentVersion,
          currentBuild: currentBuild,
          currentUserId: currentUserId,
        );
      }

      // Determinar motivo da sincronização
      SyncReason? reason;
      
      if (isFirstRun) {
        reason = SyncReason.firstInstall;
        _logger.i('🆕 Sync necessária: Primeira execução do app');
      } else if (isNewInstall) {
        reason = SyncReason.newBuild;
        _logger.i('📦 Sync necessária: Nova instalação do APK detectada (flutter run/Play Store update)');
      } else if (isNewBuild) {
        reason = SyncReason.newBuild;
        _logger.i('🏗️ Sync necessária: Nova build detectada ($lastBuildSignature → $currentBuildSignature)');
      } else if (isNewUser) {
        if (currentUserId == null) {
          // Usuário deslogado - não sincronizar, mas registrar estado
          _logger.i('👤 Usuário deslogado - pulando sync');
          return SyncCheckResult.shouldSkip(
            reason: SyncSkipReason.noUser,
            lastUserId: lastUserId,
          );
        }
        reason = SyncReason.newUser;
        _logger.i('👤 Sync necessária: Novo usuário logado ($lastUserId → $currentUserId)');
      } else {
        _logger.i('✅ Sync NÃO necessária - Todas as verificações passaram');
        return SyncCheckResult.shouldSkip(
          reason: SyncSkipReason.alreadySynced,
          lastBuildSignature: lastBuildSignature,
          lastUserId: lastUserId,
        );
      }

      return SyncCheckResult.shouldSync(
        reason: reason,
        currentVersion: currentVersion,
        currentBuild: currentBuild,
        currentUserId: currentUserId,
      );
      
    } catch (e, stack) {
      _logger.e('❌ Erro ao verificar necessidade de sync', error: e, stackTrace: stack);
      // Em caso de erro, permitir sync para garantir consistência
      return SyncCheckResult.shouldSync(
        reason: SyncReason.errorFallback,
        error: e.toString(),
      );
    }
  }

  /// Marca a sincronização como concluída, salvando os dados atuais
  Future<void> markSyncCompleted(String? userId) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final storage = LocalStorageService.instance;
      
      final buildSignature = '${packageInfo.version}+${packageInfo.buildNumber}';
      final installTimeMillis = packageInfo.installTime?.millisecondsSinceEpoch ?? 0;
      
      await storage.save(_kLastBuildSignature, buildSignature);
      await storage.save(_kLastSyncedUserId, userId ?? '');
      await storage.save(_kFirstRunComplete, true);
      
      // Salvar timestamp de instalação para detectar flutter run/Play Store updates
      if (installTimeMillis > 0) {
        await storage.save(_kLastInstallTime, installTimeMillis.toString());
      }
      
      _logger.i('✅ Sync marcada como concluída:');
      _logger.i('   - Build: $buildSignature');
      _logger.i('   - Install time: $installTimeMillis');
      _logger.i('   - Usuário: $userId');
      
    } catch (e, stack) {
      _logger.e('❌ Erro ao marcar sync como concluída', error: e, stackTrace: stack);
    }
  }
  
  /// Reseta o estado de sincronização (útil para testes ou logout)
  Future<void> resetSyncState() async {
    try {
      final storage = LocalStorageService.instance;
      
      await storage.remove(_kLastBuildSignature);
      await storage.remove(_kLastSyncedUserId);
      await storage.remove(_kFirstRunComplete);
      await storage.remove(_kLastInstallTime);
      
      _logger.w('🔄 Estado de sync resetado');
      
    } catch (e, stack) {
      _logger.e('❌ Erro ao resetar estado de sync', error: e, stackTrace: stack);
    }
  }
  
  /// Retorna informações do estado atual de sincronização (para debug)
  Future<SyncDebugInfo> getDebugInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final storage = LocalStorageService.instance;
      
      return SyncDebugInfo(
        currentVersion: packageInfo.version,
        currentBuild: packageInfo.buildNumber,
        lastBuildSignature: await storage.get<String>(_kLastBuildSignature),
        lastSyncedUserId: await storage.get<String>(_kLastSyncedUserId),
        isFirstRunComplete: await storage.get<bool>(_kFirstRunComplete) ?? false,
      );
      
    } catch (e) {
      return SyncDebugInfo(
        error: e.toString(),
      );
    }
  }
}

/// Resultado da verificação de sincronização
class SyncCheckResult {
  final bool shouldSync;
  final SyncReason? reason;
  final SyncSkipReason? skipReason;
  final String? currentVersion;
  final String? currentBuild;
  final String? currentUserId;
  final String? lastBuildSignature;
  final String? lastUserId;
  final String? error;

  SyncCheckResult._({
    required this.shouldSync,
    this.reason,
    this.skipReason,
    this.currentVersion,
    this.currentBuild,
    this.currentUserId,
    this.lastBuildSignature,
    this.lastUserId,
    this.error,
  });

  factory SyncCheckResult.shouldSync({
    required SyncReason reason,
    String? currentVersion,
    String? currentBuild,
    String? currentUserId,
    String? error,
  }) => SyncCheckResult._(
    shouldSync: true,
    reason: reason,
    currentVersion: currentVersion,
    currentBuild: currentBuild,
    currentUserId: currentUserId,
    error: error,
  );

  factory SyncCheckResult.shouldSkip({
    required SyncSkipReason reason,
    String? lastBuildSignature,
    String? lastUserId,
  }) => SyncCheckResult._(
    shouldSync: false,
    skipReason: reason,
    lastBuildSignature: lastBuildSignature,
    lastUserId: lastUserId,
  );

  @override
  String toString() {
    if (shouldSync) {
      return 'SyncCheckResult(shouldSync: true, reason: $reason, version: $currentVersion+$currentBuild, user: $currentUserId)';
    } else {
      return 'SyncCheckResult(shouldSync: false, skipReason: $skipReason, lastBuild: $lastBuildSignature, lastUser: $lastUserId)';
    }
  }
}

/// Motivos para sincronizar
enum SyncReason {
  firstInstall,    // Primeira execução do app
  newBuild,        // Nova build (versão ou build number mudou)
  newUser,         // Usuário diferente logou
  userLogin,       // Login (novo ou re-login após logout)
  errorFallback,   // Erro na verificação, sync por segurança
}

/// Motivos para pular sincronização
enum SyncSkipReason {
  alreadySynced,   // Já sincronizado com build e usuário atual
  noUser,          // Sem usuário logado
}

/// Informações de debug do estado de sincronização
class SyncDebugInfo {
  final String? currentVersion;
  final String? currentBuild;
  final String? lastBuildSignature;
  final String? lastSyncedUserId;
  final bool isFirstRunComplete;
  final String? error;

  SyncDebugInfo({
    this.currentVersion,
    this.currentBuild,
    this.lastBuildSignature,
    this.lastSyncedUserId,
    this.isFirstRunComplete = false,
    this.error,
  });

  @override
  String toString() {
    return 'SyncDebugInfo(current: $currentVersion+$currentBuild, lastBuild: $lastBuildSignature, lastUser: $lastSyncedUserId, firstRun: $isFirstRunComplete)';
  }
}
