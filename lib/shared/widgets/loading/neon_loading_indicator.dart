import 'package:flutter/material.dart';
import '../shared_widgets.dart';

/// Indicador de loading com tema neon
class NeonLoadingIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const NeonLoadingIndicator({
    this.size = 48,
    this.color = AppColors.neonBlue,
    this.strokeWidth = 3,
    super.key,
  });

  @override
  State<NeonLoadingIndicator> createState() => _NeonLoadingIndicatorState();
}

class _NeonLoadingIndicatorState extends State<NeonLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _NeonLoadingPainter(
                color: widget.color,
                strokeWidth: widget.strokeWidth,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NeonLoadingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _NeonLoadingPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw arc (3/4 of circle)
    const startAngle = -3.14159 / 2;
    const sweepAngle = 3 * 3.14159 / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_NeonLoadingPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Loading overlay com tema neon
class NeonLoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingText;
  final Color color;

  const NeonLoadingOverlay({
    required this.child,
    required this.isLoading,
    this.loadingText,
    this.color = AppColors.neonBlue,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.7),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NeonLoadingIndicator(color: color),
                  if (loadingText != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      loadingText!,
                      style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
