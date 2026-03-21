import 'package:flutter/material.dart';
import 'dart:isolate';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/app/bootstrap.dart';
import 'package:disciplinum/app/router/app_router.dart';
import 'package:disciplinum/core/theme/app_themes.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/core/storage/storage_manager.dart';

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
          sharedPreferencesProvider.overrideWithValue(startupData.prefs),
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

class DisciplinumApp extends ConsumerWidget {
  const DisciplinumApp({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeController = ref.watch(themeControllerProvider);
    final seenOnboarding = ref.watch(seenOnboardingProvider);
    
    return MaterialApp(
      title: 'Disciplinum',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeController.themeMode,
      debugShowCheckedModeBanner: false,
      initialRoute: seenOnboarding 
          ? AppRouter.authWrapper 
          : AppRouter.onboarding,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
