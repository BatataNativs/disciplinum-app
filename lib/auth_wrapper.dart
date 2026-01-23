import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/services/auth/auth_service.dart';
import 'package:disciplinum/screens/home/home_screen.dart';
import 'package:disciplinum/screens/auth_signup_login/reset_password_screen.dart';
import 'package:disciplinum/screens/opening/welcome_screen.dart';

class AuthWrapperWithoutHomeValues extends StatelessWidget {
  const AuthWrapperWithoutHomeValues({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    // Prioridade 1: Recuperação de Senha
    if (authService.isPasswordRecovery) {
      debugPrint('AuthWrapper: Exibindo ResetPasswordScreen.');
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
