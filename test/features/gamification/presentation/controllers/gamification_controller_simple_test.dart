import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:disciplinum/features/gamification/presentation/controllers/gamification_controller.dart';
import 'package:disciplinum/features/gamification/domain/entities/user_module_status.dart';
import 'package:disciplinum/infrastructure/repositories/module_repository.dart';
import 'package:disciplinum/features/auth/domain/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('GamificationController - Testes Simples', () {
    test('deve inicializar com estado correto', () {
      final controller = GamificationController(
        moduleRepository: SimpleMockModuleRepository(),
        authService: SimpleMockAuthService(),
      );

      expect(controller.moduleStates, isEmpty);
      expect(controller.isLoading, false);
      expect(controller.error, null);
      expect(controller.totalActiveModules, 0);
      expect(controller.longestStreak, 0);
      expect(controller.totalXp, 0);
      expect(controller.averageSuccessRate, 0.0);
    });

    test('deve retornar mensagem padrão quando módulo não existe', () {
      final controller = GamificationController(
        moduleRepository: SimpleMockModuleRepository(),
        authService: SimpleMockAuthService(),
      );

      expect(controller.getStreakMessage(999), contains('Comece sua jornada'));
    });

    test('deve calcular estatísticas corretamente sem módulos', () {
      final controller = GamificationController(
        moduleRepository: SimpleMockModuleRepository(),
        authService: SimpleMockAuthService(),
      );

      expect(controller.totalActiveModules, 0);
      expect(controller.longestStreak, 0);
      expect(controller.totalXp, 0);
      expect(controller.averageSuccessRate, 0.0);
    });
  });
}

// Mocks simples que implementam as interfaces necessárias
class SimpleMockModuleRepository implements ModuleRepository {
  @override
  Future<List<UserModuleStatus>> getActiveModules() async => [];
  
  @override
  Future<void> saveModuleStatus(UserModuleStatus status) async {}
  
  @override
  Future<void> syncWithCloud() async {}
  
  @override
  Future<UserModuleStatus?> getModuleStatus(int nicheId) async => null;
  
  @override
  Future<void> removeModule(int nicheId) async {}
}

class SimpleMockAuthService implements AuthService {
  @override
  User? get currentUser => null;
  
  String get email => '';
  
  @override
  String? get errorMessage => null;
  
  @override
  bool get isAuthenticated => false;
  
  @override
  bool get isEmailUser => false;
  
  @override
  bool get isLoading => false;
  
  @override
  bool get isPasswordRecovery => false;
  
  @override
  Function()? get onLogoutCallback => null;
  
  @override
  set onLogoutCallback(Function()? callback) {}
  
  @override
  Map<String, dynamic>? get userProfile => null;
  
  @override
  final SupabaseClient supabase = _MockSupabaseClient();
  
  @override
  Future<void> clearError() async {}
  
  @override
  Future<void> clearPasswordRecoveryFlag() async {}
  
  @override
  Future<bool> deleteAccount() async => true;
  
  @override
  void dispose() {}
  
  @override
  Future<void> loadUserProfile() async {}
  
  @override
  Future<bool> login(String email, String password) async => true;
  
  @override
  Future<bool> loginWithGoogle() async => true;
  
  @override
  Future<void> logout() async {}
  
  @override
  Future<bool> resetPassword(String email) async => true;
  
  @override
  void showMessage(BuildContext context, String message, {bool success = false}) {}
  
  @override
  Future<bool> signup(String email, String password, String name) async => true;
  
  @override
  Future<bool> updatePassword(String newPassword) async => true;
  
  @override
  Future<bool> updateProfile({
    String? name,
    String? avatarUrl,
    String? bio,
    bool? showAvatar,
    bool? showEmail,
  }) async => true;
  
  @override
  bool get hasListeners => false;
  
  @override
  void addListener(VoidCallback listener) {}
  
  @override
  void removeListener(VoidCallback listener) {}
  
  @override
  void notifyListeners() {}
}

class _MockSupabaseClient implements SupabaseClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
