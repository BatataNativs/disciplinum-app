import 'package:flutter/material.dart';
import 'package:disciplinum/shared/widgets/cards/niche_info_card.dart';
import 'package:disciplinum/core/utils/app_info_helper.dart';

/// Widget de conteúdo das abas
class BingeEatingTabContent extends StatelessWidget {
  final int tabIndex;
  final List<String> selectedApps;
  final Future<List<AppDisplayInfo>> Function(List<String>) onGetAppInfo;
  final Function(String) onRemoveApp;

  const BingeEatingTabContent({
    super.key,
    required this.tabIndex,
    required this.selectedApps,
    required this.onGetAppInfo,
    required this.onRemoveApp,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    switch (tabIndex) {
      case 0:
        // 0: Compulsão alimentar (módulo)
        return _buildCompulsionContent(context, isDark);
      case 1:
        // 1: Como funciona
        return _buildHowItWorksContent(isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHowItWorksContent(bool isDark) {
    return Column(
      children: [
        NicheInfoCard(
          isDark: isDark,
          icon: Icons.settings_outlined,
          title: "Em Selecionar apps, escolha os aplicativos de delivery",
          content: "Selecione os apps de delivery que você deseja monitorar. Após selecionar, ative o módulo para começar o monitoramento.",
        ),
        const SizedBox(height: 16),
        NicheInfoCard(
          isDark: isDark,
          icon: Icons.notifications_outlined,
          title: "Em Notificações, configure lembretes",
          content: "Defina horários para receber lembretes motivacionais que te ajudem a evitar pedidos por impulso.",
        ),
        const SizedBox(height: 16),
        NicheInfoCard(
          isDark: isDark,
          icon: Icons.bar_chart_rounded,
          title: "Em Estatísticas, acompanhe seus ganhos",
          content: "Visualize quantos dias você está sem pedir delivery e acompanhe sua evolução.",
        ),
      ],
    );
  }

  Widget _buildCompulsionContent(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aplicativos monitorados:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        if (selectedApps.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                "Nenhum app selecionado.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          )
        else
          FutureBuilder<List<AppDisplayInfo>>(
            future: onGetAppInfo(selectedApps),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final infos = snapshot.data!;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: infos.map((info) {
                  return InputChip(
                    visualDensity: VisualDensity.compact,
                    avatar: info.icon != null
                        ? CircleAvatar(
                            backgroundImage: MemoryImage(info.icon!),
                            backgroundColor: Colors.transparent,
                          )
                        : null,
                    label: Text(
                      info.label ?? info.package,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white : const Color(0xFF6366F1),
                      ),
                    ),
                    onDeleted: () => onRemoveApp(info.package),
                    deleteIconColor: isDark
                        ? Colors.white70
                        : const Color(0xFF6366F1).withValues(alpha: 0.7),
                    backgroundColor: (isDark ? Colors.white : const Color(0xFF6366F1))
                        .withValues(alpha: 0.1),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }).toList(),
              );
            },
          ),
      ],
    );
  }
}
