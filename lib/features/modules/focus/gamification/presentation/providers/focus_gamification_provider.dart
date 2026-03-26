import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/services/focus_gamification_service.dart';
import 'package:disciplinum/features/modules/focus/gamification/presentation/controllers/focus_gamification_controller.dart';

/// Provider para o serviço de gamificação do Focus
final focusGamificationServiceProvider = Provider<FocusGamificationService>((ref) {
  final focusService = ref.watch(focusServiceProvider);
  return FocusGamificationService(focusService);
});

/// Provider para o controller de gamificação do Focus
final focusGamificationControllerProvider = ChangeNotifierProvider<FocusGamificationController>((ref) {
  final gamificationService = ref.watch(focusGamificationServiceProvider);
  return FocusGamificationController(gamificationService);
});

/// Provider assíncrono para o estado inicial da gamificação
final focusGamificationStateProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final controller = ref.watch(focusGamificationControllerProvider);
  await controller.refresh();
  
  return {
    'insignias': controller.earnedInsignias,
    'medalhas': controller.earnedMedalhas,
    'respectedPeriods': controller.respectedPeriods,
    'progressPercentage': controller.progressPercentage,
    'nextInsignia': controller.nextInsignia,
    'disciplinumCount': controller.disciplinumCount,
    'canAwardDisciplinum': controller.canAwardDisciplinum,
  };
});

/// Provider para informações específicas de insígnias
final focusInsigniaInfoProvider = Provider.family<Map<String, String>, String>((ref, insigniaId) {
  final controller = ref.watch(focusGamificationControllerProvider);
  return controller.getInsigniaInfo(insigniaId);
});

/// Provider para informações específicas de medalhas
final focusMedalhaInfoProvider = Provider.family<Map<String, String>, String>((ref, medalhaId) {
  final controller = ref.watch(focusGamificationControllerProvider);
  return controller.getMedalhaInfo(medalhaId);
});

/// Provider para verificar se tem insígnia específica
final focusHasInsigniaProvider = Provider.family<bool, String>((ref, insigniaId) {
  final controller = ref.watch(focusGamificationControllerProvider);
  return controller.hasInsignia(insigniaId);
});

/// Provider para verificar se tem medalha específica
final focusHasMedalhaProvider = Provider.family<bool, String>((ref, medalhaId) {
  final controller = ref.watch(focusGamificationControllerProvider);
  return controller.hasMedalha(medalhaId);
});
