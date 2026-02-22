import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/models/7_moneySavingChallenge/money_saving_challenge_model.dart';
import 'package:uuid/uuid.dart';

/// Serviço para persistência do Desafio da Poupança
/// Suporta armazenamento local (SharedPreferences) e cloud (Supabase)
/// Agora suporta múltiplos desafios simultâneos.
class MoneySavingChallengeService extends ChangeNotifier {
  static const String _localKey = 'money_saving_challenge_list_data';
  static const String _oldLocalKey = 'money_saving_challenge_data';
  static const String _moduleId = 'money_saving_challenge';

  final SupabaseClient _supabase = Supabase.instance.client;
  final _uuid = const Uuid();

  List<MoneySavingChallengeModel> _challenges = [];
  MoneySavingChallengeModel? _activeChallenge;
  bool _initialized = false;

  List<MoneySavingChallengeModel> get challengesList => _challenges;
  MoneySavingChallengeModel? get activeChallenge => _activeChallenge;

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

        if (response == null) {
          fetchedChallenges = await _getLocalChallenges();
        } else {
          final jsonData = response['module_data'];
          final decoded = jsonData is String ? jsonDecode(jsonData) : jsonData;

          if (decoded is Map<String, dynamic> &&
              decoded.containsKey('challenges')) {
            final list = decoded['challenges'] as List;
            fetchedChallenges =
                list.map((e) => MoneySavingChallengeModel.fromJson(e)).toList();
          } else if (decoded is List) {
            fetchedChallenges = decoded
                .map((e) => MoneySavingChallengeModel.fromJson(e))
                .toList();
          } else if (decoded is Map<String, dynamic>) {
            // Formato antigo: um único desafio
            final single = MoneySavingChallengeModel.fromJson(decoded);
            fetchedChallenges = [
              single.copyWith(id: single.id.isEmpty ? _uuid.v4() : single.id)
            ];
          }
        }
      }

      _challenges = fetchedChallenges;
      try {
        _activeChallenge = _challenges.firstWhere((c) => c.isActive);
      } catch (_) {
        _activeChallenge = _challenges.isNotEmpty ? _challenges.first : null;
      }

      _initialized = true;
      await _saveLocalChallenges(_challenges);
      notifyListeners();
      return _challenges;
    } catch (e) {
      debugPrint('❌ Erro ao carregar desafios: $e');
      _challenges = await _getLocalChallenges();
      _initialized = true;
      notifyListeners();
      return _challenges;
    }
  }

  /// Atalho para buscar um desafio específico por ID
  Future<MoneySavingChallengeModel?> getChallenge(String id) async {
    if (!_initialized) await getChallenges();
    try {
      return _challenges.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Busca o desafio ativo no momento
  Future<MoneySavingChallengeModel?> getActiveChallenge() async {
    if (!_initialized) await getChallenges();
    return _activeChallenge;
  }

  /// Salva a lista completa de desafios (cloud + local)
  Future<void> saveChallenges(
      List<MoneySavingChallengeModel> challenges) async {
    _challenges = challenges;
    try {
      _activeChallenge = _challenges.firstWhere((c) => c.isActive);
    } catch (_) {
      _activeChallenge = _challenges.isNotEmpty ? _challenges.first : null;
    }

    // Sempre salva localmente primeiro (para garantir persistência imediata)
    await _saveLocalChallenges(_challenges);
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = {
        'user_id': userId,
        'module_id': _moduleId,
        'module_data': {
          'challenges': _challenges.map((e) => e.toJson()).toList()
        },
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      await _supabase.from('user_module_settings').upsert(
            data,
            onConflict: 'user_id, module_id',
          );
    } catch (e) {
      debugPrint('❌ Erro ao salvar desafios no cloud: $e');
    }
  }

  /// Salva ou atualiza um único desafio na lista
  Future<void> saveChallenge(MoneySavingChallengeModel challenge) async {
    if (!_initialized) await getChallenges(); // Ensure _challenges is populated
    final index = _challenges.indexWhere((c) => c.id == challenge.id);

    if (index >= 0) {
      _challenges[index] = challenge;
    } else {
      _challenges.add(challenge);
    }

    await saveChallenges(_challenges);
  }

  /// Define qual desafio é o ativo (e desativa os outros)
  Future<void> setActiveChallenge(String id) async {
    if (!_initialized) await getChallenges();
    final updated = _challenges.map((c) {
      return c.copyWith(isActive: c.id == id);
    }).toList();

    await saveChallenges(updated);
  }

  /// Marca/desmarca uma célula e salva (no desafio ativo ou em um específico)
  Future<MoneySavingChallengeModel?> toggleCell(int cellIndex,
      {String? challengeId}) async {
    MoneySavingChallengeModel? current;
    if (challengeId != null) {
      current = await getChallenge(challengeId);
    } else {
      current = await getActiveChallenge();
    }

    if (current == null) return null;

    final updated = current.toggleCell(cellIndex);
    await saveChallenge(updated);
    return updated;
  }

  /// Deleta um desafio específico
  Future<void> deleteChallenge(String id) async {
    if (!_initialized) await getChallenges();
    _challenges.removeWhere((c) => c.id == id);
    await saveChallenges(_challenges);
  }

  /// Deleta TODOS os desafios (usado na desativação do módulo)
  Future<void> deleteAllChallenges() async {
    _challenges = [];
    _activeChallenge = null;

    // Limpa localmente
    await removeAllLocal();

    // Notifica listeners para limpar UI imediatamente
    notifyListeners();

    // Sincroniza com Cloud (enviando lista vazia)
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = {
        'user_id': userId,
        'module_id': _moduleId,
        'module_data': {'challenges': []},
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      await _supabase.from('user_module_settings').upsert(
            data,
            onConflict: 'user_id, module_id',
          );
    } catch (e) {
      debugPrint('❌ Erro ao limpar desafios no cloud: $e');
    }
  }

  /// Cria um novo desafio com as configurações fornecidas e adiciona à lista
  Future<MoneySavingChallengeModel> createChallenge({
    required String title,
    required double targetAmount,
    required int periodValue,
    required String periodType,
    required int gridSize,
    required double minValue,
    required double maxValue,
    String currency = 'R\$',
    bool isActive = true,
    String? id,
  }) async {
    MoneySavingChallengeModel? existing;
    if (id != null) {
      existing = await getChallenge(id);
    }

    double oldTotalSaved = 0;
    if (existing != null) {
      oldTotalSaved = existing.totalSaved;
    }

    List<double> cellValues;
    List<int> markedCells = [];

    // Sempre geramos novos valores se gridSize, min ou max mudarem,
    // mas agora também reconstruímos o progresso com base na soma.
    cellValues = MoneySavingChallengeModel.generateCellValues(
      gridSize: gridSize,
      minValue: minValue,
      maxValue: maxValue,
      targetAmount: targetAmount,
    );

    // Se houve mudança ou se é uma edição com saldo preservado:
    if (oldTotalSaved > 0) {
      double currentSum = 0;
      // Marcamos as células até atingir o montante anterior
      for (int i = 0; i < cellValues.length; i++) {
        if (currentSum + cellValues[i] <= oldTotalSaved + 0.01) {
          // 0.01 gap de tolerância
          markedCells.add(i);
          currentSum += cellValues[i];
        } else {
          // Opcional: poderíamos tentar achar uma célula menor, mas por simplicidade, paramos aqui
          break;
        }
      }
    }

    final challenge = MoneySavingChallengeModel(
      id: id ?? _uuid.v4(),
      title: title,
      targetAmount: targetAmount,
      periodValue: periodValue,
      periodType: periodType,
      gridSize: gridSize,
      minValue: minValue,
      maxValue: maxValue,
      markedCells: markedCells,
      cellValues: cellValues,
      createdAt: existing?.createdAt ?? DateTime.now(),
      currency: currency,
      isActive: isActive,
    );

    // Se o novo desafio for ativo, desativa os outros primeiro
    if (isActive) {
      if (!_initialized) await getChallenges();
      // Desativa todos na memória local para que saveChallenge persista o novo como o único ativo
      _challenges =
          _challenges.map((c) => c.copyWith(isActive: false)).toList();
    }

    // saveChallenge já lida com substituição se o ID existir ou adição se for novo
    await saveChallenge(challenge);

    return challenge;
  }

  // ============ MÉTODOS LOCAIS (SharedPreferences) ============

  Future<List<MoneySavingChallengeModel>> _getLocalChallenges() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Tenta a chave nova primeiro
      String? jsonString = prefs.getString(_localKey);

      // Se não tem, tenta a chave antiga (migração)
      if (jsonString == null) {
        final oldData = prefs.getString(_oldLocalKey);
        if (oldData != null) {
          final decoded = jsonDecode(oldData);
          final single = MoneySavingChallengeModel.fromJson(decoded);
          final list = [
            single.copyWith(id: single.id.isEmpty ? _uuid.v4() : single.id)
          ];
          await _saveLocalChallenges(list);
          // Opcional: remover a chave antiga
          // await prefs.remove(_oldLocalKey);
          return list;
        }
        return [];
      }

      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic> &&
          decoded.containsKey('challenges')) {
        final list = decoded['challenges'] as List;
        return list.map((e) => MoneySavingChallengeModel.fromJson(e)).toList();
      } else if (decoded is List) {
        return decoded
            .map((e) => MoneySavingChallengeModel.fromJson(e))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('❌ Erro ao carregar desafios locais: $e');
      return [];
    }
  }

  Future<void> _saveLocalChallenges(
      List<MoneySavingChallengeModel> challenges) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {'challenges': challenges.map((e) => e.toJson()).toList()};
      await prefs.setString(_localKey, jsonEncode(data));
    } catch (e) {
      debugPrint('❌ Erro ao salvar desafios locais: $e');
    }
  }

  Future<void> removeAllLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_localKey);
      await prefs.remove(_oldLocalKey);
    } catch (e) {
      debugPrint('❌ Erro ao remover desafios locais: $e');
    }
  }
}
