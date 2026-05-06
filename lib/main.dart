import 'package:flutter/material.dart';
import 'dart:isolate';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/app/bootstrap.dart';
import 'package:disciplinum/app/router/app_router.dart';
import 'package:disciplinum/app/auth_navigation_listener.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/core/storage/storage_manager.dart';
import 'package:disciplinum/features/app_lock/domain/services/app_lock_service.dart';
import 'package:disciplinum/features/app_lock/infrastructure/services/navigation_service.dart';
import 'package:disciplinum/core/gamification/presentation/widgets/global_achievement_listener.dart';

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
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Erro ao inicializar app'),
              const SizedBox(height: 8),
              Text('Detalhes: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => main(),
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
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

      LoggerService.instance.d('🔒 App Lock inicializado');
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeController = ref.watch(themeControllerProvider.notifier);
    final currentTheme = ref.watch(themeControllerProvider);
    final seenOnboarding = ref.watch(seenOnboardingProvider);
    final authService = ref.watch(authServiceProvider); // Observa auth para reconstruir

    // Log para debug
    LoggerService.instance.d('🏗️ DisciplinumApp build: seenOnboarding=$seenOnboarding, user=${authService.currentUser?.id}, theme=${currentTheme.name}');
    
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
