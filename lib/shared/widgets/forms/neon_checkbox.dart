import 'package:flutter/material.dart';
import '../shared_widgets.dart';

/// Checkbox com tema neon
class NeonCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final Color activeColor;

  const NeonCheckbox({
    required this.value,
    this.onChanged,
    this.label,
    this.activeColor = AppColors.neonBlue,
    super.key,
  });

  @override
  State<NeonCheckbox> createState() => _NeonCheckboxState();
}

class _NeonCheckboxState extends State<NeonCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.2,
      end: 0.6,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.value) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(NeonCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onChanged != null ? () => widget.onChanged!(!widget.value) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: widget.activeColor.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  boxShadow: widget.value
                      ? [
                          BoxShadow(
                            color: widget.activeColor.withValues(alpha: _glowAnimation.value),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Icon(
                      Icons.check,
                      color: widget.activeColor,
                      size: 16,
                    ),
                  ),
                ),
              );
            },
          ),
          if (widget.label != null) ...[
            const SizedBox(width: 12),
            Text(
              widget.label!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
