import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/adult_content/domain/services/adult_content_service.dart';
import 'package:disciplinum/core/di/providers.dart';

/// Controller Riverpod para Adult Content
/// Substitui ChangeNotifier por StateNotifier
class AdultContentController extends StateNotifier<AdultContentState> {
  final AdultContentService _service;
  
  AdultContentController(this._service) : super(const AdultContentState()) {
    _loadData();
  }

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true);
    try {
      final config = _service.config;
      final stats = _service.stats;
      final blockedApps = _service.blockedApps;
      
      state = state.copyWith(
        config: config,
        stats: stats,
        blockedApps: blockedApps,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> blockApp(String packageName) async {
    try {
      await _service.blockApp(packageName);
      await _loadData(); // Recarrega tudo
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> unblockApp(String packageName) async {
    try {
      await _service.unblockApp(packageName);
      await _loadData(); // Recarrega tudo
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> resetStats() async {
    try {
      await _service.resetStats();
      state = state.copyWith(stats: AdultContentStats(
        totalBlockedAttempts: 0,
        totalAccessAttempts: 0,
        totalAccessTime: Duration.zero,
      ));
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Estado do AdultContentController
class AdultContentState {
  final AdultContentConfig config;
  final AdultContentStats stats;
  final List<String> blockedApps;
  final bool isLoading;
  final String? error;

  const AdultContentState({
    this.config = const AdultContentConfig(isEnabled: false),
    this.stats = const AdultContentStats(
      totalBlockedAttempts: 0,
      totalAccessAttempts: 0,
      totalAccessTime: Duration.zero,
    ),
    this.blockedApps = const [],
    this.isLoading = false,
    this.error,
  });

  AdultContentState copyWith({
    AdultContentConfig? config,
    AdultContentStats? stats,
    List<String>? blockedApps,
    bool? isLoading,
    String? error,
  }) {
    return AdultContentState(
      config: config ?? this.config,
      stats: stats ?? this.stats,
      blockedApps: blockedApps ?? this.blockedApps,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Provider para o AdultContentController
final adultContentControllerProvider = StateNotifierProvider<AdultContentController, AdultContentState>((ref) {
  final service = ref.watch(adultContentServiceProvider);
  return AdultContentController(service);
});
