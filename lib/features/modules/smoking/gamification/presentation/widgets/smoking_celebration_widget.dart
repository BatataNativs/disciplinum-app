import 'dart:async';
import 'package:flutter/material.dart';
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
    LoggerService.instance.gamification('🎊 Conquista registrada no módulo smoking: $insigniaName (diálogo gerenciado pelo GlobalAchievementListener)');
  }

  void _showMedalhaCelebration(String medalhaId, String medalhaName) {
    if (!mounted) return;
    LoggerService.instance.gamification('🏆 Medalha registrada no módulo smoking: $medalhaName (diálogo gerenciado pelo GlobalAchievementListener)');
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
