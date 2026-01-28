import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:disciplinum/models/7_moneySavingChallenge/money_saving_challenge_model.dart';

/// Serviço para persistência do Desafio da Poupança
/// Suporta armazenamento local (SharedPreferences) e cloud (Supabase)
class MoneySavingChallengeService {
  static const String _localKey = 'money_saving_challenge_data';
  static const String _moduleId = 'money_saving_challenge';

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Carrega o desafio do usuário (cloud primeiro, fallback para local)
  Future<MoneySavingChallengeModel?> getChallenge() async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      // Se não tem usuário logado, usa armazenamento local
      if (userId == null) {
        return await _getLocalChallenge();
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
        return await _getLocalChallenge();
      }

      // Deserializa do campo JSON
      final jsonData = response['module_data'];
      if (jsonData == null) return null;

      final model = MoneySavingChallengeModel.fromJson(
        jsonData is String ? jsonDecode(jsonData) : jsonData,
      );

      // Salva localmente para cache
      await _saveLocalChallenge(model);

      return model;
    } catch (e) {
      debugPrint('❌ Erro ao carregar desafio: $e');
      // Fallback para local em caso de erro
      return await _getLocalChallenge();
    }
  }

  /// Salva o desafio (cloud + local)
  Future<void> saveChallenge(MoneySavingChallengeModel challenge) async {
    // Sempre salva localmente primeiro (para garantir persistência imediata)
    await _saveLocalChallenge(challenge);

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = {
        'user_id': userId,
        'module_id': _moduleId,
        'module_data': challenge.toJson(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      await _supabase.from('user_module_settings').upsert(
            data,
            onConflict: 'user_id, module_id',
          );
    } catch (e) {
      debugPrint('❌ Erro ao salvar desafio no cloud: $e');
      // Dados já estão salvos localmente, então não é crítico
    }
  }

  /// Marca/desmarca uma célula e salva
  Future<MoneySavingChallengeModel?> toggleCell(int cellIndex) async {
    final current = await getChallenge();
    if (current == null) return null;

    final updated = current.toggleCell(cellIndex);
    await saveChallenge(updated);
    return updated;
  }

  /// Deleta o desafio completamente
  Future<void> deleteChallenge() async {
    // Remove local
    await _removeLocalChallenge();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('user_module_settings')
          .delete()
          .eq('user_id', userId)
          .eq('module_id', _moduleId);
    } catch (e) {
      debugPrint('❌ Erro ao deletar desafio no cloud: $e');
    }
  }

  /// Cria um novo desafio com as configurações fornecidas
  Future<MoneySavingChallengeModel> createChallenge({
    required double targetAmount,
    required int periodValue,
    required String periodType,
    required int gridSize,
    required double minValue,
    required double maxValue,
    String currency = 'R\$',
  }) async {
    final cellValues = MoneySavingChallengeModel.generateCellValues(
      gridSize: gridSize,
      minValue: minValue,
      maxValue: maxValue,
    );

    final challenge = MoneySavingChallengeModel(
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
    );

    await saveChallenge(challenge);
    return challenge;
  }

  // ============ MÉTODOS LOCAIS (SharedPreferences) ============

  Future<MoneySavingChallengeModel?> _getLocalChallenge() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_localKey);
      if (jsonString == null) return null;
      return MoneySavingChallengeModel.fromJson(jsonDecode(jsonString));
    } catch (e) {
      debugPrint('❌ Erro ao carregar desafio local: $e');
      return null;
    }
  }

  Future<void> _saveLocalChallenge(MoneySavingChallengeModel challenge) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localKey, jsonEncode(challenge.toJson()));
    } catch (e) {
      debugPrint('❌ Erro ao salvar desafio local: $e');
    }
  }

  Future<void> _removeLocalChallenge() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_localKey);
    } catch (e) {
      debugPrint('❌ Erro ao remover desafio local: $e');
    }
  }
}
