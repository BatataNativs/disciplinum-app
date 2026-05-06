import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/gamification/repositories/pending_achievements_repository.dart';
import 'package:disciplinum/core/gamification/entities/pending_achievement_entity.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/shared/widgets/celebration/confetti_celebration_widget.dart';

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

    await _showCelebrationDialog(achievement);

    // Após fechar o dialog, marca como exibida e mostra o próximo
    if (mounted) {
      await PendingAchievementsRepository.instance.markAsShown(achievement.id);
      
      // Pequena pausa entre dialogs
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Mostra o próximo se houver mais na fila
      _showNextInQueue();
    }
  }

  /// Exibe o dialog de celebração
  Future<void> _showCelebrationDialog(PendingAchievementEntity achievement) async {
    if (!mounted) return;

    final context = this.context;
    final overlay = Overlay.of(context);

    // Cria um overlay entry para mostrar o dialog por cima de tudo
    final overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black54,
        child: Center(
          child: _buildCelebrationContent(achievement),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Aguarda até que o usuário feche (implementado no widget)
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Remove após interação
    await _waitForDismiss(overlayEntry);
  }

  /// Aguarda o usuário interagir com o dialog
  Future<void> _waitForDismiss(OverlayEntry entry) async {
    // O dialog ficará visível até ser removido pelo usuário clicar OK
    // O Navigator.pop no botão remove automaticamente o overlay
    await Future.delayed(const Duration(seconds: 5)); // Timeout de segurança
    if (mounted) {
      entry.remove();
    }
  }

  /// Constrói o conteúdo da celebração
  Widget _buildCelebrationContent(PendingAchievementEntity achievement) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = _getModuleColor(achievement.moduleId);

    return Container(
      margin: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Confetes animados
            Positioned.fill(
              child: ConfettiCelebrationWidget(
                child: const SizedBox.expand(),
              ),
            ),
            // Conteúdo
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ícone/Imagem da conquista
                  _buildAchievementIcon(achievement, accentColor),
                  const SizedBox(height: 20),
                  // Título
                  Text(
                    achievement.type == 'medalha' ? '🏆 Nova Medalha!' : '⭐ Nova Conquista!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Nome da conquista
                  Text(
                    achievement.achievementName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Descrição
                  if (achievement.achievementDescription != null)
                    Text(
                      achievement.achievementDescription!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  const SizedBox(height: 24),
                  // Botão OK
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      onPressed: () {
                        // Fecha o overlay atual
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Incrível! 🎉',
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
          ],
        ),
      ),
    );
  }

  /// Constrói o ícone da conquista
  Widget _buildAchievementIcon(PendingAchievementEntity achievement, Color accentColor) {
    if (achievement.assetPath != null && achievement.assetPath!.isNotEmpty) {
      // Tenta carregar imagem
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accentColor.withValues(alpha: 0.2),
          border: Border.all(
            color: accentColor,
            width: 3,
          ),
        ),
        child: ClipOval(
          child: Image.asset(
            achievement.assetPath!,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFallbackIcon(achievement, accentColor),
          ),
        ),
      );
    }
    
    return _buildFallbackIcon(achievement, accentColor);
  }

  /// Ícone fallback quando não há imagem
  Widget _buildFallbackIcon(PendingAchievementEntity achievement, Color accentColor) {
    final icon = achievement.type == 'medalha' ? Icons.emoji_events : Icons.stars;
    
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accentColor.withValues(alpha: 0.2),
        border: Border.all(
          color: accentColor,
          width: 3,
        ),
      ),
      child: Icon(
        icon,
        size: 50,
        color: accentColor,
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
      'adultContent': const Color(0xFF8B5CF6),
      'moneySavingChallenge': const Color(0xFF10B981),
      'money_saving': const Color(0xFF10B981),
      'procrastination': const Color(0xFF3B82F6),
      'reading': const Color(0xFFF97316),
      'bingeEating': const Color(0xFFEC4899),
      'binge_eating': const Color(0xFFEC4899),
    };
    
    return colors[moduleId.toLowerCase()] ?? const Color(0xFF6366F1);
  }
}

/// Função pública para forçar verificação de conquistas
/// 
/// Pode ser chamada de qualquer lugar do app para verificar
/// se há conquistas pendentes e mostrar os dialogs
void checkPendingAchievementsGlobal(WidgetRef ref) {
  ref.read(forceAchievementCheckProvider.notifier).state++;
}
