import 'package:disciplinum/features/modules/procrastination/gamification/presentation/controllers/procrastination_gamification_controller.dart';
import 'package:disciplinum/shared/widgets/dialogs/deactivate_module_dialog.dart';

/// Implementação do ModuleResetService para o módulo Procrastination
/// Fornece independência total do GamificationService central
class ProcrastinationModuleResetService implements ModuleResetService {
  final ProcrastinationGamificationController _controller;

  ProcrastinationModuleResetService(this._controller);

  @override
  Future<void> resetProgress(int nicheId) async {
    // Validação de segurança para garantir que o nicheId é do Procrastination
    if (nicheId != 4) { // NicheId.procrastination.id = 4
      throw ArgumentError('Este service só pode resetar o módulo Procrastination (nicheId: 4)');
    }

    // Usar o controller local do Procrastination
    await _controller.resetProgress();
  }
}
