import 'package:flutter/material.dart';

class AvoidAdultContentNotificationsScreen extends StatefulWidget {
  const AvoidAdultContentNotificationsScreen({super.key});

  @override
  State<AvoidAdultContentNotificationsScreen> createState() =>
      _AvoidAdultContentNotificationsScreenState();
}

class _AvoidAdultContentNotificationsScreenState
    extends State<AvoidAdultContentNotificationsScreen> {
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
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: SizedBox.shrink(),
        ),
      ),
    );
  }
}
