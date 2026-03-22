import 'package:flutter_test/flutter_test.dart';
import 'package:disciplinum/features/gamification/domain/services/streak_service.dart';
import 'package:disciplinum/features/gamification/domain/entities/module_state.dart';

void main() {
  group('StreakService', () {
    group('calculateStreak', () {
      test('deve retornar 0 quando não há check-in anterior', () {
        final result = StreakService.calculateStreak(
          lastCheckIn: null,
          lastRelapse: null,
          currentStreak: 5,
        );
        
        expect(result, 0);
      });

      test('deve manter streak atual quando check-in foi feito hoje', () {
        final today = DateTime.now();
        final result = StreakService.calculateStreak(
          lastCheckIn: today,
          lastRelapse: null,
          currentStreak: 5,
        );
        
        expect(result, 5);
      });

      test('deve manter streak quando check-in foi ontem', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final result = StreakService.calculateStreak(
          lastCheckIn: yesterday,
          lastRelapse: null,
          currentStreak: 5,
        );
        
        expect(result, 5);
      });

      test('deve resetar streak quando passou mais de 1 dia sem check-in', () {
        final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
        final result = StreakService.calculateStreak(
          lastCheckIn: twoDaysAgo,
          lastRelapse: null,
          currentStreak: 5,
        );
        
        expect(result, 0);
      });
    });

    group('shouldIncrementStreak', () {
      test('deve retornar true quando não há check-in anterior', () {
        final result = StreakService.shouldIncrementStreak(
          lastCheckIn: null,
          lastRelapse: null,
        );
        
        expect(result, true);
      });

      test('deve retornar false quando check-in já foi feito hoje', () {
        final today = DateTime.now();
        final result = StreakService.shouldIncrementStreak(
          lastCheckIn: today,
          lastRelapse: null,
        );
        
        expect(result, false);
      });

      test('deve retornar true quando check-in foi ontem', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final result = StreakService.shouldIncrementStreak(
          lastCheckIn: yesterday,
          lastRelapse: null,
        );
        
        expect(result, true);
      });

      test('deve retornar false quando check-in foi há mais de 1 dia', () {
        final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
        final result = StreakService.shouldIncrementStreak(
          lastCheckIn: twoDaysAgo,
          lastRelapse: null,
        );
        
        expect(result, false);
      });
    });

    group('processRelapse', () {
      test('deve resetar streak quando recaída foi hoje', () {
        final today = DateTime.now();
        final result = StreakService.processRelapse(
          lastRelapse: today,
          currentStreak: 5,
          lastCheckIn: null,
        );
        
        expect(result, 0);
      });

      test('deve manter streak quando não há recaída', () {
        final result = StreakService.processRelapse(
          lastRelapse: null,
          currentStreak: 5,
          lastCheckIn: null,
        );
        
        expect(result, 0);
      });

      test('deve resetar streak quando recaída foi ontem sem check-in hoje', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final result = StreakService.processRelapse(
          lastRelapse: yesterday,
          currentStreak: 5,
          lastCheckIn: null,
        );
        
        expect(result, 0);
      });
    });

    group('getNextMilestone', () {
      test('deve retornar 1 para streak 0', () {
        expect(StreakService.getNextMilestone(0), 1);
      });

      test('deve retornar 3 para streak 1', () {
        expect(StreakService.getNextMilestone(1), 3);
      });

      test('deve retornar 7 para streak 3', () {
        expect(StreakService.getNextMilestone(3), 7);
      });

      test('deve retornar próximo milestone baseado na lista', () {
        expect(StreakService.getNextMilestone(5), 7);
        expect(StreakService.getNextMilestone(10), 14);
        expect(StreakService.getNextMilestone(20), 21);
        expect(StreakService.getNextMilestone(40), 50);
      });

      test('deve retornar próximo múltiplo de 100 para streaks altos', () {
        expect(StreakService.getNextMilestone(150), 200);
        expect(StreakService.getNextMilestone(250), 300);
        expect(StreakService.getNextMilestone(999), 1000);
      });
    });

    group('reachedMilestone', () {
      test('deve retornar true para milestones definidos', () {
        expect(StreakService.reachedMilestone(1), true);
        expect(StreakService.reachedMilestone(3), true);
        expect(StreakService.reachedMilestone(7), true);
        expect(StreakService.reachedMilestone(14), true);
        expect(StreakService.reachedMilestone(21), true);
        expect(StreakService.reachedMilestone(30), true);
        expect(StreakService.reachedMilestone(50), true);
        expect(StreakService.reachedMilestone(66), true);
        expect(StreakService.reachedMilestone(100), true);
        expect(StreakService.reachedMilestone(365), true);
        expect(StreakService.reachedMilestone(500), true);
        expect(StreakService.reachedMilestone(1000), true);
      });

      test('deve retornar true para múltiplos de 100 acima de 100', () {
        expect(StreakService.reachedMilestone(200), true);
        expect(StreakService.reachedMilestone(300), true);
        expect(StreakService.reachedMilestone(400), true);
        expect(StreakService.reachedMilestone(500), true);
      });

      test('deve retornar false para valores que não são milestones', () {
        expect(StreakService.reachedMilestone(2), false);
        expect(StreakService.reachedMilestone(4), false);
        expect(StreakService.reachedMilestone(6), false);
        expect(StreakService.reachedMilestone(8), false);
        expect(StreakService.reachedMilestone(15), false);
        expect(StreakService.reachedMilestone(25), false);
        expect(StreakService.reachedMilestone(150), false);
      });
    });

    group('getGracePeriodDays', () {
      test('deve retornar 1 dia para streaks menores que 7', () {
        expect(StreakService.getGracePeriodDays(0), 1);
        expect(StreakService.getGracePeriodDays(3), 1);
        expect(StreakService.getGracePeriodDays(6), 1);
      });

      test('deve retornar 2 dias para streaks entre 7 e 29', () {
        expect(StreakService.getGracePeriodDays(7), 2);
        expect(StreakService.getGracePeriodDays(15), 2);
        expect(StreakService.getGracePeriodDays(29), 2);
      });

      test('deve retornar 3 dias para streaks entre 30 e 99', () {
        expect(StreakService.getGracePeriodDays(30), 3);
        expect(StreakService.getGracePeriodDays(50), 3);
        expect(StreakService.getGracePeriodDays(99), 3);
      });

      test('deve retornar 5 dias para streaks de 100 ou mais', () {
        expect(StreakService.getGracePeriodDays(100), 5);
        expect(StreakService.getGracePeriodDays(200), 5);
        expect(StreakService.getGracePeriodDays(365), 5);
      });
    });

    group('isInGracePeriod', () {
      test('deve retornar false quando não há check-in anterior', () {
        final result = StreakService.isInGracePeriod(
          lastCheckIn: null,
          streakLength: 5,
        );
        
        expect(result, false);
      });

      test('deve retornar false quando streak é 0', () {
        final today = DateTime.now();
        final result = StreakService.isInGracePeriod(
          lastCheckIn: today,
          streakLength: 0,
        );
        
        expect(result, false);
      });

      test('deve retornar true quando está dentro do grace period', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final result = StreakService.isInGracePeriod(
          lastCheckIn: yesterday,
          streakLength: 10, // 2 dias de grace period
        );
        
        expect(result, true);
      });

      test('deve retornar false quando está fora do grace period', () {
        final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
        final result = StreakService.isInGracePeriod(
          lastCheckIn: threeDaysAgo,
          streakLength: 10, // 2 dias de grace period
        );
        
        expect(result, false);
      });
    });

    group('getStreakFreezeCount', () {
      test('deve retornar 0 para streaks menores que 30', () {
        expect(StreakService.getStreakFreezeCount(0), 0);
        expect(StreakService.getStreakFreezeCount(15), 0);
        expect(StreakService.getStreakFreezeCount(29), 0);
      });

      test('deve retornar 1 para streaks entre 30 e 59', () {
        expect(StreakService.getStreakFreezeCount(30), 1);
        expect(StreakService.getStreakFreezeCount(45), 1);
        expect(StreakService.getStreakFreezeCount(59), 1);
      });

      test('deve retornar 2 para streaks entre 60 e 89', () {
        expect(StreakService.getStreakFreezeCount(60), 2);
        expect(StreakService.getStreakFreezeCount(75), 2);
        expect(StreakService.getStreakFreezeCount(89), 2);
      });

      test('deve calcular corretamente para streaks altos', () {
        expect(StreakService.getStreakFreezeCount(90), 3);
        expect(StreakService.getStreakFreezeCount(120), 4);
        expect(StreakService.getStreakFreezeCount(365), 12);
      });
    });

    group('useStreakFreeze', () {
      test('deve retornar false quando não há freezes disponíveis', () {
        final result = StreakService.useStreakFreeze(
          availableFreezes: 0,
          currentStreak: 10,
        );
        
        expect(result, false);
      });

      test('deve retornar false quando streak é 0', () {
        final result = StreakService.useStreakFreeze(
          availableFreezes: 1,
          currentStreak: 0,
        );
        
        expect(result, false);
      });

      test('deve retornar true quando há freezes disponíveis e streak > 0', () {
        final result = StreakService.useStreakFreeze(
          availableFreezes: 2,
          currentStreak: 10,
        );
        
        expect(result, true);
      });
    });

    group('getStreakMessage', () {
      test('deve retornar mensagem correta para streaks específicos', () {
        expect(StreakService.getStreakMessage(0), 'Comece sua jornada hoje! 💪');
        expect(StreakService.getStreakMessage(1), 'Primeiro dia! Continue assim! 🌟');
        expect(StreakService.getStreakMessage(3), '3 dias! Você está criando um hábito! 🔥');
        expect(StreakService.getStreakMessage(7), '1 semana! Consistência é a chave! 🗝️');
        expect(StreakService.getStreakMessage(14), '2 semanas! Você está incrível! 🚀');
        expect(StreakService.getStreakMessage(21), '21 dias! Hábito consolidado! 🎯');
        expect(StreakService.getStreakMessage(30), '1 mês! Transformação real! 🏆');
        expect(StreakService.getStreakMessage(66), '66 dias! Você é disciplinado! 👑');
        expect(StreakService.getStreakMessage(100), '100 dias! Lendário! 🏅');
        expect(StreakService.getStreakMessage(365), '1 ano! Isso é dedicação! 🌟');
      });

      test('deve retornar mensagem genérica para outros streaks', () {
        expect(StreakService.getStreakMessage(2), '2 dias! Nada pode te parar! 💎');
        expect(StreakService.getStreakMessage(5), '5 dias! Nada pode te parar! 💎');
        expect(StreakService.getStreakMessage(50), '50 dias! Nada pode te parar! 💎');
        expect(StreakService.getStreakMessage(200), '200 dias! Nada pode te parar! 💎');
      });
    });

    group('getXpMultiplier', () {
      test('deve retornar 1.0 para streaks menores que 7', () {
        expect(StreakService.getXpMultiplier(0), 1.0);
        expect(StreakService.getXpMultiplier(3), 1.0);
        expect(StreakService.getXpMultiplier(6), 1.0);
      });

      test('deve retornar multiplicadores corretos para cada faixa', () {
        expect(StreakService.getXpMultiplier(7), 1.1);
        expect(StreakService.getXpMultiplier(10), 1.1);
        expect(StreakService.getXpMultiplier(14), 1.2);
        expect(StreakService.getXpMultiplier(20), 1.3);
        expect(StreakService.getXpMultiplier(30), 1.5);
        expect(StreakService.getXpMultiplier(50), 1.7);
        expect(StreakService.getXpMultiplier(200), 2.0);
        expect(StreakService.getXpMultiplier(400), 2.5);
      });
    });

    group('updateStreakState', () {
      test('deve incrementar streak quando faz check-in hoje', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final currentState = ModuleState(
          nicheId: 1,
          isActive: true,
          consecutiveDays: 5,
          lastCheckIn: yesterday,
          lastRelapse: null,
          totalCheckIns: 5,
          totalRelapses: 0,
          currentXp: 100,
                    earnedInsignias: [],
          maxMedal: 'bronze',
          lastUpdated: yesterday,
        );

        final result = StreakService.updateStreakState(
          currentState: currentState,
          didCheckInToday: true,
          hadRelapseToday: false,
        );

        expect(result.consecutiveDays, 6);
        expect(result.totalCheckIns, 6);
        expect(result.lastCheckIn, isNotNull);
        expect(result.lastRelapse, null);
      });

      test('deve resetar streak quando tem recaída hoje', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final currentState = ModuleState(
          nicheId: 1,
          isActive: true,
          consecutiveDays: 5,
          lastCheckIn: yesterday,
          lastRelapse: null,
          totalCheckIns: 5,
          totalRelapses: 0,
          currentXp: 100,
                    earnedInsignias: [],
          maxMedal: 'bronze',
          lastUpdated: yesterday,
        );

        final result = StreakService.updateStreakState(
          currentState: currentState,
          didCheckInToday: false,
          hadRelapseToday: true,
        );

        expect(result.consecutiveDays, 0);
        expect(result.totalRelapses, 1);
        expect(result.lastRelapse, isNotNull);
      });

      test('deve calcular streak quando não há check-in nem recaída hoje', () {
        final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
        final currentState = ModuleState(
          nicheId: 1,
          isActive: true,
          consecutiveDays: 5,
          lastCheckIn: twoDaysAgo,
          lastRelapse: null,
          totalCheckIns: 5,
          totalRelapses: 0,
          currentXp: 100,
                    earnedInsignias: [],
          maxMedal: 'bronze',
          lastUpdated: twoDaysAgo,
        );

        final result = StreakService.updateStreakState(
          currentState: currentState,
          didCheckInToday: false,
          hadRelapseToday: false,
        );

        expect(result.consecutiveDays, 0); // streak quebra por inatividade
      });
    });
  });
}
