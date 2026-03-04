import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/models/gamification/insignia.dart';
import 'package:disciplinum/widgets/home/neon_card.dart';

class MyProgressFocus extends StatelessWidget {
  const MyProgressFocus({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gamification = Provider.of<GamificationService>(context);
    final dias = gamification.diasConsecutivosByModule[NicheId.focus] ?? 0;
    final isActive = gamification.isModuleActive(NicheId.focus);
    final earned = gamification.earnedFocusInsignias;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conquistas'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDark ? Colors.black : const Color.fromARGB(255, 226, 229, 251),
              isDark ? Colors.black : const Color.fromARGB(255, 255, 255, 255),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Card de progresso ---
                NeonCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/icons/niche_foco.png',
                        height: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isActive
                            ? '$dias períodos respeitados'
                            : 'Módulo desativado',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isActive
                              ? const Color.fromARGB(255, 105, 139, 240)
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getMedalText(dias),
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // --- Grid de Insígnias ---
                Text(
                  'Insígnias de Foco',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ganhe insígnias ao respeitar seus períodos de foco.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: FocusInsignia.values.map((insignia) {
                    final isEarned = earned.contains(insignia);
                    return _InsigniaGridItem(
                      insignia: insignia,
                      isEarned: isEarned,
                      isDark: isDark,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getMedalText(int dias) {
    if (dias >= 10) {
      return '💎 Você alcançou o nível Diamante!';
    }
    if (dias >= 7) {
      return '🥇 Medalha de Ouro! Faltam ${10 - dias} dias para Diamante.';
    }
    if (dias >= 5) {
      return '🥈 Medalha de Prata! Faltam ${7 - dias} dias para Ouro.';
    }
    if (dias >= 3) {
      return '🥉 Medalha de Bronze! Faltam ${5 - dias} dias para Prata.';
    }
    return 'Faltam ${3 - dias} dias para sua primeira medalha (Bronze).';
  }
}

// --- Widget individual da insígnia no grid ---
class _InsigniaGridItem extends StatelessWidget {
  final FocusInsignia insignia;
  final bool isEarned;
  final bool isDark;

  const _InsigniaGridItem({
    required this.insignia,
    required this.isEarned,
    required this.isDark,
  });

  static const _grayscaleMatrix = <double>[
    0.2126,
    0.7152,
    0.0722,
    0.0,
    0.0,
    0.2126,
    0.7152,
    0.0722,
    0.0,
    0.0,
    0.2126,
    0.7152,
    0.0722,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    1.0,
    0.0,
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showTooltip(context),
      child: Column(
        children: [
          Expanded(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isEarned ? 1.0 : 0.35,
              child: isEarned
                  ? Image.asset(
                      insignia.asset,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.shield,
                        color: Color(0xFF6366F1),
                        size: 40,
                      ),
                    )
                  : ColorFiltered(
                      colorFilter: const ColorFilter.matrix(_grayscaleMatrix),
                      child: Image.asset(
                        insignia.asset,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.shield,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            insignia.nameBr.split(' ').last,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: isEarned
                  ? (isDark ? Colors.white70 : Colors.black87)
                  : Colors.grey,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showTooltip(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isEarned
                ? Image.asset(insignia.asset,
                    height: 80,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.shield, size: 80))
                : ColorFiltered(
                    colorFilter: const ColorFilter.matrix(_grayscaleMatrix),
                    child: Image.asset(insignia.asset,
                        height: 80,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.shield, size: 80)),
                  ),
            const SizedBox(height: 16),
            Text(
              insignia.nameBr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isEarned
                  ? '✅ Conquistada!'
                  : insignia == FocusInsignia.ferro
                      ? 'Configure e ative o módulo de Foco.'
                      : 'Respeite ${insignia.requiredDays} período${insignia.requiredDays > 1 ? 's' : ''} de foco sem'
                          ' abrir apps proibidos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }
}
