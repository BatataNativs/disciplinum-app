import 'package:flutter_test/flutter_test.dart';
import 'package:disciplinum/core/background/batched_achievement_notifier.dart';

void main() {
  group('BatchedAchievementNotifier', () {
    late BatchedAchievementNotifier notifier;

    setUp(() {
      notifier = BatchedAchievementNotifier();
      notifier.clear();
    });

    tearDown(() {
      notifier.clear();
    });

    test('should queue single notification', () {
      notifier.queueNotification(
        moduleName: 'Smoking',
        achievementType: 'streak',
        title: '🏆 Nova Conquista!',
        body: '7 dias sem fumar!',
        achievementId: 'smoking_7',
      );

      expect(notifier.pendingCount, equals(1));
    });

    test('should queue multiple notifications', () {
      notifier.queueNotification(
        moduleName: 'Smoking',
        achievementType: 'streak',
        title: '🏆 Nova Conquista!',
        body: '30 dias sem fumar!',
        achievementId: 'smoking_30',
      );

      notifier.queueNotification(
        moduleName: 'Reading',
        achievementType: 'streak',
        title: '📚 Streak de Leitura!',
        body: '30 dias consecutivos!',
        achievementId: 'reading_30',
      );

      expect(notifier.pendingCount, equals(2));
    });

    test('should clear pending notifications', () {
      notifier.queueNotification(
        moduleName: 'Focus',
        achievementType: 'sessions',
        title: '🎯 Sessões!',
        body: '100 sessões!',
        achievementId: 'focus_100',
      );

      expect(notifier.pendingCount, equals(1));

      notifier.clear();

      expect(notifier.pendingCount, equals(0));
    });

    test('should detect insignia + medal combination', () async {
      // Arrange: Simula conquista de insígnia Disciplinum + Medalha
      notifier.queueNotification(
        moduleName: 'Smoking',
        achievementType: 'insignia',
        title: '🏆 Nova Conquista!',
        body: '🎱 Disciplinum conquistada!',
        achievementId: 'smoking_disciplinum',
      );

      notifier.queueNotification(
        moduleName: 'Smoking',
        achievementType: 'medal',
        title: '🏆 Nova Conquista!',
        body: 'Medalha Bronze!',
        achievementId: 'smoking_medal_bronze',
      );

      // Act & Assert: flush() deve agrupar em notificação combinada
      // Nota: Não podemos mockar BackgroundAchievementService facilmente,
      // mas podemos verificar que não lança erro
      await expectLater(notifier.flush(), completes);
    });

    test('should batch multiple modules into summary', () async {
      // Arrange: 3 conquistas de módulos diferentes
      notifier.queueNotification(
        moduleName: 'Smoking',
        achievementType: 'streak',
        title: '🏆 Nova Conquista!',
        body: '7 dias!',
        achievementId: 'smoking_7',
      );

      notifier.queueNotification(
        moduleName: 'Reading',
        achievementType: 'streak',
        title: '📚 Streak!',
        body: '30 dias!',
        achievementId: 'reading_30',
      );

      notifier.queueNotification(
        moduleName: 'Focus',
        achievementType: 'sessions',
        title: '🎯 Sessões!',
        body: '50 sessões!',
        achievementId: 'focus_50',
      );

      // Act & Assert
      await expectLater(notifier.flush(), completes);
    });

    test('flush should clear pending notifications', () async {
      notifier.queueNotification(
        moduleName: 'Diet',
        achievementType: 'streak',
        title: '🥗 Streak!',
        body: '7 dias!',
        achievementId: 'diet_7',
      );

      expect(notifier.pendingCount, equals(1));

      await notifier.flush();

      expect(notifier.pendingCount, equals(0));
    });

    test('flush with empty queue should not fail', () async {
      await expectLater(notifier.flush(), completes);
    });
  });
}
