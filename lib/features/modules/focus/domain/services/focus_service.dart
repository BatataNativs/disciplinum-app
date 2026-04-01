import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:disciplinum/core/database/isar_service.dart';
import 'package:disciplinum/core/storage/entities/focus_status_entity.dart';
import 'package:disciplinum/infrastructure/cloud/cloud_sync_service.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/domain/models/time_of_day_range.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Temporário - classe substituta
class FocusInsignia {
  final String name;
  
  const FocusInsignia({required this.name});
  
  // Assets corrigidos - organizados por módulo
  static const madeira = FocusInsignia(name: 'madeira');
  static const bronze = FocusInsignia(name: 'bronze');
  static const prata = FocusInsignia(name: 'prata');
  static const ouro = FocusInsignia(name: 'ouro');
  
  static const List<FocusInsignia> values = [madeira, bronze, prata, ouro];
  
  // Método para obter o asset path
  String get asset => 'assets/gamification/insignias/focus/$name.png';
}

class FocusService {
  final IsarService _isarService;
  final CloudSyncService _cloudSync;

  FocusService(this._isarService, this._cloudSync);

  Future<FocusStatusEntity?> _getOrCreateStatus() async {
    final user = Supabase.instance.client.auth.currentUser;
    final userId = user?.id ?? 'local';

    final existing = await _isarService.focusStatus.filter().userIdEqualTo(userId).findFirst();
    if (existing != null) return existing;

    final newStatus = FocusStatusEntity()..userId = userId;
    await _isarService.database.writeTxn(() => _isarService.focusStatus.put(newStatus));
    return newStatus;
  }

  Future<void> saveInterval(TimeOfDay start, TimeOfDay end) async {
    final status = await _getOrCreateStatus();
    if (status == null) return;

    status.startHour = start.hour;
    status.startMinute = start.minute;
    status.endHour = end.hour;
    status.endMinute = end.minute;
    status.lastUpdated = DateTime.now();

    await _isarService.database.writeTxn(() => _isarService.focusStatus.put(status));

    // Opcional: Sync com Cloud se necessário
    await _cloudSync.removeAllTimesForNiche(nicheId: NicheId.focus.id);
    await _cloudSync.addUserNicheTime(nicheId: NicheId.focus.id, hour: start.hour, minute: start.minute);
    await _cloudSync.addUserNicheTime(nicheId: NicheId.focus.id, hour: end.hour, minute: end.minute);
  }

  Future<void> removeInterval() async {
    final status = await _getOrCreateStatus();
    if (status == null) return;

    status.startHour = null;
    status.startMinute = null;
    status.endHour = null;
    status.endMinute = null;
    status.lastUpdated = DateTime.now();

    await _isarService.database.writeTxn(() => _isarService.focusStatus.put(status));
    await _cloudSync.removeAllTimesForNiche(nicheId: NicheId.focus.id);
  }

  Future<TimeOfDayRange?> getInterval() async {
    final status = await _getOrCreateStatus();
    if (status == null || status.startHour == null || status.endHour == null) return null;

    return TimeOfDayRange(
      start: TimeOfDay(hour: status.startHour!, minute: status.startMinute!),
      end: TimeOfDay(hour: status.endHour!, minute: status.endMinute!),
    );
  }

  bool isWithinInterval(DateTime now, TimeOfDayRange? interval) {
    if (interval == null) return false;

    final minsNow = now.hour * 60 + now.minute;
    final minsIni = interval.start.hour * 60 + interval.start.minute;
    final minsFim = interval.end.hour * 60 + interval.end.minute;

    return minsIni > minsFim
        ? (minsNow >= minsIni || minsNow <= minsFim)
        : (minsNow >= minsIni && minsNow <= minsFim);
  }

  Future<int> getRespectedPeriods() async {
    final status = await _getOrCreateStatus();
    return status?.respectedPeriods ?? 0;
  }

  Future<void> addRespectedPeriod() async {
    final status = await _getOrCreateStatus();
    if (status == null) return;

    status.respectedPeriods++;
    status.lastUpdated = DateTime.now();

    await _isarService.database.writeTxn(() => _isarService.focusStatus.put(status));
  }

  Future<void> resetProgress() async {
    final status = await _getOrCreateStatus();
    if (status == null) return;

    // Preservar "Madeira"
    final hasMadeira = status.earnedInsigniaNames.contains(FocusInsignia.madeira.name);
    
    status.respectedPeriods = 0;
    status.earnedInsigniaNames.clear();
    
    if (hasMadeira) {
      status.earnedInsigniaNames.add(FocusInsignia.madeira.name);
    }
    
    status.lastUpdated = DateTime.now();

    await _isarService.database.writeTxn(() => _isarService.focusStatus.put(status));
  }

  Future<List<FocusInsignia>> getEarnedInsignias() async {
    final status = await _getOrCreateStatus();
    if (status == null) return [];

    return status.earnedInsigniaNames.map((name) {
      return FocusInsignia.values.firstWhere((e) => e.name == name);
    }).toList();
  }

  Future<void> awardInsignia(FocusInsignia insignia) async {
    final status = await _getOrCreateStatus();
    if (status == null) return;

    if (status.earnedInsigniaNames.contains(insignia.name)) return;

    status.earnedInsigniaNames.add(insignia.name);
    status.lastUpdated = DateTime.now();

    await _isarService.database.writeTxn(() => _isarService.focusStatus.put(status));
  }
}
