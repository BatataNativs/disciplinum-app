import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:disciplinum/core/events/event_bus.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/spending/gamification/domain/services/spending_celebration_service.dart';

/// Widget que escuta eventos de celebração do Spending e mostra UI de comemoração
class SpendingCelebrationWidget extends StatefulWidget {
  final Widget child;

  const SpendingCelebrationWidget({
    super.key,
    required this.child,
  });

  @override
  State<SpendingCelebrationWidget> createState() => _SpendingCelebrationWidgetState();
}

class _SpendingCelebrationWidgetState extends State<SpendingCelebrationWidget> {
  StreamSubscription? _insigniaSubscription;
  StreamSubscription? _medalhaSubscription;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _setupListeners();
  }

  @override
  void dispose() {
    _insigniaSubscription?.cancel();
    _medalhaSubscription?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  void _setupListeners() {
    _insigniaSubscription = EventBus.instance.stream
        .where((event) => event is SpendingInsigniaConquistadaEvent)
        .listen((event) {
      final insigniaEvent = event as SpendingInsigniaConquistadaEvent;
      _showInsigniaCelebration(insigniaEvent.insigniaId, insigniaEvent.insigniaName);
    });

    _medalhaSubscription = EventBus.instance.stream
        .where((event) => event is SpendingMedalhaConquistadaEvent)
        .listen((event) {
      final medalhaEvent = event as SpendingMedalhaConquistadaEvent;
      _showMedalhaCelebration(medalhaEvent.medalhaId, medalhaEvent.medalhaName);
    });

    LoggerService.instance.gamification('🎉 SpendingCelebrationWidget: listeners configurados');
  }

  void _showInsigniaCelebration(String insigniaId, String insigniaName) {
    if (!mounted) return;

    _confettiController.play();
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _InsigniaCelebrationDialog(
        insigniaName: insigniaName,
        onClose: () => Navigator.of(context).pop(),
      ),
    );

    LoggerService.instance.gamification('🎊 Diálogo de celebração exibido: $insigniaName');
  }

  void _showMedalhaCelebration(String medalhaId, String medalhaName) {
    if (!mounted) return;

    _confettiController.play();
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.heavyImpact();
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _MedalhaCelebrationDialog(
        medalhaName: medalhaName,
        onClose: () => Navigator.of(context).pop(),
      ),
    );

    LoggerService.instance.gamification('🏆 Diálogo de medalha exibido: $medalhaName');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        widget.child,
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [
            Color(0xFFE91E63), // Pink
            Color(0xFFF06292), // Light Pink
            Colors.purple,
            Colors.deepPurple,
            Colors.redAccent,
          ],
        ),
      ],
    );
  }
}

class _InsigniaCelebrationDialog extends StatelessWidget {
  final String insigniaName;
  final VoidCallback onClose;

  const _InsigniaCelebrationDialog({
    required this.insigniaName,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFE91E63).withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '💎',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nova Conquista!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              insigniaName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFE91E63),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Você está controlando seus gastos! Continue economizando.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continuar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedalhaCelebrationDialog extends StatelessWidget {
  final String medalhaName;
  final VoidCallback onClose;

  const _MedalhaCelebrationDialog({
    required this.medalhaName,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFFFD700).withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🏆',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            const Text(
              'Medalha Conquistada!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              medalhaName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Incrível! Você alcançou uma nova medalha pelo seu esforço e dedicação.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Incrível!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
