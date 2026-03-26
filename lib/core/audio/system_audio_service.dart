import 'package:flutter/services.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Service de áudio do sistema que não requer arquivos externos
/// Usa sons nativos do sistema ou gera tons programaticamente
class SystemAudioService {
  static SystemAudioService? _instance;
  static SystemAudioService get instance => _instance ??= SystemAudioService._();
  
  SystemAudioService._();

  bool _isInitialized = false;
  double _masterVolume = 1.0;

  /// Inicializa o serviço de áudio do sistema
  Future<void> initialize() async {
    try {
      // Testa se o sistema suporta feedback tátil
      await HapticFeedback.lightImpact();
      
      _isInitialized = true;
      LoggerService.instance.d('SystemAudioService inicializado com sucesso');
    } catch (e) {
      LoggerService.instance.e('Erro ao inicializar SystemAudioService', error: e);
    }
  }

  /// Verifica se o serviço está inicializado
  bool get isInitialized => _isInitialized;

  /// Define o volume master
  void setMasterVolume(double volume) {
    _masterVolume = volume.clamp(0.0, 1.0);
    LoggerService.instance.d('Volume master definido: $_masterVolume');
  }

  /// Reproduz feedback tátil baseado no tipo
  Future<void> playHapticFeedback(String tipo) async {
    if (!_isInitialized) return;
    
    try {
      switch (tipo.toLowerCase()) {
        case 'leve':
        case 'light':
          await HapticFeedback.lightImpact();
          break;
        case 'medio':
        case 'media':
        case 'medium':
          await HapticFeedback.mediumImpact();
          break;
        case 'forte':
        case 'heavy':
          await HapticFeedback.heavyImpact();
          break;
        case 'selecao':
        case 'selection':
          await HapticFeedback.selectionClick();
          break;
        case 'impacto':
        case 'impact':
          await HapticFeedback.heavyImpact(); // Usa heavyImpact como alternativa
          break;
        default:
          await HapticFeedback.mediumImpact();
      }
      
      LoggerService.instance.d('Feedback tátil reproduzido: $tipo');
    } catch (e) {
      LoggerService.instance.e('Erro no feedback tátil: $tipo', error: e);
    }
  }

  /// Reproduz "som" de conquista usando apenas feedback tátil
  /// Esta é a alternativa que não requer arquivos de áudio
  Future<void> playConquestSound(String tipo, {double volume = 1.0}) async {
    if (!_isInitialized) return;
    
    try {
      // Ajusta a intensidade baseada no volume
      final adjustedVolume = (volume * _masterVolume).clamp(0.0, 1.0);
      
      switch (tipo.toLowerCase()) {
        case 'normal':
          if (adjustedVolume > 0.7) {
            await HapticFeedback.mediumImpact();
          } else {
            await HapticFeedback.lightImpact();
          }
          break;
          
        case 'epico':
          // Sequência epic: leve -> medio -> forte
          await HapticFeedback.lightImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          await HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          await HapticFeedback.heavyImpact();
          break;
          
        case 'medalha':
          // Padrão de medalha: medio -> forte
          await HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 150));
          await HapticFeedback.heavyImpact(); // Usa heavyImpact como alternativa
          break;
          
        case 'disciplinum':
          // Padrão Disciplinum: sequência completa
          await HapticFeedback.lightImpact();
          await Future.delayed(const Duration(milliseconds: 80));
          await HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 80));
          await HapticFeedback.heavyImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          await HapticFeedback.heavyImpact(); // Usa heavyImpact como alternativa
          break;
          
        case 'milestone':
          // Milestone: seleção + medio
          await HapticFeedback.selectionClick();
          await Future.delayed(const Duration(milliseconds: 100));
          await HapticFeedback.mediumImpact();
          break;
          
        default:
          await HapticFeedback.mediumImpact();
      }
      
      LoggerService.instance.d('Som de conquista reproduzido (tátil): $tipo (volume: $adjustedVolume)');
    } catch (e) {
      LoggerService.instance.e('Erro ao reproduzir som de conquista: $tipo', error: e);
    }
  }

  /// Reproduz efeito sonoro visual (sem áudio real)
  Future<void> playSfx(String assetPath, {double volume = 1.0}) async {
    if (!_isInitialized) return;
    
    try {
      // Converte o nome do arquivo para tipo de feedback tátil
      final tipo = _extractTypeFromPath(assetPath);
      await playHapticFeedback(tipo);
      
      LoggerService.instance.d('SFX reproduzido (tátil): $assetPath -> $tipo');
    } catch (e) {
      LoggerService.instance.e('Erro ao reproduzir SFX: $assetPath', error: e);
    }
  }

  /// Extrai tipo de feedback do caminho do arquivo
  String _extractTypeFromPath(String assetPath) {
    final fileName = assetPath.split('/').last.toLowerCase();
    
    if (fileName.contains('epic') || fileName.contains('epico')) {
      return 'epico';
    } else if (fileName.contains('medalha') || fileName.contains('medal')) {
      return 'medalha';
    } else if (fileName.contains('disciplinum')) {
      return 'disciplinum';
    } else if (fileName.contains('milestone') || fileName.contains('marco')) {
      return 'milestone';
    } else if (fileName.contains('normal') || fileName.contains('conquest')) {
      return 'medio';
    } else {
      return 'medio'; // padrão
    }
  }

  /// Reproduz som de voz (usando apenas feedback tátil)
  Future<void> playVoice(String assetPath, {double volume = 1.0}) async {
    if (!_isInitialized) return;
    
    try {
      // Para narração, usa feedback tátil suave
      await HapticFeedback.selectionClick();
      
      LoggerService.instance.d('Voz reproduzida (tátil): $assetPath');
    } catch (e) {
      LoggerService.instance.e('Erro ao reproduzir voz: $assetPath', error: e);
    }
  }

  /// Para todos os sons (não aplicável ao sistema tátil)
  Future<void> stopAll() async {
    // Não há como "parar" feedback tátil, mas podemos log
    LoggerService.instance.d('Todos os "sons" parados (sistema tátil)');
  }

  /// Pausa todos os sons (não aplicável)
  Future<void> pauseAll() async {
    LoggerService.instance.d('Todos os "sons" pausados (sistema tátil)');
  }

  /// Resume todos os sons (não aplicável)
  Future<void> resumeAll() async {
    LoggerService.instance.d('Todos os "sons" resumidos (sistema tátil)');
  }

  /// Libera recursos
  Future<void> dispose() async {
    _isInitialized = false;
    LoggerService.instance.d('SystemAudioService disposed');
  }

  /// Obtém informações sobre o estado atual
  Map<String, dynamic> getStatus() {
    return {
      'initialized': _isInitialized,
      'masterVolume': _masterVolume,
      'type': 'haptic_feedback_only',
      'requiresExternalFiles': false,
    };
  }

  /// Verifica se o dispositivo suporta feedback tátil
  Future<bool> hasHapticSupport() async {
    try {
      await HapticFeedback.lightImpact();
      return true;
    } catch (e) {
      return false;
    }
  }
}
