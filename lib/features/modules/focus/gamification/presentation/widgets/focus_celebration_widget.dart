import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:disciplinum/core/audio/system_audio_service.dart';
import 'package:disciplinum/core/events/event_bus.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/services/focus_celebration_service.dart';

/// Widget que escuta eventos de celebração e exibe efeitos visuais
/// Este é um exemplo de como a UI pode consumir os eventos do FocusCelebrationService
class FocusCelebrationWidget extends StatefulWidget {
  final Widget child;

  const FocusCelebrationWidget({
    super.key,
    required this.child,
  });

  @override
  State<FocusCelebrationWidget> createState() => _FocusCelebrationWidgetState();
}

class _FocusCelebrationWidgetState extends State<FocusCelebrationWidget>
    with TickerProviderStateMixin {
  OverlayEntry? _confetesOverlay;
  AnimationController? _confetesController;
  bool _showingConfetes = false;

  @override
  void initState() {
    super.initState();
    _setupEventListeners();
    _confetesController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _removeEventListeners();
    _confetesController?.dispose();
    _hideConfetes();
    super.dispose();
  }

  void _setupEventListeners() {
    // Escuta eventos de confetes
    EventBus.instance.listen<ConfetesDispararEvent>(_onConfetesDisparar);
    
    // Escuta eventos de feedback tátil
    EventBus.instance.listen<HapticFeedbackEvent>(_onHapticFeedback);
    
    // Escuta eventos de som
    EventBus.instance.listen<SomConquistaEvent>(_onSomConquista);
    
    // Escuta eventos de conquistas principais
    EventBus.instance.listen<MedalhaConquistadaEvent>(_onMedalhaConquistada);
    EventBus.instance.listen<InsigniaDisciplinumConquistadaEvent>(_onDisciplinumConquistado);
  }

  void _removeEventListeners() {
    // EventBus não tem método para remover listeners específicos diretamente
    // Mas podemos limpar todos os listeners se necessário
    // EventBus.instance.clearListeners();
  }

  void _onConfetesDisparar(ConfetesDispararEvent event) {
    if (!mounted) return;
    
    LoggerService.instance.d('Confetes recebidos: ${event.tipo} (${event.intensidade})');
    _showConfetes(event);
  }

  void _onHapticFeedback(HapticFeedbackEvent event) {
    if (!mounted) return;
    
    LoggerService.instance.d('Feedback tátil: ${event.tipo} (${event.intensidade})');
    _triggerHapticFeedback(event);
  }

  void _onSomConquista(SomConquistaEvent event) {
    if (!mounted) return;
    
    LoggerService.instance.d('Som de conquista: ${event.tipo} (volume: ${event.volume})');
    _playConquestSound(event);
  }

  void _onMedalhaConquistada(MedalhaConquistadaEvent event) {
    if (!mounted) return;
    
    LoggerService.instance.d('Medalha conquistada: ${event.medalhaName}');
    _showConquestDialog('🏆 Medalha Conquistada!', event.medalhaName);
  }

  void _onDisciplinumConquistado(InsigniaDisciplinumConquistadaEvent event) {
    if (!mounted) return;
    
    LoggerService.instance.d('Disciplinum conquistado: #${event.disciplinumCount}');
    _showConquestDialog(
      '⭐ Insígnia Disciplinum!',
      'Incrível! Você conquistou sua ${_getOrdinalNumber(event.disciplinumCount)} insígnia Disciplinum!',
    );
  }

  void _showConfetes(ConfetesDispararEvent event) {
    if (_showingConfetes) return;
    
    setState(() {
      _showingConfetes = true;
    });

    // Cria overlay para confetes
    _confetesOverlay = OverlayEntry(
      builder: (context) => _ConfetesOverlay(
        event: event,
        controller: _confetesController!,
      ),
    );

    Overlay.of(context).insert(_confetesOverlay!);
    
    // Inicia animação
    _confetesController!.forward().then((_) {
      Future.delayed(event.duracao, () {
        _hideConfetes();
      });
    });
  }

  void _hideConfetes() {
    if (_confetesOverlay != null) {
      _confetesOverlay!.remove();
      _confetesOverlay = null;
    }
    
    if (mounted) {
      setState(() {
        _showingConfetes = false;
      });
    }
    
    _confetesController?.reset();
  }

  void _triggerHapticFeedback(HapticFeedbackEvent event) {
    try {
      switch (event.intensidade) {
        case 'leve':
          HapticFeedback.lightImpact();
          break;
        case 'media':
          HapticFeedback.mediumImpact();
          break;
        case 'forte':
          HapticFeedback.heavyImpact();
          break;
        default:
          HapticFeedback.mediumImpact();
      }
    } catch (e) {
      LoggerService.instance.e('Erro no feedback tátil', error: e);
    }
  }

  void _playConquestSound(SomConquistaEvent event) async {
    try {
      // Reproduz som usando SystemAudioService (sem arquivos externos)
      await SystemAudioService.instance.playConquestSound(
        event.tipo,
        volume: event.volume,
      );
      
      LoggerService.instance.d('🔊 Som ${event.tipo} reproduzido (tátil) com volume ${event.volume}');
    } catch (e) {
      LoggerService.instance.e('Erro ao reproduzir som', error: e);
      
      // Fallback: usa feedback tátil básico
      try {
        await SystemAudioService.instance.playHapticFeedback('medio');
        LoggerService.instance.d('🔊 Som fallback reproduzido (tátil)');
      } catch (fallbackError) {
        LoggerService.instance.w('Feedback tátil não disponível, usando apenas feedback visual');
      }
    }
  }

  void _showConquestDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ConquestDialog(
        title: title,
        message: message,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  String _getOrdinalNumber(int number) {
    switch (number) {
      case 1:
        return '1ª';
      case 2:
        return '2ª';
      case 3:
        return '3ª';
      case 4:
        return '4ª';
      default:
        return '$numberª';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showingConfetes)
          Positioned.fill(
            child: Container(
              // Overlay para bloquear interações durante confetes
              color: Colors.transparent,
            ),
          ),
      ],
    );
  }
}

/// Widget de overlay para animação de confetes
class _ConfetesOverlay extends StatefulWidget {
  final ConfetesDispararEvent event;
  final AnimationController controller;

  const _ConfetesOverlay({
    required this.event,
    required this.controller,
  });

  @override
  State<_ConfetesOverlay> createState() => _ConfetesOverlayState();
}

class _ConfetesOverlayState extends State<_ConfetesOverlay>
    with SingleTickerProviderStateMixin {
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animation = CurvedAnimation(
      parent: widget.controller,
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: _ConfetesPainter(
                progress: _animation.value,
                event: widget.event,
              ),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }
}

/// CustomPainter para desenhar confetes
class _ConfetesPainter extends CustomPainter {
  final double progress;
  final ConfetesDispararEvent event;

  _ConfetesPainter({
    required this.progress,
    required this.event,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint();
    final random = DateTime.now().millisecondsSinceEpoch;
    
    for (int i = 0; i < event.quantidade; i++) {
      final color = _parseColor(event.cores[i % event.cores.length]);
      paint.color = color;
      
      // Posição baseada no progresso e índice
      final x = (random * (i + 1)) % size.width;
      final y = size.height * (1 - progress) + (i * 10) % 100;
      
      // Tamanho do confete
      final confeteSize = 4.0 + (i % 4);
      
      // Desenha confete como retângulo
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x, y),
            width: confeteSize * 2,
            height: confeteSize,
          ),
          Radius.circular(confeteSize / 2),
        ),
        paint,
      );
    }
  }

  Color _parseColor(String colorString) {
    switch (colorString) {
      case '#FFD700':
        return const Color(0xFFFFD700); // Dourado
      case '#FFA500':
        return const Color(0xFFFFA500); // Laranja
      case '#FF6347':
        return const Color(0xFFFF6347); // Vermelho
      case '#9370DB':
        return const Color(0xFF9370DB); // Roxo
      case '#4169E1':
        return const Color(0xFF4169E1); // Azul
      case '#00CED1':
        return const Color(0xFF00CED1); // Ciano
      case '#32CD32':
        return const Color(0xFF32CD32); // Verde
      case '#FF69B4':
        return const Color(0xFFFF69B4); // Rosa
      default:
        return const Color(0xFFFFD700); // Padrão dourado
    }
  }

  @override
  bool shouldRepaint(_ConfetesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Dialog de conquista
class _ConquestDialog extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback onDismiss;

  const _ConquestDialog({
    required this.title,
    required this.message,
    required this.onDismiss,
  });

  @override
  State<_ConquestDialog> createState() => _ConquestDialogState();
}

class _ConquestDialogState extends State<_ConquestDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    
    _controller.forward();
    
    // Auto-dismiss após 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Colors.purple.withValues(alpha: 0.1),
                Colors.blue.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                widget.message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: widget.onDismiss,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Continuar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
