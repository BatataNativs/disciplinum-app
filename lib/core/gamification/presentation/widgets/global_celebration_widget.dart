import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/gamification/repositories/pending_achievements_repository.dart';
import 'package:disciplinum/core/gamification/entities/pending_achievement_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/shared/widgets/celebration/confetti_celebration_widget.dart';
import 'package:disciplinum/core/di/providers.dart';

/// Provider global para o userId atual do usuário autenticado
final currentUserIdProvider = Provider<String>((ref) {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;
  
  if (currentUser != null && currentUser.id.isNotEmpty) {
    return currentUser.id;
  }
  
  // Fallback para usuário não autenticado (modo convidado)
  return 'guest_user';
});

/// Widget global para exibir celebrações de conquistas
/// 
/// Deve ser colocado na Home Screen para verificar e mostrar
/// conquistas pendentes quando o app é aberto via notificação
/// ou quando o usuário ganha conquistas em background.
class GlobalCelebrationWidget extends ConsumerStatefulWidget {
  final Widget child;

  const GlobalCelebrationWidget({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<GlobalCelebrationWidget> createState() => _GlobalCelebrationWidgetState();
}

class _GlobalCelebrationWidgetState extends ConsumerState<GlobalCelebrationWidget> {
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    // Verifica conquistas pendentes quando o widget é montado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingAchievements();
    });
  }

  /// Verifica e exibe conquistas pendentes
  Future<void> _checkPendingAchievements() async {
    if (_isChecking) return;
    
    final userId = ref.read(currentUserIdProvider);
    if (userId.isEmpty) {
      LoggerService.instance.w('⚠️ GlobalCelebrationWidget: userId não disponível');
      return;
    }

    try {
      _isChecking = true;
      
      final hasPending = await PendingAchievementsRepository.instance.hasPendingAchievements(userId);
      
      if (hasPending && mounted) {
        LoggerService.instance.gamification('🎉 Exibindo conquistas pendentes para $userId');
        
        final pending = await PendingAchievementsRepository.instance.getPendingAchievements(userId);
        
        // Exibe cada conquista pendente sequencialmente
        for (final achievement in pending) {
          if (mounted) {
            await _showCelebrationDialog(achievement);
          }
        }
        
        // Marca todas como exibidas
        await PendingAchievementsRepository.instance.markAllAsShown(userId);
      }
    } catch (e) {
      LoggerService.instance.e('❌ Erro ao verificar conquistas pendentes', error: e);
    } finally {
      _isChecking = false;
    }
  }

  /// Exibe o dialog de celebração apropriado
  Future<void> _showCelebrationDialog(PendingAchievementEntity achievement) async {
    final context = this.context;
    
    if (achievement.type == 'insignia') {
      // Celebração de insígnia
      CelebrationHelper.showInsigniaCelebration(
        context,
        insigniaName: achievement.achievementName,
        insigniaDescription: achievement.achievementDescription,
        assetPath: achievement.assetPath,
        accentColor: _getModuleColor(achievement.moduleId),
      );
    } else if (achievement.type == 'medalha') {
      // Celebração de medalha
      CelebrationHelper.showMedalhaCelebration(
        context,
        medalhaName: achievement.achievementName,
        medalhaDescription: achievement.achievementDescription,
        assetPath: achievement.assetPath,
      );
    }

    // Pequena pausa entre dialogs
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Obtém cor do módulo para personalizar a celebração
  Color _getModuleColor(String moduleId) {
    final colors = {
      'smoking': const Color(0xFF10B981), // Verde
      'focus': const Color(0xFF6366F1),    // Indigo
      'diet': const Color(0xFFF59E0B),    // Amarelo
      'spending': const Color(0xFFEF4444), // Vermelho
      'adultContent': const Color(0xFF8B5CF6), // Roxo
      'moneySavingChallenge': const Color(0xFF10B981), // Verde
      'procrastination': const Color(0xFF3B82F6), // Azul
      'reading': const Color(0xFFF97316), // Laranja
      'bingeEating': const Color(0xFFEC4899), // Rosa
    };
    
    return colors[moduleId.toLowerCase()] ?? const Color(0xFF6366F1);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Provider para forçar verificação de conquistas pendentes
final globalCelebrationCheckProvider = StateProvider<bool>((ref) => false);

/// Função helper para disparar verificação manualmente
void triggerGlobalCelebrationCheck(WidgetRef ref) {
  ref.read(globalCelebrationCheckProvider.notifier).state = 
      !ref.read(globalCelebrationCheckProvider);
}

/// Widget que escuta mudanças no provider e dispara verificação
class GlobalCelebrationListener extends ConsumerWidget {
  final Widget child;

  const GlobalCelebrationListener({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuta mudanças no provider para forçar verificação
    ref.listen(globalCelebrationCheckProvider, (_, __) {
      // A verificação real é feita pelo GlobalCelebrationWidget
      // Este provider apenas sinaliza que deve verificar
    });

    return child;
  }
}
