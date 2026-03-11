class UserProfile {
  final String name;
  final String? avatarUrl;
  final String? bio;
  final bool showEmail;
  final bool showAvatar;

  const UserProfile({
    this.name = 'Usuário Disciplinum',
    this.avatarUrl,
    this.bio,
    this.showEmail = true,
    this.showAvatar = true,
  });

  // Facilita a integração com os dados retornados pelo Supabase
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? 'Usuário Disciplinum',
      avatarUrl: map['avatar_url'],
      bio: map['bio'],
      showEmail: map['show_email'] ?? true,
      showAvatar: map['show_avatar'] ?? true,
    );
  }

  UserProfile copyWith({
    String? name,
    String? avatarUrl,
    String? bio,
    bool? showEmail,
    bool? showAvatar,
  }) {
    return UserProfile(
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      showEmail: showEmail ?? this.showEmail,
      showAvatar: showAvatar ?? this.showAvatar,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'avatar_url': avatarUrl,
      'bio': bio,
      'show_email': showEmail,
      'show_avatar': showAvatar,
    };
  }
}
