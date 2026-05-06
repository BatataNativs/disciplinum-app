import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/features/modules/focus/gamification/presentation/providers/focus_gamification_provider.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/entities/focus_insignia.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/entities/focus_medal.dart';

class MyProgressFocus extends ConsumerWidget {
  const MyProgressFocus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dias = ref.watch(focusStreakProvider);
    final totalMinutes = ref.watch(focusTotalMinutesProvider);
    final disciplinumCount = ref.watch(focusDisciplinumCountProvider);
    final earnedInsignias = ref.watch(focusInsigniasProvider);
    final earnedMedalhas = ref.watch(focusMedalhasProvider);
    final authService = ref.watch(authServiceProvider);

    // Lógica para obter o primeiro nome
    String fullName = authService.userProfile?['name'] ?? 'Usuário';
    String firstName = fullName.split(' ').first;
    if (firstName.isEmpty) firstName = 'Usuário';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Conquistas', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Olá, $firstName!',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 4),
              const Text(
                'Seu progresso no módulo: Foco e Produtividade',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Streak atual
              _buildStatCard(
                icon: Icons.local_fire_department,
                value: '$dias',
                label: 'dias consecutivos',
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                icon: Icons.timer,
                value: '${(totalMinutes / 60).floor()}h ${totalMinutes % 60}min',
                label: 'tempo total focado',
                color: const Color(0xFF6366F1),
              ),
              const SizedBox(height: 32),

              // INSÍGNIAS
              const Text(
                'Insígnias',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 4),
              const Text(
                'Conquistas por períodos de foco respeitados',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                  children: FocusInsignia.values.map((insignia) {
                    final isEarned = earnedInsignias.contains(insignia.name);

                    // Badge count para insígnia Disciplinum
                    final badgeCount = (insignia.name == 'disciplinum' && disciplinumCount > 1)
                        ? disciplinumCount
                        : null;

                    return _AwardItem(
                      asset: insignia.asset,
                      label: insignia.nameBr,
                      isEarned: isEarned,
                      requirement: insignia.requirementDescription,
                      badgeCount: badgeCount,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

            // MEDALHAS
            const Text(
              'Medalhas',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 4),
            const Text(
              'Conquistas por insígnias especiais',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(24),
              ),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.9,
                children: FocusMedalEntity.values.map((medal) {
                  final isEarned = earnedMedalhas.contains(medal.name) ||
                      medal.canBeAwarded(earnedInsignias);

                  return _AwardItem(
                    asset: medal.asset,
                    label: medal.nameBr,
                    isEarned: isEarned,
                    requirement: medal.requirementDescription,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Contador de Disciplinum
            if (disciplinumCount > 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      '$disciplinumCount insígnia${disciplinumCount > 1 ? 's' : ''} Disciplinum conquistada${disciplinumCount > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AwardItem extends StatelessWidget {
  final String asset;
  final String label;
  final bool isEarned;
  final String requirement;
  final int? badgeCount;

  const _AwardItem({
    required this.asset,
    required this.label,
    required this.isEarned,
    required this.requirement,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ColorFiltered(
                  colorFilter: isEarned
                      ? const ColorFilter.mode(
                          Colors.transparent, BlendMode.multiply)
                      : const ColorFilter.matrix(<double>[
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0,
                          0,
                          0,
                          1,
                          0,
                        ]),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Opacity(
                      opacity: isEarned ? 1.0 : 0.4,
                      child: Image.asset(asset, fit: BoxFit.contain),
                    ),
                  ),
                ),
                // Badge de contador (tipo notificação)
                if (badgeCount != null && isEarned)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isEarned ? Colors.white : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorFiltered(
              colorFilter: isEarned
                  ? const ColorFilter.mode(
                      Colors.transparent, BlendMode.multiply)
                  : const ColorFilter.matrix(<double>[
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0,
                      0,
                      0,
                      1,
                      0,
                    ]),
              child: Opacity(
                opacity: isEarned ? 1.0 : 0.4,
                child: Image.asset(asset, height: 100),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isEarned 
                ? '✅ Conquistada!\n\nRequisito:\n$requirement'
                : 'Requisito:\n$requirement',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ok', style: TextStyle(color: Color(0xFF6366F1))),
          ),
        ],
      ),
    );
  }
}
