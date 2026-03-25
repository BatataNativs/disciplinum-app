import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/features/gamification/domain/entities/user_module_status.dart';
import 'package:disciplinum/core/navigation/navigation_service.dart';
import 'package:disciplinum/core/di/providers.dart';

/// Widget de progresso genérico para módulos
/// Reutilizável por todos os módulos do app
class ModuleProgressWidget extends ConsumerWidget {
  final NicheId nicheId;
  final String? customTitle;
  final Widget? customContent;
  final List<Widget>? customActions;

  const ModuleProgressWidget({
    super.key,
    required this.nicheId,
    this.customTitle,
    this.customContent,
    this.customActions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamification = ref.watch(gamificationServiceProvider);
    
    // Implementar getModuleStatus quando disponível
    return FutureBuilder<UserModuleStatus?>(
          future: gamification.getModuleStatus(nicheId),
          builder: (context, snapshot) {
            final moduleStatus = snapshot.data;
            final niche = NicheRepository.getById(nicheId);
        
            return Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        niche.isEmojiIcon
                            ? Text(
                                niche.iconPath,
                                style: const TextStyle(fontSize: 20),
                              )
                            : Image.asset(
                                niche.iconPath,
                                width: 24,
                                height: 24,
                                color: const Color(0xFF6366F1),
                              ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            customTitle ?? niche.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (moduleStatus != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: moduleStatus.isActive ? Colors.green : Colors.grey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              moduleStatus.isActive ? 'Ativo' : 'Inativo',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Status Info
                    if (moduleStatus != null) ...[
                      Text(
                        'Dias consecutivos: ${moduleStatus.consecutiveDays}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (moduleStatus.maxMedal != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Máxima medalha: ${moduleStatus.maxMedal}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],
                    
                    // Conteúdo customizado
                    if (customContent != null) ...[
                      customContent!,
                      const SizedBox(height: 16),
                    ],
                    
                    // Actions
                    if (customActions != null)
                      ...customActions!
                    else
                      ..._buildDefaultActions(context, nicheId),
                  ],
                ),
              ),
            );
          },
        );
  }

  List<Widget> _buildDefaultActions(BuildContext context, NicheId nicheId) {
    return [
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // Navegar para configurações do módulo
            NavigationService.navigateToModule(nicheId.id);
          },
          child: const Text('Configurações'),
        ),
      ),
    ];
  }

}
