# Correção de Serialização - Resumo

## Problema Identificado

Erro de runtime no módulo Focus:
```
type 'String' is not a subtype of type 'List<dynamic>?' in type cast
```

### Causa Raiz
As entidades de gamificação estavam retornando `String` (JSON-encoded) no método `toJson()` para campos de lista, mas os `ModuleState.fromJson()` esperavam `List<dynamic>`.

**Exemplo do problema:**
```dart
// ❌ Antes: Retornava String JSON
Map<String, dynamic> toJson() {
  return {
    'earnedInsignias': earnedInsignias, // String = '["madeira"]'
  };
}

// ✅ Depois: Retorna List<String>
Map<String, dynamic> toJson() {
  return {
    'earned_insignias': earnedInsigniasList, // List<String> = ['madeira']
  };
}
```

## Correções Aplicadas

### Entidades Corrigidas

| Entidade | Status | Alteração |
|----------|--------|-----------|
| `FocusGamificationEntity` | ✅ Corrigido | `toJson()` retorna `List<String>` |
| `ReadingGamificationEntity` | ✅ Corrigido | `toJson()` retorna `List<String>` |
| `SmokingGamificationEntity` | ✅ Corrigido | `toJson()` retorna `List<String>` |

### Entidades Já Corretas (sem alteração necessária)

| Entidade | Motivo |
|----------|--------|
| `AdultContentGamificationEntity` | Usa `List<String>` diretamente |
| `BingeEatingGamificationEntity` | Usa `List<String>` diretamente |
| `SpendingGamificationEntity` | Usa `List<String>` diretamente |
| `ProcrastinationGamificationEntity` | Usa `List<String>` diretamente |

### Entidades Sem `toJson()` (não afetadas)

| Entidade | Motivo |
|----------|--------|
| `DietGamificationEntity` | Não possui método `toJson()` |
| `MoneySavingGamificationEntity` | Não possui método `toJson()` |

## Padrão Correto para Novas Entidades

### ❌ Anti-Padrão (NÃO usar)
```dart
@Entity()
class ProblematicEntity {
  String earnedInsignias = '[]'; // String JSON no banco
  
  Map<String, dynamic> toJson() {
    return {
      'earnedInsignias': earnedInsignias, // ❌ String JSON
    };
  }
}
```

### ✅ Padrão Correto (USAR)
```dart
@Entity()
class CorrectEntity {
  String earnedInsignias = '[]'; // String JSON no banco (ObjectBox necessidade)
  
  // Getter para acesso como List
  List<String> get earnedInsigniasList {
    try {
      final List<dynamic> decoded = json.decode(earnedInsignias);
      return decoded.cast<String>();
    } catch (e) {
      return [];
    }
  }
  
  // Setter para salvar como String
  set earnedInsigniasList(List<String> insignias) {
    earnedInsignias = json.encode(insignias);
  }
  
  Map<String, dynamic> toJson() {
    return {
      'earned_insignias': earnedInsigniasList, // ✅ List<String>
    };
  }
}
```

## Fluxos Corrigidos

### 1. `FocusGamificationRepository.getFocusState()`
```dart
final jsonData = entity.toJson();  // Agora retorna List<String>
final newState = FocusModuleState.fromJson(jsonData); // ✅ Compatível
```

### 2. `ReadingModuleRepository.listAllLocal()`
```dart
return entities.map((e) => ReadingModuleState.fromJson(e.toJson())).toList(); // ✅ Funciona
```

### 3. `SmokingModuleRepository.listAllLocal()`
```dart
return entities.map((e) => SmokingModuleState.fromJson(e.toJson())).toList(); // ✅ Funciona
```

## Próximos Passos Recomendados

### 1. Testar em Dispositivo/Emulador
```bash
flutter clean
flutter pub get
flutter run
```

### 2. Limpar Dados Locais (se necessário)
Se houver dados salvos anteriormente no formato incorreto, pode ser necessário limpar:
- Desinstalar/reinstalar o app no device, OU
- Usar `ObjectBoxDataCleanup.cleanupAffectedEntities()` (arquivo criado em `lib/core/database/`)

### 3. Verificar Supabase
Dados sincronizados na nuvem devem ser naturalmente corrigidos quando:
- `syncToRemote` salva usando `state.toJson()` (ModuleState) → ✅ Já correto
- `loadFromRemote` carrega usando `ModuleState.fromJson()` → ✅ Já correto

### 4. Testes de Regressão
Verificar se outros módulos também funcionam corretamente após as alterações.

## Convenções de Nomenclatura

### Campos nas Entidades (ObjectBox)
- Use camelCase para nomes de campos
- Ex: `earnedInsignias`, `lastUpdated`

### Chaves no JSON
- Use snake_case para chaves JSON
- Ex: `earned_insignias`, `last_updated`

### Getters para Listas
- Sufixo `List` no getter
- Ex: `earnedInsigniasList`, `earnedMedalhasList`
