import 'package:disciplinum/features/modules/adult_content/gamification/presentation/controllers/adult_content_gamification_controller.dart';
import 'package:disciplinum/shared/widgets/dialogs/deactivate_module_dialog.dart';

/// Implementação do ModuleResetService para o módulo AdultContent
/// Fornece independência total do GamificationService central
class AdultContentModuleResetService implements ModuleResetService {
  final AdultContentGamificationController _controller;

  AdultContentModuleResetService(this._controller);

  @override
  Future<void> resetProgress(int nicheId) async {
    // Validação de segurança para garantir que o nicheId é do AdultContent
    if (nicheId != 8) { // NicheId.adultContent.id = 8
      throw ArgumentError('Este service só pode resetar o módulo AdultContent (nicheId: 8)');
    }

    // Usar o controller local do AdultContent
    await _controller.resetProgress();
  }
}
