import 'package:flutter/material.dart';
import '../shared_widgets.dart';

/// Switch com tema neon
class NeonSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final String? label;

  const NeonSwitch({
    required this.value,
    required this.onChanged,
    this.activeColor = AppColors.neonBlue,
    this.label,
    super.key,
  });

  @override
  State<NeonSwitch> createState() => _NeonSwitchState();
}

class _NeonSwitchState extends State<NeonSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

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
  void didUpdateWidget(NeonSwitch oldWidget) {
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 12),
        ],
        GestureDetector(
          onTap: () => widget.onChanged(!widget.value),
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                width: 48,
                height: 24,
                decoration: BoxDecoration(
                  color: widget.value ? widget.activeColor : Colors.black,
                  borderRadius: BorderRadius.circular(12),
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
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  alignment: widget.value ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
