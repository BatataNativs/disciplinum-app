class SmokingSettingsModel {
  final double packPrice;
  final int packsPerDay;
  final DateTime quitDate;
  final String currency;

  // Campos de histórico (Última tentativa)
  final double? lastPackPrice;
  final int? lastPacksPerDay;
  final DateTime? lastQuitDate;
  final String? lastCurrency;
  final double? lastSavedTotal;
  final DateTime? lastEndDate;

  SmokingSettingsModel({
    required this.packPrice,
    required this.packsPerDay,
    required this.quitDate,
    this.currency = 'R\$',
    this.lastPackPrice,
    this.lastPacksPerDay,
    this.lastQuitDate,
    this.lastCurrency,
    this.lastSavedTotal,
    this.lastEndDate,
  });

  factory SmokingSettingsModel.fromJson(Map<String, dynamic> json) {
    return SmokingSettingsModel(
      packPrice:
          (json['smoking_pack_price'] ?? json['pack_price'] as num).toDouble(),
      packsPerDay:
          (json['smoking_packs_per_day'] ?? json['packs_per_day'] as num)
              .toInt(),
      quitDate: DateTime.parse(json['smoking_quit_date'] ?? json['quit_date']),
      currency: json['smoking_currency'] ?? json['currency'] ?? 'R\$',
      // Histórico
      lastPackPrice: json['last_pack_price'] != null
          ? (json['last_pack_price'] as num).toDouble()
          : null,
      lastPacksPerDay: json['last_packs_per_day'] != null
          ? (json['last_packs_per_day'] as num).toInt()
          : null,
      lastQuitDate: json['last_quit_date'] != null
          ? DateTime.parse(json['last_quit_date'])
          : null,
      lastCurrency: json['last_currency'],
      lastSavedTotal: json['last_saved_total'] != null
          ? (json['last_saved_total'] as num).toDouble()
          : null,
      lastEndDate: json['last_end_date'] != null
          ? DateTime.parse(json['last_end_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'smoking_pack_price': packPrice,
      'smoking_packs_per_day': packsPerDay,
      'smoking_quit_date': quitDate.toIso8601String(),
      'smoking_currency': currency,
      'last_pack_price': lastPackPrice,
      'last_packs_per_day': lastPacksPerDay,
      'last_quit_date': lastQuitDate?.toIso8601String(),
      'last_currency': lastCurrency,
      'last_saved_total': lastSavedTotal,
      'last_end_date': lastEndDate?.toIso8601String(),
    };
  }

  // --- CÁLCULOS AUTOMÁTICOS ---
  Duration get timeSmokeFree =>
      DateTime.now().toUtc().difference(quitDate.toUtc());

  double get moneySavedTotal {
    final days = timeSmokeFree.inMinutes / 60 / 24;
    return days * packsPerDay * packPrice;
  }

  double get monthlySavings => packPrice * packsPerDay * 30;

  int get cigarettesNotSmoked {
    final days = timeSmokeFree.inDays;
    return days * packsPerDay * 20;
  }
}
