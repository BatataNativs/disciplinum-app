import 'package:flutter/material.dart';

class ScrollIndicatorArrow extends StatefulWidget {
  final ScrollController controller;
  final Color? color;

  const ScrollIndicatorArrow({
    super.key,
    required this.controller,
    this.color,
  });

  @override
  State<ScrollIndicatorArrow> createState() => _ScrollIndicatorArrowState();
}

class _ScrollIndicatorArrowState extends State<ScrollIndicatorArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(begin: 0.2, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    widget.controller.addListener(_scrollListener);
    // Verificar visibilidade inicial após o build
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollListener());
  }

  void _scrollListener() {
    if (!mounted) return;

    // Se o conteúdo não for rolável (scrollbar não aparece), esconde a seta
    if (!widget.controller.hasClients ||
        widget.controller.position.maxScrollExtent <= 0) {
      if (_isVisible) setState(() => _isVisible = false);
      return;
    }

    // Esconde a seta quando chegar perto do fim (ex: 20 pixels do final)
    final reachedEnd = widget.controller.offset >=
        widget.controller.position.maxScrollExtent - 20;

    if (reachedEnd && _isVisible) {
      setState(() => _isVisible = false);
    } else if (!reachedEnd && !_isVisible) {
      setState(() => _isVisible = true);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_scrollListener);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final indicatorColor = widget.color ??
        (theme.brightness == Brightness.dark ? Colors.white30 : Colors.black26);

    return FadeTransition(
      opacity: _opacityAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: indicatorColor,
          size: 28,
        ),
      ),
    );
  }
}
