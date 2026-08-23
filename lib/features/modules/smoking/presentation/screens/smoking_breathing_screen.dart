import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum BreathingTechnique {
  box4444(
    name: 'Respiração Quadrada (4-4-4-4)',
    description: 'Técnica clássica para foco, clareza e controle de estresse imediato.',
    inhale: 4,
    hold1: 4,
    exhale: 4,
    hold2: 4,
  ),
  technique478(
    name: 'Técnica 4-7-8',
    description: 'Poderoso calmante natural do sistema nervoso e alívio da ansiedade.',
    inhale: 4,
    hold1: 7,
    exhale: 8,
    hold2: 0,
  ),
  calm46(
    name: 'Respiração Calma (4-6)',
    description: 'Estimula o nervo vago e desacelera os batimentos cardíacos.',
    inhale: 4,
    hold1: 0,
    exhale: 6,
    hold2: 0,
  ),
  energy42(
    name: 'Respiração de Alívio (4-2)',
    description: 'Ciclos rápidos para dissipar impulsos agudos de vontade.',
    inhale: 4,
    hold1: 0,
    exhale: 2,
    hold2: 0,
  );

  final String name;
  final String description;
  final int inhale;
  final int hold1;
  final int exhale;
  final int hold2;

  const BreathingTechnique({
    required this.name,
    required this.description,
    required this.inhale,
    required this.hold1,
    required this.exhale,
    required this.hold2,
  });

  int get cycleDuration => inhale + hold1 + exhale + hold2;
}

enum BreathingPhase {
  inhale('INSPIRAR', Color(0xFF06B6D4)),
  hold('SEGURAR', Color(0xFF6366F1)),
  exhale('EXPIRAR', Color(0xFF10B981)),
  holdEmpty('SEGURAR', Color(0xFF8B5CF6));

  final String label;
  final Color color;

  const BreathingPhase(this.label, this.color);
}

class SmokingBreathingScreen extends StatefulWidget {
  final int initialSessionSeconds;
  final BreathingTechnique initialTechnique;

  const SmokingBreathingScreen({
    super.key,
    this.initialSessionSeconds = 180, // 3 minutos
    this.initialTechnique = BreathingTechnique.box4444,
  });

  @override
  State<SmokingBreathingScreen> createState() => _SmokingBreathingScreenState();
}

class _SmokingBreathingScreenState extends State<SmokingBreathingScreen>
    with SingleTickerProviderStateMixin {
  late BreathingTechnique _technique;
  late int _sessionDuration;
  late int _secondsRemaining;

  bool _isRunning = true;
  Timer? _sessionTimer;
  Timer? _cycleTimer;

  BreathingPhase _currentPhase = BreathingPhase.inhale;
  int _phaseSecondsLeft = 4;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _technique = widget.initialTechnique;
    _sessionDuration = widget.initialSessionSeconds;
    _secondsRemaining = _sessionDuration;

    _animController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _technique.inhale),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _startExercise();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _cycleTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _startExercise() {
    _isRunning = true;
    _currentPhase = BreathingPhase.inhale;
    _phaseSecondsLeft = _technique.inhale;

    _animController.duration = Duration(seconds: _technique.inhale);
    _animController.forward(from: 0.0);
    HapticFeedback.lightImpact();

    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining <= 1) {
        _finishSession();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });

    _cycleTimer?.cancel();
    _cycleTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !_isRunning) return;
      _tickPhase();
    });
  }

  void _tickPhase() {
    setState(() {
      _phaseSecondsLeft--;
    });

    if (_phaseSecondsLeft <= 0) {
      _transitionToNextPhase();
    }
  }

  void _transitionToNextPhase() {
    HapticFeedback.mediumImpact();

    if (_currentPhase == BreathingPhase.inhale) {
      if (_technique.hold1 > 0) {
        _currentPhase = BreathingPhase.hold;
        _phaseSecondsLeft = _technique.hold1;
      } else {
        _currentPhase = BreathingPhase.exhale;
        _phaseSecondsLeft = _technique.exhale;
        _animController.duration = Duration(seconds: _technique.exhale);
        _animController.reverse(from: 1.0);
      }
    } else if (_currentPhase == BreathingPhase.hold) {
      _currentPhase = BreathingPhase.exhale;
      _phaseSecondsLeft = _technique.exhale;
      _animController.duration = Duration(seconds: _technique.exhale);
      _animController.reverse(from: 1.0);
    } else if (_currentPhase == BreathingPhase.exhale) {
      if (_technique.hold2 > 0) {
        _currentPhase = BreathingPhase.holdEmpty;
        _phaseSecondsLeft = _technique.hold2;
      } else {
        _currentPhase = BreathingPhase.inhale;
        _phaseSecondsLeft = _technique.inhale;
        _animController.duration = Duration(seconds: _technique.inhale);
        _animController.forward(from: 0.0);
      }
    } else if (_currentPhase == BreathingPhase.holdEmpty) {
      _currentPhase = BreathingPhase.inhale;
      _phaseSecondsLeft = _technique.inhale;
      _animController.duration = Duration(seconds: _technique.inhale);
      _animController.forward(from: 0.0);
    }

    setState(() {});
  }

  void _pauseExercise() {
    setState(() {
      _isRunning = false;
    });
    _sessionTimer?.cancel();
    _cycleTimer?.cancel();
    _animController.stop();
  }

  void _resumeExercise() {
    setState(() {
      _isRunning = true;
    });

    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining <= 1) {
        _finishSession();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });

    _cycleTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !_isRunning) return;
      _tickPhase();
    });

    if (_currentPhase == BreathingPhase.inhale) {
      _animController.forward();
    } else if (_currentPhase == BreathingPhase.exhale) {
      _animController.reverse();
    }
  }

  void _restartExercise() {
    _pauseExercise();
    setState(() {
      _secondsRemaining = _sessionDuration;
    });
    _startExercise();
  }

  void _finishSession() {
    _sessionTimer?.cancel();
    _cycleTimer?.cancel();
    _animController.stop();

    if (!mounted) return;
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 28),
            SizedBox(width: 10),
            Text('Sessão Concluída!'),
          ],
        ),
        content: const Text(
          'Excelente trabalho! Seu sistema nervoso agradece. O pico mais forte da vontade costuma passar após alguns minutos de respiração consciente.',
          style: TextStyle(height: 1.4),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Concluir'),
          ),
        ],
      ),
    );
  }

  void _showTechniqueSelector() {
    _pauseExercise();
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Escolha a Técnica de Respiração',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 14),
            ...BreathingTechnique.values.map((tech) {
              final isSelected = tech == _technique;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: isSelected
                      ? const Color(0xFF6366F1).withValues(alpha: 0.12)
                      : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _technique = tech;
                      });
                      _restartExercise();
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_off_rounded,
                            color: isSelected
                                ? const Color(0xFF6366F1)
                                : colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tech.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  tech.description,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.65),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _formatTime(int totalSecs) {
    final mins = totalSecs ~/ 60;
    final secs = totalSecs % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final phaseColor = _currentPhase.color;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Alterar Técnica',
            onPressed: _showTechniqueSelector,
          ),
        ],
      ),
        body: SafeArea(
          child: Column(
            children: [
              // Header com tempo restante
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      _technique.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatTime(_secondsRemaining)} restantes',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Círculo Pulsante Central
              Center(
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    final scale = _scaleAnimation.value;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Ondas externas / Glow
                        Container(
                          width: 280 * scale,
                          height: 280 * scale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: phaseColor.withValues(alpha: 0.08),
                          ),
                        ),
                        Container(
                          width: 240 * scale,
                          height: 240 * scale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: phaseColor.withValues(alpha: 0.15),
                            boxShadow: [
                              BoxShadow(
                                color: phaseColor.withValues(alpha: 0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        ),
                        // Círculo Principal
                        Container(
                          width: 200 * scale,
                          height: 200 * scale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                phaseColor.withValues(alpha: 0.9),
                                phaseColor,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _currentPhase.label,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '$_phaseSecondsLeft',
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const Spacer(),

              // Controles Inferiores
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, size: 28),
                      tooltip: 'Reiniciar',
                      onPressed: _restartExercise,
                    ),
                    const SizedBox(width: 24),
                    // Botão Play/Pause Principal
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: phaseColor,
                        boxShadow: [
                          BoxShadow(
                            color: phaseColor.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isRunning
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 36,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          if (_isRunning) {
                            _pauseExercise();
                          } else {
                            _resumeExercise();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      icon: const Icon(Icons.tune_rounded, size: 28),
                      tooltip: 'Técnicas',
                      onPressed: _showTechniqueSelector,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }
}

