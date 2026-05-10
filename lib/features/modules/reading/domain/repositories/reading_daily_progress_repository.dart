import 'package:disciplinum/core/logging/logger_service.dart';

/// Repository para gerenciar dados de progresso diário de leitura
class ReadingDailyProgressRepository {
  static ReadingDailyProgressRepository? _instance;
  static ReadingDailyProgressRepository get instance {
    _instance ??= ReadingDailyProgressRepository._();
    return _instance!;
  }

  ReadingDailyProgressRepository._();

  /// Obtém dados de progresso dos últimos 7 dias (simulados baseado no streak)
  Future<Map<String, int>> getWeeklyProgress(String userId) async {
    try {
      // Simula dados de progresso semanal baseado em padrões realistas
      final weeklyData = <String, int>{
        'Seg': 0,
        'Ter': 0,
        'Qua': 0,
        'Qui': 0,
        'Sex': 0,
        'Sáb': 0,
        'Dom': 0,
      };

      // Gera dados realistas para demonstração
      // Em um app real, estes dados viriam do registro diário do usuário
      final random = DateTime.now().millisecondsSinceEpoch % 100;
      
      weeklyData['Seg'] = 15 + (random % 30);
      weeklyData['Ter'] = 22 + (random % 25);
      weeklyData['Qua'] = 18 + (random % 35);
      weeklyData['Qui'] = 28 + (random % 20);
      weeklyData['Sex'] = 12 + (random % 40);
      weeklyData['Sáb'] = 35 + (random % 15);
      weeklyData['Dom'] = 20 + (random % 30);

      LoggerService.instance.d('Progresso semanal simulado gerado para $userId');
      return weeklyData;
    } catch (e) {
      LoggerService.instance.e('Erro ao obter progresso semanal', error: e);
      // Retorna dados zerados em caso de erro
      return {
        'Seg': 0,
        'Ter': 0,
        'Qua': 0,
        'Qui': 0,
        'Sex': 0,
        'Sáb': 0,
        'Dom': 0,
      };
    }
  }
}
