import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/digital_detox/domain/services/digital_detox_service_local.dart';

// ==================== PROVIDERS DE ACESSO ====================

/// Provider para o DigitalDetoxServiceLocal
/// Segue o mesmo padrão dos outros módulos (ex: focusServiceLocalProvider)
final digitalDetoxServiceLocalProvider = Provider<DigitalDetoxServiceLocal>((ref) {
  return DigitalDetoxServiceLocal.instance;
});

/// Provider para obter o userId atual dentro do mÃ³dulo Digital Detox
/// VersÃ£o local independente (padrÃ£o plugin)
final digitalDetoxCurrentUserIdProvider = Provider<String>((ref) {
  // Implementação local sem depender de core/di
  // Por enquanto retorna guest_user - pode ser expandido no futuro
  return 'guest_user';
});

// ==================== ESTADO ====================

/// Estado do módulo Digital Detox
class DigitalDetoxState {
  final List<String> monitoredApps;
  final List<String> selectedApps;
  final bool isModuleActive;
  final bool isLoading;
  final String? error;

  const DigitalDetoxState({
    required this.monitoredApps,
    required this.selectedApps,
    required this.isModuleActive,
    this.isLoading = false,
    this.error,
  });

  DigitalDetoxState copyWith({
    List<String>? monitoredApps,
    List<String>? selectedApps,
    bool? isModuleActive,
    bool? isLoading,
    String? error,
  }) {
    return DigitalDetoxState(
      monitoredApps: monitoredApps ?? this.monitoredApps,
      selectedApps: selectedApps ?? this.selectedApps,
      isModuleActive: isModuleActive ?? this.isModuleActive,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Notifier para gerenciar o estado do módulo Digital Detox
class DigitalDetoxNotifier extends StateNotifier<DigitalDetoxState> {
  final DigitalDetoxServiceLocal _service;
  final List<String> _selectedApps = [];
  bool _isModuleActive = false;
  String? _error;

  DigitalDetoxNotifier(this._service) : super(const DigitalDetoxState(monitoredApps: [], selectedApps: [], isModuleActive: false));

  List<String> get selectedApps => _selectedApps;
  bool get isModuleActive => _isModuleActive;
  String? get error => _error;

  Future<void> _loadData(String userId) async {
    try {
      state = state.copyWith(isLoading: true);
      final isActive = await _service.isModuleActive(userId);
      final apps = await _service.getMonitoredApps(userId);
      state = DigitalDetoxState(
        monitoredApps: apps,
        selectedApps: _selectedApps,
        isModuleActive: isActive,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = DigitalDetoxState(
        monitoredApps: state.monitoredApps,
        selectedApps: _selectedApps,
        isModuleActive: state.isModuleActive,
        isLoading: false,
        error: 'Erro ao carregar dados: $e',
      );
    }
  }

  Future<void> activateModule(String userId) async {
    try {
      await _service.activateModule(userId);
      await _loadData(userId);
      _isModuleActive = true;
    } catch (e) {
      state = DigitalDetoxState(
        monitoredApps: state.monitoredApps,
        selectedApps: _selectedApps,
        isModuleActive: state.isModuleActive,
        error: 'Erro ao ativar mÃ³dulo: $e',
      );
    }
  }

  Future<void> deactivateModule(String userId) async {
    try {
      await _service.deactivateModule(userId);
      await _loadData(userId);
      _isModuleActive = false;
    } catch (e) {
      state = DigitalDetoxState(
        monitoredApps: state.monitoredApps,
        selectedApps: _selectedApps,
        isModuleActive: state.isModuleActive,
        error: 'Erro ao desativar mÃ³dulo: $e',
      );
    }
  }

  Future<void> addMonitoredApp(String userId, String appPackage) async {
    try {
      await _service.addMonitoredApp(userId, appPackage);
      await _loadData(userId);
    } catch (e) {
      state = DigitalDetoxState(
        monitoredApps: state.monitoredApps,
        selectedApps: _selectedApps,
        isModuleActive: state.isModuleActive,
        error: 'Erro ao adicionar app: $e',
      );
    }
  }

  Future<void> removeMonitoredApp(String userId, String appPackage) async {
    try {
      await _service.removeMonitoredApp(userId, appPackage);
      final apps = await _service.getMonitoredApps(userId);
      state = DigitalDetoxState(
        monitoredApps: apps,
        selectedApps: _selectedApps,
        isModuleActive: state.isModuleActive,
        error: null,
      );
    } catch (e) {
      state = DigitalDetoxState(
        monitoredApps: state.monitoredApps,
        selectedApps: _selectedApps,
        isModuleActive: state.isModuleActive,
        error: 'Erro ao remover app: $e',
      );
    }
  }

  Future<void> addCommonApps(String userId) async {
    // Implementar adiÃ§Ã£o de apps comuns
    final commonApps = [
      'com.facebook.katana',
      'com.instagram.android',
      'com.twitter.android',
      'com.whatsapp',
      'com.spotify.music',
      'com.netflix.mediaclient',
      'com.youtube.app',
      'com.reddit.frontpage',
      'com.tiktok',
    ];
    
    // Adicionar apps comuns Ã  lista monitorada
    for (final app in commonApps) {
      if (!state.monitoredApps.contains(app)) {
        await _service.addMonitoredApp(userId, app);
      }
    }
    
    // Recarregar dados apÃ³s adicionar apps
    await _loadData(userId);
  }

  void clearError() {
    state = DigitalDetoxState(
      monitoredApps: state.monitoredApps,
      selectedApps: _selectedApps,
      isModuleActive: state.isModuleActive,
      error: null,
    );
  }
}

/// Provider do notifier
final digitalDetoxNotifierProvider = StateNotifierProvider.family<DigitalDetoxNotifier, DigitalDetoxState, String>((ref, userId) {
  final service = ref.watch(digitalDetoxServiceLocalProvider);
  return DigitalDetoxNotifier(service).._loadData(userId);
});
