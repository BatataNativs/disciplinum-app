import 'package:disciplinum/features/modules/spending/gamification/presentation/controllers/spending_gamification_controller.dart';
import 'package:disciplinum/shared/widgets/dialogs/deactivate_module_dialog.dart';

/// Implementação do ModuleResetService para o módulo Spending
/// Fornece independência total do GamificationService central
class SpendingModuleResetService implements ModuleResetService {
  final SpendingGamificationController _controller;

  SpendingModuleResetService(this._controller);

  @override
  Future<void> resetProgress(int nicheId) async {
    // Validação de segurança para garantir que o nicheId é do Spending
    if (nicheId != 5) { // NicheId.spending.id = 5
      throw ArgumentError('Este service só pode resetar o módulo Spending (nicheId: 5)');
    }

    // Usar o controller local do Spending
    await _controller.resetProgress();
  }
}
