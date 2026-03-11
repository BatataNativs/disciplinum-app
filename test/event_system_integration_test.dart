import 'package:flutter_test/flutter_test.dart';
import 'package:disciplinum/core/events/event_bus.dart';
import 'package:disciplinum/core/events/events/gamification_events.dart';
import 'package:disciplinum/core/events/events/behavior_events.dart';
import 'package:disciplinum/core/events/events/gamification_event_emitter.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/features/gamification/domain/entities/medal.dart';
import 'package:disciplinum/features/gamification/domain/entities/insignia.dart';

void main() {
  group('Event System Integration Tests', () {
    late EventBus eventBus;
    late List<AppEvent> capturedEvents;

    setUp(() {
      // Limpar estado anterior
      eventBus = EventBus.instance;
      eventBus.clearListeners();
      capturedEvents = [];

      // Configurar listener para capturar eventos
      eventBus.stream.listen((event) {
        capturedEvents.add(event);
      });
    });

    tearDown(() {
      eventBus.clearListeners();
    });

    test('EventBus deve emitir e receber eventos corretamente', () async {
      // Limpar eventos capturados
      capturedEvents.clear();

      // Emitir evento de medalha
      final medal = GamificationMedal.bronze;
      GamificationEventEmitter.emitMedalAwarded(
        nicheId: NicheId.smoking,
        medal: medal,
        consecutiveDays: 1,
      );

      // Aguardar processamento do evento
      await Future.delayed(Duration(milliseconds: 10));

      // Verificar se o evento foi capturado
      expect(capturedEvents.length, greaterThan(0));
      expect(capturedEvents.first, isA<MedalAwardedEvent>());
      
      final medalEvent = capturedEvents.first as MedalAwardedEvent;
      expect(medalEvent.data['nicheId'], NicheId.smoking);
      expect(medalEvent.data['consecutiveDays'], 1);
    });

    test('EventBus deve emitir múltiplos eventos em sequência', () async {
      // Limpar eventos capturados
      capturedEvents.clear();

      // Emitir múltiplos eventos
      GamificationEventEmitter.emitModuleActivated(nicheId: NicheId.smoking);
      GamificationEventEmitter.emitCheckIn(
        nicheId: NicheId.smoking,
        type: CheckInType.daily,
      );

      // Aguardar processamento
      await Future.delayed(Duration(milliseconds: 10));

      // Verificar se todos os eventos foram capturados
      expect(capturedEvents.length, equals(2));
      expect(capturedEvents[0], isA<ModuleActivatedEvent>());
      expect(capturedEvents[1], isA<CheckInEvent>());
    });

    test('EventBus deve lidar com eventos de recaída', () async {
      // Limpar eventos capturados
      capturedEvents.clear();

      // Emitir evento de recaída
      GamificationEventEmitter.emitRelapse(
        nicheId: NicheId.smoking,
        type: RelapseType.minor,
        reason: 'Estresse',
        streakLost: 5,
      );

      // Aguardar processamento
      await Future.delayed(Duration(milliseconds: 10));

      // Verificar se o evento foi capturado corretamente
      expect(capturedEvents.length, equals(1));
      expect(capturedEvents.first, isA<RelapseEvent>());
      
      final relapseEvent = capturedEvents.first as RelapseEvent;
      expect(relapseEvent.data['nicheId'], NicheId.smoking);
      expect(relapseEvent.data['streakLost'], 5);
    });

    test('EventBus deve emitir eventos de insígnia de foco', () async {
      // Limpar eventos capturados
      capturedEvents.clear();

      // Criar insígnia de foco
      final insignia = FocusInsignia.ferro;

      // Emitir evento de insígnia
      GamificationEventEmitter.emitFocusInsigniaAwarded(
        nicheId: NicheId.smoking,
        insignia: insignia,
        totalFocusTime: 180, // 3 horas em minutos
      );

      // Aguardar processamento
      await Future.delayed(Duration(milliseconds: 10));

      // Verificar se o evento foi capturado corretamente
      expect(capturedEvents.length, equals(1));
      expect(capturedEvents.first, isA<FocusInsigniaAwardedEvent>());
      
      final insigniaEvent = capturedEvents.first as FocusInsigniaAwardedEvent;
      expect(insigniaEvent.data['nicheId'], NicheId.smoking);
      expect(insigniaEvent.data['totalFocusTime'], 180);
    });

    test('EventBus deve manter ordem cronológica dos eventos', () async {
      // Limpar eventos capturados
      capturedEvents.clear();

      // Emitir eventos em sequência rápida
      GamificationEventEmitter.emitModuleActivated(nicheId: NicheId.smoking);
      GamificationEventEmitter.emitCheckIn(
        nicheId: NicheId.smoking,
        type: CheckInType.daily,
      );
      GamificationEventEmitter.emitModuleDeactivated(
        nicheId: NicheId.smoking,
        reason: 'Teste',
      );

      // Aguardar processamento
      await Future.delayed(Duration(milliseconds: 20));

      // Verificar ordem dos eventos
      expect(capturedEvents.length, equals(3));
      expect(capturedEvents[0], isA<ModuleActivatedEvent>());
      expect(capturedEvents[1], isA<CheckInEvent>());
      expect(capturedEvents[2], isA<ModuleDeactivatedEvent>());
    });

    test('GamificationEventEmitter deve configurar sessão corretamente', () {
      // Configurar sessão para testes
      GamificationEventEmitter.setCurrentSession('test-session-123');
      
      // Emitir evento com sessão configurada
      capturedEvents.clear();
      GamificationEventEmitter.emitModuleActivated(nicheId: NicheId.smoking);

      // Verificar se a sessão foi configurada
      expect(capturedEvents.length, equals(1));
      expect(capturedEvents.first.sessionId, equals('test-session-123'));
    });

    test('EventBus deve limpar listeners corretamente', () {
      // Verificar que não há listeners antes
      expect(eventBus.listenerCount, equals(0));

      // Adicionar listener
      eventBus.listen<ModuleActivatedEvent>((event) {
        capturedEvents.add(event);
      });

      // Verificar que listener foi adicionado
      expect(eventBus.listenerCount, greaterThan(0));

      // Limpar listeners
      eventBus.clearListeners();

      // Verificar que não há mais listeners
      expect(eventBus.listenerCount, equals(0));
    });
  });
}
