import 'package:flutter/material.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/models/niche.dart';
import 'package:disciplinum/widgets/notifications/notification_message_editor.dart';

class FocusNotificationsScreen extends StatefulWidget {
  const FocusNotificationsScreen({super.key});

  @override
  State<FocusNotificationsScreen> createState() =>
      _FocusNotificationsScreenState();
}

class _FocusNotificationsScreenState extends State<FocusNotificationsScreen> {
  final Niche _niche = NicheRepository.getById(NicheId.focus);

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
            ],
          ),
        ),
      ),
    );
  }
}
