import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../auth/domain/entities/user.dart' as auth;
import 'package:disciplinum/core/logging/logger_service.dart';

/// Controller para gerenciar estado do perfil do usuário
/// Implementa ChangeNotifier para integração com Provider
/// Substitui o uso direto do AuthService no ProfileScreen
class ProfileController extends ChangeNotifier {
  final ProfileRepository _repository;
  final LoggerService _logger;

  // Estado do controller
  auth.User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _userProfile;
  bool _isEditing = false;

  // Controllers para edição
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();

  // Getters para UI
  auth.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isEditing => _isEditing;
  bool get hasError => _errorMessage != null;
  TextEditingController get nameController => _nameController;
  TextEditingController get bioController => _bioController;

  ProfileController({
    required ProfileRepository repository,
    required LoggerService logger,
  })  : _repository = repository,
        _logger = logger {
    _loadUserProfile();
  }

  /// Carrega o perfil do usuário
  Future<void> _loadUserProfile() async {
    try {
      _setLoading(true);
      _clearError();
      
      _logger.i('ProfileController: Carregando perfil do usuário');
      
      final user = await _repository.getCurrentUser();
      final profile = await _repository.getUserProfile();
      
      _currentUser = user;
      _userProfile = profile;
      
      // Preencher controllers com dados atuais
      if (user != null) {
        _nameController.text = user.displayName ?? '';
        _bioController.text = profile?['bio'] ?? '';
      }
      
      _logger.i('ProfileController: Perfil carregado: ${user?.email ?? 'null'}');
      notifyListeners();
    } catch (e) {
      _logger.e('ProfileController: Erro ao carregar perfil: $e');
      _setError('Erro ao carregar perfil');
    } finally {
      _setLoading(false);
    }
  }

  /// Atualiza o perfil do usuário
  Future<bool> updateProfile({
    String? name,
    String? bio,
    String? avatarUrl,
  }) async {
    if (_currentUser == null) {
      _setError('Usuário não logado');
      return false;
    }

    try {
      _setLoading(true);
      _clearError();
      
      _logger.i('ProfileController: Atualizando perfil: ${_currentUser!.id}');
      
      // Atualizar nome se fornecido
      if (name != null && name.isNotEmpty) {
        await _repository.updateProfile(_currentUser!.id, name: name);
      }
      
      // Atualizar metadados adicionais
      final updates = <String, dynamic>{};
      if (bio != null) updates['bio'] = bio;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      
      if (updates.isNotEmpty) {
        await _repository.updateUserMetadata(_currentUser!.id, updates);
      }
      
      // Recarregar dados
      await _loadUserProfile();
      
      _logger.i('ProfileController: Perfil atualizado com sucesso');
      return true;
    } catch (e) {
      _logger.e('ProfileController: Erro ao atualizar perfil: $e');
      _setError('Erro ao atualizar perfil');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Faz upload de avatar
  Future<bool> uploadAvatar(String filePath) async {
    if (_currentUser == null) {
      _setError('Usuário não logado');
      return false;
    }

    try {
      _setLoading(true);
      _clearError();
      
      _logger.i('ProfileController: Fazendo upload de avatar');
      
      final avatarUrl = await _repository.uploadAvatar(_currentUser!.id, filePath);
      
      // Atualizar perfil com nova URL do avatar
      await updateProfile(avatarUrl: avatarUrl);
      
      _logger.i('ProfileController: Avatar upload concluído');
      return true;
    } catch (e) {
      _logger.e('ProfileController: Erro no upload de avatar: $e');
      _setError('Erro ao fazer upload de avatar');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Alterna modo de edição
  void toggleEditMode() {
    _isEditing = !_isEditing;
    if (!_isEditing) {
      // Reset controllers para valores originais
      if (_currentUser != null) {
        _nameController.text = _currentUser!.displayName ?? '';
        _bioController.text = _userProfile?['bio'] ?? '';
      }
    }
    _logger.i('ProfileController: Edit mode: $_isEditing');
    notifyListeners();
  }

  /// Salva as edições
  Future<bool> saveEdits() async {
    if (!_isEditing) return false;
    
    final name = _nameController.text.trim();
    final bio = _bioController.text.trim();
    
    if (name.isEmpty) {
      _setError('Nome não pode estar vazio');
      return false;
    }
    
    final success = await updateProfile(name: name, bio: bio.isEmpty ? null : bio);
    
    if (success) {
      _isEditing = false;
      _logger.i('ProfileController: Edições salvas com sucesso');
    }
    
    return success;
  }

  /// Cancela as edições
  void cancelEdits() {
    if (_isEditing) {
      toggleEditMode();
    }
  }

  /// Faz logout
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _clearError();
      
      _logger.i('ProfileController: Fazendo logout');
      
      await _repository.signOut();
      
      _currentUser = null;
      _userProfile = null;
      _isEditing = false;
      
      _logger.i('ProfileController: Logout realizado');
      notifyListeners();
    } catch (e) {
      _logger.e('ProfileController: Erro no logout: $e');
      _setError('Erro ao fazer logout');
    } finally {
      _setLoading(false);
    }
  }

  /// Verifica se email está verificado
  Future<bool> isEmailVerified() async {
    if (_currentUser == null) return false;
    
    try {
      return await _repository.isEmailVerified(_currentUser!.id);
    } catch (e) {
      _logger.e('ProfileController: Erro ao verificar email: $e');
      return false;
    }
  }

  /// Reenvia verificação de email
  Future<bool> resendEmailVerification() async {
    try {
      _setLoading(true);
      _clearError();
      
      _logger.i('ProfileController: Reenviando verificação de email');
      
      await _repository.resendEmailVerification();
      
      _logger.i('ProfileController: Verificação reenviada com sucesso');
      return true;
    } catch (e) {
      _logger.e('ProfileController: Erro ao reenviar verificação: $e');
      _setError('Erro ao reenviar verificação');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Exclui conta do usuário
  Future<bool> deleteAccount() async {
    if (_currentUser == null) {
      _setError('Usuário não logado');
      return false;
    }

    try {
      _setLoading(true);
      _clearError();
      
      _logger.i('ProfileController: Excluindo conta: ${_currentUser!.id}');
      
      await _repository.deleteAccount(_currentUser!.id);
      
      _currentUser = null;
      _userProfile = null;
      _isEditing = false;
      
      _logger.i('ProfileController: Conta excluída com sucesso');
      notifyListeners();
      return true;
    } catch (e) {
      _logger.e('ProfileController: Erro ao excluir conta: $e');
      _setError('Erro ao excluir conta');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Obtém estatísticas do usuário
  Future<Map<String, dynamic>?> getUserStats() async {
    if (_currentUser == null) return null;
    
    try {
      _logger.i('ProfileController: Obtendo estatísticas do usuário');
      return await _repository.getUserStats(_currentUser!.id);
    } catch (e) {
      _logger.e('ProfileController: Erro ao obter estatísticas: $e');
      return null;
    }
  }

  /// Atualiza preferências do usuário
  Future<bool> updatePreferences(Map<String, dynamic> preferences) async {
    if (_currentUser == null) return false;
    
    try {
      _setLoading(true);
      _clearError();
      
      _logger.i('ProfileController: Atualizando preferências');
      
      await _repository.updateUserPreferences(_currentUser!.id, preferences);
      
      // Recarregar perfil
      await _loadUserProfile();
      
      return true;
    } catch (e) {
      _logger.e('ProfileController: Erro ao atualizar preferências: $e');
      _setError('Erro ao atualizar preferências');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Métodos privados para gerenciar estado
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Limpa mensagem de erro (público)
  void clearError() {
    _clearError();
  }

  /// Dispose para limpar recursos
  @override
  void dispose() {
    _logger.i('ProfileController: Disposing resources');
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  /// Refresh manual do perfil
  Future<void> refreshProfile() async {
    await _loadUserProfile();
  }

  /// Obtém nome de exibição do usuário
  String get displayName {
    if (_currentUser?.displayName != null && _currentUser!.displayName!.isNotEmpty) {
      return _currentUser!.displayName!;
    }
    if (_currentUser?.email != null) {
      return _currentUser!.email.split('@').first;
    }
    return 'Usuário';
  }

  /// Verifica se perfil está completo
  bool get isProfileComplete {
    if (_currentUser == null) return false;
    
    return _currentUser!.displayName != null && 
           _currentUser!.displayName!.isNotEmpty &&
           _currentUser!.email.isNotEmpty;
  }

  /// Obtém iniciais do nome para avatar
  String get initials {
    final name = _currentUser?.displayName ?? '';
    if (name.isEmpty) return displayName.substring(0, 1).toUpperCase();
    
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }
}
