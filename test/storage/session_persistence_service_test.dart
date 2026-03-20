import 'package:flutter_test/flutter_test.dart';
import 'package:disciplinum/core/database/isar_service.dart';
import 'package:disciplinum/core/storage/session_persistence_service.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';

void main() {
  group('SessionPersistenceService Tests', () {
    late SessionPersistenceService persistenceService;
    late IsarService isarService;

    setUpAll(() async {
      // Inicializar Isar para testes
      isarService = IsarService.instance;
      await isarService.initialize();
      
      // Inicializar SessionPersistenceService
      persistenceService = SessionPersistenceService(isarService);
    });

    tearDownAll(() async {
      // Limpar banco após testes
      await isarService.clearAll();
      await isarService.close();
    });

    setUp(() async {
      // Limpar dados antes de cada teste
      await isarService.clearAll();
    });

    test('Deve salvar e recuperar estado de monitoramento', () async {
      // Salvar estado
      await persistenceService.saveMonitoringState(
        activeNicheId: NicheId.reading,
        isMonitoringActive: true,
        monitoredApps: ['com.instagram.android', 'com.facebook.katana'],
      );

      // Recuperar estado
      final state = await persistenceService.getMonitoringState();

      expect(state, isNotNull);
      final stateNotNull = state!;
      expect(stateNotNull.activeNicheId, equals(NicheId.reading));
      expect(stateNotNull.isMonitoringActive, isTrue);
      expect(stateNotNull.monitoredApps, hasLength(2));
      expect(stateNotNull.monitoredApps, contains('com.instagram.android'));
      expect(stateNotNull.monitoredApps, contains('com.facebook.katana'));
    });

    test('Deve salvar e recuperar sessões de detecção', () async {
      // Salvar sessão
      await persistenceService.saveDetectionSession(
        packageName: 'com.instagram.android',
        nicheId: NicheId.reading,
        duration: 30,
        remainingSeconds: 15,
      );

      // Recuperar sessões ativas
      final sessions = await persistenceService.getActiveSessions();

      expect(sessions, hasLength(1));
      expect(sessions.first.packageName, equals('com.instagram.android'));
      expect(sessions.first.nicheId, equals(NicheId.reading));
      expect(sessions.first.isActive, isTrue);
      expect(sessions.first.duration, equals(30));
      expect(sessions.first.remainingSeconds, equals(15));
    });

    test('Deve marcar sessão como inativa', () async {
      // Salvar sessão
      await persistenceService.saveDetectionSession(
        packageName: 'com.instagram.android',
        nicheId: NicheId.reading,
        duration: 30,
      );

      // Marcar como inativa
      await persistenceService.markSessionInactive('com.instagram.android');

      // Verificar que não há sessões ativas
      final activeSessions = await persistenceService.getActiveSessions();
      expect(activeSessions, isEmpty);
    });

    test('Deve registrar violação', () async {
      // Salvar estado de monitoramento
      await persistenceService.saveMonitoringState(
        activeNicheId: NicheId.reading,
        isMonitoringActive: true,
        monitoredApps: ['com.instagram.android'],
      );

      // Registrar violação
      await persistenceService.registerViolation();

      // Verificar violação
      final state = await persistenceService.getMonitoringState();
      expect(state, isNotNull);
      expect(state!.violationCount, equals(1));
      expect(state.lastViolationTime, isNotNull);
    });

    test('Deve atualizar heartbeat', () async {
      // Salvar estado
      await persistenceService.saveMonitoringState(
        activeNicheId: NicheId.reading,
        isMonitoringActive: true,
        monitoredApps: ['com.instagram.android'],
      );

      final originalState = await persistenceService.getMonitoringState();
      expect(originalState, isNotNull);
      final originalStateNotNull = originalState!;
      final originalHeartbeat = originalStateNotNull.lastHeartbeat;

      // Esperar um pouco e atualizar heartbeat
      await Future.delayed(const Duration(milliseconds: 100));
      await persistenceService.updateHeartbeat();

      // Verificar que heartbeat foi atualizado
      final updatedState = await persistenceService.getMonitoringState();
      expect(updatedState, isNotNull);
      final updatedStateNotNull = updatedState!;
      expect(updatedStateNotNull.lastHeartbeat, isNotNull);
      expect(updatedStateNotNull.lastHeartbeat.isAfter(originalHeartbeat), isTrue);
    });

    test('Deve limpar estado de monitoramento', () async {
      // Salvar estado
      await persistenceService.saveMonitoringState(
        activeNicheId: NicheId.reading,
        isMonitoringActive: true,
        monitoredApps: ['com.instagram.android'],
      );

      // Limpar estado
      await persistenceService.clearMonitoringState();

      // Verificar que não há estado
      final state = await persistenceService.getMonitoringState();
      expect(state, isNull);
    });

    test('Deve obter estatísticas das sessões', () async {
      // Salvar algumas sessões
      await persistenceService.saveDetectionSession(
        packageName: 'com.instagram.android',
        nicheId: NicheId.reading,
        duration: 30,
      );

      await persistenceService.saveDetectionSession(
        packageName: 'com.facebook.katana',
        nicheId: NicheId.focus,
        duration: 25,
      );

      await persistenceService.saveMonitoringState(
        activeNicheId: NicheId.reading,
        isMonitoringActive: true,
        monitoredApps: ['com.instagram.android'],
      );

      // Obter estatísticas
      final stats = await persistenceService.getSessionStats();

      expect(stats['totalSessions'], equals(2));
      expect(stats['activeSessions'], equals(2));
      expect(stats['isMonitoringActive'], isTrue);
      expect(stats['activeNicheId'], equals('reading'));
      expect(stats['violationCount'], equals(0));
    });
  });
}
