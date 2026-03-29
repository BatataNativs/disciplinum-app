import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

/// Widget para exibir celebrações com confetes e mensagens flutuantes
class CelebrationWidget extends StatefulWidget {
  final String title;
  final String message;
  final String emoji;
  final VoidCallback? onDismiss;
  final bool autoDismiss;

  const CelebrationWidget({
    super.key,
    required this.title,
    required this.message,
    this.emoji = '🎉',
    this.onDismiss,
    this.autoDismiss = true,
  });

  @override
  State<CelebrationWidget> createState() => _CelebrationWidgetState();
}

class _CelebrationWidgetState extends State<CelebrationWidget>
    with TickerProviderStateMixin {
  late final ConfettiController _confettiController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Configurar controlador de confetes
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Configurar animações
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Iniciar animações e confetes
    _startCelebration();

    // Auto dismiss se configurado
    if (widget.autoDismiss) {
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          _dismiss();
        }
      });
    }
  }

  void _startCelebration() {
    // Iniciar animações
    _fadeController.forward();
    _scaleController.forward();

    // Disparar confetes em múltiplas direções
    Future.delayed(const Duration(milliseconds: 200), () {
      _confettiController.play();
    });

    // Segunda onda de confetes
    Future.delayed(const Duration(milliseconds: 800), () {
      _confettiController.play();
    });
  }

  void _dismiss() {
    _fadeController.reverse().then((_) {
      if (mounted) {
        widget.onDismiss?.call();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Confetes
          Positioned.fill(
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.yellow,
                Colors.orange,
                Colors.purple,
                Colors.pink,
                Colors.cyan,
              ],
            ),
          ),

          // Conteúdo da celebração
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Emoji animado
                      AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value * 1.2,
                            child: Text(
                              widget.emoji,
                              style: const TextStyle(fontSize: 80),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Título
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Mensagem
                      Text(
                        widget.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Botão OK
                      ElevatedButton(
                        onPressed: _dismiss,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para exibir celebração de saúde (específico para Smoking)
class HealthCelebrationWidget extends StatelessWidget {
  final String benefitTitle;
  final String benefitMessage;
  final VoidCallback? onDismiss;

  const HealthCelebrationWidget({
    super.key,
    required this.benefitTitle,
    required this.benefitMessage,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return CelebrationWidget(
      title: benefitTitle,
      message: benefitMessage,
      emoji: '🎊',
      onDismiss: onDismiss,
    );
  }
}

/// Widget para exibir celebração econômica (específico para Smoking)
class EconomicCelebrationWidget extends StatelessWidget {
  final String economicTitle;
  final String economicMessage;
  final VoidCallback? onDismiss;

  const EconomicCelebrationWidget({
    super.key,
    required this.economicTitle,
    required this.economicMessage,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return CelebrationWidget(
      title: economicTitle,
      message: economicMessage,
      emoji: '💰',
      onDismiss: onDismiss,
    );
  }
}
