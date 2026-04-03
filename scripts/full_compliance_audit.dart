#!/usr/bin/env dart

/// Script de Auditoria COMPLETA - 100% Compliance Check
/// 
/// Verifica TODOS os contratos para todos os 9 módulos:
/// - ModuleStateContract
/// - ModuleRepositoryContract
/// - ModuleEventContract
/// - Estrutura de pastas correta
/// - Imports sem referências antigas
/// 
/// Uso:
///   dart scripts/full_compliance_audit.dart

library;

import 'dart:io';

void main(List<String> args) async {
  final auditor = FullComplianceAuditor();
  
  // print('''
  // ╔══════════════════════════════════════════════════════════════════╗
  // ║         AUDITORIA COMPLETA - 100% COMPLIANCE CHECK              ║
  // ╚══════════════════════════════════════════════════════════════════╝
  // ''');
  
  final results = await auditor.auditAll();
  
  auditor.printFinalReport(results);
  
  // Exit code baseado no resultado
  final allPassed = results.values.every((r) => r.isFullyCompliant);
  exit(allPassed ? 0 : 1);
}

class FullComplianceAuditor {
  static const List<String> allModules = [
    'smoking',
    'focus',
    'diet',
    'money_saving',
    'reading',
    'binge_eating',
    'adult_content',
    'procrastination',
    'spending',
  ];
  
  /// Audit all modules for all contracts
  Future<Map<String, ModuleAuditResult>> auditAll() async {
    final results = <String, ModuleAuditResult>{};
    
    for (final module in allModules) {
      // print('🔍 Auditando módulo: $module...');
      results[module] = await _auditModule(module);
    }
    
    return results;
  }
  
  /// Comprehensive audit of a single module
  Future<ModuleAuditResult> _auditModule(String module) async {
    final checks = <String, ContractCheck>{};
    
    // 1. Check ModuleStateContract
    checks['ModuleStateContract'] = await _checkModuleStateContract(module);
    
    // 2. Check ModuleRepositoryContract
    checks['ModuleRepositoryContract'] = await _checkModuleRepositoryContract(module);
    
    // 3. Check ModuleEventContract
    checks['ModuleEventContract'] = await _checkModuleEventContract(module);
    
    // 4. Check folder structure
    checks['FolderStructure'] = await _checkFolderStructure(module);
    
    // 5. Check for old imports (gamification/domain/entities/xxx_module_state.dart)
    checks['NoOldImports'] = await _checkNoOldImports(module);
    
    // 6. Check gamification entity uses correct ModuleState
    checks['GamificationEntityMapping'] = await _checkGamificationEntityMapping(module);
    
    return ModuleAuditResult(
      moduleName: module,
      checks: checks,
    );
  }
  
  /// Check 1: ModuleStateContract implementation
  Future<ContractCheck> _checkModuleStateContract(String module) async {
    final file = File(
      'lib/features/modules/$module/domain/entities/${module}_module_state.dart',
    );
    
    if (!await file.exists()) {
      return ContractCheck(
        name: 'ModuleStateContract',
        passed: false,
        errors: ['Arquivo não encontrado: ${file.path}'],
      );
    }
    
    final content = await file.readAsString();
    final errors = <String>[];
    
    // Verificar implements ModuleStateContract
    if (!content.contains('implements ModuleStateContract')) {
      errors.add('Não implementa ModuleStateContract');
    }
    
    // Verificar moduleId correto
    final moduleIdPattern = "moduleId = '$module'";
    if (!content.contains(moduleIdPattern)) {
      errors.add("moduleId não definido como '$module'");
    }
    
    // Verificar métodos obrigatórios
    final requiredMethods = [
      'toJson()',
      'fromJson',
      'toMap()',
      'fromMap',
      'copyWith',
      'progressMetrics',
      'currentStage',
      'schemaVersion',
    ];
    
    for (final method in requiredMethods) {
      if (!content.contains(method)) {
        errors.add('Método/campo ausente: $method');
      }
    }
    
    return ContractCheck(
      name: 'ModuleStateContract',
      passed: errors.isEmpty,
      errors: errors,
    );
  }
  
  /// Check 2: ModuleRepositoryContract implementation
  Future<ContractCheck> _checkModuleRepositoryContract(String module) async {
    final file = File(
      'lib/features/modules/$module/domain/repositories/${module}_module_repository.dart',
    );
    
    if (!await file.exists()) {
      return ContractCheck(
        name: 'ModuleRepositoryContract',
        passed: false,
        errors: ['Arquivo não encontrado: ${file.path}'],
      );
    }
    
    final content = await file.readAsString();
    final errors = <String>[];
    
    // Verificar implements ModuleRepositoryContract
    if (!content.contains('implements ModuleRepositoryContract<${module}_module_state')) {
      // Check with proper casing
      final className = _toPascalCase(module);
      if (!content.contains('implements ModuleRepositoryContract<$className')) {
        errors.add('Não implementa ModuleRepositoryContract corretamente');
      }
    }
    
    // Verificar métodos obrigatórios do contrato
    final requiredMethods = [
      'initialize()',
      'dispose()',
      'saveLocal',
      'loadLocal',
      'existsLocal',
      'deleteLocal',
      'listAllLocal',
      'syncToRemote',
      'loadFromRemote',
      'existsRemote',
      'deleteRemote',
      'resolveConflict',
      'fullSync',
      'hasDivergence',
      'clearAll',
      'exportToJson',
      'importFromJson',
      'statusStream',
    ];
    
    for (final method in requiredMethods) {
      if (!content.contains(method)) {
        errors.add('Método ausente: $method');
      }
    }
    
    // Verificar uso de Isar
    if (!content.contains('IsarService.instance.database')) {
      errors.add('Não usa IsarService.instance.database');
    }
    
    // Verificar uso de Supabase
    if (!content.contains('Supabase.instance.client')) {
      errors.add('Não usa Supabase.instance.client');
    }
    
    return ContractCheck(
      name: 'ModuleRepositoryContract',
      passed: errors.isEmpty,
      errors: errors,
    );
  }
  
  /// Check 3: ModuleEventContract implementation
  Future<ContractCheck> _checkModuleEventContract(String module) async {
    final file = File(
      'lib/features/modules/$module/domain/events/${module}_module_event.dart',
    );
    
    if (!await file.exists()) {
      return ContractCheck(
        name: 'ModuleEventContract',
        passed: false,
        errors: ['Arquivo não encontrado: ${file.path}'],
      );
    }
    
    final content = await file.readAsString();
    final errors = <String>[];
    
    // Verificar implements ModuleEventContract
    if (!content.contains('implements ModuleEventContract')) {
      errors.add('Evento não implementa ModuleEventContract');
    }
    
    // Verificar moduleId correto no evento (suporta campo final ou getter)
    final moduleIdPattern1 = "moduleId = '$module'";
    final moduleIdPattern2 = "get moduleId => '$module'";
    if (!content.contains(moduleIdPattern1) && !content.contains(moduleIdPattern2)) {
      errors.add("moduleId do evento não definido como '$module'");
    }
    
    // Verificar campos obrigatórios
    final requiredFields = [
      'eventType',
      'userId',
      'timestamp',
      'payload',
      'eventVersion',
      'category',
    ];
    
    for (final field in requiredFields) {
      if (!content.contains('get $field')) {
        errors.add('Campo ausente no evento: $field');
      }
    }
    
    // Verificar toJson()
    if (!content.contains('Map<String, dynamic> toJson()')) {
      errors.add('Método toJson() ausente no evento');
    }
    
    // Verificar Factory
    final className = _toPascalCase(module);
    if (!content.contains('class ${className}EventFactory')) {
      errors.add('Factory de eventos não encontrada');
    }
    
    if (!content.contains('implements ModuleEventFactory<')) {
      errors.add('Factory não implementa ModuleEventFactory');
    }
    
    return ContractCheck(
      name: 'ModuleEventContract',
      passed: errors.isEmpty,
      errors: errors,
    );
  }
  
  /// Check 4: Folder structure
  Future<ContractCheck> _checkFolderStructure(String module) async {
    final errors = <String>[];
    
    final requiredFolders = [
      'lib/features/modules/$module/domain/entities',
      'lib/features/modules/$module/domain/repositories',
      'lib/features/modules/$module/domain/events',
      'lib/features/modules/$module/gamification/domain/entities',
    ];
    
    for (final folder in requiredFolders) {
      final dir = Directory(folder);
      if (!await dir.exists()) {
        errors.add('Pasta ausente: $folder');
      }
    }
    
    return ContractCheck(
      name: 'FolderStructure',
      passed: errors.isEmpty,
      errors: errors,
    );
  }
  
  /// Check 5: No old imports referencing gamification/domain/entities/xxx_module_state.dart
  Future<ContractCheck> _checkNoOldImports(String module) async {
    final errors = <String>[];
    final oldImportPattern = 'gamification/domain/entities/${module}_module_state.dart';
    
    // Verificar todos os arquivos Dart do módulo
    final moduleDir = Directory('lib/features/modules/$module');
    if (await moduleDir.exists()) {
      await for (final file in moduleDir.list(recursive: true)) {
        if (file is File && file.path.endsWith('.dart')) {
          final content = await file.readAsString();
          if (content.contains(oldImportPattern)) {
            errors.add('Import antigo encontrado em: ${file.path}');
          }
        }
      }
    }
    
    return ContractCheck(
      name: 'NoOldImports',
      passed: errors.isEmpty,
      errors: errors,
    );
  }
  
  /// Check 6: Gamification entity uses correct ModuleState from domain/
  Future<ContractCheck> _checkGamificationEntityMapping(String module) async {
    final file = File(
      'lib/features/modules/$module/gamification/domain/entities/${module}_gamification_entity.dart',
    );
    
    if (!await file.exists()) {
      return ContractCheck(
        name: 'GamificationEntityMapping',
        passed: false,
        errors: ['Arquivo não encontrado: ${file.path}'],
      );
    }
    
    final content = await file.readAsString();
    final errors = <String>[];
    
    // Verificar import correto (deve vir de domain/entities/, não gamification/)
    final correctImport = 'features/modules/$module/domain/entities/${module}_module_state.dart';
    if (!content.contains(correctImport)) {
      errors.add('Import do ModuleState deve vir de domain/entities/');
    }
    
    // Verificar fromModuleState e toModuleState
    if (!content.contains('fromModuleState')) {
      errors.add('Método fromModuleState não encontrado');
    }
    
    if (!content.contains('toModuleState')) {
      errors.add('Método toModuleState não encontrado');
    }
    
    // Verificar mapeamento de campos (lastUpdated -> updatedAt)
    if (content.contains('lastUpdated: state.lastUpdated')) {
      errors.add('Mapeamento incorreto: deve usar state.updatedAt');
    }
    
    return ContractCheck(
      name: 'GamificationEntityMapping',
      passed: errors.isEmpty,
      errors: errors,
    );
  }
  
  /// Print final comprehensive report
  void printFinalReport(Map<String, ModuleAuditResult> results) {
    // print('\n' + '═' * 70);
    // print('📊 RELATÓRIO FINAL DE CONFORMIDADE - 100% CHECK');
    // print('═' * 70);
    
    // var totalChecks = 0;
    // var passedChecks = 0;
    var fullyCompliantModules = 0;
    
    for (final entry in results.entries) {
      // final module = entry.key;
      final result = entry.value;
      
      // print('\n📦 $module');
      // print('─' * 70);
      
      for (final check in result.checks.entries) {
        // final checkName = check.key;
        final checkResult = check.value;
        
        // totalChecks++;
        if (checkResult.passed) {
          // passedChecks++;
          // print('  ✅ $checkName');
        } else {
          // print('  ❌ $checkName');
          for (final _ in checkResult.errors) {
            // print('     • $error');
          }
        }
      }
      
      // final score = result.complianceScore;
      // final status = result.isFullyCompliant ? '✅ 100%' : '❌ ${(score * 100).toStringAsFixed(1)}%';
      // print('  ─────────────────────────────────────');
      // print('  📊 Score: $status');
      
      if (result.isFullyCompliant) {
        fullyCompliantModules++;
      }
    }
    
    // print('\n' + '═' * 70);
    // print('📈 ESTATÍSTICAS GERAIS');
    // print('═' * 70);
    // print('  • Total de verificações: $totalChecks');
    // print('  • Verificações passadas: $passedChecks');
    // print('  • Verificações falhas: ${totalChecks - passedChecks}');
    // print('  • Módulos 100% compliant: $fullyCompliantModules/${results.length}');
    // print('  • Taxa de sucesso geral: ${((passedChecks / totalChecks) * 100).toStringAsFixed(1)}%');
    
    // print('\n' + '═' * 70);
    if (fullyCompliantModules == results.length) {
      // print('🎉 PARABÉNS! Todos os módulos estão 100% COMPLIANT!');
      // print('✅ Todos os contratos estão corretamente implementados!');
    } else {
      // print('⚠️  ATENÇÃO: ${results.length - fullyCompliantModules} módulo(s) precisam de correções!');
    }
    // print('═' * 70);
    // print('');
  }
  
  /// Convert snake_case to PascalCase
  String _toPascalCase(String snakeCase) {
    return snakeCase
        .split('_')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join('');
  }
}

/// Result of auditing a single module
class ModuleAuditResult {
  final String moduleName;
  final Map<String, ContractCheck> checks;
  
  ModuleAuditResult({
    required this.moduleName,
    required this.checks,
  });
  
  double get complianceScore {
    if (checks.isEmpty) return 0.0;
    final passed = checks.values.where((c) => c.passed).length;
    return passed / checks.length;
  }
  
  bool get isFullyCompliant => complianceScore == 1.0;
}

/// Result of checking a specific contract
class ContractCheck {
  final String name;
  final bool passed;
  final List<String> errors;
  
  ContractCheck({
    required this.name,
    required this.passed,
    required this.errors,
  });
}
