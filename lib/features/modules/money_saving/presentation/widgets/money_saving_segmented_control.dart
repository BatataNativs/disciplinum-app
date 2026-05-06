import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MoneySavingSegmentedControl extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;

  const MoneySavingSegmentedControl({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  State<MoneySavingSegmentedControl> createState() => _MoneySavingSegmentedControlState();
}

class _MoneySavingSegmentedControlState extends State<MoneySavingSegmentedControl> {
  final List<String> options = ['Desafio da Poupança', 'Como Funciona'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(options.length, (index) {
          final isSelected = widget.selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                widget.onIndexChanged(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  options[index],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : colorScheme.onSurface.withValues(alpha: 0.6),
                    letterSpacing: isSelected ? 0.3 : 0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
