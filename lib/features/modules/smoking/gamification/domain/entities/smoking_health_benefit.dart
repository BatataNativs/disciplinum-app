/// Entidade de benefícios de saúde específicos do módulo Smoking
/// Notificações especiais que aparecem em marcos específicos
enum SmokingHealthBenefitEntity {
  bloodPressure,    // 20 minutos - Pressão arterial normal
  carbonMonoxide,   // 1 dia - Sem monóxido de carbono
  tasteSmell,       // 2 dias - Olfato e paladar melhoram
  breathing,        // 3 dias - Respiração mais fácil
  circulation,      // 14 dias - Circulação melhora
  lungFunction;     // 90 dias - Função pulmonar +10%
}

extension SmokingHealthBenefitEntityExtension on SmokingHealthBenefitEntity {
  /// Converte para string para armazenamento
  String get name {
    switch (this) {
      case SmokingHealthBenefitEntity.bloodPressure:
        return 'blood_pressure';
      case SmokingHealthBenefitEntity.carbonMonoxide:
        return 'carbon_monoxide';
      case SmokingHealthBenefitEntity.tasteSmell:
        return 'taste_smell';
      case SmokingHealthBenefitEntity.breathing:
        return 'breathing';
      case SmokingHealthBenefitEntity.circulation:
        return 'circulation';
      case SmokingHealthBenefitEntity.lungFunction:
        return 'lung_function';
    }
  }

  /// Obtém o tempo em minutos/horas/dias para este benefício
  String get timeRequired {
    switch (this) {
      case SmokingHealthBenefitEntity.bloodPressure:
        return '20 minutos';
      case SmokingHealthBenefitEntity.carbonMonoxide:
        return '1 dia';
      case SmokingHealthBenefitEntity.tasteSmell:
        return '2 dias';
      case SmokingHealthBenefitEntity.breathing:
        return '3 dias';
      case SmokingHealthBenefitEntity.circulation:
        return '14 dias';
      case SmokingHealthBenefitEntity.lungFunction:
        return '90 dias';
    }
  }

  /// Obtém o tempo em minutos para cálculo
  int get timeInMinutes {
    switch (this) {
      case SmokingHealthBenefitEntity.bloodPressure:
        return 20; // 20 minutos
      case SmokingHealthBenefitEntity.carbonMonoxide:
        return 24 * 60; // 1 dia = 1440 minutos
      case SmokingHealthBenefitEntity.tasteSmell:
        return 2 * 24 * 60; // 2 dias = 2880 minutos
      case SmokingHealthBenefitEntity.breathing:
        return 3 * 24 * 60; // 3 dias = 4320 minutos
      case SmokingHealthBenefitEntity.circulation:
        return 14 * 24 * 60; // 14 dias = 20160 minutos
      case SmokingHealthBenefitEntity.lungFunction:
        return 90 * 24 * 60; // 90 dias = 129600 minutos
    }
  }

  /// Obtém o título da notificação
  String get notificationTitle {
    switch (this) {
      case SmokingHealthBenefitEntity.bloodPressure:
        return 'Pressão arterial normal 🎊';
      case SmokingHealthBenefitEntity.carbonMonoxide:
        return 'Sem monóxido de carbono 🎊';
      case SmokingHealthBenefitEntity.tasteSmell:
        return 'Olfato e paladar melhoram 🎊';
      case SmokingHealthBenefitEntity.breathing:
        return 'Respiração mais fácil 🎊';
      case SmokingHealthBenefitEntity.circulation:
        return 'Circulação melhora 🎊';
      case SmokingHealthBenefitEntity.lungFunction:
        return 'Função pulmonar +10% 🎊';
    }
  }

  /// Obtém o corpo da notificação
  String get notificationBody {
    switch (this) {
      case SmokingHealthBenefitEntity.bloodPressure:
        return 'Sua pressão arterial e frequência cardíaca tem potencial de melhora após 20 minutos. Continue!';
      case SmokingHealthBenefitEntity.carbonMonoxide:
        return 'Seus níveis de monóxido de carbono no sangue podem diminuir drasticamente após 1 dia. Continue!';
      case SmokingHealthBenefitEntity.tasteSmell:
        return 'Olfato e paladar costumam melhorar após 2 dias. Aproveite. E continue!';
      case SmokingHealthBenefitEntity.breathing:
        return 'Sua respiração tende a melhorar após 3 dias. Provavelmente vai conseguir dormir melhor. E continue!';
      case SmokingHealthBenefitEntity.circulation:
        return 'Sua circulação tende a melhorar após 14 dias. Tente caminhar mais após isso. Continue!';
      case SmokingHealthBenefitEntity.lungFunction:
        return 'Sua função pulmonar pode ter tido uma melhora de uns 10% após 90 dias. Aproveite mais a vida! E continue em frente!';
    }
  }

  /// Obtém a mensagem da janelinha flutuante
  String get floatingMessage {
    return notificationBody;
  }

  /// Obtém o emoji correspondente
  String get emoji {
    return '🎊';
  }

  /// Obtém a categoria do benefício
  String get category {
    switch (this) {
      case SmokingHealthBenefitEntity.bloodPressure:
        return 'Imediato';
      case SmokingHealthBenefitEntity.carbonMonoxide:
      case SmokingHealthBenefitEntity.tasteSmell:
      case SmokingHealthBenefitEntity.breathing:
        return 'Curto Prazo';
      case SmokingHealthBenefitEntity.circulation:
        return 'Médio Prazo';
      case SmokingHealthBenefitEntity.lungFunction:
        return 'Longo Prazo';
    }
  }

  /// Verifica se é um benefício imediato
  bool get isImmediate => category == 'Imediato';

  /// Obtém a cor do tema para este benefício
  String get themeColor {
    switch (this) {
      case SmokingHealthBenefitEntity.bloodPressure:
        return '#FF6B6B'; // Vermelho para pressão
      case SmokingHealthBenefitEntity.carbonMonoxide:
        return '#4ECDC4'; // Ciano para ar limpo
      case SmokingHealthBenefitEntity.tasteSmell:
        return '#FFD93D'; // Amarelo para sabor
      case SmokingHealthBenefitEntity.breathing:
        return '#95E1D3'; // Verde para respiração
      case SmokingHealthBenefitEntity.circulation:
        return '#F38181'; // Rosa para circulação
      case SmokingHealthBenefitEntity.lungFunction:
        return '#AA96DA'; // Roxo para pulmões
    }
  }
}
