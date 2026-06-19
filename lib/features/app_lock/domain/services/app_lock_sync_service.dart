import 'package:disciplinum/features/app_lock/infrastructure/channels/app_lock_channel.dart';
import 'package:disciplinum/features/modules/digital_detox/domain/services/digital_detox_service_local.dart';
import 'package:disciplinum/features/modules/binge_eating/domain/services/binge_eating_service_local.dart';
import 'package:disciplinum/features/modules/adult_content/domain/services/adult_content_service_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Serviço responsável por sincronizar as configurações dos módulos
/// com a camada nativa do Android (LockDecisionEngine).
class AppLockSyncService {
  static AppLockSyncService? _instance;
  static AppLockSyncService get instance => _instance ??= AppLockSyncService._internal();

  AppLockSyncService._internal();

  /// Sincroniza todas as configurações de módulos para o Android nativo
  Future<void> syncAllConfigs() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        LoggerService.instance.w('AppLockSyncService: Usuário não logado, abortando sincronização.');
        return;
      }

      final List<Map<String, dynamic>> configs = [];
      final Set<String> allMonitoredApps = {};

      // 1. Digital Detox
      final detoxConfig = await DigitalDetoxServiceLocal.instance.getConfig(userId);
      if (detoxConfig != null) {
        if (detoxConfig.isModuleActive) {
          allMonitoredApps.addAll(detoxConfig.monitoredApps);
        }
        
        String? startTime;
        String? endTime;
        
        // Se a janela de tempo estiver ativada, o app fica PERMITIDO entre allowedStartTime e allowedEndTime.
        // O bloqueio (LockDecisionEngine) deve ficar ativo no horário oposto (do allowedEndTime até o allowedStartTime).
        if (detoxConfig.enableTimeWindow) {
          startTime = detoxConfig.allowedEndTime;
          endTime = detoxConfig.allowedStartTime;
        }

        configs.add({
          'id': 'digital_detox',
          'name': 'Digital Detox',
          'isActive': detoxConfig.isModuleActive,
          'monitoredPackages': detoxConfig.monitoredApps,
          'startTime': startTime,
          'endTime': endTime,
        });
      }

      // 2. Binge Eating
      final bingeConfig = await BingeEatingServiceLocal.instance.getConfig();
      final isBingeActive = bingeConfig.isModuleActive && bingeConfig.enableAppLock;
      if (isBingeActive) {
        allMonitoredApps.addAll(bingeConfig.monitoredApps);
      }
      configs.add({
        'id': 'binge_eating',
        'name': 'Compulsão Alimentar',
        'isActive': isBingeActive,
        'monitoredPackages': bingeConfig.monitoredApps,
      });

      // 3. Adult Content
      final adultConfig = await AdultContentServiceLocal.instance.getConfig();
      final isAdultActive = adultConfig.isModuleActive && adultConfig.enableAppLock;
      if (isAdultActive) {
        allMonitoredApps.addAll(adultConfig.monitoredApps);
      }
      configs.add({
        'id': 'adult_content',
        'name': 'Jejum 18+',
        'isActive': isAdultActive,
        'monitoredPackages': adultConfig.monitoredApps,
      });

      LoggerService.instance.i('AppLockSyncService: Enviando updateModuleConfigs: $configs');
      LoggerService.instance.i('AppLockSyncService: Enviando updateMonitoredApps: $allMonitoredApps');

      // Envia os dados para a camada nativa
      await AppLockChannel.updateModuleConfigs(configs);
      await AppLockChannel.updateMonitoredApps(allMonitoredApps.toList());

      LoggerService.instance.system('AppLockSyncService: Sincronização nativa concluída com sucesso.');
    } catch (e) {
      LoggerService.instance.e('Erro ao sincronizar configurações do App Lock nativo', error: e);
    }
  }
}
