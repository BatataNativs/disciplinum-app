import 'package:objectbox/objectbox.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/features/modules/reading/gamification/domain/entities/reading_gamification_entity.dart';
import 'package:disciplinum/features/modules/reading/gamification/domain/services/reading_migration_checker.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

class ReadingGamificationRepository {
  static ReadingGamificationRepository? _instance;
  static ReadingGamificationRepository get instance => _instance ??= ReadingGamificationRepository._();
  ReadingGamificationRepository._();

  Box<ReadingGamificationEntity> get _box => ObjectBoxService.instance.store.box<ReadingGamificationEntity>();

  Future<void> saveReadingState(ReadingGamificationEntity entity) async {
    try {
      final existingEntity = _box.get(1);
      if (existingEntity != null) {
        entity.id = existingEntity.id;
      } else {
        entity.id = 1;
      }
      _box.put(entity);
      LoggerService.instance.gamification('✅ Estado Reading gamificação salvo com ObjectBox');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao salvar estado Reading gamificação', error: e, stackTrace: stackTrace);
    }
  }

  Future<ReadingGamificationEntity?> getReadingState() async {
    try {
      // Pega o primeiro registro (sempre 1 para simplificar como outros módulos)
      return _box.get(1);
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao carregar estado Reading gamificação', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> clearReadingState() async {
    try {
      _box.removeAll();
      LoggerService.instance.gamification('🗑️ Estado Reading gamificação limpo');
    } catch (e, stackTrace) {
      LoggerService.instance.e('Erro ao limpar estado Reading gamificação', error: e, stackTrace: stackTrace);
    }
  }

  /// Sincroniza com Supabase (cloud sync)
  Future<void> syncWithSupabase(ReadingGamificationEntity entity) async {
    try {
      // Verifica se Supabase está disponível antes de sincronizar
      final migrationStatus = await ReadingMigrationChecker.instance.checkMigrationStatus();
      if (migrationStatus != MigrationStatus.complete) {
        LoggerService.instance.w('⚠️ Supabase não disponível - pulando sincronização');
        return;
      }

      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId != null) {
        await supabase.from('reading_gamification_states').upsert({
          'user_id': userId,
          'state_data': entity.toJson(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        LoggerService.instance.gamification('☁️ Estado Reading sincronizado com Supabase');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao sincronizar estado Reading com Supabase', error: e);
    }
  }

  /// Carrega estado do Supabase
  Future<ReadingGamificationEntity?> loadFromSupabase() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId != null) {
        final response = await supabase
            .from('reading_gamification_states')
            .select('state_data')
            .eq('user_id', userId)
            .maybeSingle();

        if (response != null && response['state_data'] != null) {
          return ReadingGamificationEntity.fromJson(response['state_data']);
        }
      }
      return null;
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar estado Reading do Supabase', error: e);
      return null;
    }
  }

  /// Inicializa o repositório
  Future<void> initialize() async {
    try {
      // Verifica se o Supabase está pronto para uso
      final migrationOk = await ReadingMigrationChecker.instance.ensureMigration();
      if (!migrationOk) {
        LoggerService.instance.w('⚠️ Supabase não está migrado - usando apenas Isar local');
      }

      LoggerService.instance.gamification('ReadingGamificationRepository inicializado');
    } catch (e) {
      LoggerService.instance.e('Erro ao inicializar ReadingGamificationRepository', error: e);
    }
  }

  /// Verifica se Supabase está disponível
  Future<bool> get supabaseAvailable async {
    return await ReadingMigrationChecker.instance.checkMigrationStatus() == MigrationStatus.complete;
  }
}
