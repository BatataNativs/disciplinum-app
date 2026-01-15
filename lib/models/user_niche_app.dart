class UserNicheApp {
  final String userId;
  final int nicheId;
  final String appPackage;

  UserNicheApp({
    required this.userId,
    required this.nicheId,
    required this.appPackage,
  });

  factory UserNicheApp.fromJson(Map<String, dynamic> json) {
    return UserNicheApp(
      userId: json['user_id'] as String,
      nicheId: json['niche_id'] as int,
      appPackage: json['app_package'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'niche_id': nicheId,
      'app_package': appPackage,
    };
  }
}
