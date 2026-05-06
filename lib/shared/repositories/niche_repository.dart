import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/models/common/niche.dart';

/// Repository simples para NicheId
/// Implementação básica para compatibilidade com código existente
class NicheRepository {
  static Niche getById(NicheId nicheId) {
    // Implementação básica com dados hardcoded
    // Em produção, buscar do banco de dados ou API
    switch (nicheId) {
      case NicheId.smoking:
        return Niche(
          id: nicheId.id,
          nicheId: nicheId,
          name: 'Parar de Fumar',
          description: 'Acompanhe seu progresso para parar de fumar',
          icon: '🚭',
          color: '#FF5252',
        );
      case NicheId.bingeEating:
        return Niche(
          id: nicheId.id,
          nicheId: nicheId,
          name: 'Compulsão Alimentar',
          description: 'Controle sua compulsão alimentar',
          icon: '🍔',
          color: '#FF9800',
        );
      case NicheId.diet:
        return Niche(
          id: nicheId.id,
          nicheId: nicheId,
          name: 'Dieta',
          description: 'Mantenha uma dieta equilibrada',
          icon: '🥗',
          color: '#4CAF50',
        );
      case NicheId.spending:
        return Niche(
          id: nicheId.id,
          nicheId: nicheId,
          name: 'Controle de Gastos',
          description: 'Controle seus gastos financeiros',
          icon: '💰',
          color: '#2196F3',
        );
      case NicheId.focus:
        return Niche(
          id: nicheId.id,
          nicheId: nicheId,
          name: 'Foco e Produtividade',
          description: 'Melhore seu foco e produtividade',
          icon: '🎯',
          color: '#9C27B0',
        );
      case NicheId.adultContent:
        return Niche(
          id: nicheId.id,
          nicheId: nicheId,
          name: 'Evitar Conteúdo Adulto',
          description: 'Controle acesso a conteúdo adulto',
          icon: '🔞',
          color: '#E91E63',
        );
      case NicheId.moneySavingChallenge:
        return Niche(
          id: nicheId.id,
          nicheId: nicheId,
          name: 'Desafio da Poupança',
          description: 'Desafie-se a juntar dinheiro',
          icon: '🏦',
          color: '#00BCD4',
        );
      case NicheId.procrastination:
        return Niche(
          id: nicheId.id,
          nicheId: nicheId,
          name: 'Evitar Procrastinação',
          description: 'Supere a procrastinação',
          icon: '⏰',
          color: '#FF5722',
        );
      case NicheId.reading:
        return Niche(
          id: nicheId.id,
          nicheId: nicheId,
          name: 'Leitura',
          description: 'Acompanhe seus hábitos de leitura',
          icon: '📚',
          color: '#795548',
        );
      case NicheId.digitalDetox:
        return Niche(
          id: nicheId.id,
          nicheId: nicheId,
          name: 'Jejum Digital',
          description: 'Controle inteligente do uso de redes sociais e apps',
          icon: '📱',
          color: '#7C4DFF',
        );
    }
  }

  static List<Niche> getAll() {
    return NicheId.values.map((nicheId) => getById(nicheId)).toList();
  }

  static List<Niche> getAllNiches() {
    return NicheId.values.map((nicheId) => getById(nicheId)).toList();
  }

  static Niche? getByIdInt(int id) {
    try {
      final nicheId = NicheId.fromInt(id);
      return getById(nicheId);
    } catch (e) {
      return null;
    }
  }
}
