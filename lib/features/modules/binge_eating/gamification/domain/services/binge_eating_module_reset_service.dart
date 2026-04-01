import 'package:disciplinum/features/modules/binge_eating/gamification/presentation/controllers/binge_eating_gamification_controller.dart';
import 'package:disciplinum/shared/widgets/dialogs/deactivate_module_dialog.dart';

/// Implementação do ModuleResetService para o módulo BingeEating
/// Fornece independência total do GamificationService central
class BingeEatingModuleResetService implements ModuleResetService {
  final BingeEatingGamificationController _controller;

  BingeEatingModuleResetService(this._controller);

  @override
  Future<void> resetProgress(int nicheId) async {
    // Validação de segurança para garantir que o nicheId é do BingeEating
    if (nicheId != 7) { // NicheId.bingeEating.id = 7
      throw ArgumentError('Este service só pode resetar o módulo BingeEating (nicheId: 7)');
    }

    // Usar o controller local do BingeEating
    await _controller.resetProgress();
  }
}
