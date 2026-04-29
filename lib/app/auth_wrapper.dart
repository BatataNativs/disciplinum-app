import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/home/presentation/screens/home_screen.dart';
import 'package:disciplinum/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:disciplinum/features/onboarding/presentation/screens/welcome_screen.dart';

/// AuthWrapper gerencia o fluxo de autenticação.
/// A sincronização inicial é tratada na HomeScreen com overlay esmaecido.
class AuthWrapperWithoutHomeValues extends ConsumerStatefulWidget {
  const AuthWrapperWithoutHomeValues({super.key});

  @override
  ConsumerState<AuthWrapperWithoutHomeValues> createState() => _AuthWrapperWithoutHomeValuesState();
}

class _AuthWrapperWithoutHomeValuesState extends ConsumerState<AuthWrapperWithoutHomeValues> {
  bool _wasLoading = false;
  bool _isVerifying = false;

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    
    // Logs detalhados para diagnóstico
    LoggerService.instance.d('🔍 AuthWrapper BUILD: isLoading=${authService.isLoading}, currentUserId=${authService.currentUser?.id}, isSocialLoginInProgress=${authService.isSocialLoginInProgress}, _isVerifying=$_isVerifying, _wasLoading=$_wasLoading');

    // Detecta transição de loading para não-loading
    if (_wasLoading && !authService.isLoading) {
      LoggerService.instance.d('🔍 AuthWrapper: Transição de loading para não-loading detectada');
      // Se terminou de carregar mas não tem usuário ainda, aguarda brevemente
      // para evitar flash da WelcomeScreen durante atualização do estado
      if (authService.currentUser?.id == null && !_isVerifying) {
        LoggerService.instance.d('🔍 AuthWrapper: Iniciando verificação de 800ms (usuário ainda null)');
        _isVerifying = true;
        // Aguarda até 800ms para o estado do usuário ser atualizado
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            LoggerService.instance.d('🔍 AuthWrapper: Verificação completa, reconstruindo...');
            setState(() {
              _isVerifying = false;
            });
          }
        });
      }
    }
    _wasLoading = authService.isLoading;

    // Prioridade 1: Recuperação de Senha
    if (authService.isPasswordRecovery) {
      LoggerService.instance.d('AuthWrapper: Exibindo ResetPasswordScreen.');
      return const ResetPasswordScreen();
    }

    // Prioridade 2: Loader ou Verificação
    if (authService.isLoading || _isVerifying) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Prioridade 3: Lógica de Autenticação
    final currentUserId = authService.currentUser?.id;
    
    if (currentUserId != null) {
      LoggerService.instance.d('AuthWrapper: Usuário logado ($currentUserId) -> HomeScreen');
      // Logado -> Home (a sincronização inicial acontece lá com overlay)
      return const HomeScreen();
    } else {
      LoggerService.instance.d('AuthWrapper: Sem usuário -> WelcomeScreen');
      // Deslogado -> Welcome
      return const WelcomeScreen();
    }
  }
}
