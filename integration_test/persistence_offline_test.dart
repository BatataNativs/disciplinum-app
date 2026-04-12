import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:disciplinum/main.dart' as app;
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/features/modules/reading/gamification/domain/entities/reading_gamification_entity.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/entities/smoking_gamification_entity.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/entities/focus_gamification_entity.dart';

/// Testes de integração para persistência offline (ObjectBox)
///
/// Fase 5 - Teste 1: Verificar persistência local funciona sem internet
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Persistência Offline - ObjectBox', () {
    testWidgets('ObjectBox inicializa corretamente', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verificar que ObjectBox está disponível
      final store = ObjectBoxService.instance.store;
      expect(store, isNotNull);
    });

    test('Salvar e recuperar estado Reading offline', () async {
      // Criar entidade de teste
      final entity = ReadingGamificationEntity();
      entity.consecutiveDays = 5;
      entity.earnedInsigniasList = ['madeira', 'ferro'];
      entity.earnedMedalhasList = ['bronze'];
      entity.touch();

      // Salvar no ObjectBox
      final box = ObjectBoxService.instance.store.box<ReadingGamificationEntity>();
      final id = box.put(entity);
      expect(id, greaterThan(0));

      // Recuperar
      final retrieved = box.get(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.consecutiveDays, equals(5));
      expect(retrieved.earnedInsigniasList, containsAll(['madeira', 'ferro']));
      expect(retrieved.earnedMedalhasList, contains('bronze'));

      // Limpar
      box.remove(id);
    });

    test('Salvar e recuperar estado Smoking offline', () async {
      final entity = SmokingGamificationEntity();
      entity.consecutivePositiveDays = 10;
      entity.earnedInsigniasList = ['madeira', 'ferro', 'aluminio'];
      entity.earnedMedalhasList = ['bronze', 'prata'];
      entity.touch();

      final box = ObjectBoxService.instance.store.box<SmokingGamificationEntity>();
      final id = box.put(entity);
      expect(id, greaterThan(0));

      final retrieved = box.get(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.consecutivePositiveDays, equals(10));

      box.remove(id);
    });

    test('Salvar e recuperar estado Focus offline', () async {
      final entity = FocusGamificationEntity();
      entity.currentStreakDays = 7;
      entity.earnedInsigniasList = ['madeira'];
      entity.touch();

      final box = ObjectBoxService.instance.store.box<FocusGamificationEntity>();
      final id = box.put(entity);
      expect(id, greaterThan(0));

      final retrieved = box.get(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.currentStreakDays, equals(7));

      box.remove(id);
    });

    test('Todas as entidades de gamificação existem no ObjectBox', () async {
      final store = ObjectBoxService.instance.store;

      // Verificar que todas as entidades de gamificação estão registradas
      final readingBox = store.box<ReadingGamificationEntity>();
      final smokingBox = store.box<SmokingGamificationEntity>();
      final focusBox = store.box<FocusGamificationEntity>();

      expect(readingBox, isNotNull);
      expect(smokingBox, isNotNull);
      expect(focusBox, isNotNull);
    });
  });
}
