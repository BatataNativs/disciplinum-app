import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/services/focus_gamification_service.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/entities/focus_insignia.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/entities/focus_medalha.dart';
import 'package:disciplinum/features/modules/focus/gamification/presentation/controllers/focus_gamification_controller.dart';

/// Provider para o serviço de gamificação do Focus
final focusGamificationServiceProvider = Provider<FocusGamificationService>((ref) {
  final focusService = ref.watch(focusServiceProvider);
  final repository = ref.watch(focusGamificationRepositoryProvider);
  return FocusGamificationService(repository, focusService);
});

/// Provider para o controller de gamificação do Focus
final focusGamificationControllerProvider = StateNotifierProvider<FocusGamificationController, FocusGamificationState>((ref) {
  final gamificationService = ref.watch(focusGamificationServiceProvider);
  return FocusGamificationController(gamificationService);
});

/// Provider para acessar getters do controller (compatibilidade)
final focusGamificationControllerAccessProvider = Provider((ref) {
  final controller = ref.watch(focusGamificationControllerProvider.notifier);
  return controller;
});

/// Provider assíncrono para o estado inicial da gamificação
final focusGamificationStateProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final controller = ref.watch(focusGamificationControllerAccessProvider);
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

/// Provider para informações de insígnias
final focusInsigniaInfoProvider = Provider.family<Map<String, String>, String>((ref, insigniaId) {
  final controller = ref.watch(focusGamificationControllerAccessProvider);
  final insignia = controller.getInsigniaInfo(insigniaId);
  
  if (insignia == null) return {};
  
  return {
    'name': insignia.name,
    'description': insignia.description,
    'icon': insignia.icon,
  };
});

/// Provider para informações de medalhas
final focusMedalhaInfoProvider = Provider.family<Map<String, String>, String>((ref, medalhaId) {
  final controller = ref.watch(focusGamificationControllerAccessProvider);
  final medalha = controller.getMedalhaInfo(medalhaId);
  
  if (medalha == null) return {};
  
  return {
    'name': medalha.name,
    'description': medalha.description,
    'icon': medalha.icon,
  };
});

/// Provider para verificar se tem insígnia
final focusHasInsigniaProvider = Provider.family<bool, String>((ref, insigniaId) {
  final controller = ref.watch(focusGamificationControllerAccessProvider);
  return controller.hasInsignia(insigniaId);
});

/// Provider para verificar se tem medalha
final focusHasMedalhaProvider = Provider.family<bool, String>((ref, medalhaId) {
  final controller = ref.watch(focusGamificationControllerAccessProvider);
  return controller.hasMedalha(medalhaId);
});
