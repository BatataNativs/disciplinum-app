import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:disciplinum/core/events/event_bus.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/services/smoking_celebration_service.dart';

/// Widget que escuta eventos de celebração do Smoking e mostra UI de comemoração
/// Deve ser colocado na árvore de widgets da homescreen ou tela do módulo
class SmokingCelebrationWidget extends StatefulWidget {
  final Widget child;

  const SmokingCelebrationWidget({
    super.key,
    required this.child,
  });

  @override
  State<SmokingCelebrationWidget> createState() => _SmokingCelebrationWidgetState();
}

class _SmokingCelebrationWidgetState extends State<SmokingCelebrationWidget> {
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
    // Escuta eventos de insígnias conquistadas
    _insigniaSubscription = EventBus.instance.stream
        .where((event) => event is SmokingInsigniaConquistadaEvent)
        .listen((event) {
      final insigniaEvent = event as SmokingInsigniaConquistadaEvent;
      _showInsigniaCelebration(insigniaEvent.insigniaId, insigniaEvent.insigniaName);
    });

    // Escuta eventos de medalhas conquistadas
    _medalhaSubscription = EventBus.instance.stream
        .where((event) => event is SmokingMedalhaConquistadaEvent)
        .listen((event) {
      final medalhaEvent = event as SmokingMedalhaConquistadaEvent;
      _showMedalhaCelebration(medalhaEvent.medalhaId, medalhaEvent.medalhaName);
    });

    LoggerService.instance.gamification('🎉 SmokingCelebrationWidget: listeners configurados');
  }

  void _showInsigniaCelebration(String insigniaId, String insigniaName) {
    if (!mounted) return;

    // Toca confetes
    _confettiController.play();

    // Feedback tátil
    HapticFeedback.heavyImpact();

    // Mostra diálogo de celebração
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

    // Toca confetes com mais intensidade para medalhas
    _confettiController.play();

    // Feedback tátil mais forte para medalhas
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.heavyImpact();
    });

    // Mostra diálogo de celebração de medalha
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
            Colors.green,
            Colors.blue,
            Colors.pink,
            Colors.orange,
            Colors.purple,
            Colors.yellow,
            Colors.cyan,
            Colors.red,
          ],
        ),
      ],
    );
  }
}

/// Diálogo de celebração para insígnias
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
            color: const Color(0xFF6366F1).withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Emoji de celebração
            const Text(
              '🎉',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            // Título
            const Text(
              'Nova Conquista!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Nome da insígnia
            Text(
              insigniaName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6366F1),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            // Mensagem motivacional
            const Text(
              'Você está indo muito bem! Continue mantendo a disciplina para desbloquear mais conquistas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            // Botão
            ElevatedButton(
              onPressed: onClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
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

/// Diálogo de celebração para medalhas
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
            // Emoji de medalha
            const Text(
              '🏆',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            // Título
            const Text(
              'Medalha Conquistada!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Nome da medalha
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
            // Mensagem especial
            const Text(
              'Incrível! Você alcançou uma nova medalha pelo seu esforço e dedicação.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            // Botão
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
                'Vamos lá!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
