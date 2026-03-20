class SmokingSettingsModel {
  final int dailyCigarettes;
  final double pricePerPack;
  final int cigarettesPerPack;
  final DateTime startDate;
  final DateTime? quitDate;
  final bool isActive;
  
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
    this.isActive = true,
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
    bool? isActive,
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
      isActive: isActive ?? this.isActive,
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
    'isActive': isActive,
    'currency': currency,
    'lastPackPrice': lastPackPrice,
    'lastPacksPerDay': lastPacksPerDay,
    'lastQuitDate': lastQuitDate?.toIso8601String(),
    'lastCurrency': lastCurrency,
    'lastSavedTotal': lastSavedTotal,
    'lastEndDate': lastEndDate?.toIso8601String(),
  };

  factory SmokingSettingsModel.fromJson(Map<String, dynamic> json) => SmokingSettingsModel(
    dailyCigarettes: json['dailyCigarettes']?.toInt() ?? 20,
    pricePerPack: json['pricePerPack']?.toDouble() ?? 10.0,
    cigarettesPerPack: json['cigarettesPerPack']?.toInt() ?? 20,
    startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
    quitDate: json['quitDate'] != null ? DateTime.parse(json['quitDate']) : null,
    isActive: json['isActive'] ?? true,
    currency: json['currency'] ?? 'R\$',
    lastPackPrice: json['lastPackPrice']?.toDouble(),
    lastPacksPerDay: json['lastPacksPerDay']?.toDouble(),
    lastQuitDate: json['lastQuitDate'] != null ? DateTime.parse(json['lastQuitDate']) : null,
    lastCurrency: json['lastCurrency'],
    lastSavedTotal: json['lastSavedTotal']?.toDouble(),
    lastEndDate: json['lastEndDate'] != null ? DateTime.parse(json['lastEndDate']) : null,
  );
}
