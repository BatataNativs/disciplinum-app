import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Widget genérico de celebração com confetes
/// Pode ser usado por qualquer módulo para mostrar confetes e dialogs de parabenização
class ConfettiCelebrationWidget extends StatefulWidget {
  final Widget child;
  final ConfettiController? controller;
  final Function(String title, String message)? onCelebration;

  const ConfettiCelebrationWidget({
    super.key,
    required this.child,
    this.controller,
    this.onCelebration,
  });

  @override
  State<ConfettiCelebrationWidget> createState() => _ConfettiCelebrationWidgetState();
}

class _ConfettiCelebrationWidgetState extends State<ConfettiCelebrationWidget> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = widget.controller ?? 
        ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _confettiController.dispose();
    }
    super.dispose();
  }

  void play() {
    _confettiController.play();
  }

  void stop() {
    _confettiController.stop();
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
          createParticlePath: _drawStar,
        ),
      ],
    );
  }

  Path _drawStar(Size size) {
    double degToRad(double deg) => deg * (math.pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(
        halfWidth + externalRadius * math.cos(step),
        halfWidth + externalRadius * math.sin(step),
      );
      path.lineTo(
        halfWidth + internalRadius * math.cos(step + halfDegreesPerStep),
        halfWidth + internalRadius * math.sin(step + halfDegreesPerStep),
      );
    }
    path.close();
    return path;
  }
}

/// Controller global para celebrações
class CelebrationController {
  static final CelebrationController _instance = CelebrationController._internal();
  factory CelebrationController() => _instance;
  CelebrationController._internal();

  final List<Function()> _listeners = [];

  void addListener(Function() listener) {
    _listeners.add(listener);
  }

  void removeListener(Function() listener) {
    _listeners.remove(listener);
  }

  void notify() {
    for (final listener in _listeners) {
      listener();
    }
  }
}

/// Dialog de celebração para insígnias (com confetes integrados)
class InsigniaCelebrationDialog extends StatefulWidget {
  final String insigniaName;
  final String? insigniaDescription;
  final String? assetPath;
  final VoidCallback onClose;
  final Color accentColor;

  const InsigniaCelebrationDialog({
    super.key,
    required this.insigniaName,
    this.insigniaDescription,
    this.assetPath,
    required this.onClose,
    this.accentColor = const Color(0xFF6366F1),
  });

  @override
  State<InsigniaCelebrationDialog> createState() => _InsigniaCelebrationDialogState();
}

class _InsigniaCelebrationDialogState extends State<InsigniaCelebrationDialog> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    // Inicia confetes após um pequeno delay para o dialog aparecer primeiro
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _confettiController.play();
        HapticFeedback.heavyImpact();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 40),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: widget.accentColor.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 40), // Espaço para a imagem
                // Emoji de celebração
                const Text(
                  '🎉',
                  style: TextStyle(fontSize: 48),
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
                  widget.insigniaName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: widget.accentColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.insigniaDescription != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    widget.insigniaDescription!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                // Botão
                ElevatedButton(
                  onPressed: widget.onClose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.accentColor,
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
          // Confetti widget
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ConfettiWidget(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog de celebração para medalhas (com confetes integrados)
class MedalhaCelebrationDialog extends StatefulWidget {
  final String medalhaName;
  final String? medalhaDescription;
  final String? assetPath;
  final VoidCallback onClose;

  const MedalhaCelebrationDialog({
    super.key,
    required this.medalhaName,
    this.medalhaDescription,
    this.assetPath,
    required this.onClose,
  });

  @override
  State<MedalhaCelebrationDialog> createState() => _MedalhaCelebrationDialogState();
}

class _MedalhaCelebrationDialogState extends State<MedalhaCelebrationDialog> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
    
    // Inicia confetes após um pequeno delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _confettiController.play();
        HapticFeedback.heavyImpact();
        // Dobro de vibração para medalhas
        Future.delayed(const Duration(milliseconds: 100), () {
          HapticFeedback.heavyImpact();
        });
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 40),
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
                const SizedBox(height: 40),
                // Emoji de medalha
                const Text(
                  '🏆',
                  style: TextStyle(fontSize: 48),
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
                  widget.medalhaName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (widget.medalhaDescription != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    widget.medalhaDescription!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                // Botão
                ElevatedButton(
                  onPressed: widget.onClose,
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
          // Confetti widget
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Color(0xFFFFD700), // Gold
                Colors.orange,
                Colors.yellow,
                Colors.amber,
                Colors.white,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper para mostrar dialogs de celebração
class CelebrationHelper {
  static void showInsigniaCelebration(
    BuildContext context, {
    required String insigniaName,
    String? insigniaDescription,
    String? assetPath,
    Color accentColor = const Color(0xFF6366F1),
  }) {
    LoggerService.instance.gamification('🎉 Mostrando celebração de insígnia: $insigniaName');
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => InsigniaCelebrationDialog(
        insigniaName: insigniaName,
        insigniaDescription: insigniaDescription,
        assetPath: assetPath,
        accentColor: accentColor,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  static void showMedalhaCelebration(
    BuildContext context, {
    required String medalhaName,
    String? medalhaDescription,
    String? assetPath,
  }) {
    LoggerService.instance.gamification('🏆 Mostrando celebração de medalha: $medalhaName');
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MedalhaCelebrationDialog(
        medalhaName: medalhaName,
        medalhaDescription: medalhaDescription,
        assetPath: assetPath,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }
}
