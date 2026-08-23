import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Barra superior moderna e padronizada com 4 ações rápidas para o módulo Smoking
class SmokingTopActionBar extends StatelessWidget {
  final bool isModuleActive;
  final VoidCallback onOpenCheckIn;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenStatistics;
  final VoidCallback onToggleModule;

  const SmokingTopActionBar({
    super.key,
    required this.isModuleActive,
    required this.onOpenCheckIn,
    required this.onOpenNotifications,
    required this.onOpenStatistics,
    required this.onToggleModule,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          // 1. Check-in
          Expanded(
            child: _buildActionItem(
              context,
              icon: Icons.check_circle_outline_rounded,
              label: 'Check-in',
              onTap: onOpenCheckIn,
            ),
          ),
          const SizedBox(width: 4),

          // 2. Lembretes/Notificações
          Expanded(
            child: _buildActionItem(
              context,
              icon: Icons.notifications_none_rounded,
              label: 'Lembretes',
              onTap: onOpenNotifications,
            ),
          ),
          const SizedBox(width: 4),

          // 3. Estatísticas
          Expanded(
            child: _buildActionItem(
              context,
              icon: Icons.insights_rounded,
              label: 'Estatísticas',
              onTap: onOpenStatistics,
            ),
          ),
          const SizedBox(width: 4),

          // 4. Ativar / Desativar
          Expanded(
            child: _buildActionItem(
              context,
              icon: Icons.power_settings_new_rounded,
              label: isModuleActive ? 'Ativo' : 'Ativar',
              isActiveStatus: isModuleActive,
              onTap: onToggleModule,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActiveStatus = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    final Color itemColor = isActiveStatus
        ? const Color(0xFF10B981) // Verde esmeralda moderno para status ativo
        : colorScheme.onSurface.withValues(alpha: 0.85);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(11),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isActiveStatus
                ? const Color(0xFF10B981).withValues(alpha: 0.12)
                : colorScheme.surface.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: isActiveStatus
                  ? const Color(0xFF10B981).withValues(alpha: 0.3)
                  : colorScheme.outline.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: itemColor,
                  ),
                  if (isActiveStatus)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: itemColor,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

