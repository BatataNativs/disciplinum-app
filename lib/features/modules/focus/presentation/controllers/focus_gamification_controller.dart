import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/services/focus_gamification_service.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/entities/focus_insignia.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/entities/focus_medalha.dart';
import 'package:disciplinum/features/modules/focus/gamification/presentation/providers/focus_gamification_provider.dart';

/// Controller Riverpod para gamificação do Focus
/// Substitui ChangeNotifier por StateNotifier
class FocusGamificationController extends StateNotifier<FocusGamificationState> {
  final FocusGamificationService _service;
  
  FocusGamificationController(this._service) : super(const FocusGamificationState()) {
    _loadData();
  }

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true);
    try {
      final currentInsignia = _service.currentInsignia != null 
          ? FocusInsigniaEntity.values.firstWhere((e) => e.name == _service.currentInsignia!.name)
          : null;
      final earnedInsignias = _service.earnedInsignias.map((i) => 
          FocusInsigniaEntity.values.firstWhere((e) => e.name == i.name)).toList();
      final currentMedal = _service.currentMedal;
      final earnedMedals = _service.earnedMedals;
      final respectedPeriods = _service.respectedPeriods;
      
      state = state.copyWith(
        currentInsignia: currentInsignia,
        earnedInsignias: earnedInsignias,
        currentMedal: currentMedal,
        earnedMedals: earnedMedals,
        respectedPeriods: respectedPeriods,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> checkInsigniaProgress() async {
    try {
      await _service.checkInsigniaProgress();
      await _loadData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> checkMedalProgress() async {
    try {
      await _service.checkMedalProgress();
      await _loadData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> resetProgress() async {
    try {
      await _service.resetProgress();
      await _loadData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Estado do FocusGamificationController
class FocusGamificationState {
  final FocusInsigniaEntity? currentInsignia;
  final List<FocusInsigniaEntity> earnedInsignias;
  final FocusMedalha? currentMedal;
  final List<FocusMedalha> earnedMedals;
  final int respectedPeriods;
  final bool isLoading;
  final String? error;

  const FocusGamificationState({
    this.currentInsignia,
    this.earnedInsignias = const [],
    this.currentMedal,
    this.earnedMedals = const [],
    this.respectedPeriods = 0,
    this.isLoading = false,
    this.error,
  });

  FocusGamificationState copyWith({
    FocusInsigniaEntity? currentInsignia,
    List<FocusInsigniaEntity>? earnedInsignias,
    FocusMedalha? currentMedal,
    List<FocusMedalha>? earnedMedals,
    int? respectedPeriods,
    bool? isLoading,
    String? error,
  }) {
    return FocusGamificationState(
      currentInsignia: currentInsignia ?? this.currentInsignia,
      earnedInsignias: earnedInsignias ?? this.earnedInsignias,
      currentMedal: currentMedal ?? this.currentMedal,
      earnedMedals: earnedMedals ?? this.earnedMedals,
      respectedPeriods: respectedPeriods ?? this.respectedPeriods,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Calcula estatísticas derivadas
  int get totalInsignias => earnedInsignias.length;
  int get totalMedals => earnedMedals.length;
  
  double get insigniaProgress {
    if (currentInsignia == null) return 0.0;
    return currentInsignia?.progressPercentage ?? 0.0;
  }

  bool hasInsignia(FocusInsigniaEntity insignia) {
    return earnedInsignias.contains(insignia);
  }

  bool hasMedal(FocusMedalha medal) {
    return earnedMedals.contains(medal);
  }
}

/// Provider para o FocusGamificationController
final focusGamificationControllerProvider = StateNotifierProvider<FocusGamificationController, FocusGamificationState>((ref) {
  final service = ref.watch(focusGamificationServiceProvider);
  return FocusGamificationController(service);
});
