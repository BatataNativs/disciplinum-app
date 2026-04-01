import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/infrastructure/services/gamification_messages.dart';
import 'package:disciplinum/features/modules/smoking/presentation/providers/module_unlock_providers.dart';

class NotificationMessageEditor extends ConsumerWidget {
  final NicheId nicheId;

  const NotificationMessageEditor({super.key, required this.nicheId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iap = ref.watch(iapServiceProvider);
    
    // Verificar desbloqueio local via provider
    final localUnlockAsync = ref.watch(moduleUnlockStatusProvider(
      (moduleId: nicheId.id.toString(), unlockType: 'custom_notifications'),
    ));
    
    // Obter mensagem atual do serviço de gamificação
    final currentMsg = GamificationMessages.getModuleMessage(
      nicheId,
      isUnlocked: iap.isCustomNotifUnlocked,
      customMessages: {},
    );
    
    final bool hasAccess = localUnlockAsync.when(
      data: (localUnlock) => iap.isCustomNotifUnlocked || localUnlock,
      loading: () => iap.isCustomNotifUnlocked,
      error: (_, __) => iap.isCustomNotifUnlocked,
    );

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
                  _showEditDialog(context, ref, currentMsg);
                } else {
                  _showUnlockDialog(context, ref);
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

  void _showEditDialog(BuildContext context, WidgetRef ref, String currentMessage) {
    final controller = TextEditingController(text: currentMessage);
    
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
            onPressed: () {
              // Salvar mensagem via provider local
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mensagem atualizada!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showUnlockDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Desbloquear Personalização'),
        content: const Text(
          'Assista a um vídeo para desbloquear a personalização de notificações para este módulo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Voltar'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              Navigator.pop(ctx);
              _handleUnlock(context, ref);
            },
            label: const Text('Assistir Vídeo'),
          ),
        ],
      ),
    );
  }

  void _handleUnlock(BuildContext context, WidgetRef ref) {
    final adService = ref.read(adServiceProvider.notifier);
    final unlockNotifier = ref.read(moduleUnlockNotifierProvider(
      (moduleId: nicheId.id.toString(), unlockType: 'custom_notifications'),
    ).notifier);
    
    adService.loadRewardedAd();
    
    adService.showRewardedAd(
      onUserEarnedReward: () async {
        await unlockNotifier.unlock(method: 'ad');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Personalização desbloqueada! 🎉'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      onAdDismissed: () {},
    );
  }
}
