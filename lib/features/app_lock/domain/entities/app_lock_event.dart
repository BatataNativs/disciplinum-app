import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:flutter/foundation.dart';

/// Evento de bloqueio de app
/// Representa a tentativa de abrir um app monitorado
class AppLockEvent {
  /// Nome do pacote do app bloqueado
  final String packageName;
  
  /// Nome amigável do app
  final String appName;
  
  /// Ícone do app (bytes da imagem)
  final Uint8List? appIconBytes;
  
  /// ID do módulo ativo
  final NicheId nicheId;
  
  /// Mensagem de alerta personalizada
  final String alertMessage;
  
  /// Timestamp do evento
  final DateTime timestamp;
  
  /// Callback quando usuário escolhe sair
  final VoidCallback onExitApp;
  
  /// Callback quando usuário escolhe abrir
  final VoidCallback onOpenApp;

  const AppLockEvent({
    required this.packageName,
    required this.appName,
    this.appIconBytes,
    required this.nicheId,
    required this.alertMessage,
    required this.timestamp,
    required this.onExitApp,
    required this.onOpenApp,
  });
}
