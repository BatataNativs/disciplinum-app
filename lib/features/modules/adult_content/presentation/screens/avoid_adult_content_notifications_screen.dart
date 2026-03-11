import 'package:flutter/material.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/features/notifications/presentation/widgets/notification_message_editor.dart';

class AvoidAdultContentNotificationsScreen extends StatefulWidget {
  const AvoidAdultContentNotificationsScreen({super.key});

  @override
  State<AvoidAdultContentNotificationsScreen> createState() =>
      _AvoidAdultContentNotificationsScreenState();
}

class _AvoidAdultContentNotificationsScreenState
    extends State<AvoidAdultContentNotificationsScreen> {
  final Niche _niche = NicheRepository.getById(NicheId.adultContent);

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
              NotificationMessageEditor(nicheId: _niche.id),
              const SizedBox(height: 8),

              // Como funciona - Notificações
              _buildMinimalInfoCard(
                description:
                    'A notificação chegará automaticamente sempre que você abrir um dos aplicativos selecionados para monitoramento.',
                isDark: isDark,
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

  Widget _buildMinimalInfoCard({
    required String description,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        description,
        style: TextStyle(
          fontSize: 12,
          color: const Color(0xFF64748B),
          height: 1.4,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
