import 'package:disciplinum/shared/models/common/niche_category.dart';

/// Repository para NicheCategory
/// Implementação básica para compatibilidade com código existente
class NicheCategoryRepository {
  static List<NicheCategory> getAll() {
    // Implementação básica com dados hardcoded
    // Em produção, buscar do banco de dados ou API
    return [
      const NicheCategory(
        id: 1,
        name: 'Saúde',
        description: 'Hábitos relacionados à saúde e bem-estar',
        icon: '❤️',
        color: '#FF5252',
        isActive: true,
      ),
      const NicheCategory(
        id: 2,
        name: 'Finanças',
        description: 'Controle financeiro e economia',
        icon: '💵',
        color: '#2196F3',
        isActive: true,
      ),
      const NicheCategory(
        id: 3,
        name: 'Produtividade',
        description: 'Foco, organização e produtividade',
        icon: '📈',
        color: '#9C27B0',
        isActive: true,
      ),
      const NicheCategory(
        id: 4,
        name: 'Mente a autocontrole',
        description: 'Aprendizado e crescimento pessoal',
        icon: '📚',
        color: '#FF9800',
        isActive: true,
      ),
    ];
  }

  static NicheCategory? getById(int id) {
    try {
      return getAll().firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  static NicheCategory? getCategoryByName(String name) {
    try {
      return getAll().firstWhere((category) => 
          category.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  static List<NicheCategory> getActiveCategories() {
    return getAll().where((category) => category.isActive).toList();
  }

  static List<NicheCategory> getAllCategories() {
    return getAll();
  }

  static List<NicheCategory> getCategories() {
    return getAll();
  }
}
