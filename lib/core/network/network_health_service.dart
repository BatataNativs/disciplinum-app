import 'dart:async';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/config/app_config.dart';
import 'package:disciplinum/core/network/dns_resolver.dart';

/// Serviço para verificar saúde da conexão de rede
class NetworkHealthService {
  static final NetworkHealthService _instance = NetworkHealthService._internal();
  factory NetworkHealthService() => _instance;
  NetworkHealthService._internal();

  Timer? _healthCheckTimer;
  bool _isHealthy = true;
  DateTime? _lastSuccessCheck;

  /// Inicia monitoramento contínuo da conexão
  void startHealthCheck({Duration interval = const Duration(minutes: 5)}) {
    stopHealthCheck();
    _healthCheckTimer = Timer.periodic(interval, (_) => checkConnectivity());
    // Verificação inicial
    checkConnectivity();
  }

  /// Para monitoramento
  void stopHealthCheck() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;
  }

  /// Verifica conectividade com Supabase usando resolução DNS avançada
  Future<bool> checkConnectivity() async {
    try {
      if (AppConfig.supabaseUrl.isEmpty) {
        LoggerService.instance.w('URL Supabase não configurada');
        return false;
      }

      // Extrair hostname da URL
      final uri = Uri.parse(AppConfig.supabaseUrl);
      final host = uri.host;
      
      // Usar DnsResolver para resolução robusta
      final addresses = await DnsResolver().resolveHost(host);
      if (addresses.isNotEmpty) {
        _isHealthy = true;
        _lastSuccessCheck = DateTime.now();
        LoggerService.instance.d('Conectividade OK: $host -> ${addresses.first.address}');
        return true;
      }
    } catch (e) {
      _isHealthy = false;
      LoggerService.instance.e('Falha na verificação de conectividade', error: e);
      return false;
    }
    return false;
  }

  /// Verifica se a conexão está saudável
  bool get isHealthy => _isHealthy;

  /// Última verificação bem-sucedida
  DateTime? get lastSuccessCheck => _lastSuccessCheck;

  /// Verifica se deve tentar operação de rede baseada em histórico
  Future<bool> shouldAttemptNetworkOperation() async {
    // Forçar verificação agora e esperar resultado
    final isConnected = await checkConnectivity();
    LoggerService.instance.i('NetworkHealthService: Verificação forçada concluída - isHealthy: $isConnected');
    
    return isConnected;
  }

  /// Limpa recursos
  void dispose() {
    stopHealthCheck();
  }
}
