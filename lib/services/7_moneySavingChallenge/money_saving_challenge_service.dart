import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/models/7_moneySavingChallenge/money_saving_challenge_model.dart';
import 'package:uuid/uuid.dart';

/// Serviço para persistência do Desafio da Poupança
/// Suporta armazenamento local (SharedPreferences) e cloud (Supabase)
/// Agora suporta múltiplos desafios simultâneos.
class MoneySavingChallengeService {
  static const String _localKey = 'money_saving_challenge_list_data';
  static const String _oldLocalKey = 'money_saving_challenge_data';
  static const String _moduleId = 'money_saving_challenge';

  final SupabaseClient _supabase = Supabase.instance.client;
  final _uuid = const Uuid();

  /// Carrega os desafios do usuário (cloud primeiro, fallback para local)
  Future<List<MoneySavingChallengeModel>> getChallenges() async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      // Se não tem usuário logado, usa armazenamento local
      if (userId == null) {
        return await _getLocalChallenges();
      }

      // Tenta carregar do Supabase
      final response = await _supabase
          .from('user_module_settings')
          .select()
          .eq('user_id', userId)
          .eq('module_id', _moduleId)
          .maybeSingle();

      if (response == null) {
        // Tenta pegar do local como fallback
        return await _getLocalChallenges();
      }

      // Deserializa do campo JSON
      final jsonData = response['module_data'];
      if (jsonData == null) return [];

      final decoded = jsonData is String ? jsonDecode(jsonData) : jsonData;

      List<MoneySavingChallengeModel> challenges = [];

      if (decoded is Map<String, dynamic> &&
          decoded.containsKey('challenges')) {
        // Formato novo: lista dentro de um objeto
        final list = decoded['challenges'] as List;
        challenges =
            list.map((e) => MoneySavingChallengeModel.fromJson(e)).toList();
      } else if (decoded is List) {
        // Formato intermediário: lista direta
        challenges =
            decoded.map((e) => MoneySavingChallengeModel.fromJson(e)).toList();
      } else if (decoded is Map<String, dynamic>) {
        // Formato antigo: um único desafio
        final single = MoneySavingChallengeModel.fromJson(decoded);
        challenges = [
          single.copyWith(id: single.id.isEmpty ? _uuid.v4() : single.id)
        ];
      }

      // Salva localmente para cache
      await _saveLocalChallenges(challenges);

      return challenges;
    } catch (e) {
      debugPrint('❌ Erro ao carregar desafios: $e');
      // Fallback para local em caso de erro
      return await _getLocalChallenges();
    }
  }

  /// Atalho para buscar um desafio específico por ID
  Future<MoneySavingChallengeModel?> getChallenge(String id) async {
    final list = await getChallenges();
    try {
      return list.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Busca o desafio ativo no momento
  Future<MoneySavingChallengeModel?> getActiveChallenge() async {
    final list = await getChallenges();
    try {
      return list.firstWhere((c) => c.isActive);
    } catch (_) {
      // Se não tiver nenhum ativo mas tiver desafios, ativa o primeiro (opcional) ou retorna null
      return list.isNotEmpty ? list.first : null;
    }
  }

  /// Salva a lista completa de desafios (cloud + local)
  Future<void> saveChallenges(
      List<MoneySavingChallengeModel> challenges) async {
    // Sempre salva localmente primeiro (para garantir persistência imediata)
    await _saveLocalChallenges(challenges);

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = {
        'user_id': userId,
        'module_id': _moduleId,
        'module_data': {
          'challenges': challenges.map((e) => e.toJson()).toList()
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
    final list = await getChallenges();
    final index = list.indexWhere((c) => c.id == challenge.id);

    if (index >= 0) {
      list[index] = challenge;
    } else {
      list.add(challenge);
    }

    await saveChallenges(list);
  }

  /// Define qual desafio é o ativo (e desativa os outros)
  Future<void> setActiveChallenge(String id) async {
    final list = await getChallenges();
    final updated = list.map((c) {
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
    final list = await getChallenges();
    list.removeWhere((c) => c.id == id);
    await saveChallenges(list);
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
  }) async {
    final cellValues = MoneySavingChallengeModel.generateCellValues(
      gridSize: gridSize,
      minValue: minValue,
      maxValue: maxValue,
    );

    final challenge = MoneySavingChallengeModel(
      id: _uuid.v4(),
      title: title,
      targetAmount: targetAmount,
      periodValue: periodValue,
      periodType: periodType,
      gridSize: gridSize,
      minValue: minValue,
      maxValue: maxValue,
      markedCells: [],
      cellValues: cellValues,
      createdAt: DateTime.now(),
      currency: currency,
      isActive: isActive,
    );

    // Se o novo desafio for ativo, desativa os outros
    if (isActive) {
      final list = await getChallenges();
      final updatedList = list.map((c) => c.copyWith(isActive: false)).toList();
      updatedList.add(challenge);
      await saveChallenges(updatedList);
    } else {
      await saveChallenge(challenge);
    }

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
