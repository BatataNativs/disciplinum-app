import 'package:flutter/material.dart';

/// Tela de Quebras de Controle do modulo Controle de Gastos
/// Permite usar uma "quebra" para acessar temporariamente apps de compras
/// Equivalente as Quebras de Jejum no Digital Detox
class SpendingControlBreakScreen extends StatelessWidget {
  const SpendingControlBreakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quebra de Controle'),
        backgroundColor: const Color(0xFFF59E0B),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card explicativo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.coffee_rounded, color: Colors.white, size: 32),
                  SizedBox(height: 12),
                  Text('Quebra de Controle',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text(
                    'Uma quebra permite acessar apps de compras temporariamente sem perder sua sequencia. Use com moderacao!',
                    style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Como ganhar quebras
            Text('Como ganhar quebras de controle?',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              icon: Icons.emoji_events_rounded,
              color: const Color(0xFFF59E0B),
              title: 'Sequencias longas',
              subtitle:
                  'Apos 7 dias sem acessar apps bloqueados, voce ganha uma quebra de controle.',
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              icon: Icons.star_rounded,
              color: const Color(0xFF8B5CF6),
              title: 'Conquistas especiais',
              subtitle:
                  'Certas medalhas e insignias tambem concedem quebras de controle como recompensa.',
            ),
            const SizedBox(height: 24),

            // Aviso importante
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.orange.shade700, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Uso responsavel',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade800)),
                        const SizedBox(height: 4),
                        Text(
                          'Cada quebra tem validade de 30 dias. Use apenas quando realmente necessario para nao comprometer seu controle financeiro.',
                          style: TextStyle(
                              color: Colors.orange.shade700, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Placeholder - quebras disponiveis
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Icon(Icons.coffee_rounded,
                      size: 48,
                      color: colorScheme.onSurface.withValues(alpha: 0.3)),
                  const SizedBox(height: 12),
                  Text(
                    'Nenhuma quebra disponivel',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Continue com sua sequencia para ganhar quebras de controle!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.5)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context,
      {required IconData icon,
      required Color color,
      required String title,
      required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        color: Color(0xFF6B7280), fontSize: 13, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
