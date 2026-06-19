/// Camada Platform - Serviços nativos de plataforma
/// 
/// Esta camada contém todos os serviços que interagem diretamente com
/// funcionalidades nativas do sistema operacional (Android/iOS).
/// 
/// Estrutura:
/// - app_lock/: Serviços nativos de App Lock (AccessibilityService, LockActivity)
/// - background/: Serviços de background (Foreground Service, Work Manager)
/// - device/: Serviços de dispositivo (permissões, informações de hardware)
library;

// App Lock
export 'app_lock/installed_app_service.dart';

// Background
export 'background/foreground_service_controller.dart';

// Device
export 'device/device_info_service.dart';
export 'device/permission_service.dart';
