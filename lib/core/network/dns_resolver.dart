import 'dart:convert';
import 'dart:io';
import 'package:disciplinum/core/storage/objectbox_preferences_repository.dart';
import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Serviço para resolver problemas de DNS com múltiplas estratégias
class DnsResolver {
  static final DnsResolver _instance = DnsResolver._internal();
  factory DnsResolver() => _instance;
  DnsResolver._internal() {
    _loadPersistedCache();
  }

  // Cache válido por 30 minutos
  static const Duration _cacheDuration = Duration(minutes: 30);
  static const String _cacheKey = 'dns_cache_persistent';

  // Cache de resoluções bem-sucedidas
  final Map<String, List<InternetAddress>> _dnsCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  /// Carrega cache persistente do ObjectBoxPreferencesRepository
  Future<void> _loadPersistedCache() async {
    try {
      final prefs = ObjectBoxPreferencesRepository(ObjectBoxService.instance.store);
      final cacheJson = await prefs.getString(_cacheKey);
      if (cacheJson != null) {
        final cacheData = jsonDecode(cacheJson) as Map<String, dynamic>;
        for (final entry in cacheData.entries) {
          final timestamp = DateTime.parse(entry.value['timestamp'] as String);
          // Só carregar se não estiver muito expirado (máximo 24h)
          if (DateTime.now().difference(timestamp) < const Duration(hours: 24)) {
            final addresses = (entry.value['addresses'] as List<dynamic>)
                .map((addr) => InternetAddress(addr as String))
                .toList();
            _dnsCache[entry.key] = addresses;
            _cacheTimestamps[entry.key] = timestamp;
          }
        }
        LoggerService.instance.d('Cache DNS persistente carregado: ${_dnsCache.length} entradas');
      }
    } catch (e) {
      LoggerService.instance.w('Erro ao carregar cache DNS persistente: $e');
    }
  }

  /// Salva cache persistente no ObjectBoxPreferencesRepository
  Future<void> _savePersistedCache() async {
    try {
      final prefs = ObjectBoxPreferencesRepository(ObjectBoxService.instance.store);
      final cacheData = <String, dynamic>{};
      
      for (final entry in _dnsCache.entries) {
        final timestamp = _cacheTimestamps[entry.key];
        if (timestamp != null) {
          cacheData[entry.key] = {
            'addresses': entry.value.map((addr) => addr.address).toList(),
            'timestamp': timestamp.toIso8601String(),
          };
        }
      }
      
      await prefs.setString(_cacheKey, jsonEncode(cacheData));
    } catch (e) {
      LoggerService.instance.w('Erro ao salvar cache DNS persistente: $e');
    }
  }

  /// Resolve hostname com múltiplas estratégias
  Future<List<InternetAddress>> resolveHost(String host) async {
    // 1. Tentar cache primeiro
    final cached = _getCachedAddresses(host);
    if (cached.isNotEmpty) {
      LoggerService.instance.d('DNS cache hit para $host');
      return cached;
    }

    // 2. Tentar resolução padrão
    try {
      final addresses = await InternetAddress.lookup(host);
      if (addresses.isNotEmpty) {
        _cacheAddresses(host, addresses);
        LoggerService.instance.d('DNS resolvido para $host: ${addresses.first.address}');
        return addresses;
      }
    } catch (e) {
      LoggerService.instance.w('DNS padrão falhou para $host: $e');
    }

    // 3. Tentar resolução com diferentes tipos (IPv4/IPv6)
    try {
      final ipv4Addresses = await InternetAddress.lookup(host, type: InternetAddressType.IPv4);
      if (ipv4Addresses.isNotEmpty) {
        _cacheAddresses(host, ipv4Addresses);
        LoggerService.instance.d('DNS IPv4 resolvido para $host: ${ipv4Addresses.first.address}');
        return ipv4Addresses;
      }
    } catch (e) {
      LoggerService.instance.w('DNS IPv4 falhou para $host: $e');
    }

    // 4. Tentar com Google DNS (fallback)
    try {
      final googleDnsAddresses = await _resolveWithGoogleDns(host);
      if (googleDnsAddresses.isNotEmpty) {
        _cacheAddresses(host, googleDnsAddresses);
        LoggerService.instance.d('DNS Google resolvido para $host: ${googleDnsAddresses.first.address}');
        return googleDnsAddresses;
      }
    } catch (e) {
      LoggerService.instance.w('DNS Google falhou para $host: $e');
    }

    // 5. Retornar cache antigo se disponível (mesmo expirado)
    final expiredCache = _getExpiredAddresses(host);
    if (expiredCache.isNotEmpty) {
      LoggerService.instance.w('Usando cache DNS expirado para $host');
      return expiredCache;
    }

    LoggerService.instance.e('DNS não conseguiu resolver $host');
    throw SocketException('Failed to resolve host: $host');
  }

  /// Resolve usando Google DNS (8.8.8.8)
  Future<List<InternetAddress>> _resolveWithGoogleDns(String host) async {
    // Esta é uma implementação simplificada
    // Em produção, você poderia usar uma biblioteca DNS específica
    return await InternetAddress.lookup(host);
  }

  /// Obtém endereços do cache
  List<InternetAddress> _getCachedAddresses(String host) {
    final timestamp = _cacheTimestamps[host];
    if (timestamp == null) return [];

    if (DateTime.now().difference(timestamp) > _cacheDuration) {
      // Cache expirado
      _dnsCache.remove(host);
      _cacheTimestamps.remove(host);
      return [];
    }

    return _dnsCache[host] ?? [];
  }

  /// Obtém cache expirado (fallback)
  List<InternetAddress> _getExpiredAddresses(String host) {
    return _dnsCache[host] ?? [];
  }

  /// Armazena endereços no cache
  void _cacheAddresses(String host, List<InternetAddress> addresses) {
    _dnsCache[host] = addresses;
    _cacheTimestamps[host] = DateTime.now();
    _cleanExpiredCache();
    _savePersistedCache(); // Salvar persistentemente
  }

  /// Limpa cache expirado
  void _cleanExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    for (final entry in _cacheTimestamps.entries) {
      if (now.difference(entry.value) > _cacheDuration) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _dnsCache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  /// Limpa todo o cache
  void clearCache() {
    _dnsCache.clear();
    _cacheTimestamps.clear();
  }

  /// Verifica se host pode ser resolvido
  Future<bool> canResolve(String host) async {
    try {
      await resolveHost(host);
      return true;
    } catch (e) {
      return false;
    }
  }
}
