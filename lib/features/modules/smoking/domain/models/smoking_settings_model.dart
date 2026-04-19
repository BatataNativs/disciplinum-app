class SmokingSettingsModel {
  final int dailyCigarettes;
  final double pricePerPack;
  final int cigarettesPerPack;
  final DateTime startDate;
  final DateTime? quitDate;
  final bool isModuleActive;
  
  // Legacy fields for compatibility
  final String currency;
  final double? lastPackPrice;
  final double? lastPacksPerDay;
  final DateTime? lastQuitDate;
  final String? lastCurrency;
  final double? lastSavedTotal;
  final DateTime? lastEndDate;

  SmokingSettingsModel({
    required this.dailyCigarettes,
    required this.pricePerPack,
    required this.cigarettesPerPack,
    required this.startDate,
    this.quitDate,
    this.isModuleActive = true,
    this.currency = 'R\$',
    this.lastPackPrice,
    this.lastPacksPerDay,
    this.lastQuitDate,
    this.lastCurrency,
    this.lastSavedTotal,
    this.lastEndDate,
  });

  // Getters for compatibility
  double get packPrice => pricePerPack;
  double get packsPerDay => dailyCigarettes / cigarettesPerPack;
  Duration get timeSmokeFree => quitDate != null 
      ? DateTime.now().difference(quitDate!)
      : Duration.zero;
  double get moneySavedTotal {
    if (quitDate == null) return lastSavedTotal ?? 0.0;
    final daysWithoutSmoking = timeSmokeFree.inDays;
    final dailyCost = (packPrice * packsPerDay);
    return daysWithoutSmoking * dailyCost;
  }
  double get monthlySavings => moneySavedTotal * 30 / timeSmokeFree.inDays.clamp(1, 30);
  
  bool get isConfigured => dailyCigarettes > 0 && pricePerPack > 0 && cigarettesPerPack > 0;

  SmokingSettingsModel copyWith({
    int? dailyCigarettes,
    double? pricePerPack,
    int? cigarettesPerPack,
    DateTime? startDate,
    DateTime? quitDate,
    bool? isModuleActive,
    String? currency,
    double? lastPackPrice,
    double? lastPacksPerDay,
    DateTime? lastQuitDate,
    String? lastCurrency,
    double? lastSavedTotal,
    DateTime? lastEndDate,
  }) {
    return SmokingSettingsModel(
      dailyCigarettes: dailyCigarettes ?? this.dailyCigarettes,
      pricePerPack: pricePerPack ?? this.pricePerPack,
      cigarettesPerPack: cigarettesPerPack ?? this.cigarettesPerPack,
      startDate: startDate ?? this.startDate,
      quitDate: quitDate ?? this.quitDate,
      isModuleActive: isModuleActive ?? this.isModuleActive,
      currency: currency ?? this.currency,
      lastPackPrice: lastPackPrice ?? this.lastPackPrice,
      lastPacksPerDay: lastPacksPerDay ?? this.lastPacksPerDay,
      lastQuitDate: lastQuitDate ?? this.lastQuitDate,
      lastCurrency: lastCurrency ?? this.lastCurrency,
      lastSavedTotal: lastSavedTotal ?? this.lastSavedTotal,
      lastEndDate: lastEndDate ?? this.lastEndDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'dailyCigarettes': dailyCigarettes,
    'pricePerPack': pricePerPack,
    'cigarettesPerPack': cigarettesPerPack,
    'startDate': startDate.toIso8601String(),
    'quitDate': quitDate?.toIso8601String(),
    'isModuleActive': isModuleActive,
    'currency': currency,
    'lastPackPrice': lastPackPrice,
    'lastPacksPerDay': lastPacksPerDay,
    'lastQuitDate': lastQuitDate?.toIso8601String(),
    'lastCurrency': lastCurrency,
    'lastSavedTotal': lastSavedTotal,
    'lastEndDate': lastEndDate?.toIso8601String(),
  };

  factory SmokingSettingsModel.fromJson(Map<String, dynamic> json) => SmokingSettingsModel(
    // Campos atuais (do Supabase user_module_settings)
    dailyCigarettes: json['smoking_packs_per_day']?.toInt() ?? json['dailyCigarettes']?.toInt() ?? 20,
    pricePerPack: json['smoking_pack_price']?.toDouble() ?? json['pricePerPack']?.toDouble() ?? 10.0,
    cigarettesPerPack: json['cigarettesPerPack']?.toInt() ?? 20,
    startDate: json['startDate'] != null 
        ? DateTime.parse(json['startDate']) 
        : DateTime.now(),
    quitDate: json['smoking_quit_date'] != null 
        ? DateTime.parse(json['smoking_quit_date']) 
        : json['quitDate'] != null 
            ? DateTime.parse(json['quitDate']) 
            : null,
    isModuleActive: json['isModuleActive'] ?? json['is_active'] ?? true,
    currency: json['smoking_currency'] ?? json['currency'] ?? 'R\$',
    // Campos de histórico (last_*)
    lastPackPrice: json['last_pack_price']?.toDouble() ?? json['lastPackPrice']?.toDouble(),
    lastPacksPerDay: json['last_packs_per_day']?.toDouble() ?? json['lastPacksPerDay']?.toDouble(),
    lastQuitDate: json['last_quit_date'] != null 
        ? DateTime.parse(json['last_quit_date']) 
        : json['lastQuitDate'] != null 
            ? DateTime.parse(json['lastQuitDate']) 
            : null,
    lastCurrency: json['last_currency'] ?? json['lastCurrency'],
    lastSavedTotal: json['last_saved_total']?.toDouble() ?? json['lastSavedTotal']?.toDouble(),
    lastEndDate: json['last_end_date'] != null 
        ? DateTime.parse(json['last_end_date']) 
        : json['lastEndDate'] != null 
            ? DateTime.parse(json['lastEndDate']) 
            : null,
  );
}
