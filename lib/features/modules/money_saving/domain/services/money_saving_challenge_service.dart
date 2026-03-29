import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:disciplinum/core/storage/isar_preferences_repository.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_challenge_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Serviço para persistência do Desafio da Poupança - VERSÃO RIVERPOD
/// Service puro sem ChangeNotifier - estado gerenciado pelo controller
/// Suporta armazenamento local (IsarPreferencesRepository) e cloud (Supabase)
/// Suporta múltiplos desafios simultâneos.
class MoneySavingChallengeService {
  static const String _localKey = 'money_saving_challenge_list_data';
  static const String _oldLocalKey = 'money_saving_challenge_data';
  static const String _moduleId = 'money_saving_challenge';

  final IsarPreferencesRepository _prefs;
  final SupabaseClient _supabase = Supabase.instance.client;
  final _uuid = const Uuid();

  List<MoneySavingChallengeModel> _challenges = [];
  MoneySavingChallengeModel? _activeChallenge;
  bool _initialized = false;

  MoneySavingChallengeService(this._prefs) {
    getChallenges();
  }

  // GETTERS
  List<MoneySavingChallengeModel> get challenges => _challenges;
  MoneySavingChallengeModel? get activeChallenge => _activeChallenge;
  
  // ALIASES PARA COMPATIBILIDADE
  List<MoneySavingChallengeModel> get challengesList => _challenges;
  double get totalContributions => activeChallenge?.totalSaved ?? 0.0;

  /// Carrega os desafios do usuário (cloud primeiro, fallback para local)
  Future<List<MoneySavingChallengeModel>> getChallenges(
      {bool forceRefresh = false}) async {
    if (_initialized && !forceRefresh) return _challenges;

    try {
      final userId = _supabase.auth.currentUser?.id;
      List<MoneySavingChallengeModel> fetchedChallenges = [];

      // Se não tem usuário logado, usa armazenamento local
      if (userId == null) {
        fetchedChallenges = await _getLocalChallenges();
      } else {
        // Tenta carregar do Supabase
        final response = await _supabase
            .from('user_module_settings')
            .select()
            .eq('user_id', userId)
            .eq('module_id', _moduleId)
            .maybeSingle();

        if (response != null && response['settings'] != null) {
          final settings = response['settings'] as Map<String, dynamic>;
          final challengesJson = settings['challenges'] as List<dynamic>?;
          if (challengesJson != null) {
            fetchedChallenges = challengesJson
                .map((c) => MoneySavingChallengeModel.fromJson(c))
                .toList();
          }
        } else {
          // Fallback para local se não encontrou no cloud
          fetchedChallenges = await _getLocalChallenges();
        }
      }

      _challenges = fetchedChallenges;
      _updateActiveChallenge();
      _initialized = true;
      return _challenges;
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar desafios: $e');
      // Fallback para local em caso de erro
      _challenges = await _getLocalChallenges();
      _updateActiveChallenge();
      _initialized = true;
      return _challenges;
    }
  }

  Future<void> createChallenge({
    required String title,
    required double targetAmount,
    required int periodValue,
    required String periodType,
    required int gridSize,
    double minValue = 1.0,
    double maxValue = 100.0,
    String currency = 'R\$',
  }) async {
    final newChallenge = MoneySavingChallengeModel(
      id: _uuid.v4(),
      title: title,
      targetAmount: targetAmount,
      periodValue: periodValue,
      periodType: periodType,
      gridSize: gridSize,
      minValue: minValue,
      maxValue: maxValue,
      markedCells: [],
      cellValues: _generateCellValues(gridSize, minValue, maxValue),
      createdAt: DateTime.now(),
      currency: currency,
      isActive: true,
    );

    _challenges.add(newChallenge);
    _updateActiveChallenge();
    await _saveChallenges();
  }

  Future<void> updateChallenge(MoneySavingChallengeModel updatedChallenge) async {
    final index = _challenges.indexWhere((c) => c.id == updatedChallenge.id);
    if (index != -1) {
      _challenges[index] = updatedChallenge;
      _updateActiveChallenge();
      await _saveChallenges();
    }
  }

  Future<void> deleteChallenge(String challengeId) async {
    _challenges.removeWhere((c) => c.id == challengeId);
    _updateActiveChallenge();
    await _saveChallenges();
  }

  Future<void> setActiveChallenge(String challengeId) async {
    // Desativa todos os desafios
    for (int i = 0; i < _challenges.length; i++) {
      _challenges[i] = _challenges[i].copyWith(isActive: i == 0 ? true : false);
    }
    
    // Ativa o desafio selecionado
    final index = _challenges.indexWhere((c) => c.id == challengeId);
    if (index != -1) {
      _challenges[index] = _challenges[index].copyWith(isActive: true);
    }
    
    _updateActiveChallenge();
    await _saveChallenges();
  }

  Future<void> markCell(String challengeId, int cellIndex) async {
    final challengeIndex = _challenges.indexWhere((c) => c.id == challengeId);
    if (challengeIndex == -1) return;

    final challenge = _challenges[challengeIndex];
    final markedCells = List<int>.from(challenge.markedCells);
    
    if (markedCells.contains(cellIndex)) {
      markedCells.remove(cellIndex);
    } else {
      markedCells.add(cellIndex);
    }

    _challenges[challengeIndex] = challenge.copyWith(markedCells: markedCells);
    _updateActiveChallenge();
    await _saveChallenges();
  }

  Future<void> unmarkCell(String challengeId, int cellIndex) async {
    final challengeIndex = _challenges.indexWhere((c) => c.id == challengeId);
    if (challengeIndex == -1) return;

    final challenge = _challenges[challengeIndex];
    final markedCells = List<int>.from(challenge.markedCells);
    markedCells.remove(cellIndex);

    _challenges[challengeIndex] = challenge.copyWith(markedCells: markedCells);
    _updateActiveChallenge();
    await _saveChallenges();
  }

  Future<void> resetChallenge(String challengeId) async {
    final challengeIndex = _challenges.indexWhere((c) => c.id == challengeId);
    if (challengeIndex == -1) return;

    _challenges[challengeIndex] = _challenges[challengeIndex].copyWith(
      markedCells: [],
    );
    _updateActiveChallenge();
    await _saveChallenges();
  }

  // MÉTODOS DE COMPATIBILIDADE
  MoneySavingChallengeModel? getActiveChallenge() => activeChallenge;
  
  Future<void> saveChallenge(MoneySavingChallengeModel challenge) async {
    await updateChallenge(challenge);
  }

  Future<void> addContribution(double amount) async {
    if (_activeChallenge != null) {
      // Adiciona como se estivesse marcando a próxima célula disponível
      final challenge = _activeChallenge!;
      final nextCellIndex = challenge.markedCells.length;
      if (nextCellIndex < challenge.gridSize) {
        await markCell(challenge.id, nextCellIndex);
      }
    }
  }

  Future<void> toggleCell(String challengeId, int cellIndex) async {
    final challenge = _challenges.firstWhere((c) => c.id == challengeId);
    if (challenge.markedCells.contains(cellIndex)) {
      await unmarkCell(challengeId, cellIndex);
    } else {
      await markCell(challengeId, cellIndex);
    }
  }

  Future<void> resetAllData() async {
    _challenges.clear();
    _activeChallenge = null;
    await _saveChallenges();
  }

  Future<void> deleteAllChallenges() async {
    await resetAllData();
  }

  // MÉTODOS PRIVADOS
  Future<List<MoneySavingChallengeModel>> _getLocalChallenges() async {
    try {
      // Tenta primeiro a nova chave (lista)
      String? data = await _prefs.getString(_localKey);
      if (data != null) {
        final List<dynamic> json = jsonDecode(data);
        return json.map((c) => MoneySavingChallengeModel.fromJson(c)).toList();
      }

      // Fallback para a chave antiga (único desafio)
      data = await _prefs.getString(_oldLocalKey);
      if (data != null) {
        final json = jsonDecode(data);
        final challenge = MoneySavingChallengeModel.fromJson(json);
        return [challenge];
      }

      return [];
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar desafios locais: $e');
      return [];
    }
  }

  Future<void> _saveChallenges() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      
      if (userId != null) {
        // Salva no Supabase
        await _supabase
            .from('user_module_settings')
            .upsert({
              'user_id': userId,
              'module_id': _moduleId,
              'settings': {
                'challenges': _challenges.map((c) => c.toJson()).toList(),
              },
              'updated_at': DateTime.now().toIso8601String(),
            });
      }

      // Sempre salva localmente como backup
      await _prefs.setString(
        _localKey,
        jsonEncode(_challenges.map((c) => c.toJson()).toList()),
      );
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar desafios: $e');
      // Apenas salva localmente em caso de erro
      try {
        await _prefs.setString(
          _localKey,
          jsonEncode(_challenges.map((c) => c.toJson()).toList()),
        );
      } catch (localError) {
        LoggerService.instance.e('Erro ao salvar localmente: $localError');
      }
    }
  }

  void _updateActiveChallenge() {
    _activeChallenge = _challenges.isNotEmpty
        ? _challenges.firstWhere(
            (c) => c.isActive,
            orElse: () => _challenges.first,
          )
        : null;
  }

  List<double> _generateCellValues(int gridSize, double minValue, double maxValue) {
    final values = <double>[];
    final step = (maxValue - minValue) / (gridSize - 1);
    
    for (int i = 0; i < gridSize; i++) {
      values.add(minValue + (i * step));
    }
    
    return values;
  }
}
