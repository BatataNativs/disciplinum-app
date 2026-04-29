import 'dart:async';
import 'dart:io';
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
  DateTime? _lastFailureLogged;
  int _consecutiveFailures = 0;
  
  static const int _maxConsecutiveFailures = 3;
  static const Duration _failureLogThrottle = Duration(minutes: 5); // Logar falha a cada 5 min

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
        _logFailure('URL Supabase não configurada', isConfigError: true);
        return false;
      }

      // Extrair hostname da URL
      final uri = Uri.parse(AppConfig.supabaseUrl);
      final host = uri.host;
      
      // Usar DnsResolver para resolução robusta
      final addresses = await DnsResolver().resolveHost(host);
      if (addresses.isNotEmpty) {
        _isHealthy = true;
        _consecutiveFailures = 0;
        _lastSuccessCheck = DateTime.now();
        LoggerService.instance.d('Conectividade OK: $host -> ${addresses.first.address}');
        return true;
      }
    } on SocketException catch (e) {
      _isHealthy = false;
      _consecutiveFailures++;
      _logFailure('Sem conexão de rede: $e', isNetworkError: true);
      return false;
    } catch (e) {
      _isHealthy = false;
      _consecutiveFailures++;
      _logFailure('Falha na verificação de conectividade: $e');
      return false;
    }
    return false;
  }

  /// Loga falha com throttling para evitar spam
  void _logFailure(String message, {bool isNetworkError = false, bool isConfigError = false}) {
    final now = DateTime.now();
    
    // Só logar erro de rede se for a primeira vez ou após 5 minutos
    if (isNetworkError) {
      if (_consecutiveFailures <= _maxConsecutiveFailures || 
          _lastFailureLogged == null ||
          now.difference(_lastFailureLogged!) > _failureLogThrottle) {
        LoggerService.instance.w('📡 $message (tentativa $_consecutiveFailures)');
        _lastFailureLogged = now;
      } else {
        // Log silencioso - apenas debug
        LoggerService.instance.d('📡 $message (suprimido)');
      }
    } else if (isConfigError) {
      LoggerService.instance.w('⚙️ $message');
    } else {
      LoggerService.instance.e('❌ $message');
    }
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
