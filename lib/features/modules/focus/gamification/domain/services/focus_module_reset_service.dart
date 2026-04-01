import 'package:disciplinum/features/modules/focus/gamification/presentation/controllers/focus_gamification_controller_plugin.dart';
import 'package:disciplinum/shared/widgets/dialogs/deactivate_module_dialog.dart';

/// Implementação do ModuleResetService para o módulo Focus
/// Fornece independência total do GamificationService central
class FocusModuleResetService implements ModuleResetService {
  final FocusGamificationController _controller;

  FocusModuleResetService(this._controller);

  @override
  Future<void> resetProgress(int nicheId) async {
    // Validação de segurança para garantir que o nicheId é do Focus
    if (nicheId != 3) { // NicheId.focus.id = 3
      throw ArgumentError('Este service só pode resetar o módulo Focus (nicheId: 3)');
    }

    // Usar o controller local do Focus
    await _controller.resetProgress();
  }
}
