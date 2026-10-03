import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:disciplinum/core/gamification/repositories/pending_achievements_repository.dart';
import 'package:disciplinum/core/gamification/entities/pending_achievement_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/features/app_lock/infrastructure/services/navigation_service.dart';

/// Provider para stream de conquistas pendentes
/// 
/// Este provider notifica quando há novas conquistas pendentes
/// em qualquer parte do app, não só na Home Screen
final pendingAchievementsStreamProvider = StreamProvider<List<PendingAchievementEntity>>((ref) async* {
  final authService = ref.watch(authServiceProvider);
  final userId = authService.currentUser?.id ?? 'guest_user';
  
  // Verifica a cada 2 segundos se há conquistas pendentes
  await for (final _ in Stream.periodic(const Duration(seconds: 2))) {
    final pending = await PendingAchievementsRepository.instance.getPendingAchievements(userId);
    yield pending;
  }
});

/// Provider para forçar verificação manual de conquistas
final forceAchievementCheckProvider = StateProvider<int>((ref) => 0);

/// Widget global que escuta conquistas pendentes em QUALQUER tela
/// 
/// Deve ser colocado no topo da árvore de widgets, envolvendo o MaterialApp
/// para garantir que dialogs de conquista apareçam imediatamente em qualquer
/// tela do app, não só na Home Screen
class GlobalAchievementListener extends ConsumerStatefulWidget {
  final Widget child;

  const GlobalAchievementListener({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<GlobalAchievementListener> createState() => _GlobalAchievementListenerState();
}

class _GlobalAchievementListenerState extends ConsumerState<GlobalAchievementListener> {
  bool _isShowing = false;
  final List<PendingAchievementEntity> _queue = [];

  @override
  void initState() {
    super.initState();
    // Verifica conquistas pendentes ao iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingAchievements();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Escuta o provider de stream para detectar novas conquistas
    ref.listen(pendingAchievementsStreamProvider, (previous, next) {
      next.whenData((achievements) {
        if (achievements.isNotEmpty && mounted) {
          _handleNewAchievements(achievements);
        }
      });
    });

    // Também escuta o provider de forçar verificação
    ref.listen(forceAchievementCheckProvider, (_, __) {
      _checkPendingAchievements();
    });

    return widget.child;
  }

  /// Verifica e processa conquistas pendentes
  Future<void> _checkPendingAchievements() async {
    final authService = ref.read(authServiceProvider);
    final userId = authService.currentUser?.id ?? 'guest_user';

    try {
      final pending = await PendingAchievementsRepository.instance.getPendingAchievements(userId);
      
      if (pending.isNotEmpty && mounted) {
        _handleNewAchievements(pending);
      }
    } catch (e) {
      LoggerService.instance.e('❌ Erro ao verificar conquistas pendentes', error: e);
    }
  }

  /// Processa novas conquistas, adicionando à fila e mostrando sequencialmente
  void _handleNewAchievements(List<PendingAchievementEntity> achievements) {
    // Filtra apenas as que ainda não estão na fila
    final newAchievements = achievements.where((a) => 
      !_queue.any((q) => q.achievementId == a.achievementId)
    ).toList();

    if (newAchievements.isNotEmpty) {
      LoggerService.instance.gamification(
        '🎉 ${newAchievements.length} nova(s) conquista(s) detectada(s) globalmente'
      );
      
      _queue.addAll(newAchievements);
      
      // Se não estiver mostrando nada, inicia a sequência
      if (!_isShowing) {
        _showNextInQueue();
      }
    }
  }

  /// Mostra o próximo dialog na fila
  Future<void> _showNextInQueue() async {
    if (_queue.isEmpty || !mounted) {
      _isShowing = false;
      return;
    }

    _isShowing = true;
    final achievement = _queue.removeAt(0);

    try {
      await _showCelebrationDialog(achievement);
    } catch (e) {
      LoggerService.instance.e('❌ Erro ao exibir dialog de celebração', error: e);
    }

    // Após fechar o dialog, marca como exibida e mostra o próximo
    if (mounted) {
      await PendingAchievementsRepository.instance.markAsShown(achievement.id);
      
      // Pequena pausa entre dialogs
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Mostra o próximo se houver mais na fila
      _showNextInQueue();
    }
  }

  /// Exibe o dialog de celebração via showDialog limpo e sem vazamentos
  Future<void> _showCelebrationDialog(PendingAchievementEntity achievement) async {
    final navContext = AppLockNavigationService.currentContext ?? (mounted ? context : null);
    if (navContext == null) return;

    await showDialog<void>(
      context: navContext,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: _CelebrationDialogContent(
          achievement: achievement,
          accentColor: _getModuleColor(achievement.moduleId),
          onClose: () => Navigator.of(dialogContext).pop(),
        ),
      ),
    );
  }

  /// Obtém cor do módulo
  Color _getModuleColor(String moduleId) {
    final colors = {
      'smoking': const Color(0xFF10B981),
      'focus': const Color(0xFF6366F1),
      'diet': const Color(0xFFF59E0B),
      'spending': const Color(0xFFEF4444),
      'adultcontent': const Color(0xFF8B5CF6),
      'adult_content': const Color(0xFF8B5CF6),
      'moneysavingchallenge': const Color(0xFF10B981),
      'money_saving': const Color(0xFF10B981),
      'procrastination': const Color(0xFF3B82F6),
      'reading': const Color(0xFFF97316),
      'bingeeating': const Color(0xFFEC4899),
      'binge_eating': const Color(0xFFEC4899),
      'digitaldetox': const Color(0xFF06B6D4),
      'digital_detox': const Color(0xFF06B6D4),
    };
    
    return colors[moduleId.toLowerCase()] ?? const Color(0xFF6366F1);
  }
}

/// Conteúdo do dialog de celebração com confetes e feedback tátil
class _CelebrationDialogContent extends StatefulWidget {
  final PendingAchievementEntity achievement;
  final Color accentColor;
  final VoidCallback onClose;

  const _CelebrationDialogContent({
    required this.achievement,
    required this.accentColor,
    required this.onClose,
  });

  @override
  State<_CelebrationDialogContent> createState() => _CelebrationDialogContentState();
}

class _CelebrationDialogContentState extends State<_CelebrationDialogContent> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _confettiController.play();
        HapticFeedback.heavyImpact();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.accentColor.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAchievementIcon(widget.achievement, widget.accentColor),
                const SizedBox(height: 20),
                Text(
                  widget.achievement.type == 'medalha' ? '🏆 Nova Medalha!' : 'Nova Conquista!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _formatItemName(widget.achievement.achievementName, widget.achievement.type),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: widget.accentColor,
                  ),
                ),
                if (widget.achievement.achievementDescription != null &&
                    widget.achievement.achievementDescription!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    _formatRequirement(widget.achievement.achievementDescription!),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.75),
                      height: 1.3,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    onPressed: widget.onClose,
                    child: const Text(
                      'Ok 🎉',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Confetes no topo do dialog
        Positioned(
          top: 0,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
              Colors.yellow,
              Colors.cyan,
              Colors.amber,
            ],
          ),
        ),
      ],
    );
  }

  String _formatItemName(String name, String type) {
    final cleanName = name.trim();
    if (type.toLowerCase() == 'medalha') {
      if (cleanName.toLowerCase().startsWith('medalha:')) return cleanName;
      return 'Medalha: $cleanName';
    } else {
      if (cleanName.toLowerCase().startsWith('insígnia:') ||
          cleanName.toLowerCase().startsWith('insignia:')) {
        return cleanName;
      }
      return 'Insígnia: $cleanName';
    }
  }

  String _formatRequirement(String description) {
    var desc = description.trim();
    if (desc.toLowerCase().startsWith('requisito:')) {
      desc = desc.substring('requisito:'.length).trim();
    }
    final conversions = {
      'Ative ': 'Ativar ',
      'Pague ': 'Pagar ',
      'Conclua ': 'Concluir ',
      'Complete ': 'Completar ',
      'Alcance ': 'Alcançar ',
      'Fique ': 'Ficar ',
      'Leia ': 'Ler ',
      'Economize ': 'Economizar ',
      'Mantenha ': 'Manter ',
      'Registre ': 'Registrar ',
      'Evite ': 'Evitar ',
      'Bloqueie ': 'Bloquear ',
      'Desafie ': 'Desafiar ',
    };
    for (final entry in conversions.entries) {
      if (desc.startsWith(entry.key)) {
        desc = '${entry.value}${desc.substring(entry.key.length)}';
        break;
      }
    }
    return 'Requisito: $desc';
  }

  Widget _buildAchievementIcon(PendingAchievementEntity achievement, Color accentColor) {
    if (achievement.assetPath != null && achievement.assetPath!.isNotEmpty) {
      return SizedBox(
        width: 100,
        height: 100,
        child: Image.asset(
          achievement.assetPath!,
          width: 100,
          height: 100,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildFallbackIcon(achievement, accentColor),
        ),
      );
    }
    
    return _buildFallbackIcon(achievement, accentColor);
  }

  Widget _buildFallbackIcon(PendingAchievementEntity achievement, Color accentColor) {
    final icon = achievement.type == 'medalha' ? Icons.emoji_events : Icons.military_tech;
    
    return SizedBox(
      width: 100,
      height: 100,
      child: Icon(
        icon,
        size: 72,
        color: accentColor,
      ),
    );
  }
}

/// Função pública para forçar verificação de conquistas
/// 
/// Pode ser chamada de qualquer lugar do app para verificar
/// se há conquistas pendentes e mostrar os dialogs
void checkPendingAchievementsGlobal(WidgetRef ref) {
  ref.read(forceAchievementCheckProvider.notifier).state++;
}
