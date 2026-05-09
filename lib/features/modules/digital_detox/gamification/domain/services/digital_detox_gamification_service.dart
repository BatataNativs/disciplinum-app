import '../entities/digital_detox_gamification_entity.dart';
import '../repositories/digital_detox_gamification_repository.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

class DigitalDetoxGamificationService {
  final DigitalDetoxGamificationRepository _gamificationRepo;

  DigitalDetoxGamificationService(this._gamificationRepo);

  // Inicializar gamificação do usuário (concede insígnia de madeira)
  DigitalDetoxGamificationEntity initializeGamification(String userId) {
    LoggerService.instance.i('🎮 Gamification: Inicializando gamificação para usuário $userId');
    
    var gamification = _gamificationRepo.getByUserId(userId);
    if (gamification == null) {
      gamification = DigitalDetoxGamificationEntity(userId: userId);
      _gamificationRepo.save(gamification);
      LoggerService.instance.i('🎮 Gamification: Insígnia de madeira concedida');
    }
    
    return gamification;
  }

  // Processar dia válido (respeitou limites)
  Future<DigitalDetoxGamificationEntity> processValidDay(String userId) async {
    LoggerService.instance.i('🎮 Gamification: Processando dia válido para usuário $userId');
    
    var gamification = _gamificationRepo.getOrCreateByUserId(userId);
    gamification = gamification.addDisciplinedDay();
    await _gamificationRepo.save(gamification);
    
    LoggerService.instance.i('🎮 Gamification: Dia válido processado, streak atual: ${gamification.currentStreak}');
    return gamification;
  }

  // Resetar streak (falhou)
  Future<DigitalDetoxGamificationEntity> resetStreak(String userId) async {
    LoggerService.instance.i('🎮 Gamification: Resetando streak para usuário $userId');
    
    var gamification = _gamificationRepo.getOrCreateByUserId(userId);
    gamification = gamification.resetStreak();
    await _gamificationRepo.save(gamification);
    
    LoggerService.instance.i('🎮 Gamification: Streak resetado');
    return gamification;
  }

  // Usar quebra de jejum
  Future<DigitalDetoxGamificationEntity> useFastingBreak(String userId) async {
    LoggerService.instance.i('🎮 Gamification: Usando quebra de jejum para usuário $userId');
    
    var gamification = _gamificationRepo.getOrCreateByUserId(userId);
    
    if (!gamification.shouldAwardFastingBreak()) {
      LoggerService.instance.w('🎮 Gamification: Usuário não tem dias suficientes para quebra de jejum');
      return gamification;
    }
    
    gamification = gamification.resetSevenDayCycle();
    await _gamificationRepo.save(gamification);
    
    LoggerService.instance.i('🎮 Gamification: Quebra de jejum utilizada');
    return gamification;
  }

  // Obter gamificação do usuário
  DigitalDetoxGamificationEntity? getGamification(String userId) {
    return _gamificationRepo.getByUserId(userId);
  }

  // Verificar se usuário tem streak ativo
  bool hasActiveStreak(String userId) {
    final gamification = getGamification(userId);
    return (gamification?.currentStreak ?? 0) > 0;
  }

  // Obter streak atual
  int getCurrentStreak(String userId) {
    final gamification = getGamification(userId);
    return gamification?.currentStreak ?? 0;
  }

  // Obter maior streak
  int getLongestStreak(String userId) {
    final gamification = getGamification(userId);
    return gamification?.longestStreak ?? 0;
  }

  // Obter total de dias disciplinados
  int getTotalDisciplinedDays(String userId) {
    final gamification = getGamification(userId);
    return gamification?.totalDisciplinedDays ?? 0;
  }

  // Obter insígnias conquistadas
  List<String> getEarnedInsignias(String userId) {
    final gamification = getGamification(userId);
    return gamification?.earnedInsigniasList ?? [];
  }

  // Obter medalhas conquistadas
  List<String> getEarnedMedalhas(String userId) {
    final gamification = getGamification(userId);
    return gamification?.earnedMedalhasList ?? [];
  }

  // Verificar se módulo está ativo
  bool isModuleActive(String userId) {
    final gamification = getGamification(userId);
    return gamification?.isModuleActive ?? false;
  }

  // Ativar módulo
  Future<DigitalDetoxGamificationEntity> activateModule(String userId) async {
    LoggerService.instance.i('🎮 Gamification: Ativando módulo para usuário $userId');
    
    var gamification = _gamificationRepo.getOrCreateByUserId(userId);
    gamification = gamification.copyWith(isModuleActive: true, updatedAt: DateTime.now());
    await _gamificationRepo.save(gamification);
    
    return gamification;
  }

  // Desativar módulo
  Future<DigitalDetoxGamificationEntity> deactivateModule(String userId) async {
    LoggerService.instance.i('🎮 Gamification: Desativando módulo para usuário $userId');
    
    var gamification = _gamificationRepo.getOrCreateByUserId(userId);
    gamification = gamification.copyWith(isModuleActive: false, updatedAt: DateTime.now());
    await _gamificationRepo.save(gamification);
    
    return gamification;
  }

  // Obter dias até próxima insígnia
  int getDaysUntilNextInsignia(String userId) {
    final gamification = getGamification(userId);
    if (gamification == null) return -1;
    
    final currentStreak = gamification.currentStreak;
    
    // Lógica simplificada para calcular dias até próxima insígnia
    if (currentStreak < 7) return 7 - currentStreak;
    if (currentStreak < 30) return 30 - currentStreak;
    if (currentStreak < 100) return 100 - currentStreak;
    return -1; // Já conquistou todas as insígnias básicas
  }
}
