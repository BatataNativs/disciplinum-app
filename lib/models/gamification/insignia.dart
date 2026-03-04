enum FocusInsignia {
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
    switch (this) {
      case FocusInsignia.ferro:
        return 'assets/escudo_ferro.png';
      case FocusInsignia.aluminio:
        return 'assets/escudo_aluminio.png';
      case FocusInsignia.latao:
        return 'assets/escudo_latao.png';
      case FocusInsignia.bronze:
        return 'assets/escudo_bronze.png';
      case FocusInsignia.prata:
        return 'assets/escudo_prata.png';
      case FocusInsignia.ouro:
        return 'assets/escudo_ouro.png';
      case FocusInsignia.diamante:
        return 'assets/escudo_diamante.png';
      case FocusInsignia.disciplinum:
        return 'assets/escudo_disciplinum.png';
    }
  }

  int get requiredDays {
    switch (this) {
      case FocusInsignia.ferro:
        return 0; // Ganha ao configurar e ativar o módulo
      case FocusInsignia.aluminio:
        return 1;
      case FocusInsignia.latao:
        return 2;
      case FocusInsignia.bronze:
        return 3;
      case FocusInsignia.prata:
        return 4;
      case FocusInsignia.ouro:
        return 5;
      case FocusInsignia.diamante:
        return 9;
      case FocusInsignia.disciplinum:
        return 10;
    }
  }
}
