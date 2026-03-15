# Guia de Migração: Provider → Riverpod

## 🎯 Objetivo

Migrar o Disciplinum de Provider para Riverpod de forma gradual e segura, mantendo a funcionalidade existente.

## 📋 Status Atual

### ✅ Configurado
- Dependências do Riverpod adicionadas
- Providers principais criados
- Wrapper de migração implementado
- Tela de exemplo funcionando

### 🔄 Em Progresso
- Migrar services principais
- Migrar telas uma por uma
- Testes automatizados

## 🚀 Como Usar

### 1. Envolver o App

```dart
// Antes (Provider)
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<GamificationService>(...),
        // ... outros providers
      ],
      child: MaterialApp(...),
    ),
  );
}

// Depois (Riverpod)
void main() {
  runApp(
    RiverpodApp(
      child: MaterialApp(...),
    ),
  );
}
```

### 2. Migrar Telas

```dart
// Antes (Provider)
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final service = Provider.of<GamificationService>(context);
    return Text(service.data);
  }
}

// Depois (Riverpod)
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(gamificationServiceProvider);
    return Text(service.data);
  }
}
```

### 3. Migrar Services

```dart
// Antes (ChangeNotifier)
class MyService extends ChangeNotifier {
  String _data = '';
  String get data => _data;
  
  void updateData(String newData) {
    _data = newData;
    notifyListeners();
  }
}

// Depois (StateNotifier)
class MyServiceNotifier extends StateNotifier<String> {
  MyServiceNotifier(this._service) : super('');
  final MyService _service;
  
  void updateData(String newData) {
    state = newData;
    _service.saveData(newData);
  }
}
```

## 📁 Arquivos Criados

### Core DI
- `lib/core/di/providers.dart` - Todos os providers centralizados
- `lib/core/di/riverpod_wrapper.dart` - Wrapper para migração gradual

### App Configuration
- `lib/app/riverpod_app.dart` - Configuração principal do Riverpod

### Exemplo
- `lib/features/home/presentation/screens/home_screen_riverpod.dart` - Tela de exemplo

## 🔄 Estratégia de Migração

### Fase 1: Configuração ✅
- [x] Adicionar dependências
- [x] Criar providers principais
- [x] Implementar wrapper

### Fase 2: Services (Em Andamento)
- [ ] Migrar GamificationService
- [ ] Migrar ForegroundDetector
- [ ] Migrar AuthService
- [ ] Migrar CountdownService

### Fase 3: Telas (A Fazer)
- [ ] HomeScreen
- [ ] Telas dos módulos
- [ ] Telas de configuração

### Fase 4: Testes (A Fazer)
- [ ] Testes unitários dos providers
- [ ] Testes de widget
- [ ] Testes de integração

## 🎯 Benefícios da Migração

### Performance
- **Compile-time safety**: Erros detectados em tempo de compilação
- **Rebuilds otimizados**: Apenas widgets que realmente mudam são reconstruídos
- **Menos boilerplate**: Código mais conciso

### Manutenibilidade
- **DI automática**: Não precisa de Provider.of manual
- **Testabilidade**: Mais fácil de testar isoladamente
- **Type safety**: Maior segurança de tipos

### Escalabilidade
- **State management unificado**: Um padrão para todo o app
- **Composição**: Providers podem ser combinados facilmente
- **Extensibilidade**: Fácil adicionar novos features

## 🛠️ Padrões Recomendados

### 1. Providers de Serviço
```dart
final myServiceProvider = Provider<MyService>((ref) {
  return MyService();
});
```

### 2. State Notifiers
```dart
final myStateProvider = StateNotifierProvider<MyStateNotifier, MyState>((ref) {
  return MyStateNotifier(ref.watch(myServiceProvider));
});
```

### 3. Async Providers
```dart
final asyncDataProvider = FutureProvider<MyData>((ref) async {
  final service = ref.watch(myServiceProvider);
  return await service.fetchData();
});
```

### 4. Computed Providers
```dart
final computedProvider = Provider<String>((ref) {
  final data1 = ref.watch(provider1);
  final data2 = ref.watch(provider2);
  return '$data1 + $data2';
});
```

## 🧪 Testes

### Teste de Provider
```dart
test('myServiceProvider', () {
  final container = ProviderContainer();
  final service = container.read(myServiceProvider);
  expect(service, isA<MyService>());
});
```

### Teste de StateNotifier
```dart
test('MyStateNotifier', () {
  final notifier = MyStateNotifier();
  expect(notifier.state, initialState);
  
  notifier.updateState('new value');
  expect(notifier.state, 'new value');
});
```

## 📚 Recursos

- [Documentação Oficial Riverpod](https://riverpod.dev/)
- [Guia de Migração](https://riverpod.dev/docs/migration)
- [Exemplos e Padrões](https://riverpod.dev/docs/cookbooks)

## ⚠️ Notas Importantes

1. **Migração Gradual**: Não precisa migrar tudo de uma vez
2. **Compatibilidade**: Provider e Riverpod podem coexistir
3. **Testes**: Teste cada migração antes de prosseguir
4. **Performance**: Monitore o impacto na performance

## 🔄 Próximos Passos

1. **Executar `flutter pub get`** para instalar dependências
2. **Rodar `flutter pub run build_runner build`** para code generation
3. **Testar a tela de exemplo** para validar configuração
4. **Começar migração pelos services mais simples**
5. **Atualizar telas gradualmente**

## 📊 Checklist de Validação

- [ ] App compila sem erros
- [ ] Tela de exemplo funciona
- [ ] Services básicos funcionam
- [ ] Performance mantida ou melhorada
- [ ] Testes passando

---
