/// Enum que define todos os temas disponíveis no app
enum AppTheme {
  light('Tema Claro', isFree: true),
  dark('Tema Escuro', isFree: false),
  pink('Tema Rosa', isFree: false),
  halloween('Tema Halloween', isFree: false);

  final String displayName;
  final bool isFree;
  
  const AppTheme(this.displayName, {this.isFree = false});

  /// Converte string para enum
  static AppTheme fromString(String value) {
    return AppTheme.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AppTheme.light,
    );
  }
}
