import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wrapper para facilitar migração gradual de Provider para Riverpod
class RiverpodWrapper {
  /// Wrapper principal para envolver o app com ProviderScope
  static Widget wrapWithProviders({
    required Widget child,
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: overrides,
      child: child,
    );
  }

  /// Helper para migrar de Provider.of para Riverpod (contexto legado)
  static T of<T>(
    BuildContext context,
    ProviderBase<T> provider, {
    bool listen = true,
  }) {
    final container = ProviderScope.containerOf(context);
    return container.read(provider);
  }
}

/// Extension methods para facilitar uso em contextos Flutter
extension RiverpodContext on BuildContext {
  /// Lê um provider sem escutar mudanças (similar a Provider.of sem listen)
  T read<T>(ProviderBase<T> provider) {
    return ProviderScope.containerOf(this).read(provider);
  }

  /// Obtém o container do Riverpod do contexto
  ProviderContainer get container => ProviderScope.containerOf(this);
}
