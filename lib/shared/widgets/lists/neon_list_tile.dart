import 'package:flutter/material.dart';
import '../shared_widgets.dart';

/// ListTile com tema neon
class NeonListTile extends StatefulWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? accentColor;
  final bool showGlow;
  final EdgeInsetsGeometry? contentPadding;

  const NeonListTile({
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.accentColor,
    this.showGlow = true,
    this.contentPadding,
    super.key,
  });

  @override
  State<NeonListTile> createState() => _NeonListTileState();
}

class _NeonListTileState extends State<NeonListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHoverChange(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    
    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.accentColor ?? AppColors.neonBlue;
    
    return MouseRegion(
      onEnter: (_) => _onHoverChange(true),
      onExit: (_) => _onHoverChange(false),
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: accentColor.withValues(alpha: _isHovered ? 0.5 : 0.3),
                width: 1,
              ),
              boxShadow: widget.showGlow && _isHovered
                  ? [
                      BoxShadow(
                        color: accentColor.withValues(alpha: _glowAnimation.value),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: widget.contentPadding ?? const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (widget.leading != null) ...[
                        widget.leading!,
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.title != null)
                              DefaultTextStyle(
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                child: widget.title!,
                              ),
                            if (widget.subtitle != null) ...[
                              const SizedBox(height: 4),
                              DefaultTextStyle(
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 14,
                                ),
                                child: widget.subtitle!,
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (widget.trailing != null) ...[
                        const SizedBox(width: 16),
                        widget.trailing!,
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ListTile para seleção com tema neon
class NeonSelectionListTile extends StatefulWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final bool selected;
  final ValueChanged<bool>? onChanged;
  final Color? accentColor;
  final NeonSelectionType selectionType;

  const NeonSelectionListTile({
    this.leading,
    this.title,
    this.subtitle,
    required this.selected,
    this.onChanged,
    this.accentColor,
    this.selectionType = NeonSelectionType.checkbox,
    super.key,
  });

  @override
  State<NeonSelectionListTile> createState() => _NeonSelectionListTileState();
}

class _NeonSelectionListTileState extends State<NeonSelectionListTile>
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
      begin: 0.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.selected) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(NeonSelectionListTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      if (widget.selected) {
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
    final accentColor = widget.accentColor ?? AppColors.neonBlue;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: accentColor.withValues(alpha: widget.selected ? 0.5 : 0.3),
              width: 1,
            ),
            boxShadow: widget.selected
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: _glowAnimation.value),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onChanged != null ? () => widget.onChanged!(!widget.selected) : null,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildSelectionWidget(accentColor),
                    const SizedBox(width: 16),
                    if (widget.leading != null) ...[
                      widget.leading!,
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.title != null)
                            DefaultTextStyle(
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              child: widget.title!,
                            ),
                          if (widget.subtitle != null) ...[
                            const SizedBox(height: 4),
                            DefaultTextStyle(
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 14,
                              ),
                              child: widget.subtitle!,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectionWidget(Color accentColor) {
    switch (widget.selectionType) {
      case NeonSelectionType.checkbox:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Icon(
                Icons.check,
                color: accentColor,
                size: 16,
              ),
            ),
          ),
        );
      case NeonSelectionType.radio:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
            border: Border.all(
              color: accentColor.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      case NeonSelectionType.switch_:
        return Container(
          width: 48,
          height: 24,
          decoration: BoxDecoration(
            color: widget.selected ? accentColor : Colors.black,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: widget.selected ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
    }
  }
}

/// Tipos de seleção neon
enum NeonSelectionType {
  checkbox,
  radio,
  switch_,
}
