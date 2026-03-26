import 'package:disciplinum/features/gamification/domain/entities/insignia.dart';

/// Entidade de insígnias específicas do módulo Focus
/// Extende o enum base com funcionalidades específicas do módulo
enum FocusInsigniaEntity {
  madeira,
  ferro,
  aluminio,
  latao,
  bronze,
  prata,
  ouro,
  diamante,
  disciplinum
}

extension FocusInsigniaEntityExtension on FocusInsigniaEntity {
  /// Converte para o enum base do sistema
  FocusInsignia toBaseInsignia() {
    switch (this) {
      case FocusInsigniaEntity.madeira:
        return FocusInsignia.madeira;
      case FocusInsigniaEntity.ferro:
        return FocusInsignia.ferro;
      case FocusInsigniaEntity.aluminio:
        return FocusInsignia.aluminio;
      case FocusInsigniaEntity.latao:
        return FocusInsignia.latao;
      case FocusInsigniaEntity.bronze:
        return FocusInsignia.bronze;
      case FocusInsigniaEntity.prata:
        return FocusInsignia.prata;
      case FocusInsigniaEntity.ouro:
        return FocusInsignia.ouro;
      case FocusInsigniaEntity.diamante:
        return FocusInsignia.diamante;
      case FocusInsigniaEntity.disciplinum:
        return FocusInsignia.disciplinum;
    }
  }

  /// Verifica se esta é a insígnia Disciplinum
  bool get isDisciplinum => this == FocusInsigniaEntity.disciplinum;

  /// Verifica se esta é a insígnia inicial (Madeira)
  bool get isInitial => this == FocusInsigniaEntity.madeira;

  /// Obtém o progresso percentual até esta insígnia
  double get progressPercentage {
    switch (this) {
      case FocusInsigniaEntity.madeira:
        return 0.0;
      case FocusInsigniaEntity.ferro:
        return 10.0;
      case FocusInsigniaEntity.aluminio:
        return 20.0;
      case FocusInsigniaEntity.latao:
        return 30.0;
      case FocusInsigniaEntity.bronze:
        return 40.0;
      case FocusInsigniaEntity.prata:
        return 50.0;
      case FocusInsigniaEntity.ouro:
        return 60.0;
      case FocusInsigniaEntity.diamante:
        return 90.0;
      case FocusInsigniaEntity.disciplinum:
        return 100.0;
    }
  }
}
