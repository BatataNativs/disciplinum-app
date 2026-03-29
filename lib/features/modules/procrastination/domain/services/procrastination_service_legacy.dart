// DEPRECATED: Use ProcrastinationServiceIsar instead
// This file is kept for backward compatibility only
// Note: Remove this file after migration is complete

import 'package:disciplinum/core/logging/logger_service.dart';

/// @deprecated Use ProcrastinationServiceIsar instead
/// Legacy service using IsarPreferencesRepository - DO NOT USE FOR NEW CODE
class ProcrastinationService {
  /// @deprecated Use ProcrastinationServiceIsar.instance instead
  static ProcrastinationService? _instance;
  /// @deprecated Use ProcrastinationServiceIsar.instance instead
  static ProcrastinationService get instance => _instance ??= ProcrastinationService._();
  
  ProcrastinationService._() {
    LoggerService.instance.w('DEPRECATED: ProcrastinationService is deprecated. Use ProcrastinationServiceIsar.instance instead.');
  }
  
  /// @deprecated This service is deprecated and will be removed
  void deprecatedMethod() {
    throw UnsupportedError('ProcrastinationService is deprecated. Use ProcrastinationServiceIsar.instance instead.');
  }
}
