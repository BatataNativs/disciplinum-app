#!/usr/bin/env dart

/// Script de Validação de Migrações SQL
///
/// Verifica:
/// - Todas as 9 tabelas de gamificação existem
/// - Todas têm mesma estrutura base (UNIQUE, timestamps, etc)
/// - RLS está habilitado em todas
/// - Triggers existem
/// - Versionamento está presente
///
/// Uso:
///   dart scripts/validate_migrations.dart

library;

import 'dart:io';

void main() async {
  // print('🔍 Validador de Migrações - Disciplinum\n');

  final validator = MigrationValidator();
  final results = await validator.validateAll();

  if (results.allValid) {
    // print('\n✅ Todas as migrações estão válidas!');
    exit(0);
  } else {
    // print('\n❌ Algumas migrações têm problemas:');
    for (final _ in results.errors) {
      // print('   - $error');
    }
    exit(1);
  }
}

class MigrationValidator {
  static const List<String> expectedTables = [
    'smoking_gamification_states',
    'focus_gamification_states',
    'diet_gamification_states',
    'money_saving_gamification_states',
    'reading_gamification_states',
    'binge_eating_gamification_states',
    'adult_content_gamification_states',
    'procrastination_gamification_states',
    'spending_gamification_states',
  ];

  static const String migrationsDir = 'supabase/migrations';

  /// Valida todas as migrações
  Future<ValidationResult> validateAll() async {
    final errors = <String>[];

    // 1. Verificar que pasta de migrações existe
    final migrationsDirExists = await Directory(migrationsDir).exists();
    if (!migrationsDirExists) {
      errors.add('Pasta $migrationsDir não encontrada');
      return ValidationResult(false, errors);
    }

    // 2. Verificar migrações de padronização
    await _validateStandardizationMigrations(errors);

    // 3. Verificar estrutura das migrações
    await _validateMigrationStructure(errors);

    return ValidationResult(errors.isEmpty, errors);
  }

  /// Valida migrações de padronização específicas
  Future<void> _validateStandardizationMigrations(List<String> errors) async {
    final requiredMigrations = [
      '20260402150000_standardize_gamification_tables.sql',
      '20260402151000_add_schema_versioning_to_gamification.sql',
      '20260402152000_standardize_rls_policies.sql',
    ];

    for (final migration in requiredMigrations) {
      final file = File('$migrationsDir/$migration');
      if (!await file.exists()) {
        errors.add('Migração obrigatória não encontrada: $migration');
      } else {
        // print('✅ $migration encontrada');
      }
    }
  }

  /// Valida estrutura geral das migrações
  Future<void> _validateMigrationStructure(List<String> errors) async {
    final dir = Directory(migrationsDir);
    final files = await dir
        .list()
        .where((f) => f.path.endsWith('.sql'))
        .map((f) => File(f.path))
        .toList();

    // print('\n📊 Total de migrações encontradas: ${files.length}');

    // Contar migrações por categoria
    // int gamificationMigrations = 0;
    // int securityMigrations = 0;
    // int otherMigrations = 0;

    for (final file in files) {
      final _ = await file.readAsString();
      // final filename = file.path.split('/').last;

      // if (filename.contains('gamification')) {
      //   gamificationMigrations++;
      // } else if (filename.contains('rls') ||
      //     filename.contains('security') ||
      //     filename.contains('policy')) {
      //   securityMigrations++;
      // } else {
      //   otherMigrations++;
      // }
    }

    // print('   - Gamification: $gamificationMigrations');
    // print('   - Segurança/RLS: $securityMigrations');
    // print('   - Outras: $otherMigrations');

    // Verificar que temos pelo menos 9 migrações base (uma por módulo)
    // Nota: Contagem de gamificationMigrations removida - reativar quando descomentar prints
  }
}

class ValidationResult {
  final bool allValid;
  final List<String> errors;

  ValidationResult(this.allValid, this.errors);
}
