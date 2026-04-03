import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Enum que representa os estados de conectividade da rede
enum NetworkState {
  /// Dispositivo conectado (WiFi ou dados móveis)
  online,

  /// Dispositivo sem conectividade
  offline,

  /// Estado desconhecido (ainda não determinado)
  unknown,
}

/// Provider que expõe o estado atual da rede como um Stream
///
/// Uso:
/// ```dart
/// final networkState = ref.watch(networkStateProvider);
/// networkState.when(
///   data: (state) => print('Rede: $state'),
///   loading: () => print('Verificando...'),
///   error: (e, _) => print('Erro: $e'),
/// );
/// ```
final networkStateProvider = StreamProvider<NetworkState>((ref) {
  return ref.watch(networkStateObserverProvider.notifier).stream;
});

/// Provider do NetworkStateObserver para acesso direto
final networkStateObserverProvider = StateNotifierProvider<NetworkStateObserver, NetworkState>((ref) {
  return NetworkStateObserver(
    logger: LoggerService.instance,
  );
});

/// Provider que reage a mudanças de rede e dispara sync automaticamente
///
/// Este provider deve ser escutado no nível do app para garantir
/// que sincronização ocorra sempre que o dispositivo voltar online.
final autoSyncOnNetworkChangeProvider = Provider<void>((ref) {
  final networkStateAsync = ref.watch(networkStateProvider);

  networkStateAsync.whenData((state) async {
    if (state == NetworkState.online) {
      final logger = LoggerService.instance;
      logger.i('🌐 Dispositivo online - Disparando sincronização automática');

      // Aqui você pode adicionar a lógica de sync quando tiver o Supabase configurado
      // final syncService = ref.read(moduleSyncServiceProvider);
      // await syncService.processPendingSyncs();
    }
  });
});

/// Notifier que monitora o estado da conectividade do dispositivo
///
/// Usa dart:io para verificar conectividade via lookup de DNS.
/// Não requer pacotes externos como connectivity_plus.
class NetworkStateObserver extends StateNotifier<NetworkState> {
  final LoggerService _logger;
  Timer? _periodicTimer;

  /// Stream exposto para listeners externos
  final _controller = StreamController<NetworkState>.broadcast();

  /// Stream de estado de rede
  @override
  Stream<NetworkState> get stream => _controller.stream;

  NetworkStateObserver({
    required LoggerService logger,
  })  : _logger = logger,
        super(NetworkState.unknown) {
    _init();
  }

  /// Inicializa o monitoramento de rede
  void _init() {
    _logger.i('🌐 NetworkStateObserver inicializado');

    // Verificar estado inicial
    _checkConnectivity();

    // Verificar periodicamente (a cada 30 segundos)
    _periodicTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkConnectivity(),
    );
  }

  /// Verifica conectividade via lookup DNS
  Future<void> _checkConnectivity() async {
    try {
      // Tenta resolver um domínio confiável (Google DNS)
      final result = await InternetAddress.lookup('8.8.8.8')
          .timeout(const Duration(seconds: 3));

      final isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      final newState = isOnline ? NetworkState.online : NetworkState.offline;

      if (state != newState) {
        _logger.i('🌐 Mudança de estado de rede: $state -> $newState');
        state = newState;
        _controller.add(newState);
      }
    } on SocketException catch (_) {
      if (state != NetworkState.offline) {
        _logger.w('� Dispositivo ficou offline');
        state = NetworkState.offline;
        _controller.add(NetworkState.offline);
      }
    } on TimeoutException catch (_) {
      if (state != NetworkState.offline) {
        _logger.w('📵 Timeout na verificação de rede - considerando offline');
        state = NetworkState.offline;
        _controller.add(NetworkState.offline);
      }
    } catch (e) {
      _logger.e('Erro ao verificar conectividade', error: e);
      if (state != NetworkState.unknown) {
        state = NetworkState.unknown;
        _controller.add(NetworkState.unknown);
      }
    }
  }

  /// Força verificação imediata de conectividade
  Future<void> checkNow() async {
    _logger.i('🌐 Verificação de rede solicitada manualmente');
    await _checkConnectivity();
  }

  /// Verifica se o dispositivo está online no momento
  bool get isOnline => state == NetworkState.online;

  /// Verifica se o dispositivo está offline no momento
  bool get isOffline => state == NetworkState.offline;

  @override
  void dispose() {
    _periodicTimer?.cancel();
    _controller.close();
    super.dispose();
  }
}
