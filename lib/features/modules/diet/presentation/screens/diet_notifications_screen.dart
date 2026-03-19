import 'package:flutter/material.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/features/notifications/presentation/widgets/notification_message_editor.dart';

import 'package:disciplinum/shared/widgets/cards/niche_info_card.dart';

class DietNotificationsScreen extends StatefulWidget {
  const DietNotificationsScreen({super.key});

  @override
  State<DietNotificationsScreen> createState() =>
      _DietNotificationsScreenState();
}

class _DietNotificationsScreenState extends State<DietNotificationsScreen> {
  final Niche _niche = NicheRepository.getById(NicheId.diet);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            isDark ? const Color(0xFF0F172A) : const Color(0xFFEFF6FF),
            isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Notificações',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seção: Texto da Notificação
              _buildSectionHeader(
                title: 'Texto da Notificação',
                subtitle:
                    'Que chegará sempre que você abrir um dos apps selecionados para monitoramento com o módulo ativado.',
                icon: Icons.message_rounded,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              NotificationMessageEditor(nicheId: _niche.nicheId),
              const SizedBox(height: 16),

              // Como funciona - Notificações
              NicheInfoCard(
                isDark: isDark,
                icon: Icons.info_outline,
                title: 'Como funciona',
                content:
                    'A notificação chegará automaticamente sempre que você abrir um dos aplicativos selecionados para monitoramento.',
              ),
              const SizedBox(height: 16),

              // Seção: Aviso especial
              _buildSectionHeader(
                title: 'Aviso Importante',
                subtitle: 'Este módulo notifica 30 minutos antes do horário definido',
                icon: Icons.access_time_rounded,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              NicheInfoCard(
                isDark: isDark,
                icon: Icons.warning_rounded,
                title: 'Preparação',
                color: Colors.orange,
                content:
                    'Este módulo vai te notificar 30 min antes do horário definido. Para dar tempo de preparar ou esquentar sua refeição.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF3B82F6),
                const Color(0xFF2563EB),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
