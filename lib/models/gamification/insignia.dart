enum FocusInsignia {
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

extension FocusInsigniaExtension on FocusInsignia {
  String get nameBr {
    switch (this) {
      case FocusInsignia.madeira:
        return 'Focado Madeira';
      case FocusInsignia.ferro:
        return 'Focado Ferro';
      case FocusInsignia.aluminio:
        return 'Focado Alumínio';
      case FocusInsignia.latao:
        return 'Focado Latão';
      case FocusInsignia.bronze:
        return 'Focado Bronze';
      case FocusInsignia.prata:
        return 'Focado Prata';
      case FocusInsignia.ouro:
        return 'Focado Ouro';
      case FocusInsignia.diamante:
        return 'Focado Diamante';
      case FocusInsignia.disciplinum:
        return 'Focado Disciplinum';
    }
  }

  String get asset {
    const prefix = 'assets/insignias/';
    switch (this) {
      case FocusInsignia.madeira:
        return '${prefix}escudo_madeira.png';
      case FocusInsignia.ferro:
        return '${prefix}escudo_ferro.png';
      case FocusInsignia.aluminio:
        return '${prefix}escudo_aluminio.png';
      case FocusInsignia.latao:
        return '${prefix}escudo_latao.png';
      case FocusInsignia.bronze:
        return '${prefix}escudo_bronze.png';
      case FocusInsignia.prata:
        return '${prefix}escudo_prata.png';
      case FocusInsignia.ouro:
        return '${prefix}escudo_ouro.png';
      case FocusInsignia.diamante:
        return '${prefix}escudo_diamante.png';
      case FocusInsignia.disciplinum:
        return '${prefix}escudo_disciplinum.png';
    }
  }

  int get requiredDays {
    switch (this) {
      case FocusInsignia.madeira:
        return 0; // Ganha ao configurar e ativar o módulo
      case FocusInsignia.ferro:
        return 1;
      case FocusInsignia.aluminio:
        return 2;
      case FocusInsignia.latao:
        return 3;
      case FocusInsignia.bronze:
        return 4;
      case FocusInsignia.prata:
        return 5;
      case FocusInsignia.ouro:
        return 9;
      case FocusInsignia.diamante:
        return 10;
      case FocusInsignia.disciplinum:
        return 11;
    }
  }
}
