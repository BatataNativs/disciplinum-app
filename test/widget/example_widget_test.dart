import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Exemplo de teste de widget
/// 
/// Este é um template para testes de widget. Copie e adapte conforme necessário.
void main() {
  testWidgets('deve renderizar widget corretamente', (WidgetTester tester) async {
    // Arrange
    const testWidget = MaterialApp(
      home: Scaffold(
        body: Text('Test Widget'),
      ),
    );

    // Act
    await tester.pumpWidget(testWidget);

    // Assert
    expect(find.text('Test Widget'), findsOneWidget);
  });

  testWidgets('deve responder a tap', (WidgetTester tester) async {
    // Arrange
    bool tapped = false;
    final testWidget = MaterialApp(
      home: Scaffold(
        body: ElevatedButton(
          onPressed: () {
            tapped = true;
          },
          child: const Text('Tap Me'),
        ),
      ),
    );

    // Act
    await tester.pumpWidget(testWidget);
    await tester.tap(find.text('Tap Me'));
    await tester.pump();

    // Assert
    expect(tapped, true);
  });

  testWidgets('deve atualizar texto ao pressionar botão', (WidgetTester tester) async {
    // Arrange
    final testWidget = MaterialApp(
      home: const CounterWidget(),
    );

    // Act
    await tester.pumpWidget(testWidget);
    expect(find.text('Count: 0'), findsOneWidget);

    // Act - increment counter
    await tester.tap(find.text('Increment'));
    await tester.pump();

    // Assert
    expect(find.text('Count: 1'), findsOneWidget);
  });
}

/// Widget de exemplo para testar
class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('Count: $_counter'),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _counter++;
              });
            },
            child: const Text('Increment'),
          ),
        ],
      ),
    );
  }
}
