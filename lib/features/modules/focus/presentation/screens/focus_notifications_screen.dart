import 'package:flutter/material.dart';

class FocusNotificationsScreen extends StatefulWidget {
  const FocusNotificationsScreen({super.key});

  @override
  State<FocusNotificationsScreen> createState() =>
      _FocusNotificationsScreenState();
}

class _FocusNotificationsScreenState extends State<FocusNotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.surface,
            colorScheme.surfaceContainerHighest,
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
              color: colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: colorScheme.onSurface,
          ),
        ),
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: SizedBox.shrink(),
        ),
      ),
    );
  }
}
