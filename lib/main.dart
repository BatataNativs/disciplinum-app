import 'package:flutter/material.dart';
import 'dart:isolate';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/app/bootstrap.dart';
import 'package:disciplinum/app/router/app_router.dart';
import 'package:disciplinum/app/auth_navigation_listener.dart';
import 'package:disciplinum/app/error_recovery_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/core/storage/storage_manager.dart';
import 'package:disciplinum/features/app_lock/domain/services/app_lock_service.dart';
import 'package:disciplinum/features/app_lock/infrastructure/services/navigation_service.dart';
import 'package:disciplinum/core/gamification/presentation/widgets/global_achievement_listener.dart';
import 'package:disciplinum/features/app_lock/domain/services/app_lock_sync_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  
  // Configurar tratamento global de erros
  FlutterError.onError = (FlutterErrorDetails details) {
    LoggerService.instance.e(
      'Flutter Error',
      error: details.exception,
      stackTrace: details.stack,
    );
  };
  
  // Capturar erros não tratados a nível de plataforma
  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    final errorAndStacktrace = pair as List<dynamic>;
    final error = errorAndStacktrace.first;
    final stackTrace = errorAndStacktrace.last as StackTrace;
    LoggerService.instance.e(
      'Uncaught Error',
      error: error,
      stackTrace: stackTrace,
    );
  }).sendPort);
  
  try {
    // Verificar espaço de armazenamento antes de inicializar
    await StorageManager.checkAndCleanIfNeeded();
    
    final startupData = await AppBootstrap.initialize();

    // Aguarda o Supabase restaurar a sessão antes de subir o app.
    // Isso garante que currentUserIdProvider terá o UUID real desde o início,
    // eliminando a race condition que causava saves com 'guest_user'.
    // Timeout de 4s: se não houver sessão salva (usuário não logado), continua normalmente.
    if (Supabase.instance.client.auth.currentSession == null) {
      try {
        await Supabase.instance.client.auth.onAuthStateChange
            .where((e) => e.event == AuthChangeEvent.initialSession || e.session != null)
            .first
            .timeout(const Duration(seconds: 4));
        LoggerService.instance.d('✅ Supabase: sessão restaurada antes do runApp');
      } catch (_) {
        // Timeout: usuário não está logado, continua normalmente em modo guest
        LoggerService.instance.d('⚠️ Supabase: nenhuma sessão encontrada (modo guest ou não logado)');
      }
    } else {
      LoggerService.instance.d('✅ Supabase: sessão já disponível imediatamente');
    }
    
    runApp(
      ProviderScope(
        overrides: [
          seenOnboardingProvider.overrideWithValue(startupData.seenOnboarding),
        ],
        child: const DisciplinumApp(),
      ),
    );
  } catch (e, stackTrace) {
    LoggerService.instance.e('Error during initialization', error: e, stackTrace: stackTrace);
    runApp(ErrorRecoveryScreen(
      error: e.toString(),
      stackTrace: stackTrace,
    ));
  }
}

class DisciplinumApp extends ConsumerStatefulWidget {
  const DisciplinumApp({super.key});

  @override
  ConsumerState<DisciplinumApp> createState() => _DisciplinumAppState();
}

class _DisciplinumAppState extends ConsumerState<DisciplinumApp> {
  @override
  void initState() {
    super.initState();
    
    // Inicializar App Lock após o primeiro frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final container = ProviderScope.containerOf(context);
      
      // Configurar ProviderContainer para AppLockService
      AppLockService.setContainer(container);
      
      // A sessão já foi aguardada no main() antes do runApp.
      // Disparamos a sincronização diretamente aqui.
      AppLockSyncService.instance.syncAllConfigs();

      // Também escuta eventos futuros (login/logout) para manter o nativo sincronizado
      Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        if (data.session != null) {
          AppLockSyncService.instance.syncAllConfigs();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Observa o estado para reconstruir quando mudar, mas usa o notifier para pegar o themeData
    ref.watch(themeControllerProvider);
    final themeController = ref.read(themeControllerProvider.notifier);
    final seenOnboarding = ref.watch(seenOnboardingProvider);
    final authService = ref.watch(authServiceProvider); // Observa auth para reconstruir
    
    return GlobalAchievementListener(
      child: AuthNavigationListener(
        child: MaterialApp(
          title: 'Disciplinum',
          navigatorKey: AppLockNavigationService.navigatorKey, // Key para App Lock
          theme: themeController.themeData, // Tema dinâmico baseado no tema selecionado
          debugShowCheckedModeBanner: false,
          // Se usuário está logado, vai para AuthWrapper (que leva para Home)
          // Se não viu onboarding e não está logado, vai para onboarding
          initialRoute: (seenOnboarding || authService.currentUser != null)
              ? AppRouter.authWrapper
              : AppRouter.onboarding,
          onGenerateRoute: AppRouter.generateRoute,
        ),
      ),
    );
  }
}
