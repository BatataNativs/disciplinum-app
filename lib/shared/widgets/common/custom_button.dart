import 'package:flutter/material.dart';

/// Botão customizado com tema neon do Disciplinum
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final bool isLoading;
  final bool isOutlined;
  final bool isNeon;
  final Widget? icon;
  final double borderRadius;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.isLoading = false,
    this.isOutlined = false,
    this.isNeon = true,
    this.icon,
    this.borderRadius = 12.0,
    this.textStyle,
    this.padding,
  });

  factory CustomButton.primary({
    required String text,
    VoidCallback? onPressed,
    Widget? icon,
    double? width,
    double? height,
    bool isLoading = false,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: const Color(0xFF00FFFF), // Neon cyan
      textColor: Colors.black,
      icon: icon,
      width: width,
      height: height,
      isLoading: isLoading,
      isNeon: true,
    );
  }

  factory CustomButton.secondary({
    required String text,
    VoidCallback? onPressed,
    Widget? icon,
    double? width,
    double? height,
    bool isLoading = false,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: const Color(0xFFFF00FF), // Neon magenta
      textColor: Colors.white,
      icon: icon,
      width: width,
      height: height,
      isLoading: isLoading,
      isNeon: true,
    );
  }

  factory CustomButton.outlined({
    required String text,
    VoidCallback? onPressed,
    Widget? icon,
    double? width,
    double? height,
    bool isLoading = false,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: Colors.transparent,
      textColor: const Color(0xFF00FFFF),
      icon: icon,
      width: width,
      height: height,
      isLoading: isLoading,
      isOutlined: true,
      isNeon: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor = backgroundColor ?? 
        (isOutlined ? Colors.transparent : theme.primaryColor);
    final effectiveTextColor = textColor ?? 
        (isOutlined ? backgroundColor : Colors.white);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      height: height ?? 48,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: isNeon ? effectiveBackgroundColor.withValues(alpha: 0.3) : null,
          highlightColor: isNeon ? effectiveBackgroundColor.withValues(alpha: 0.2) : null,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: isOutlined 
                  ? Border.all(color: effectiveTextColor ?? Colors.black, width: 2)
                  : null,
              boxShadow: isNeon && !isOutlined && onPressed != null
                  ? [
                      BoxShadow(
                        color: effectiveBackgroundColor.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: effectiveBackgroundColor.withValues(alpha: 0.3),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Padding(
                padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
                child: isLoading
                    ? _buildLoadingIndicator(effectiveTextColor ?? Colors.black)
                    : _buildButtonContent(effectiveTextColor ?? Colors.black),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent(Color textColor) {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon!,
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: textStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: textStyle,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

  Widget _buildLoadingIndicator(Color color) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

/// Botão com efeito de brilho neon animado
class NeonButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color neonColor;
  final Widget? icon;
  final double? width;
  final double? height;

  const NeonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.neonColor = const Color(0xFF00FFFF),
    this.icon,
    this.width,
    this.height,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height ?? 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.neonColor.withValues(alpha: _glowAnimation.value),
                blurRadius: 12,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: widget.neonColor.withValues(alpha: _glowAnimation.value * 0.5),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: widget.neonColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: widget.neonColor, width: 2),
              ),
            ),
            child: widget.icon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      widget.icon!,
                      const SizedBox(width: 8),
                      Text(widget.text),
                    ],
                  )
                : Text(widget.text),
          ),
        );
      },
    );
  }
}

/// Botão flutuante com tema neon
class NeonFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final Color? backgroundColor;
  final String? tooltip;

  const NeonFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.backgroundColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final color = backgroundColor ?? const Color(0xFF00FFFF);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 12,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.black,
        elevation: 0,
        tooltip: tooltip,
        child: IconTheme(
          data: IconThemeData(color: color),
          child: icon,
        ),
      ),
    );
  }
}
