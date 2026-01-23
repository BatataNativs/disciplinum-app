import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/main.dart'; // Para navigatorKey
import 'package:disciplinum/app_router.dart';
import 'package:disciplinum/misc/system_stuff/preferences_service.dart';
import 'package:disciplinum/services/cloud/cloud_sync_service.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/models/user_niche_app.dart';
import 'package:disciplinum/models/user_niche_time.dart';
import 'package:disciplinum/models/1_smoking/smoking_settings_model.dart';
import 'package:disciplinum/services/1_smoking/smoking_service.dart';

class AuthService extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  User? _currentUser;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  bool _isPasswordRecovery = false;
  bool _isSocialLoginInProgress = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isPasswordRecovery => _isPasswordRecovery;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isEmailUser => _currentUser?.appMetadata['provider'] == 'email';

  late final StreamSubscription _authSubscription;
  Function()? onLogoutCallback;

  AuthService() {
    _initializeAuth();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  // ========================= UTILIDADES =========================
  void showMessage(BuildContext context, String message,
      {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ====================== INICIALIZAÇÃO =========================
  Future<void> _initializeAuth() async {
    _currentUser = supabase.auth.currentUser;
    if (_currentUser != null) await loadUserProfile();
    notifyListeners();

    _authSubscription = supabase.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.passwordRecovery) {
        _currentUser = session?.user;
        _isPasswordRecovery = true;
        _isLoading = false;
        notifyListeners();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            AppRouter.resetPassword,
            (route) => false,
          );
        });
        if (_currentUser != null) {
          await _loadUserProfileInternal();
          notifyListeners();
        }
      } else if (event == AuthChangeEvent.signedIn && session != null) {
        await Future.delayed(const Duration(milliseconds: 400));
        if (_isPasswordRecovery) return;

        _currentUser = session.user;
        await _ensureUserProfileExists();
        await loadUserProfile();

        // Migração de guest mode
        await _migrateGuestData();

        if (_isSocialLoginInProgress) {
          _isSocialLoginInProgress = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            navigatorKey.currentState?.pushNamedAndRemoveUntil(
              AppRouter.profile,
              (route) => false,
            );
          });
        }
        notifyListeners();
      } else if (event == AuthChangeEvent.signedOut) {
        if (_isPasswordRecovery) return;
        _currentUser = null;
        _userProfile = null;
        notifyListeners();
      }
    });
  }

  // ===================== MIGRAÇÃO GUEST ========================
  Future<void> _migrateGuestData() async {
    if (!await PreferencesService.isGuestMode()) return;

    try {
      final guestData = await PreferencesService.exportAll();

      // Migrar apps
      final apps = (guestData['apps'] as List)
          .map((e) => UserNicheApp.fromJson(e))
          .toList();
      for (final app in apps) {
        await CloudSyncService.addUserNicheApp(
          nicheId: NicheId.fromInt(app.nicheId),
          package: app.appPackage,
        );
      }

      // Migrar horários
      final times = (guestData['times'] as List)
          .map((e) => UserNicheTime.fromJson(e))
          .toList();
      for (final t in times) {
        await CloudSyncService.addUserNicheTime(
          nicheId: t.nicheId,
          hour: t.hour,
          minute: t.minute,
        );
      }

      // Migrar dados de cigarro (NOVO)
      final smokingData = guestData['smoking'];
      if (smokingData != null) {
        try {
          final settings = SmokingSettingsModel.fromJson(smokingData);
          await SmokingService().saveSettings(settings);
        } catch (e) {
          debugPrint('Erro ao migrar dados de cigarro: $e');
        }
      }

      await PreferencesService.clearAll();
    } catch (e) {
      debugPrint('Erro ao migrar dados do guest: $e');
    }
  }

  // =================== PERFIL DE USUÁRIO =======================
  Future<void> _ensureUserProfileExists() async {
    if (_currentUser == null) return;
    try {
      final user = _currentUser!;
      final existingProfile = await supabase
          .from('users')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();
      if (existingProfile != null) return;

      final nameFromMeta =
          (user.userMetadata?['full_name'] ?? user.userMetadata?['name'])
              ?.toString();

      await supabase.from('users').insert({
        'id': user.id,
        'email': user.email ?? '',
        'name': nameFromMeta ??
            (user.email != null ? user.email!.split('@').first : 'Usuário'),
        'avatar_url': (user.userMetadata?['avatar_url'])?.toString() ?? '',
      });
    } catch (e) {
      debugPrint('Erro ao criar perfil inicial: $e');
    }
  }

  Future<void> loadUserProfile() async {
    await _loadUserProfileInternal();
    notifyListeners();
  }

  Future<void> _loadUserProfileInternal() async {
    if (_currentUser == null) return;
    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('id', _currentUser!.id)
          .maybeSingle();
      if (response != null) _userProfile = response;
    } catch (e) {
      debugPrint('Erro ao carregar perfil: $e');
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? avatarUrl,
    bool? showEmail,
    bool? showAvatar,
    String? bio,
  }) async {
    if (_currentUser == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (showEmail != null) updates['show_email'] = showEmail;
      if (showAvatar != null) updates['show_avatar'] = showAvatar;
      if (bio != null) updates['bio'] = bio;

      await supabase.from('users').update(updates).eq('id', _currentUser!.id);

      await loadUserProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao atualizar perfil: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ======================== LOGIN / SIGNUP =====================
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await supabase.auth
          .signInWithPassword(email: email, password: password);
      _currentUser = response.user;
      await loadUserProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Erro desconhecido: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await supabase.auth
          .signUp(email: email, password: password, data: {'name': name});
      if (response.session == null) {
        _currentUser = null;
        _userProfile = null;
        _errorMessage = 'Verifique seu e-mail para ativar a conta.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      _currentUser = response.user;
      await _ensureUserProfileExists();
      await loadUserProfile();
      await _migrateGuestData();
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Erro ao criar conta: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _isSocialLoginInProgress = true;
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.disciplinum.app://login-callback',
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao iniciar login Google: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ========================= LOGOUT ===========================
  Future<void> logout() async {
    _isLoading = true;
    _isPasswordRecovery = false;
    _isSocialLoginInProgress = false;
    notifyListeners();
    try {
      await supabase.auth.signOut();
      onLogoutCallback?.call();
      _currentUser = null;
      _userProfile = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erro ao fazer logout: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearPasswordRecoveryFlag() {
    _isPasswordRecovery = false;
    notifyListeners();
  }

  // ======================== SENHA ============================
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'com.disciplinum.app://login-callback',
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Erro ao solicitar redefinição: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
      _isLoading = false;
      _isPasswordRecovery = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Erro ao atualizar senha: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ======================== DELETE ACCOUNT ====================
  Future<bool> deleteAccount() async {
    if (_currentUser == null) {
      _errorMessage = 'Nenhum usuário logado';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _currentUser!.id;

      // Deleta dados em tabelas relacionadas
      final tablesToDelete = ['user_niches', 'user_times', 'users'];
      for (final table in tablesToDelete) {
        final response = await supabase.from(table).delete().eq('id', userId);
        if (response.error != null) {
          _errorMessage =
              'Erro ao deletar dados em $table: ${response.error!.message}';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      // Deleta a conta do Supabase (Admin API necessária)
      await supabase.auth.admin.deleteUser(userId);

      _currentUser = null;
      _userProfile = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao deletar conta: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
