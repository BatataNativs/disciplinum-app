import 'dart:async';
// ignore_for_file: unused_element
import 'package:flutter/material.dart';
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
    LoggerService.instance.gamification('🎊 Conquista registrada no módulo spending: $insigniaName (diálogo gerenciado pelo GlobalAchievementListener)');
  }

  void _showMedalhaCelebration(String medalhaId, String medalhaName) {
    if (!mounted) return;
    LoggerService.instance.gamification('🏆 Medalha registrada no módulo spending: $medalhaName (diálogo gerenciado pelo GlobalAchievementListener)');
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
