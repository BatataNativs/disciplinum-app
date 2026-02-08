enum NicheId {
  smoking(1),
  bingeEating(2),
  diet(3),
  spending(4),
  focus(5),
  adultContent(6),
  moneySavingChallenge(7),
  procrastination(8),
  reading(9);

  final int id;
  const NicheId(this.id);

  static NicheId fromInt(int id) {
    return NicheId.values.firstWhere(
      (e) => e.id == id,
      orElse: () => throw ArgumentError('Invalid NicheId: $id'),
    );
  }

  static NicheId? tryFromInt(int? id) {
    if (id == null) return null;
    try {
      return fromInt(id);
    } catch (_) {
      return null;
    }
  }
}
