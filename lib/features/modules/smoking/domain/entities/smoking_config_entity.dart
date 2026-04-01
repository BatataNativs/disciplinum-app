import 'package:isar/isar.dart';

part 'smoking_config_entity.g.dart';

/// Entidade Isar para configurações do módulo Smoking
/// Persiste estado de ativação e configurações do usuário
@Collection()
class SmokingConfigEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String userId;

  // Estado do módulo
  bool isModuleActive = false;

  // Configurações de fumo
  int dailyCigarettes = 0;
  double pricePerPack = 0.0;
  int cigarettesPerPack = 20;
  DateTime? quitDate;
  String currency = 'R\$';

  // Campos para histórico/backup
  double? lastPackPrice;
  double? lastPacksPerDay;
  DateTime? lastQuitDate;
  String? lastCurrency;
  double? lastSavedTotal;
  DateTime? lastEndDate;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  SmokingConfigEntity({
    required this.userId,
    this.isModuleActive = false,
    this.dailyCigarettes = 0,
    this.pricePerPack = 0.0,
    this.cigarettesPerPack = 20,
    this.quitDate,
    this.currency = 'R\$',
    this.lastPackPrice,
    this.lastPacksPerDay,
    this.lastQuitDate,
    this.lastCurrency,
    this.lastSavedTotal,
    this.lastEndDate,
  });

  /// Atualiza o timestamp
  void touch() {
    updatedAt = DateTime.now();
  }

  /// Cria cópia com novos valores
  SmokingConfigEntity copyWith({
    String? userId,
    bool? isModuleActive,
    int? dailyCigarettes,
    double? pricePerPack,
    int? cigarettesPerPack,
    DateTime? quitDate,
    String? currency,
    double? lastPackPrice,
    double? lastPacksPerDay,
    DateTime? lastQuitDate,
    String? lastCurrency,
    double? lastSavedTotal,
    DateTime? lastEndDate,
  }) {
    return SmokingConfigEntity(
      userId: userId ?? this.userId,
      isModuleActive: isModuleActive ?? this.isModuleActive,
      dailyCigarettes: dailyCigarettes ?? this.dailyCigarettes,
      pricePerPack: pricePerPack ?? this.pricePerPack,
      cigarettesPerPack: cigarettesPerPack ?? this.cigarettesPerPack,
      quitDate: quitDate ?? this.quitDate,
      currency: currency ?? this.currency,
      lastPackPrice: lastPackPrice ?? this.lastPackPrice,
      lastPacksPerDay: lastPacksPerDay ?? this.lastPacksPerDay,
      lastQuitDate: lastQuitDate ?? this.lastQuitDate,
      lastCurrency: lastCurrency ?? this.lastCurrency,
      lastSavedTotal: lastSavedTotal ?? this.lastSavedTotal,
      lastEndDate: lastEndDate ?? this.lastEndDate,
    )..id = id
      ..createdAt = createdAt
      ..updatedAt = DateTime.now();
  }
}
