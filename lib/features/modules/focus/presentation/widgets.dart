import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/entities/focus_insignia.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/entities/focus_medalha.dart';

class MyProgressFocus extends ConsumerWidget {
  const MyProgressFocus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusService = ref.watch(focusServiceProvider);
    final earnedInsigniasFuture = focusService.getEarnedInsignias(); // CORRIGIDO: Obter do FocusService

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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Título do Módulo ---
            const Text(
              'Foco e Produtividade',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Seu progresso no módulo',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // --- Seção: Medalhas ---
            const Text(
              'Medalhas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E), // Cinza escuro/grafite
                borderRadius: BorderRadius.circular(24),
              ),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.8,
                children: FocusMedalha.values.map((medal) {
                  return FutureBuilder<List<FocusInsignia>?>(
                    future: earnedInsigniasFuture.then((list) => list as List<FocusInsignia>?),
                    builder: (context, snapshot) {
                      final earnedInsignias = snapshot.data ?? [];
                      final earnedInsigniaNames = earnedInsignias.map((insignia) => insignia.name).toList();
                      final isEarned = medal.canBeAwarded(earnedInsigniaNames);
                      
                      return _AwardItem(
                        asset: medal.asset,
                        label: medal.nameBr,
                        isEarned: isEarned,
                        requirement: _getMedalRequirement(medal),
                      );
                    },
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 32),

            // --- Seção: Insígnias ---
            Text(
              'Insígnias',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Grid de insígnias
            FutureBuilder<List<FocusInsignia>?>(
              future: earnedInsigniasFuture.then((list) => list as List<FocusInsignia>?), // Convert to nullable
              builder: (context, snapshot) {
                final earnedInsignias = snapshot.data ?? [];
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.8,
                  children: FocusInsignia.values.map((insignia) {
                    final isEarned = earnedInsignias.contains(insignia);
                    return _AwardItem(
                      asset: insignia.asset,
                      label: insignia.nameBr.split(' ').last,
                      isEarned: isEarned,
                      requirement: '', // Insígnias não têm requisitos
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getMedalRequirement(FocusMedalha medal) {
    return medal.requirementDescription;
  }
}

class _AwardItem extends StatelessWidget {
  final String asset;
  final String label;
  final bool isEarned;
  final String requirement;

  const _AwardItem({
    required this.asset,
    required this.label,
    required this.isEarned,
    required this.requirement,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Column(
        children: [
          Expanded(
            child: ColorFiltered(
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
                      0,
                      1,
                      0,
                    ]),
              child: Padding(
                padding: const EdgeInsets.all(
                    14), // Controle o tamanho aqui (maior padding = menor imagem)
                child: Opacity(
                  opacity: isEarned ? 1.0 : 0.4,
                  child: Image.asset(asset, fit: BoxFit.contain),
                ),
              ),
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
