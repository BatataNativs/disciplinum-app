class BlockedApp {
  final String id;
  final String packageName;
  final String appName;
  final String? blockingReason;
  final bool isTemporary;
  final DateTime? expiresAt;

  BlockedApp({
    required this.id,
    required this.packageName,
    required this.appName,
    this.blockingReason,
    this.isTemporary = false,
    this.expiresAt,
  });
}
