import 'package:disciplinum/features/modules/diet/gamification/presentation/controllers/diet_gamification_controller.dart';
import 'package:disciplinum/shared/widgets/dialogs/deactivate_module_dialog.dart';

/// Implementação do ModuleResetService para o módulo Diet
/// Fornece independência total do GamificationService central
class DietModuleResetService implements ModuleResetService {
  final DietGamificationController _controller;

  DietModuleResetService(this._controller);

  @override
  Future<void> resetProgress(int nicheId) async {
    // Validação de segurança para garantir que o nicheId é do Diet
    if (nicheId != 2) { // NicheId.diet.id = 2
      throw ArgumentError('Este service só pode resetar o módulo Diet (nicheId: 2)');
    }

    // Usar o controller local do Diet
    await _controller.resetProgress();
  }
}
