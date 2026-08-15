import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/profile/presentation/widgets/theme_options_dialog.dart';

class ThemeButton extends ConsumerWidget {
  const ThemeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF1F2937), Color(0xFF374151)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: Icon(Icons.palette, color: Colors.white, size: 22),
        label: const Text(
          'Temas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => const ThemeOptionsDialog(),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}
