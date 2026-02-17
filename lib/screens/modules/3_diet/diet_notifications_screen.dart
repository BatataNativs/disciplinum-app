import 'package:flutter/material.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/models/niche.dart';
import 'package:disciplinum/widgets/notifications/notification_message_editor.dart';

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
            isDark ? Colors.black : const Color.fromARGB(255, 226, 229, 251),
            isDark ? Colors.black : const Color.fromARGB(255, 255, 255, 255)
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Notificações'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NotificationMessageEditor(nicheId: _niche.id),
              const SizedBox(height: 24),
              const Text(
                "ATENÇÃO: Este módulo vai te notificar 30 min antes do horário definido. Pra dar tempo de preparar ou esquentar sua refeição",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
