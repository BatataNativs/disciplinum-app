import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/features/auth/presentation/screens/biometric_lock_screen.dart';

/// Widget guardião que intercepta a interface e exibe a tela de bloqueio biométrico
/// no topo absoluto da árvore de navegação sempre que o app estiver bloqueado.
class BiometricLockGuardian extends ConsumerWidget {
  final Widget child;

  const BiometricLockGuardian({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lockState = ref.watch(biometricLockControllerProvider);
    final authState = ref.watch(authServiceProvider);

    final hasActiveSession = authState.currentUser?.id != null;

    final shouldShowLock = lockState.isInitialized &&
        lockState.isEnabled &&
        lockState.isLocked &&
        hasActiveSession;

    return Stack(
      children: [
        child,
        if (shouldShowLock)
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: BiometricLockScreen(
                onUnlocked: () {
                  ref.read(biometricLockControllerProvider.notifier).unlock();
                },
              ),
            ),
          ),
      ],
    );
  }
}
