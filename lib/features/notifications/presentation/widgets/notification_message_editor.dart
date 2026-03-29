import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/features/gamification/domain/services/gamification_messages.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/infrastructure/ads/ad_service.dart';
import 'package:disciplinum/core/utils/enhanced_snackbar_helper.dart';

class NotificationMessageEditor extends ConsumerWidget {
  final NicheId nicheId;

  const NotificationMessageEditor({super.key, required this.nicheId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iap = ref.watch(iapServiceProvider);
    final gamificationState = ref.watch(gamificationServiceProvider);
    final gamificationNotifier = ref.read(gamificationServiceProvider.notifier);
    final adService = ref.read(adServiceProvider.notifier);
    final currentMsg = GamificationMessages.getModuleMessage(
      nicheId,
      isUnlocked: iap.isCustomNotifUnlocked ||
          gamificationNotifier.isNotificationUnlocked(nicheId),
      customMessages: gamificationState.customMessages,
    );

    // Verifica se tem iap global OU se liberou esse módulo nas prefs locais
    final bool hasAccess = iap.isCustomNotifUnlocked ||
        gamificationNotifier.isNotificationUnlocked(nicheId);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF171717), // Anthracite
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Texto da notificação do módulo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              if (!hasAccess)
                const Icon(Icons.lock_outline, size: 16, color: Colors.white),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currentMsg,
            style: const TextStyle(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                if (hasAccess) {
                  _openEditMessageDialog(context, ref, gamificationState, gamificationNotifier);
                } else {
                  _showPremiumFeatureDialog(context, gamificationNotifier, adService);
                }
              },
              label: Text(
                hasAccess ? 'Editar Mensagem' : 'Personalizar 🔓',
                style: const TextStyle(color: Colors.white),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPremiumFeatureDialog(BuildContext context,
      GamificationService gamification, AdService adService) {
    // Tenta pré-carregar o vídeo nos bastidores caso ainda não tenha sido
    adService.loadRewardedAd();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Desbloquear Personalização'),
        content: const Text(
          'Você pode assistir a um rápido vídeo para liberar a personalização DESTE módulo, '
          'ou conhecer nossa Lojinha para adquirir as Notificações Personalizáveis e liberar TODOS de uma vez.',
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Voltar'),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow, size: 18),
                onPressed: () {
                  Navigator.pop(ctx);
                  _handleAdUnlock(context, gamification, adService);
                },
                label: const Text('Assistir Vídeo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.diamond_outlined, size: 18),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, '/lojinha');
                },
                label: const Text('Ir para Lojinha'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleAdUnlock(BuildContext context, GamificationService gamification,
      AdService adService) {
    // Se quiser você pode mostrar um loading aqui (ex: CircularProgressIndicator)
    EnhancedSnackBarHelper.showInfo(context, 'Carregando anúncio...');

    adService.showRewardedAd(
      onUserEarnedReward: () {
        gamification.unlockNotification(nicheId);
        if (context.mounted) {
          EnhancedSnackBarHelper.showSuccess(
              context, 'Personalização desbloqueada! 🎉');
        }
      },
      onAdDismissed: () {
        // Nada de extra precisa ser feito ao fechar o ad sem recompensa,
        // mas você poderia avisar 'Vídeo fechado antes do fim' se quiser.
      },
    );
  }

  void _openEditMessageDialog(
      BuildContext context, WidgetRef ref, GamificationState gamificationState, GamificationService gamificationNotifier) {
    final iap = ref.read(iapServiceProvider);
    final controller = TextEditingController(
        text: GamificationMessages.getModuleMessage(
      nicheId,
      isUnlocked: iap.isCustomNotifUnlocked ||
          gamificationNotifier.isNotificationUnlocked(nicheId),
      customMessages: gamificationState.customMessages,
    ));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Mensagem'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Digite sua mensagem personalizada...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                gamificationNotifier.setCustomMessage(nicheId, controller.text);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  EnhancedSnackBarHelper.showSuccess(context, 'Mensagem atualizada!');
                }
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
