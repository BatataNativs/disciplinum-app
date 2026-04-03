# Contributing to Disciplinum

Obrigado por seu interesse em contribuir com o Disciplinum! Este documento fornece as diretrizes para contribuição.

## 🎯 Filosofia do Projeto

Disciplinum segue princípios de **arquitetura modular** com **"Contrato Invisível"**:

- **Independência**: Cada módulo é autônomo
- **Consistência**: Todos seguem padrões estruturais comuns
- **Qualidade**: Código production-ready, sem atalhos

## 🚀 Como Começar

### 1. Configurar Ambiente

```bash
# Clone o repositório
git clone <repo-url>
cd disciplinum_app

# Instale dependências
flutter pub get

# Rode build_runner (necessário para Isar)
flutter pub run build_runner build --delete-conflicting-outputs

# Verifique se tudo está funcionando
flutter analyze
flutter test
```

### 2. Entender a Arquitetura

Leia antes de começar:
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) - Visão geral
- [docs/MODULE_CONTRACT_GUIDE.md](docs/MODULE_CONTRACT_GUIDE.md) - Contratos de módulos
- [docs/adr/001-modular-architecture-with-contracts.md](docs/adr/001-modular-architecture-with-contracts.md) - Decisões arquiteturais

## 📝 Checklist de Qualidade

Antes de submeter qualquer código:

### Para Novos Módulos

- [ ] Implementa `ModuleStateContract`
- [ ] Implementa `ModuleRepositoryContract`
- [ ] Implementa `ModuleEventContract`
- [ ] Tem `schemaVersion` >= 1
- [ ] Segue estrutura de diretórios padrão
- [ ] Passa em `dart scripts/full_compliance_audit.dart`
- [ ] Zero erros em `flutter analyze`
- [ ] Testes unitários cobrem regras de negócio

### Para Modificações em Módulos Existentes

- [ ] Não quebra contratos existentes
- [ ] Se altera schema, incrementa `schemaVersion`
- [ ] Atualiza migrações SQL se necessário
- [ ] Documenta breaking changes
- [ ] Passa em todos os testes existentes
- [ ] Passa em `dart scripts/full_compliance_audit.dart`

### Para Infraestrutura/Core

- [ ] Não quebra nenhum dos 9 módulos
- [ ] Documenta mudanças em ADRs se arquitetural
- [ ] Testes de integração passam
- [ ] Performance não degrade > 10%

## 🏗️ Criando um Novo Módulo

### Passo 1: Estrutura de Diretórios

```
lib/features/modules/{module_name}/
├── domain/
│   ├── entities/
│   │   └── {module}_module_state.dart      # Implementa ModuleStateContract
│   └── repositories/
│       └── {module}_module_repository.dart # Implementa ModuleRepositoryContract
├── gamification/
│   └── domain/
│       ├── entities/
│       │   └── {module}_gamification_entity.dart  # @collection Isar
│       └── repositories/
│           └── {module}_gamification_repository.dart
└── presentation/
    └── screens/
        └── {module}_screen.dart
```

### Passo 2: Implementar Contratos

```dart
// {module}_module_state.dart
class NewModuleState implements ModuleStateContract {
  @override
  String get moduleId => 'new_module';

  @override
  int get schemaVersion => 1;

  @override
  DateTime get createdAt => _createdAt;

  @override
  DateTime get updatedAt => _updatedAt;

  // Campos específicos do módulo...
}
```

### Passo 3: Criar Migração SQL

```sql
-- supabase/migrations/XXX_create_new_module_gamification_states.sql
CREATE TABLE new_module_gamification_states (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  state_data JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id)
);

ALTER TABLE new_module_gamification_states ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only see their own new_module data" 
  ON new_module_gamification_states FOR SELECT 
  USING (auth.uid() = user_id);

-- ... outras policies
```

### Passo 4: Validar

```bash
# Verificar conformidade
dart scripts/full_compliance_audit.dart

# Verificar análise estática
flutter analyze

# Rodar testes
flutter test
```

## 🧪 Padrões de Teste

### Testes Unitários

```dart
group('NewModuleState', () {
  test('implements ModuleStateContract', () {
    final state = NewModuleState(/* ... */);
    expect(state, isA<ModuleStateContract>());
  });

  test('serializes to JSON correctly', () {
    final state = NewModuleState(/* ... */);
    final json = state.toJson();
    expect(json['_schema_version'], 1);
    expect(json['_module_id'], 'new_module');
  });
});
```

### Testes de Integração

```dart
// integration_test/new_module_test.dart
void main() {
  testWidgets('Module flow works end-to-end', (tester) async {
    // Testar fluxo completo do módulo
  });
}
```

## 🔄 Fluxo de Trabalho

1. **Branch**: Crie branch a partir de `develop`
   ```bash
   git checkout -b feature/nome-descritivo
   ```

2. **Desenvolva**: Implemente seguindo padrões

3. **Teste**: Verifique localmente
   ```bash
   flutter analyze
   dart scripts/full_compliance_audit.dart
   flutter test
   ```

4. **Documente**: Atualize docs se necessário

5. **Commit**: Mensagens claras e descritivas
   ```bash
   git commit -m "feat: adiciona módulo X com contratos Y"
   ```

6. **PR**: Abra Pull Request para `develop`
   - Descreva o que mudou
   - Referencie issues relacionadas
   - Inclua screenshots se houver UI

## 🐛 Reportando Bugs

Use o template:

```markdown
**Descrição**
Descrição clara do bug

**Reprodução**
Passos para reproduzir:
1. Vá para '...'
2. Clique em '...'
3. Veja o erro

**Comportamento Esperado**
O que deveria acontecer

**Screenshots**
Se aplicável

**Ambiente**
- Flutter version: [e.g. 3.16.0]
- Plataforma: [iOS/Android]
- Versão do app: [e.g. 1.2.3]
```

## 💡 Sugerindo Features

Abra uma issue com:
- Descrição clara da feature
- Justificativa (por que é necessária)
- Proposta de implementação (opcional)
- Mockups/diagramas (se aplicável)

## 📋 Convenções de Código

### Nomenclatura

| Elemento | Convenção | Exemplo |
|----------|-----------|---------|
| Classes | PascalCase | `FocusModuleState` |
| Métodos/Variáveis | camelCase | `loadFromRemote()` |
| Constantes | camelCase | `defaultTimeout` |
| Arquivos | snake_case | `focus_module_state.dart` |
| JSON Fields | snake_case | `sessions_completed` |
| Module IDs | snake_case | `'focus'`, `'money_saving'` |

### Estrutura de Arquivos

- Máximo 300 linhas por arquivo (ideal)
- Um conceito principal por arquivo
- Imports organizados: Dart → Flutter → Packages → Relativos

### Documentação

- Documente classes públicas com `///`
- Explique o "porquê", não o "o quê"
- Inclua exemplos de uso quando útil

## 🎓 Recursos de Aprendizado

- [Clean Architecture - Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Riverpod Documentation](https://riverpod.dev/docs/getting_started)
- [Isar Documentation](https://isar.dev/docs/tutorials/quickstart)
- [Supabase Documentation](https://supabase.com/docs)

## ❓ Dúvidas?

- Abra uma issue com label `question`
- Ou pergunte no canal #dev no Discord

---

**Lembre-se**: Qualidade > Quantidade. Cada linha de código deve justificar sua existência.

Obrigado por contribuir! 🚀
