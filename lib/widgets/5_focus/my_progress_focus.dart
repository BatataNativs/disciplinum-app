import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/services/auth/auth_service.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/models/gamification/insignia.dart';
import 'package:disciplinum/models/gamification/medal.dart';

class MyProgressFocus extends StatelessWidget {
  const MyProgressFocus({super.key});

  @override
  Widget build(BuildContext context) {
    final gamification = Provider.of<GamificationService>(context);
    final authService = Provider.of<AuthService>(context);
    final periodosRespeitados = gamification.getRespectedFocusPeriods(NicheId.focus); // NOVO: Usar períodos de foco
    final earnedInsignias = gamification.earnedFocusInsignias;

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
                children: GamificationMedal.values.map((medal) {
                  final isEarned =
                      (medal == GamificationMedal.bronze && periodosRespeitados >= 3) ||
                          (medal == GamificationMedal.prata && periodosRespeitados >= 5) ||
                          (medal == GamificationMedal.ouro && periodosRespeitados >= 7) ||
                          (medal == GamificationMedal.diamante && periodosRespeitados >= 10);

                  return _AwardItem(
                    asset: medal.asset,
                    label: medal.nameBr,
                    isEarned: isEarned,
                    requirement: _getMedalRequirement(medal),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 32),

            // --- Seção: Insígnias ---
            const Text(
              'Insígnias',
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
                children: FocusInsignia.values.map((insignia) {
                  final isEarned = earnedInsignias.contains(insignia);
                  return _AwardItem(
                    asset: insignia.asset,
                    label: insignia.nameBr.split(' ').last,
                    isEarned: isEarned,
                    requirement: _getInsigniaRequirement(insignia),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMedalRequirement(GamificationMedal medal) {
    switch (medal) {
      case GamificationMedal.bronze:
        return '3 períodos de foco'; // CORRIGIDO: períodos em vez de dias
      case GamificationMedal.prata:
        return '5 períodos de foco';
      case GamificationMedal.ouro:
        return '7 períodos de foco';
      case GamificationMedal.diamante:
        return '10 períodos de foco';
    }
  }

  String _getInsigniaRequirement(FocusInsignia insignia) {
    if (insignia == FocusInsignia.madeira) return 'Ative o módulo de Foco'; // CORRIGIDO: madeira em vez de ferro
    return '${insignia.requiredDays} períodos de foco respeitados';
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
