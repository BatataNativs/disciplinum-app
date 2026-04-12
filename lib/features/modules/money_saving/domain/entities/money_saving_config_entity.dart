import 'package:objectbox/objectbox.dart';

@Entity()
class MoneySavingConfigEntity {
  @Id()
  int id = 0;

  @Unique()
  String userId;

  bool isModuleActive = false;
  String? activeChallengeId;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  MoneySavingConfigEntity({
    required this.userId,
    this.isModuleActive = false,
    this.activeChallengeId,
  });

  void touch() {
    updatedAt = DateTime.now();
  }

  MoneySavingConfigEntity copyWith({
    String? userId,
    bool? isModuleActive,
    String? activeChallengeId,
  }) {
    return MoneySavingConfigEntity(
      userId: userId ?? this.userId,
      isModuleActive: isModuleActive ?? this.isModuleActive,
      activeChallengeId: activeChallengeId ?? this.activeChallengeId,
    )..id = id
      ..createdAt = createdAt
      ..updatedAt = DateTime.now();
  }
}
