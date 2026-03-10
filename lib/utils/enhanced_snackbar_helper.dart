import 'package:flutter/material.dart';
import 'dart:async';

class EnhancedSnackBarHelper {
  static void showSuccess(BuildContext context, String message) {
    _showOverlay(context, message, const Color(0xFF10B981), Icons.check_circle);
  }

  static void showError(BuildContext context, String message) {
    _showOverlay(
        context, message, const Color(0xFFEF4444), Icons.error_outline);
  }

  static void showInfo(BuildContext context, String message) {
    _showOverlay(context, message, const Color(0xFF6366F1), Icons.info_outline);
  }

  static void showWarning(BuildContext context, String message) {
    _showOverlay(
        context, message, const Color(0xFFF59E0B), Icons.warning_amber);
  }

  static void showCustom(BuildContext context, String message,
      Color backgroundColor, IconData icon) {
    _showOverlay(context, message, backgroundColor, icon);
  }

  static void _showOverlay(BuildContext context, String message,
      Color backgroundColor, IconData icon) {
    try {
      final overlay = Overlay.of(context, rootOverlay: true);
      
      late OverlayEntry entry;
      entry = OverlayEntry(
        builder: (context) => _OverlayNotification(
          message: message,
          backgroundColor: backgroundColor,
          icon: icon,
          onDismiss: () {
            if (entry.mounted) {
              entry.remove();
            }
          },
        ),
      );

      overlay.insert(entry);
    } catch (e) {
      // Se não encontrar Overlay, usa debugPrint para não quebrar o app
      debugPrint('Snackbar não pôde ser exibido: $message\nErro: $e');
    }
  }
}

class _OverlayNotification extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final IconData icon;
  final VoidCallback onDismiss;

  const _OverlayNotification({
    required this.message,
    required this.backgroundColor,
    required this.icon,
    required this.onDismiss,
  });

  @override
  State<_OverlayNotification> createState() => _OverlayNotificationState();
}

class _OverlayNotificationState extends State<_OverlayNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    _timer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 40,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _offsetAnimation,
            child: Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.vertical,
              onDismissed: (_) => widget.onDismiss(),
              child: Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.horizontal,
                onDismissed: (_) => widget.onDismiss(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(widget.icon, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
