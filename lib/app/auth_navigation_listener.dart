import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/app/router/app_router.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Widget que escuta mudanças no estado de autenticação e navega automaticamente
/// para a Home quando o usuário faz login (de qualquer tela que esteja).
class AuthNavigationListener extends ConsumerStatefulWidget {
  final Widget child;

  const AuthNavigationListener({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AuthNavigationListener> createState() => _AuthNavigationListenerState();
}

class _AuthNavigationListenerState extends ConsumerState<AuthNavigationListener> {
  String? _previousUserId;
  bool _isNavigating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final authService = ref.read(authServiceProvider);
    final currentUserId = authService.currentUser?.id;
    
    // Detecta novo login (usuário anterior era nulo e agora tem usuário)
    if (_previousUserId == null && currentUserId != null && !_isNavigating) {
      _isNavigating = true;
      LoggerService.instance.i('🔐 Novo login detectado. Navegando para Home...');
      
      // Navega para AuthWrapper (que vai mostrar Home) e limpa pilha
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRouter.authWrapper,
            (route) => false,
          );
        }
        _isNavigating = false;
      });
    }
    
    _previousUserId = currentUserId;
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild quando authService muda para detectar login
    ref.watch(authServiceProvider);
    
    return widget.child;
  }
}
