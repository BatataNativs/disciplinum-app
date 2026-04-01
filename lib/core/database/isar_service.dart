import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/database/entities/user_module_state.dart';
import 'package:disciplinum/core/database/entities/reading_book_entity.dart';
import 'package:disciplinum/core/database/entities/gamification_progress.dart';
import 'package:disciplinum/core/storage/entities/detection_session_entity.dart';
import 'package:disciplinum/core/storage/entities/monitoring_state_entity.dart';
import 'package:disciplinum/features/modules/spending/domain/entities/expense_entity.dart';
import 'package:disciplinum/core/database/entities/app_preference.dart';
import 'package:disciplinum/core/storage/entities/daily_checkin_entity.dart';
import 'package:disciplinum/core/storage/entities/focus_status_entity.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/entities/smoking_gamification_entity.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/entities/focus_gamification_entity.dart';
import 'package:disciplinum/features/modules/diet/gamification/domain/entities/diet_gamification_entity.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/domain/entities/money_saving_gamification_entity.dart';
import 'package:disciplinum/features/modules/reading/gamification/domain/entities/reading_gamification_entity.dart';
import 'package:disciplinum/features/modules/binge_eating/gamification/domain/entities/binge_eating_gamification_entity.dart';
import 'package:disciplinum/features/modules/adult_content/gamification/domain/entities/adult_content_gamification_entity.dart';
import 'package:disciplinum/features/modules/adult_content/domain/entities/adult_content_config_entity.dart';
import 'package:disciplinum/features/modules/binge_eating/domain/entities/binge_eating_config_entity.dart';
import 'package:disciplinum/features/modules/diet/domain/entities/diet_config_entity.dart';
import 'package:disciplinum/features/modules/focus/domain/entities/focus_interval_entity.dart';
import 'package:disciplinum/features/modules/focus/domain/entities/focus_config_entity.dart';
import 'package:disciplinum/features/modules/reading/domain/entities/reading_config_entity.dart';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_challenge_entity.dart';
import 'package:disciplinum/features/modules/procrastination/domain/entities/procrastination_config_entity.dart';
import 'package:disciplinum/features/modules/procrastination/gamification/domain/entities/procrastination_gamification_entity.dart';
import 'package:disciplinum/features/modules/spending/gamification/domain/entities/spending_gamification_entity.dart';
import 'package:disciplinum/infrastructure/iap/domain/entities/iap_entitlement.dart';

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
          ExpenseEntitySchema,
          AppPreferenceSchema,
          DailyCheckinSchema,
          FocusStatusEntitySchema,
          SmokingGamificationEntitySchema,
          FocusGamificationEntitySchema,
          DietGamificationEntitySchema,
          MoneySavingGamificationEntitySchema,
          ReadingGamificationEntitySchema,
          BingeEatingGamificationEntitySchema,
          AdultContentGamificationEntitySchema,
          AdultContentConfigEntitySchema,
          BingeEatingConfigEntitySchema,
          DietConfigEntitySchema,
          FocusIntervalEntitySchema,
          FocusConfigEntitySchema,
          ReadingConfigEntitySchema,
          MoneySavingChallengeEntitySchema,
          MoneySavingGridCellEntitySchema,
          ProcrastinationConfigEntitySchema,
          ProcrastinationGamificationEntitySchema,
          SpendingGamificationEntitySchema,
          IapEntitlementSchema,
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
  
  /// Getter para IapEntitlements
  IsarCollection<IapEntitlement> get iapEntitlements => database.iapEntitlements; // ✅ ADICIONADO

  /// Getter para Expenses
  IsarCollection<ExpenseEntity> get expenses => database.expenseEntitys;

  /// Getter para DailyCheckins
  IsarCollection<DailyCheckin> get dailyCheckins => database.dailyCheckins;

  /// Getter para FocusStatus
  IsarCollection<FocusStatusEntity> get focusStatus => database.focusStatusEntitys;

  /// Getter para SmokingGamificationEntity
  IsarCollection<SmokingGamificationEntity> get smokingGamificationStates => database.smokingGamificationEntitys;

  /// Getter para FocusGamificationEntity
  IsarCollection<FocusGamificationEntity> get focusGamificationStates => database.focusGamificationEntitys;

  /// Getter para DietGamificationEntity
  IsarCollection<DietGamificationEntity> get dietGamificationStates => database.dietGamificationEntitys;

  /// Getter para MoneySavingGamificationEntity
  IsarCollection<MoneySavingGamificationEntity> get moneySavingGamificationStates => database.moneySavingGamificationEntitys;

  /// Getter para ReadingGamificationEntity
  IsarCollection<ReadingGamificationEntity> get readingGamificationStates => database.readingGamificationEntitys;

  /// Getter para BingeEatingGamificationEntity
  IsarCollection<BingeEatingGamificationEntity> get bingeEatingGamificationStates => database.bingeEatingGamificationEntitys;

  /// Getter para AdultContentGamificationEntity
  IsarCollection<AdultContentGamificationEntity> get adultContentGamificationStates => database.adultContentGamificationEntitys;

  /// Getter para AdultContentConfigEntity
  IsarCollection<AdultContentConfigEntity> get adultContentConfigs => database.adultContentConfigEntitys;

  /// Getter para BingeEatingConfigEntity
  IsarCollection<BingeEatingConfigEntity> get bingeEatingConfigs => database.bingeEatingConfigEntitys;

  /// Getter para DietConfigEntity
  IsarCollection<DietConfigEntity> get dietConfigs => database.dietConfigEntitys;

  /// Getter para FocusIntervalEntity
  IsarCollection<FocusIntervalEntity> get focusIntervals => database.focusIntervalEntitys;

  /// Getter para FocusConfigEntity
  IsarCollection<FocusConfigEntity> get focusConfigs => database.focusConfigEntitys;

  /// Getter para ReadingConfigEntity
  IsarCollection<ReadingConfigEntity> get readingConfigs => database.readingConfigEntitys;

  /// Getter para MoneySavingChallengeEntity
  IsarCollection<MoneySavingChallengeEntity> get moneySavingChallenges => database.moneySavingChallengeEntitys;

  /// Getter para MoneySavingGridCellEntity
  IsarCollection<MoneySavingGridCellEntity> get moneySavingGridCells => database.moneySavingGridCellEntitys;

  /// Getter para ProcrastinationConfigEntity
  IsarCollection<ProcrastinationConfigEntity> get procrastinationConfigs => database.procrastinationConfigEntitys;

  /// Getter para ProcrastinationGamificationEntity
  IsarCollection<ProcrastinationGamificationEntity> get procrastinationGamificationStates => database.procrastinationGamificationEntitys;

  /// Getter para ExpenseEntity
  IsarCollection<ExpenseEntity> get expensesCollection => database.expenseEntitys;

  /// Getter para SpendingGamificationEntity
  IsarCollection<SpendingGamificationEntity> get spendingGamificationStates => database.spendingGamificationEntitys;

  /// Fecha o banco de dados banco (apenas para desenvolvimento)
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
