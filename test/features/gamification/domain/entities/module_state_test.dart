import 'package:flutter_test/flutter_test.dart';
import 'package:disciplinum/features/gamification/domain/entities/module_state.dart';
import 'package:disciplinum/features/gamification/domain/entities/user_module_status.dart';

void main() {
  group('ModuleState', () {
    test('deve criar ModuleState com valores padrão', () {
      final now = DateTime.now();
      final moduleState = ModuleState(
        nicheId: 1,
        isActive: true,
        consecutiveDays: 5,
        lastCheckIn: now,
        lastRelapse: null,
        totalCheckIns: 10,
        totalRelapses: 2,
        currentXp: 150,
        earnedInsignias: ['beginner', 'week_warrior'],
        maxMedal: 'silver',
        lastUpdated: now,
      );

      expect(moduleState.nicheId, 1);
      expect(moduleState.isActive, true);
      expect(moduleState.consecutiveDays, 5);
      expect(moduleState.lastCheckIn, now);
      expect(moduleState.lastRelapse, null);
      expect(moduleState.totalCheckIns, 10);
      expect(moduleState.totalRelapses, 2);
      expect(moduleState.currentXp, 150);
      expect(moduleState.earnedInsignias, ['beginner', 'week_warrior']);
      expect(moduleState.maxMedal, 'silver');
      expect(moduleState.lastUpdated, now);
    });

    test('copyWith deve criar cópia com valores atualizados', () {
      final now = DateTime.now();
      final originalState = ModuleState(
        nicheId: 1,
        isActive: true,
        consecutiveDays: 5,
        lastCheckIn: now,
        lastRelapse: null,
        totalCheckIns: 10,
        totalRelapses: 2,
        currentXp: 150,
        earnedInsignias: ['beginner'],
        maxMedal: 'bronze',
        lastUpdated: now,
      );

      final updatedState = originalState.copyWith(
        consecutiveDays: 6,
        currentXp: 160,
        earnedInsignias: ['beginner', 'week_warrior'],
      );

      expect(updatedState.nicheId, 1); // não alterado
      expect(updatedState.isActive, true); // não alterado
      expect(updatedState.consecutiveDays, 6); // alterado
      expect(updatedState.currentXp, 160); // alterado
      expect(updatedState.earnedInsignias, ['beginner', 'week_warrior']); // alterado
      expect(updatedState.maxMedal, 'bronze'); // não alterado
    });

    test('copyWith deve manter lista original quando não especificada', () {
      final now = DateTime.now();
      final originalState = ModuleState(
        nicheId: 1,
        isActive: true,
        consecutiveDays: 5,
        lastCheckIn: now,
        lastRelapse: null,
        totalCheckIns: 10,
        totalRelapses: 2,
        currentXp: 150,
        earnedInsignias: ['beginner'],
        maxMedal: 'bronze',
        lastUpdated: now,
      );

      final updatedState = originalState.copyWith(consecutiveDays: 6);

      expect(updatedState.earnedInsignias, ['beginner']);
      expect(identical(updatedState.earnedInsignias, originalState.earnedInsignias), true);
    });

    test('deve calcular successRate corretamente', () {
      final now = DateTime.now();
      final moduleState = ModuleState(
        nicheId: 1,
        isActive: true,
        consecutiveDays: 5,
        lastCheckIn: now,
        lastRelapse: null,
        totalCheckIns: 10,
        totalRelapses: 2,
        currentXp: 150,
        earnedInsignias: [],
        maxMedal: 'bronze',
        lastUpdated: now,
      );

      expect(moduleState.successRate, 0.8); // (10-2)/10 = 0.8
    });

    test('deve verificar needsCheckInToday corretamente', () {
      final today = DateTime.now();
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      
      // Estado com check-in hoje não precisa de check-in
      final stateWithCheckInToday = ModuleState(
        nicheId: 1,
        isActive: true,
        consecutiveDays: 5,
        lastCheckIn: today,
        lastRelapse: null,
        totalCheckIns: 10,
        totalRelapses: 2,
        currentXp: 150,
        earnedInsignias: [],
        maxMedal: 'bronze',
        lastUpdated: today,
      );

      // Estado sem check-in hoje precisa de check-in
      final stateWithoutCheckInToday = ModuleState(
        nicheId: 1,
        isActive: true,
        consecutiveDays: 5,
        lastCheckIn: yesterday,
        lastRelapse: null,
        totalCheckIns: 10,
        totalRelapses: 2,
        currentXp: 150,
        earnedInsignias: [],
        maxMedal: 'bronze',
        lastUpdated: yesterday,
      );

      expect(stateWithCheckInToday.needsCheckInToday, false);
      expect(stateWithoutCheckInToday.needsCheckInToday, true);
    });

    test('deve converter de UserModuleStatus corretamente', () {
      final now = DateTime.now();
      final userModuleStatus = UserModuleStatus(
        userId: 'test_user',
        nicheId: 1,
        isActive: true,
        consecutiveDays: 5,
        focusPeriodsRespected: 3,
        lastUpdated: now,
        earnedInsignias: ['beginner', 'week_warrior'],
        maxMedal: 'silver',
      );

      final moduleState = ModuleState.fromUserModuleStatus(userModuleStatus);

      expect(moduleState.nicheId, 1);
      expect(moduleState.isActive, true);
      expect(moduleState.consecutiveDays, 5);
      expect(moduleState.focusPeriodsRespected, 3);
      expect(moduleState.lastUpdated, now);
      expect(moduleState.earnedInsignias, ['beginner', 'week_warrior']);
      expect(moduleState.maxMedal, 'silver');
      // Valores padrão para campos novos
      expect(moduleState.currentXp, 0);
      expect(moduleState.lastCheckIn, null);
      expect(moduleState.lastRelapse, null);
      expect(moduleState.totalCheckIns, 0);
      expect(moduleState.totalRelapses, 0);
    });

    test('deve converter para UserModuleStatus corretamente', () {
      final now = DateTime.now();
      final moduleState = ModuleState(
        nicheId: 1,
        isActive: true,
        consecutiveDays: 5,
        focusPeriodsRespected: 3,
        lastCheckIn: now,
        lastRelapse: null,
        totalCheckIns: 10,
        totalRelapses: 2,
        currentXp: 150,
        earnedInsignias: ['beginner', 'week_warrior'],
        maxMedal: 'silver',
        lastUpdated: now,
      );

      final userModuleStatus = moduleState.toUserModuleStatus(userId: 'test_user');

      expect(userModuleStatus.userId, 'test_user');
      expect(userModuleStatus.nicheId, 1);
      expect(userModuleStatus.isActive, true);
      expect(userModuleStatus.consecutiveDays, 5);
      expect(userModuleStatus.focusPeriodsRespected, 3);
      expect(userModuleStatus.lastUpdated, now);
      expect(userModuleStatus.earnedInsignias, ['beginner', 'week_warrior']);
      expect(userModuleStatus.maxMedal, 'silver');
    });

    test('equals deve funcionar corretamente', () {
      final now = DateTime.now();
      final state1 = ModuleState(
        nicheId: 1,
        isActive: true,
        consecutiveDays: 5,
        lastCheckIn: now,
        lastRelapse: null,
        totalCheckIns: 10,
        totalRelapses: 2,
        currentXp: 150,
        earnedInsignias: ['beginner'],
        maxMedal: 'bronze',
        lastUpdated: now,
      );

      final state2 = ModuleState(
        nicheId: 1,
        isActive: true,
        consecutiveDays: 5,
        lastCheckIn: now,
        lastRelapse: null,
        totalCheckIns: 10,
        totalRelapses: 2,
        currentXp: 150,
        earnedInsignias: ['beginner'],
        maxMedal: 'bronze',
        lastUpdated: now,
      );

      final state3 = ModuleState(
        nicheId: 2, // diferente
        isActive: true,
        consecutiveDays: 5,
        lastCheckIn: now,
        lastRelapse: null,
        totalCheckIns: 10,
        totalRelapses: 2,
        currentXp: 150,
        earnedInsignias: ['beginner'],
        maxMedal: 'bronze',
        lastUpdated: now,
      );

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });

    test('hashCode deve ser consistente', () {
      final now = DateTime.now();
      final state1 = ModuleState(
        nicheId: 1,
        isActive: true,
        consecutiveDays: 5,
        lastCheckIn: now,
        lastRelapse: null,
        totalCheckIns: 10,
        totalRelapses: 2,
        currentXp: 150,
        earnedInsignias: ['beginner'],
        maxMedal: 'bronze',
        lastUpdated: now,
      );

      final state2 = ModuleState(
        nicheId: 1,
        isActive: true,
        consecutiveDays: 5,
        lastCheckIn: now,
        lastRelapse: null,
        totalCheckIns: 10,
        totalRelapses: 2,
        currentXp: 150,
        earnedInsignias: ['beginner'],
        maxMedal: 'bronze',
        lastUpdated: now,
      );

      expect(state1.hashCode, equals(state2.hashCode));
    });

    test('toString deve retornar representação legível', () {
      final now = DateTime.now();
      final moduleState = ModuleState(
        nicheId: 1,
        isActive: true,
        consecutiveDays: 5,
        lastCheckIn: now,
        lastRelapse: null,
        totalCheckIns: 10,
        totalRelapses: 2,
        currentXp: 150,
        earnedInsignias: ['beginner'],
        maxMedal: 'bronze',
        lastUpdated: now,
      );

      final stringRepresentation = moduleState.toString();
      expect(stringRepresentation, contains('ModuleState'));
      expect(stringRepresentation, contains('nicheId: 1'));
      expect(stringRepresentation, contains('consecutiveDays: 5'));
      expect(stringRepresentation, contains('currentXp: 150'));
    });

    test('deve calcular hasActiveStreak corretamente', () {
      final stateWithStreak = ModuleState(
        nicheId: 1,
        isActive: true,
        consecutiveDays: 5,
      );

      final stateWithoutStreak = ModuleState(
        nicheId: 1,
        isActive: true,
        consecutiveDays: 0,
      );

      final stateInactive = ModuleState(
        nicheId: 1,
        isActive: false,
        consecutiveDays: 5,
      );

      expect(stateWithStreak.hasActiveStreak, true);
      expect(stateWithoutStreak.hasActiveStreak, false);
      expect(stateInactive.hasActiveStreak, false);
    });

    test('deve calcular daysSinceLastRelapse corretamente', () {
      final now = DateTime.now();
      final twoDaysAgo = now.subtract(const Duration(days: 2));
      
      final stateWithoutRelapse = ModuleState(
        nicheId: 1,
        isActive: true,
        consecutiveDays: 5,
        lastRelapse: null,
      );

      final stateWithRelapse = ModuleState(
        nicheId: 1,
        isActive: true,
        consecutiveDays: 5,
        lastRelapse: twoDaysAgo,
      );

      expect(stateWithoutRelapse.daysSinceLastRelapse, 5); // retorna consecutiveDays
      expect(stateWithRelapse.daysSinceLastRelapse, 2); // dias desde a recaída
    });

    test('deve calcular canEarnXp corretamente', () {
      final activeWithStreak = ModuleState(
        nicheId: 1,
        isActive: true,
        consecutiveDays: 5,
      );

      final inactiveWithStreak = ModuleState(
        nicheId: 1,
        isActive: false,
        consecutiveDays: 5,
      );

      final activeWithoutStreak = ModuleState(
        nicheId: 1,
        isActive: true,
        consecutiveDays: 0,
      );

      expect(activeWithStreak.canEarnXp, true);
      expect(inactiveWithStreak.canEarnXp, false);
      expect(activeWithoutStreak.canEarnXp, false);
    });

    test('deve calcular potentialXp corretamente', () {
      final stateWithoutStreak = ModuleState(
        nicheId: 1,
        isActive: true,
        consecutiveDays: 0,
      );

      final stateWithSmallStreak = ModuleState(
        nicheId: 1,
        isActive: true,
        consecutiveDays: 5,
        earnedInsignias: ['beginner'],
      );

      final stateWithLargeStreak = ModuleState(
        nicheId: 1,
        isActive: true,
        consecutiveDays: 10,
        earnedInsignias: ['beginner', 'week_warrior'],
      );

      expect(stateWithoutStreak.potentialXp, 0); // não pode ganhar XP
      
      // 5 dias * 10 = 50 (sem bônus de streak)
      // 1 insignia * 25 = 25
      // Total = 75
      expect(stateWithSmallStreak.potentialXp, 75);
      
      // 10 dias * 10 = 100
      // +50 bônus de streak (> 7 dias)
      // 2 insignias * 25 = 50
      // Total = 200
      expect(stateWithLargeStreak.potentialXp, 200);
    });
  });
}
