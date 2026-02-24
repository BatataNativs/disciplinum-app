import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/services/iap/iap_service.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/widgets/profile/lojinha.dart';
import 'package:disciplinum/services/ads/ad_service.dart';

class NotificationMessageEditor extends StatelessWidget {
  final NicheId nicheId;

  const NotificationMessageEditor({super.key, required this.nicheId});

  @override
  Widget build(BuildContext context) {
    final iap = Provider.of<IapService>(context);
    final gamification = Provider.of<GamificationService>(context);
    final adService = Provider.of<AdService>(context, listen: false);
    final currentMsg = getModuleMessage(nicheId);

    // Verifica se tem iap global OU se liberou esse módulo nas prefs locais
    final bool hasAccess = iap.isCustomNotifUnlocked ||
        gamification.isNotificationUnlocked(nicheId);

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
                  _openEditMessageDialog(context, gamification);
                } else {
                  _showPremiumFeatureDialog(context, gamification, adService);
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
                  showDialog(
                    context: context,
                    builder: (_) => const Lojinha(),
                  );
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Carregando anúncio...')),
    );

    adService.showRewardedAd(
      onUserEarnedReward: () {
        gamification.unlockNotification(nicheId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Personalização desbloqueada! 🎉')),
          );
        }
      },
      onAdDismissed: () {
        // Nada de extra precisa ser feito ao fechar o ad sem recompensa,
        // mas você poderia avisar 'Vídeo fechado antes do fim' se quiser.
      },
    );
  }

  void _openEditMessageDialog(
      BuildContext context, GamificationService gamification) {
    final controller = TextEditingController(text: getModuleMessage(nicheId));
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
                await gamification.setCustomMessage(nicheId, controller.text);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mensagem atualizada!')),
                  );
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
