#!/usr/bin/env dart

/// Script de Auditoria de Conformidade de Módulos
/// 
/// Verifica se os módulos seguem o "Contrato Invisível" definido em:
/// docs/MODULE_CONTRACT_GUIDE.md
/// 
/// Uso:
///   dart scripts/audit_module_compliance.dart --module=focus
///   dart scripts/audit_module_compliance.dart --all
///   dart scripts/audit_module_compliance.dart --check-json

import 'dart:io';

void main(List<String> args) async {
  final auditor = ModuleAuditor();
  
  if (args.contains('--help') || args.contains('-h')) {
    _printHelp();
    return;
  }
  
  if (args.contains('--all')) {
    await auditor.auditAllModules();
  } else if (args.contains('--check-json')) {
    await auditor.validateJsonFiles();
  } else {
    final moduleArg = args.firstWhere(
      (a) => a.startsWith('--module='),
      orElse: () => '',
    );
    
    if (moduleArg.isEmpty) {
      print('❌ Erro: Especifique --module=<nome> ou --all');
      _printHelp();
      exit(1);
    }
    
    final moduleName = moduleArg.split('=')[1];
    await auditor.auditModule(moduleName);
  }
}

void _printHelp() {
  print('''
🔍 Auditor de Conformidade de Módulos - Disciplinum

Uso:
  dart scripts/audit_module_compliance.dart [opções]

Opções:
  --module=<nome>    Audita módulo específico (ex: focus, diet)
  --all              Audita todos os 9 módulos
  --check-json       Valida arquivos JSON de exemplo
  --help, -h         Mostra esta ajuda

Exemplos:
  dart scripts/audit_module_compliance.dart --module=focus
  dart scripts/audit_module_compliance.dart --all
''');
}

class ModuleAuditor {
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
  
  /// Audita todos os módulos
  Future<void> auditAllModules() async {
    print('🔍 Iniciando auditoria completa dos 9 módulos...\n');
    
    final results = <String, AuditResult>{};
    
    for (final module in allModules) {
      results[module] = await _auditModuleInternal(module);
    }
    
    _printSummary(results);
  }
  
  /// Audita módulo específico
  Future<void> auditModule(String moduleName) async {
    print('🔍 Auditando módulo: $moduleName\n');
    
    final result = await _auditModuleInternal(moduleName);
    _printResult(moduleName, result);
  }
  
  /// Valida arquivos JSON de exemplo
  Future<void> validateJsonFiles() async {
    print('🔍 Validando arquivos JSON de exemplo...\n');
    
    // Implementação futura
    print('⚠️  Funcionalidade em desenvolvimento');
  }
  
  /// Auditoria interna
  Future<AuditResult> _auditModuleInternal(String moduleName) async {
    final checks = <String, bool>{};
    final errors = <String>[];
    
    // Check 1: Arquivo de estado existe
    final stateFile = File(
      'lib/features/modules/$moduleName/domain/entities/${moduleName}_module_state.dart',
    );
    checks['state_file_exists'] = await stateFile.exists();
    if (!checks['state_file_exists']!) {
      errors.add('Arquivo de estado não encontrado: ${stateFile.path}');
    }
    
    // Check 2: Implementa ModuleStateContract
    if (checks['state_file_exists']!) {
      final content = await stateFile.readAsString();
      checks['implements_contract'] = content.contains('implements ModuleStateContract');
      checks['has_moduleId'] = content.contains("moduleId = '$moduleName'");
      checks['has_schemaVersion'] = content.contains('schemaVersion');
      checks['has_toJson'] = content.contains('Map<String, dynamic> toJson()');
      checks['has_toMap'] = content.contains('Map<String, dynamic> toMap()');
      checks['has_progressMetrics'] = content.contains('progressMetrics');
      checks['has_currentStage'] = content.contains('currentStage');
    } else {
      checks['implements_contract'] = false;
      checks['has_moduleId'] = false;
      checks['has_schemaVersion'] = false;
      checks['has_toJson'] = false;
      checks['has_toMap'] = false;
      checks['has_progressMetrics'] = false;
      checks['has_currentStage'] = false;
    }
    
    // Check 3: Repository existe
    final repoFile = File(
      'lib/features/modules/$moduleName/domain/repositories/${moduleName}_repository.dart',
    );
    checks['repository_exists'] = await repoFile.exists();
    
    // Check 4: Gamification entity existe
    final gamificationFile = File(
      'lib/features/modules/$moduleName/gamification/domain/entities/${moduleName}_gamification_entity.dart',
    );
    checks['gamification_entity_exists'] = await gamificationFile.exists();
    
    // Check 5: Notifier existe
    final notifierFile = File(
      'lib/features/modules/$moduleName/gamification/presentation/controllers/${moduleName}_notifier.dart',
    );
    checks['notifier_exists'] = await notifierFile.exists();
    
    return AuditResult(
      moduleName: moduleName,
      checks: checks,
      errors: errors,
    );
  }
  
  /// Imprime resultado individual
  void _printResult(String moduleName, AuditResult result) {
    print('📦 Módulo: $moduleName');
    print('─' * 50);
    
    for (final entry in result.checks.entries) {
      final icon = entry.value ? '✅' : '❌';
      print('  $icon ${entry.key}');
    }
    
    if (result.errors.isNotEmpty) {
      print('\n⚠️  Erros:');
      for (final error in result.errors) {
        print('   • $error');
      }
    }
    
    final score = result.complianceScore;
    final scoreIcon = score >= 0.8 ? '🟢' : score >= 0.5 ? '🟡' : '🔴';
    print('\n$scoreIcon Score de conformidade: ${(score * 100).toStringAsFixed(1)}%\n');
  }
  
  /// Imprime resumo de todos os módulos
  void _printSummary(Map<String, AuditResult> results) {
    print('\n' + '=' * 60);
    print('📊 RESUMO DA AUDITORIA');
    print('=' * 60);
    
    var totalScore = 0.0;
    var compliant = 0;
    var partial = 0;
    var nonCompliant = 0;
    
    for (final entry in results.entries) {
      final score = entry.value.complianceScore;
      totalScore += score;
      
      if (score >= 0.8) {
        compliant++;
      } else if (score >= 0.5) {
        partial++;
      } else {
        nonCompliant++;
      }
      
      final icon = score >= 0.8 ? '✅' : score >= 0.5 ? '⚠️' : '❌';
      print('$icon ${entry.key.padRight(20)} ${(score * 100).toStringAsFixed(1)}%');
    }
    
    print('\n' + '─' * 60);
    print('📈 Estatísticas:');
    print('   • Compliant:     $compliant/${results.length}');
    print('   • Parcial:       $partial/${results.length}');
    print('   • Não compliant: $nonCompliant/${results.length}');
    print('   • Média geral:   ${((totalScore / results.length) * 100).toStringAsFixed(1)}%');
    print('=' * 60);
  }
}

class AuditResult {
  final String moduleName;
  final Map<String, bool> checks;
  final List<String> errors;
  
  AuditResult({
    required this.moduleName,
    required this.checks,
    required this.errors,
  });
  
  double get complianceScore {
    if (checks.isEmpty) return 0.0;
    final passed = checks.values.where((v) => v).length;
    return passed / checks.length;
  }
}
