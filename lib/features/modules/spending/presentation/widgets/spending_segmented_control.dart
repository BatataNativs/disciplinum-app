import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget de controle de abas da tela Spending
class SpendingSegmentedControl extends StatelessWidget {
  final int selectedIndex;
  final PageController pageController;
  final Function(int) onIndexChanged;

  const SpendingSegmentedControl({
    super.key,
    required this.selectedIndex,
    required this.pageController,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final List<String> options = ['Controlar Gastos', 'Como Funciona'];

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(options.length, (index) {
          final isSelected = selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                if (pageController.hasClients) {
                  pageController.animateToPage(index,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutQuad);
                } else {
                  onIndexChanged(index);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFF6366F1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color:
                                const Color(0xFF6366F1).withValues(alpha: 0.3),
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
