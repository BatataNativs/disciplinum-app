/// Entidade de benefícios econômicos específicos do módulo Smoking
/// Notificações especiais baseadas em maços de cigarro economizados
enum SmokingEconomicBenefitEntity {
  onePack,      // 1 maço economizado
  twoPacks,     // 2 maços economizados
  fivePacks,    // 5 maços economizados
  tenPacks,     // 10 maços economizados
  twentyPacks,  // 20 maços economizados
  thirtyPacks;  // 30 maços economizados
}

extension SmokingEconomicBenefitEntityExtension on SmokingEconomicBenefitEntity {
  /// Converte para string para armazenamento
  String get name {
    switch (this) {
      case SmokingEconomicBenefitEntity.onePack:
        return 'one_pack';
      case SmokingEconomicBenefitEntity.twoPacks:
        return 'two_packs';
      case SmokingEconomicBenefitEntity.fivePacks:
        return 'five_packs';
      case SmokingEconomicBenefitEntity.tenPacks:
        return 'ten_packs';
      case SmokingEconomicBenefitEntity.twentyPacks:
        return 'twenty_packs';
      case SmokingEconomicBenefitEntity.thirtyPacks:
        return 'thirty_packs';
    }
  }

  /// Obtém o número de maços economizados
  int get packsCount {
    switch (this) {
      case SmokingEconomicBenefitEntity.onePack:
        return 1;
      case SmokingEconomicBenefitEntity.twoPacks:
        return 2;
      case SmokingEconomicBenefitEntity.fivePacks:
        return 5;
      case SmokingEconomicBenefitEntity.tenPacks:
        return 10;
      case SmokingEconomicBenefitEntity.twentyPacks:
        return 20;
      case SmokingEconomicBenefitEntity.thirtyPacks:
        return 30;
    }
  }

  /// Obtém o título da notificação
  String get notificationTitle {
    switch (this) {
      case SmokingEconomicBenefitEntity.onePack:
        return 'Economizou o valor de 1 maço 🎊';
      case SmokingEconomicBenefitEntity.twoPacks:
        return 'Economizou o valor de 2 maços 🎊';
      case SmokingEconomicBenefitEntity.fivePacks:
        return 'Economizou o valor de 5 maços 🎊';
      case SmokingEconomicBenefitEntity.tenPacks:
        return 'Economizou o valor de 10 maços 🎊';
      case SmokingEconomicBenefitEntity.twentyPacks:
        return 'Economizou o valor de 20 maços 🎊';
      case SmokingEconomicBenefitEntity.thirtyPacks:
        return 'Economizou o valor de 30 maços 🎊';
    }
  }

  /// Obtém o corpo da notificação
  String get notificationBody {
    switch (this) {
      case SmokingEconomicBenefitEntity.onePack:
        return 'Parabéns 🎊! Economizou o valor de 1 maço';
      case SmokingEconomicBenefitEntity.twoPacks:
        return 'Parabéns 🎊! Economizou o valor de 2 maços';
      case SmokingEconomicBenefitEntity.fivePacks:
        return 'Parabéns 🎊! Economizou o valor de 5 maços';
      case SmokingEconomicBenefitEntity.tenPacks:
        return 'Parabéns 🎊! Economizou o valor de 10 maços';
      case SmokingEconomicBenefitEntity.twentyPacks:
        return 'Parabéns 🎊! Economizou o valor de 20 maços';
      case SmokingEconomicBenefitEntity.thirtyPacks:
        return 'Parabéns 🎊! Economizou o valor de 30 maços';
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
      case SmokingEconomicBenefitEntity.onePack:
      case SmokingEconomicBenefitEntity.twoPacks:
        return 'Inicial';
      case SmokingEconomicBenefitEntity.fivePacks:
      case SmokingEconomicBenefitEntity.tenPacks:
        return 'Intermediário';
      case SmokingEconomicBenefitEntity.twentyPacks:
      case SmokingEconomicBenefitEntity.thirtyPacks:
        return 'Avançado';
    }
  }

  /// Obtém a descrição do impacto financeiro
  String get financialImpact {
    switch (this) {
      case SmokingEconomicBenefitEntity.onePack:
        return 'Comece a ver o dinheiro acumulando!';
      case SmokingEconomicBenefitEntity.twoPacks:
        return 'Já dá para um café especial!';
      case SmokingEconomicBenefitEntity.fivePacks:
        return 'Dinheiro para um lanche ou livro!';
      case SmokingEconomicBenefitEntity.tenPacks:
        return 'Valor para uma pequena recompensa!';
      case SmokingEconomicBenefitEntity.twentyPacks:
        return 'Quantia significativa para seu orçamento!';
      case SmokingEconomicBenefitEntity.thirtyPacks:
        return 'Dinheiro para um grande objetivo!';
    }
  }

  /// Obtém a cor do tema para este benefício
  String get themeColor {
    switch (this) {
      case SmokingEconomicBenefitEntity.onePack:
        return '#4CAF50'; // Verde para dinheiro
      case SmokingEconomicBenefitEntity.twoPacks:
        return '#8BC34A'; // Verde claro
      case SmokingEconomicBenefitEntity.fivePacks:
        return '#CDDC39'; // Amarelo verde
      case SmokingEconomicBenefitEntity.tenPacks:
        return '#FFC107'; // Âmbar
      case SmokingEconomicBenefitEntity.twentyPacks:
        return '#FF9800'; // Laranja
      case SmokingEconomicBenefitEntity.thirtyPacks:
        return '#FF5722'; // Laranja escuro
    }
  }

  /// Calcula o valor economizado baseado no preço do maço
  double calculateSavedAmount(double packPrice) {
    return packsCount * packPrice;
  }

  /// Obtém descrição formatada com valor monetário
  String getFormattedDescription(double packPrice) {
    final savedAmount = calculateSavedAmount(packPrice);
    return '$notificationTitle - R\$ ${savedAmount.toStringAsFixed(2)}';
  }
}
