/// Entidade de benefícios de saúde específicos do módulo Smoking
/// Notificações especiais que aparecem em marcos específicos
enum SmokingHealthBenefitEntity {
  bloodPressure,    // 20 minutos - Pressão arterial normal
  carbonMonoxide,   // 1 dia - Sem monóxido de carbono
  tasteSmell,       // 2 dias - Olfato e paladar melhoram
  breathing,        // 3 dias - Respiração mais fácil
  lungCleaning,     // 7 dias - Pulmão começa a limpar
  circulation,      // 14 dias - Circulação melhora
  lungCapacity,     // 30 dias - Capacidade pulmonar melhora
  lungFunction,     // 90 dias - Função pulmonar +10%
  heartRiskHalf,    // 180 dias - Risco cardíaco pela metade
  nonSmoker;        // 365 dias - Não-fumante completo
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
      case SmokingHealthBenefitEntity.lungCleaning:
        return 'lung_cleaning';
      case SmokingHealthBenefitEntity.circulation:
        return 'circulation';
      case SmokingHealthBenefitEntity.lungCapacity:
        return 'lung_capacity';
      case SmokingHealthBenefitEntity.lungFunction:
        return 'lung_function';
      case SmokingHealthBenefitEntity.heartRiskHalf:
        return 'heart_risk_half';
      case SmokingHealthBenefitEntity.nonSmoker:
        return 'non_smoker';
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
      case SmokingHealthBenefitEntity.lungCleaning:
        return '7 dias';
      case SmokingHealthBenefitEntity.circulation:
        return '14 dias';
      case SmokingHealthBenefitEntity.lungCapacity:
        return '30 dias';
      case SmokingHealthBenefitEntity.lungFunction:
        return '90 dias';
      case SmokingHealthBenefitEntity.heartRiskHalf:
        return '180 dias';
      case SmokingHealthBenefitEntity.nonSmoker:
        return '365 dias';
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
      case SmokingHealthBenefitEntity.lungCleaning:
        return 7 * 24 * 60; // 7 dias = 10080 minutos
      case SmokingHealthBenefitEntity.circulation:
        return 14 * 24 * 60; // 14 dias = 20160 minutos
      case SmokingHealthBenefitEntity.lungCapacity:
        return 30 * 24 * 60; // 30 dias = 43200 minutos
      case SmokingHealthBenefitEntity.lungFunction:
        return 90 * 24 * 60; // 90 dias = 129600 minutos
      case SmokingHealthBenefitEntity.heartRiskHalf:
        return 180 * 24 * 60; // 180 dias = 259200 minutos
      case SmokingHealthBenefitEntity.nonSmoker:
        return 365 * 24 * 60; // 365 dias = 525600 minutos
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
      case SmokingHealthBenefitEntity.lungCleaning:
        return 'Pulmão começando a limpar 🎊';
      case SmokingHealthBenefitEntity.circulation:
        return 'Circulação melhora 🎊';
      case SmokingHealthBenefitEntity.lungCapacity:
        return 'Capacidade pulmonar melhorando 🎊';
      case SmokingHealthBenefitEntity.lungFunction:
        return 'Função pulmonar +10% 🎊';
      case SmokingHealthBenefitEntity.heartRiskHalf:
        return 'Risco cardíaco pela metade 🎊';
      case SmokingHealthBenefitEntity.nonSmoker:
        return 'Não-fumante completo! 🎊';
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
      case SmokingHealthBenefitEntity.lungCleaning:
        return 'Seu pulmão começou a se limpar naturalmente após 7 dias. Continue!';
      case SmokingHealthBenefitEntity.circulation:
        return 'Sua circulação tende a melhorar após 14 dias. Tente caminhar mais após isso. Continue!';
      case SmokingHealthBenefitEntity.lungCapacity:
        return 'Sua capacidade pulmonar está melhorando após 30 dias. Você já sente mais energia! Continue!';
      case SmokingHealthBenefitEntity.lungFunction:
        return 'Sua função pulmonar pode ter tido uma melhora de uns 10% após 90 dias. Aproveite mais a vida! E continue em frente!';
      case SmokingHealthBenefitEntity.heartRiskHalf:
        return 'Após 180 dias, seu risco de doença cardíaca caiu pela metade. Continue!';
      case SmokingHealthBenefitEntity.nonSmoker:
        return 'Após 1 ano, seu risco de doença cardíaca é igual ao de um não-fumante. Parabéns! Continue!';
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
      case SmokingHealthBenefitEntity.lungCleaning:
        return 'Curto Prazo';
      case SmokingHealthBenefitEntity.circulation:
      case SmokingHealthBenefitEntity.lungCapacity:
        return 'Médio Prazo';
      case SmokingHealthBenefitEntity.lungFunction:
      case SmokingHealthBenefitEntity.heartRiskHalf:
      case SmokingHealthBenefitEntity.nonSmoker:
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
      case SmokingHealthBenefitEntity.lungCleaning:
        return '#A8E6CF'; // Verde claro para limpeza
      case SmokingHealthBenefitEntity.circulation:
        return '#F38181'; // Rosa para circulação
      case SmokingHealthBenefitEntity.lungCapacity:
        return '#FFB347'; // Laranja para capacidade
      case SmokingHealthBenefitEntity.lungFunction:
        return '#AA96DA'; // Roxo para pulmões
      case SmokingHealthBenefitEntity.heartRiskHalf:
        return '#FF6B9D'; // Rosa escuro para coração
      case SmokingHealthBenefitEntity.nonSmoker:
        return '#FFD700'; // Dourado para conquista
    }
  }
}
