import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/riverpod_wrapper.dart';
import 'package:disciplinum/features/home/presentation/screens/home_screen.dart';

/// Configuração principal do App com Riverpod
/// 
/// Para usar, substitua o MaterialApp atual por:
/// ```dart
/// RiverpodApp(
///   child: MaterialApp(...),
/// )
/// ```
class RiverpodApp extends StatelessWidget {
  final Widget child;

  const RiverpodApp({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RiverpodWrapper.wrapWithProviders(
      child: child,
      // Overrides podem ser adicionados aqui para testes ou configurações específicas
      overrides: [
        // Exemplo de override:
        // localStorageServiceProvider.overrideWithValue(MockLocalStorageService()),
      ],
    );
  }
}

/// Widget Consumer para facilitar migração gradual
/// 
/// Uso:
/// ```dart
/// RiverpodConsumer(
///   builder: (context, ref, child) {
///     final state = ref.watch(myProvider);
///     return MyWidget(state: state);
///   },
/// )
/// ```
class RiverpodConsumer extends ConsumerWidget {
  final Widget Function(BuildContext context, WidgetRef ref, Widget? child) builder;
  final Widget? child;

  const RiverpodConsumer({
    super.key,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return builder(context, ref, child);
  }
}

/// Helper para criar ConsumerWidgets facilmente
class RiverpodBuilder<T> extends ConsumerWidget {
  final ProviderListenable<T> provider;
  final Widget Function(BuildContext context, T value, WidgetRef ref) builder;
  final Widget? child;

  const RiverpodBuilder({
    super.key,
    required this.provider,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(provider);
    return builder(context, value, ref);
  }
}

/// Exemplo de como migrar telas existentes
class MigrationExample extends StatelessWidget {
  const MigrationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return RiverpodApp(
      child: MaterialApp(
        title: 'Disciplinum - Riverpod Migration',
        home: const HomeScreen(),
        // ... outras configurações do MaterialApp
      ),
    );
  }
}

/// Extension para facilitar uso em telas existentes
extension RiverpodMigration on StatelessWidget {
  /// Converte um StatelessWidget para usar Riverpod
  Widget withRiverpod() {
    return RiverpodApp(child: this);
  }
}

/// Extension para ConsumerWidget
extension RiverpodConsumerExtension on ConsumerWidget {
  /// Helper para ler providers de forma tipada
  T read<T>(WidgetRef ref, ProviderBase<T> provider) {
    return ref.read(provider);
  }

  /// Helper para assistir providers de forma tipada
  T watch<T>(WidgetRef ref, ProviderBase<T> provider) {
    return ref.watch(provider);
  }
}
