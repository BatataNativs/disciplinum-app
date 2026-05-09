import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';
import 'package:disciplinum/core/gamification/repositories/pending_achievements_repository.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';

/// Serviço centralizado para gerenciar notificações push de conquistas
/// 
/// Responsável por:
/// - Enviar notificações quando usuário ganha insígnias/medalhas
/// - Salvar conquistas pendentes para exibição posterior
/// - Gerenciar IDs únicos de notificações
class AchievementNotificationService {
  static AchievementNotificationService? _instance;
  static AchievementNotificationService get instance => 
      _instance ??= AchievementNotificationService._();
  
  AchievementNotificationService._();

  /// Base ID para notificações de conquistas (range: 8000-8999)
  static const int _baseAchievementNotificationId = 8000;

  /// Envia notificação quando usuário ganha insígnia
  /// 
  /// [moduleId] - ID do módulo (ex: 'smoking', 'focus')
  /// [insigniaId] - ID da insígnia (ex: 'ouro', 'prata')
  /// [insigniaName] - Nome exibível da insígnia
  /// [insigniaDescription] - Descrição opcional
  /// [assetPath] - Caminho do ícone opcional
  Future<void> showInsigniaNotification({
    required String moduleId,
    required String insigniaId,
    required String insigniaName,
    String? insigniaDescription,
    String? assetPath,
  }) async {
    try {
      LoggerService.instance.gamification('📱 Notificação insígnia: $insigniaName ($moduleId)');

      // Gera ID único para a notificação
      final notificationId = _generateNotificationId(moduleId, 'insignia', insigniaId);
      
      // Obtém nome amigável do módulo
      final moduleName = _getModuleName(moduleId);

      // Envia notificação push
      await NotificationService.showNotification(
        id: notificationId,
        title: '🎉 Nova Insígnia Conquistada!',
        body: 'Você conquistou "$insigniaName" em $moduleName!',
        payload: jsonEncode({
          'type': 'achievement',
          'achievementType': 'insignia',
          'moduleId': moduleId,
          'achievementId': insigniaId,
          'achievementName': insigniaName,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      // Salva como pendente para mostrar dialog ao abrir app
      await PendingAchievementsRepository.instance.addPendingAchievement(
        userId: await _getCurrentUserId(),
        type: 'insignia',
        moduleId: moduleId,
        achievementId: insigniaId,
        achievementName: insigniaName,
        achievementDescription: insigniaDescription,
        assetPath: assetPath,
      );

      LoggerService.instance.gamification('✅ Notificação insígnia enviada: $insigniaName');
    } catch (e) {
      LoggerService.instance.e('❌ Erro ao enviar notificação de insígnia', error: e);
    }
  }

  /// Envia notificação quando usuário ganha medalha
  /// 
  /// [moduleId] - ID do módulo
  /// [medalhaId] - ID da medalha
  /// [medalhaName] - Nome exibível da medalha
  /// [medalhaDescription] - Descrição opcional
  /// [assetPath] - Caminho do ícone opcional
  Future<void> showMedalhaNotification({
    required String moduleId,
    required String medalhaId,
    required String medalhaName,
    String? medalhaDescription,
    String? assetPath,
    String? rarity, // comum, rara, épica, lendária
  }) async {
    try {
      LoggerService.instance.gamification('📱 Notificação medalha: $medalhaName ($moduleId)');

      final notificationId = _generateNotificationId(moduleId, 'medalha', medalhaId);
      final moduleName = _getModuleName(moduleId);

      // Emoji baseado na raridade
      final emoji = _getRarityEmoji(rarity);

      await NotificationService.showNotification(
        id: notificationId,
        title: '$emoji Nova Medalha!',
        body: 'Você conquistou a medalha "$medalhaName" em $moduleName! Continue mantendo a disciplina!',
        payload: jsonEncode({
          'type': 'achievement',
          'achievementType': 'medalha',
          'moduleId': moduleId,
          'achievementId': medalhaId,
          'achievementName': medalhaName,
          'rarity': rarity,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      await PendingAchievementsRepository.instance.addPendingAchievement(
        userId: await _getCurrentUserId(),
        type: 'medalha',
        moduleId: moduleId,
        achievementId: medalhaId,
        achievementName: medalhaName,
        achievementDescription: medalhaDescription,
        assetPath: assetPath,
      );

      LoggerService.instance.gamification('✅ Notificação medalha enviada: $medalhaName');
    } catch (e) {
      LoggerService.instance.e('❌ Erro ao enviar notificação de medalha', error: e);
    }
  }

  /// Envia notificação para eventos especiais (ex: desafio completo)
  Future<void> showSpecialAchievementNotification({
    required String moduleId,
    required String achievementId,
    required String title,
    required String body,
    String? assetPath,
  }) async {
    try {
      final notificationId = _generateNotificationId(moduleId, 'special', achievementId);

      await NotificationService.showNotification(
        id: notificationId,
        title: title,
        body: body,
        payload: jsonEncode({
          'type': 'achievement',
          'achievementType': 'special',
          'moduleId': moduleId,
          'achievementId': achievementId,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      await PendingAchievementsRepository.instance.addPendingAchievement(
        userId: await _getCurrentUserId(),
        type: 'special',
        moduleId: moduleId,
        achievementId: achievementId,
        achievementName: title,
        assetPath: assetPath,
      );

      LoggerService.instance.gamification('✅ Notificação especial enviada: $title');
    } catch (e) {
      LoggerService.instance.e('❌ Erro ao enviar notificação especial', error: e);
    }
  }

  /// Gera ID único para notificação baseado em módulo, tipo e conquista
  /// 
  /// Garante que cada conquista tenha um ID único e consistente
  int _generateNotificationId(String moduleId, String type, String achievementId) {
    // Hash simples para gerar ID único no range 8000-8999
    final combined = '${moduleId}_${type}_$achievementId';
    final hash = combined.hashCode.abs() % 1000; // 0-999
    return _baseAchievementNotificationId + hash;
  }

  /// Mapa de nomes amigáveis para módulos
  static const Map<String, String> _moduleNames = {
    'smoking': 'Parar de Fumar',
    'focus': 'Foco',
    'diet': 'Dieta',
    'spending': 'Controle de Gastos',
    'adultContent': 'Jejum 18+',
    'moneySavingChallenge': 'Desafio da Poupança',
    'procrastination': 'Produtividade',
    'reading': 'Leitura',
    'bingeEating': 'Compulsão Alimentar',
  };

  /// Obtém nome amigável do módulo
  String _getModuleName(String moduleId) {
    // Primeiro tenta o mapa local
    final friendlyName = _moduleNames[moduleId.toLowerCase()];
    if (friendlyName != null) return friendlyName;

    try {
      // Tenta obter do repositório de nichos
      final niche = NicheRepository.getAll().firstWhere(
        (n) => n.id.toString().toLowerCase() == moduleId.toLowerCase() || 
               n.name.toLowerCase() == moduleId.toLowerCase(),
        orElse: () => throw Exception('Niche not found'),
      );
      return niche.name;
    } catch (e) {
      // Fallback: retorna o ID capitalizado
      if (moduleId.isEmpty) return 'Módulo';
      return moduleId[0].toUpperCase() + moduleId.substring(1);
    }
  }

  /// Obtém emoji baseado na raridade da medalha
  String _getRarityEmoji(String? rarity) {
    switch (rarity?.toLowerCase()) {
      case 'lendária':
      case 'lendaria':
        return '👑';
      case 'épica':
      case 'epica':
        return '💎';
      case 'rara':
        return '🏆';
      case 'comum':
      default:
        return '🥉';
    }
  }

  /// Obtém ID do usuário atual do Supabase Auth
  Future<String> _getCurrentUserId() async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser != null && currentUser.id.isNotEmpty) {
        return currentUser.id;
      }
    } catch (e) {
      LoggerService.instance.w('⚠️ Erro ao obter userId do Supabase', error: e);
    }
    
    // Fallback para guest_user quando não há usuário autenticado
    return 'guest_user';
  }
}
