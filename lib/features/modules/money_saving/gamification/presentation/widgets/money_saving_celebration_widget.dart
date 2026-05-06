import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:disciplinum/core/events/event_bus.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/domain/services/money_saving_celebration_service.dart';

/// Widget que escuta eventos de celebração do Money Saving e mostra UI de comemoração
class MoneySavingCelebrationWidget extends StatefulWidget {
  final Widget child;

  const MoneySavingCelebrationWidget({
    super.key,
    required this.child,
  });

  @override
  State<MoneySavingCelebrationWidget> createState() => _MoneySavingCelebrationWidgetState();
}

class _MoneySavingCelebrationWidgetState extends State<MoneySavingCelebrationWidget> {
  StreamSubscription? _insigniaSubscription;
  StreamSubscription? _medalhaSubscription;
  StreamSubscription? _desafioCompletoSubscription;
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
    _desafioCompletoSubscription?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  void _setupListeners() {
    // Escuta eventos de insígnias conquistadas
    _insigniaSubscription = EventBus.instance.stream
        .where((event) => event is MoneySavingInsigniaConquistadaEvent)
        .listen((event) {
      final insigniaEvent = event as MoneySavingInsigniaConquistadaEvent;
      _showInsigniaCelebration(insigniaEvent.insigniaId, insigniaEvent.insigniaName);
    });

    // Escuta eventos de medalhas conquistadas
    _medalhaSubscription = EventBus.instance.stream
        .where((event) => event is MoneySavingMedalhaConquistadaEvent)
        .listen((event) {
      final medalhaEvent = event as MoneySavingMedalhaConquistadaEvent;
      _showMedalhaCelebration(medalhaEvent.medalhaId, medalhaEvent.medalhaName);
    });

    // Escuta eventos de desafio completo
    _desafioCompletoSubscription = EventBus.instance.stream
        .where((event) => event is MoneySavingDesafioCompletoEvent)
        .listen((event) {
      final desafioEvent = event as MoneySavingDesafioCompletoEvent;
      _showDesafioCompletoCelebration(desafioEvent.desafioName, desafioEvent.valorTotal);
    });

    LoggerService.instance.gamification('🎉 MoneySavingCelebrationWidget: listeners configurados');
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

  void _showDesafioCompletoCelebration(String desafioName, double valorTotal) {
    if (!mounted) return;

    // Confetes por mais tempo para desafio completo
    _confettiController.play();
    
    // Feedback tátil épico
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.heavyImpact();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      HapticFeedback.heavyImpact();
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _DesafioCompletoDialog(
        desafioName: desafioName,
        valorTotal: valorTotal,
        onClose: () => Navigator.of(context).pop(),
      ),
    );

    LoggerService.instance.gamification('🎊🎊🎊 Diálogo de DESAFIO COMPLETO exibido: $desafioName - R\$ $valorTotal');
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
            Color(0xFF4CAF50), // Green
            Color(0xFF8BC34A), // Light Green
            Colors.teal,
            Colors.cyan,
            Colors.amber,
            Colors.orange,
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
            color: const Color(0xFF4CAF50).withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '💰',
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
                color: Color(0xFF4CAF50),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Você está economizando muito bem! Continue acumulando suas conquistas.',
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
                backgroundColor: const Color(0xFF4CAF50),
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
              'Incrível! Você alcançou uma nova medalha pelo seu esforço em economizar.',
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

/// Diálogo especial para desafio completo
class _DesafioCompletoDialog extends StatelessWidget {
  final String desafioName;
  final double valorTotal;
  final VoidCallback onClose;

  const _DesafioCompletoDialog({
    required this.desafioName,
    required this.valorTotal,
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
            color: const Color(0xFFFFD700).withValues(alpha: 0.8),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.3),
              blurRadius: 30,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎉🎉🎉',
              style: TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'DESAFIO COMPLETO!',
              style: TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              desafioName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF4CAF50),
                  width: 2,
                ),
              ),
              child: Text(
                'R\$ ${valorTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFF4CAF50),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Parabéns! Você completou seu desafio de economia e alcançou sua meta!',
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
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Comemorar! 🎊',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
