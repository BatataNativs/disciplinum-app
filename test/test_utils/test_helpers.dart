import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:disciplinum/features/gamification/domain/entities/module_state.dart';
import 'package:disciplinum/features/gamification/domain/entities/user_module_status.dart';

/// Helper para criar test data
class TestDataFactory {
  /// Cria ModuleState de teste
  static ModuleState createModuleState({
    int nicheId = 1,
    bool isActive = true,
    int consecutiveDays = 7,
    int? focusPeriodsRespected,
    DateTime? lastUpdated,
    String? maxMedal,
    List<String> earnedInsignias = const [],
    int currentXp = 100,
    Map<String, dynamic> moduleSpecificData = const {},
    DateTime? lastCheckIn,
    DateTime? lastRelapse,
    int totalCheckIns = 7,
    int totalRelapses = 0,
  }) {
    return ModuleState(
      nicheId: nicheId,
      isActive: isActive,
      consecutiveDays: consecutiveDays,
      focusPeriodsRespected: focusPeriodsRespected,
      lastUpdated: lastUpdated ?? DateTime.now(),
      maxMedal: maxMedal,
      earnedInsignias: earnedInsignias,
      currentXp: currentXp,
      moduleSpecificData: moduleSpecificData,
      lastCheckIn: lastCheckIn ?? DateTime.now().subtract(const Duration(days: 1)),
      lastRelapse: lastRelapse,
      totalCheckIns: totalCheckIns,
      totalRelapses: totalRelapses,
    );
  }

  /// Cria UserModuleStatus de teste
  static UserModuleStatus createUserModuleStatus({
    String userId = 'test_user',
    int nicheId = 1,
    bool isActive = true,
    int consecutiveDays = 7,
    int? focusPeriodsRespected,
    DateTime? lastUpdated,
    String? maxMedal,
    List<String> earnedInsignias = const [],
  }) {
    return UserModuleStatus(
      userId: userId,
      nicheId: nicheId,
      isActive: isActive,
      consecutiveDays: consecutiveDays,
      focusPeriodsRespected: focusPeriodsRespected,
      lastUpdated: lastUpdated ?? DateTime.now(),
      maxMedal: maxMedal,
      earnedInsignias: earnedInsignias,
    );
  }

  /// Cria lista de ModuleStates para teste
  static List<ModuleState> createModuleStateList({
    int count = 3,
    bool allActive = true,
  }) {
    return List.generate(count, (index) {
      return createModuleState(
        nicheId: index + 1,
        isActive: allActive,
        consecutiveDays: (index + 1) * 3,
        currentXp: (index + 1) * 50,
      );
    });
  }
}

/// Helper para setup de testes
class TestSetup {
  /// Configura widget tester com material app
  static Widget createTestWidget({required Widget child}) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  /// Configura widget tester com material app e rota
  static Widget createTestWidgetWithRoute({
    required Widget child,
    String route = '/',
  }) {
    return MaterialApp(
      home: child,
      routes: {
        route: (context) => child,
      },
    );
  }
}

/// Helper para assertions de teste
class TestAssertions {
  /// Verifica se ModuleState tem valores esperados
  static void expectModuleState(
    ModuleState actual,
    ModuleState expected, {
    bool checkTimestamps = false,
  }) {
    expect(actual.nicheId, expected.nicheId);
    expect(actual.isActive, expected.isActive);
    expect(actual.consecutiveDays, expected.consecutiveDays);
    expect(actual.focusPeriodsRespected, expected.focusPeriodsRespected);
    expect(actual.maxMedal, expected.maxMedal);
    expect(actual.earnedInsignias, expected.earnedInsignias);
    expect(actual.currentXp, expected.currentXp);
    expect(actual.moduleSpecificData, expected.moduleSpecificData);
    expect(actual.lastCheckIn, expected.lastCheckIn);
    expect(actual.lastRelapse, expected.lastRelapse);
    expect(actual.totalCheckIns, expected.totalCheckIns);
    expect(actual.totalRelapses, expected.totalRelapses);

    if (checkTimestamps) {
      expect(actual.lastUpdated, expected.lastUpdated);
    }
  }

  /// Verifica se lista de ModuleStates contém nichos esperados
  static void expectModuleStatesContainNiches(
    List<ModuleState> states,
    List<int> expectedNiches,
  ) {
    expect(states.length, expectedNiches.length);
    
    for (final nicheId in expectedNiches) {
      expect(
        states.any((state) => state.nicheId == nicheId),
        true,
        reason: 'Expected to find module state for niche $nicheId',
      );
    }
  }
}

/// Helper para waits em testes assíncronos
class TestWaits {
  /// Espera por Future completar
  static Future<T> waitForFuture<T>(Future<T> future) async {
    return await future;
  }

  /// Espera por múltiplos Futures
  static Future<List<T>> waitForFutures<T>(List<Future<T>> futures) async {
    return await Future.wait(futures);
  }

  /// Espera por duração específica (para animações)
  static Future<void> waitForDuration(Duration duration) async {
    await Future.delayed(duration);
  }

  /// Espera por widget aparecer
  static Future<void> waitForWidget(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await tester.pumpAndSettle(timeout);
    expect(finder, findsOneWidget);
  }

  /// Espera por widget desaparecer
  static Future<void> waitForWidgetToDisappear(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await tester.pumpAndSettle(timeout);
    expect(finder, findsNothing);
  }
}

/// Helper para simulação de eventos
class EventSimulation {
  /// Simula clique em botão
  static Future<void> tapButton(
    WidgetTester tester,
    Finder buttonFinder,
  ) async {
    await tester.tap(buttonFinder);
    await tester.pump();
  }

  /// Simula preenchimento de campo de texto
  static Future<void> fillTextField(
    WidgetTester tester,
    Finder textFieldFinder,
    String text,
  ) async {
    await tester.tap(textFieldFinder);
    await tester.pump();
    await tester.enterText(textFieldFinder, text);
    await tester.pump();
  }

  /// Simula scroll
  static Future<void> scroll(
    WidgetTester tester,
    Finder scrollableFinder,
    Finder targetFinder, {
    double delta = 100.0,
  }) async {
    await tester.scrollUntilVisible(
      targetFinder,
      delta,
      scrollable: scrollableFinder,
    );
    await tester.pump();
  }

  /// Simula drag
  static Future<void> drag(
    WidgetTester tester,
    Finder finder,
    Offset start,
    Offset end, {
    Duration duration = const Duration(milliseconds: 300),
  }) async {
    await tester.drag(finder, end - start);
    await tester.pump(duration);
  }
}

/// Extension methods para facilitar testes
extension WidgetTesterExtensions on WidgetTester {
  /// Encontra widget por tipo genérico
  Finder findByType<T>() {
    return find.byType(T);
  }

  /// Encontra widget por key
  Finder findByKey(String key) {
    return find.byKey(Key(key));
  }

  /// Encontra widget por texto
  Finder findByText(String text) {
    return find.text(text);
  }

  /// Encontra widget por ícone
  Finder findByIcon(IconData icon) {
    return find.byIcon(icon);
  }

  /// Verifica se widget existe
  bool widgetExists<T>() {
    return findByType<T>().evaluate().isNotEmpty;
  }

  /// Verifica se widget com texto existe
  bool textExists(String text) {
    return findByText(text).evaluate().isNotEmpty;
  }

  /// Verifica se widget com key existe
  bool keyExists(String key) {
    return findByKey(key).evaluate().isNotEmpty;
  }
}

/// Extension methods para facilitar asserts
extension FinderExtensions on Finder {
  /// Verifica se finder exatamente um widget
  void shouldFindOne() {
    expect(this, findsOneWidget);
  }

  /// Verifica se finder exatamente N widgets
  void shouldFindExactly(int count) {
    expect(this, findsNWidgets(count));
  }

  /// Verifica se finder encontra pelo menos um widget
  void shouldFindAtLeastOne() {
    expect(this, findsWidgets);
  }

  /// Verifica se finder não encontra widgets
  void shouldFindNone() {
    expect(this, findsNothing);
  }
}

/// Constantes para testes
class TestConstants {
  static const String testUserId = 'test_user_123';
  static const String testEmail = 'test@example.com';
  static const Duration defaultTimeout = Duration(seconds: 5);
  static const Duration shortDelay = Duration(milliseconds: 100);
  static const Duration mediumDelay = Duration(milliseconds: 500);
  static const Duration longDelay = Duration(seconds: 1);
}
