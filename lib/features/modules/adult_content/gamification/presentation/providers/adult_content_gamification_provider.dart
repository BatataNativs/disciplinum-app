import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/adult_content/gamification/domain/repositories/adult_content_gamification_repository.dart';
import 'package:disciplinum/features/modules/adult_content/presentation/notifiers/adult_content_gamification_notifier.dart';

/// Re-export do provider do notifier (plugin architecture)
export 'package:disciplinum/features/modules/adult_content/presentation/notifiers/adult_content_gamification_notifier.dart'
    show
        adultContentGamificationNotifierProvider,
        adultContentGamificationStateProvider,
        AdultContentGamificationNotifier,
        AdultContentGamificationState;

/// Provider legado para controller - redireciona para notifier
@Deprecated('Use adultContentGamificationNotifierProvider em vez deste')
final adultContentGamificationControllerProvider = StateNotifierProvider<AdultContentGamificationNotifier, AdultContentGamificationState>((ref) {
  final repository = AdultContentGamificationRepository.instance;
  return AdultContentGamificationNotifier(repository);
});

/// Provider para o repositório de gamificação do Adult Content
final adultContentGamificationRepositoryProvider = Provider<AdultContentGamificationRepository>((ref) {
  return AdultContentGamificationRepository.instance;
});

/// Provider para o streak do Adult Content
final adultContentStreakProvider = Provider<int>((ref) {
  final state = ref.watch(adultContentGamificationNotifierProvider);
  return state.currentStreak;
});

/// Provider para verificar se o módulo está ativo
final adultContentActiveProvider = Provider<bool>((ref) {
  final state = ref.watch(adultContentGamificationNotifierProvider);
  return state.isModuleActive;
});
