import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/home/presentation/screens/home_screen.dart';
import 'package:disciplinum/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:disciplinum/features/onboarding/presentation/screens/welcome_screen.dart';

class AuthWrapperWithoutHomeValues extends ConsumerWidget {
  const AuthWrapperWithoutHomeValues({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);

    // Prioridade 1: Recuperação de Senha
    if (authService.isPasswordRecovery) {
      LoggerService.instance.d('AuthWrapper: Exibindo ResetPasswordScreen.');
      return const ResetPasswordScreen();
    }

    // Prioridade 2: Loader
    if (authService.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Prioridade 3: Lógica de Autenticação
    if (authService.isAuthenticated) {
      // Logado -> Home
      return const HomeScreen();
    } else {
      // Deslogado -> Welcome Screen (Portal de Consentimento)
      return const WelcomeScreen();
    }
  }
}
