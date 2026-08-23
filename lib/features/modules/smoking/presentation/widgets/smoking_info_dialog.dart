import 'package:flutter/material.dart';

/// Diálogo modal moderno e sóbrio com explicações sobre o módulo Smoking
class SmokingInfoDialog extends StatelessWidget {
  const SmokingInfoDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const SmokingInfoDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header do Dialog
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.smoke_free_rounded,
                      color: Color(0xFF6366F1),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Como funciona',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Módulo Parar de Fumar',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Lista de Tópicos
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildTopicTile(
                        context,
                        icon: Icons.tune_rounded,
                        title: '1. Informações de Consumo',
                        description:
                            'Preencha o valor do maço, quantidade diária e data de parada para calcular economia e progresso.',
                      ),
                      _buildTopicTile(
                        context,
                        icon: Icons.grid_view_rounded,
                        title: '2. Barra de Ações Rápidas',
                        description:
                            'No topo da tela, gerencie Check-in, Notificações, Estatísticas e Ativação do módulo com um toque.',
                      ),
                      _buildTopicTile(
                        context,
                        icon: Icons.check_circle_outline_rounded,
                        title: '3. Check-in Diário',
                        description:
                            'Registre diariamente sua vitória ao não fumar. O check-in é fundamental para manter seu streak e foco.',
                      ),
                      _buildTopicTile(
                        context,
                        icon: Icons.notifications_active_outlined,
                        title: '4. Lembretes e Motivação',
                        description:
                            'Receba notificações em horários estratégicos com frases adaptadas ao seu tempo de superação.',
                      ),
                      _buildTopicTile(
                        context,
                        icon: Icons.insights_rounded,
                        title: '5. Estatísticas e Saúde',
                        description:
                            'Monitore o dinheiro poupado, cigarros não fumados e a evolução da recuperação do seu corpo.',
                      ),
                      _buildTopicTile(
                        context,
                        icon: Icons.emoji_events_outlined,
                        title: '6. Conquistas e Insígnias',
                        description:
                            'Desbloqueie medalhas conforme alcança marcos de dias livres do cigarro até a maestria Disciplinum.',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Botão Entendi
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Entendi',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

