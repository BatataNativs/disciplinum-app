import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/infrastructure/cloud/cloud_sync_service.dart';
import 'package:disciplinum/core/di/providers.dart';

/// Estado de gamificação para um módulo específico
class ModuleGamificationState {
  final bool isActive;
  final int consecutiveDays;
  final DateTime? lastCheckIn;
  final Map<String, dynamic> additionalData;

  const ModuleGamificationState({
    this.isActive = false,
    this.consecutiveDays = 0,
    this.lastCheckIn,
    this.additionalData = const {},
  });

  ModuleGamificationState copyWith({
    bool? isActive,
    int? consecutiveDays,
    DateTime? lastCheckIn,
    Map<String, dynamic>? additionalData,
  }) {
    return ModuleGamificationState(
      isActive: isActive ?? this.isActive,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}

/// Notifier para gerenciar estado de gamificação de um módulo
class ModuleGamificationNotifier extends StateNotifier<ModuleGamificationState> {
  final NicheId _nicheId;
  final CloudSyncService _cloudSync;
  bool _isInitialized = false;

  ModuleGamificationNotifier(this._nicheId, this._cloudSync) 
    : super(const ModuleGamificationState()) {
    // Carregar estado automaticamente ao criar
    _initialize();
  }

  /// Inicialização automática
  Future<void> _initialize() async {
    if (!_isInitialized) {
      await loadState();
      _isInitialized = true;
    }
  }

  /// Carrega o estado inicial
  Future<void> loadState() async {
    try {
      final moduleStatus = await _cloudSync.loadModuleStatus(_nicheId);
      
      state = state.copyWith(
        isActive: moduleStatus?.isActive ?? false,
        consecutiveDays: moduleStatus?.consecutiveDays ?? 0,
      );
    } catch (e) {
      state = state.copyWith(isActive: false);
    }
  }

  /// Atualiza status ativo
  void setActive(bool value) {
    state = state.copyWith(isActive: value);
  }

  /// Atualiza dias consecutivos
  void setConsecutiveDays(int days) {
    state = state.copyWith(consecutiveDays: days);
  }

  /// Incrementa dias consecutivos
  void incrementConsecutiveDays() {
    state = state.copyWith(consecutiveDays: state.consecutiveDays + 1);
  }

  /// Reseta dias consecutivos
  void resetConsecutiveDays() {
    state = state.copyWith(consecutiveDays: 0);
  }
}

/// Provider factory para criar providers de gamificação específicos por módulo
final moduleGamificationProvider = StateNotifierProvider
    .family<ModuleGamificationNotifier, ModuleGamificationState, NicheId>(
  (ref, nicheId) {
    final cloudSync = ref.watch(cloudSyncServiceProvider);
    return ModuleGamificationNotifier(nicheId, cloudSync);
  },
);
