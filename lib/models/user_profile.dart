class UserProfile {
  final String name;
  final String? avatarPath;
  final int totalPoints;
  final int streakDays;

  const UserProfile({
    this.name = 'Usuário Disciplinum',
    this.avatarPath,
    this.totalPoints = 0,
    this.streakDays = 0,
  });

  // Adicionado para facilitar integração com Supabase
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? 'Usuário Disciplinum',
      avatarPath: map['avatar_url'], // Note que no banco deve ser avatar_url
      totalPoints: map['total_points'] ?? 0,
      streakDays: map['streak_days'] ?? 0,
    );
  }

  UserProfile copyWith({
    String? name,
    String? avatarPath,
    int? totalPoints,
    int? streakDays,
  }) {
    return UserProfile(
      name: name ?? this.name,
      avatarPath: avatarPath ?? this.avatarPath,
      totalPoints: totalPoints ?? this.totalPoints,
      streakDays: streakDays ?? this.streakDays,
    );
  }
}
