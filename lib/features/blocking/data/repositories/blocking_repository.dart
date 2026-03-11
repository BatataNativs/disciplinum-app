import 'package:disciplinum/features/blocking/domain/entities/blocked_app.dart';

class BlockingRepository {
  Future<List<BlockedApp>> getBlockedApps() async {
    return [];
  }

  Future<void> saveBlockedApp(BlockedApp app) async {
    // Salvar regra no Supabase/Local
  }
}
