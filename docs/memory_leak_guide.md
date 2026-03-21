# 🧠 Guia Completo: Memory Leaks no Flutter/Disciplinum

## O que é Memory Leak?

Memory Leak é quando o app aloca memória mas **nunca a libera**, causando:
- 📈 Consumo crescente de RAM
- 🐌 Performance degradante
- 💥 Crashes por falta de memória
- 🔄 Múltiplos GC (Garbage Collection)

---

## 🔍 Principais Causas no Disciplinum

### 1. **Streams Não Fechados**
```dart
// ❌ MEMORY LEAK
final subscription = someStream.listen((data) => print(data));
// Nunca chama subscription.cancel()

// ✅ CORRETO
StreamSubscription? _subscription;

void initState() {
  _subscription = someStream.listen((data) => print(data));
}

void dispose() {
  _subscription?.cancel(); // Libera memória!
}
```

### 2. **Timers Não Cancelados**
```dart
// ❌ MEMORY LEAK
Timer.periodic(Duration(seconds: 1), (timer) => print('tick'));
// Timer nunca é cancelado

// ✅ CORRETO
Timer? _timer;

void startTimer() {
  _timer?.cancel();
  _timer = Timer.periodic(Duration(seconds: 1), _onTick);
}

void dispose() {
  _timer?.cancel(); // Libera memória!
}
```

### 3. **Controllers Não Descartados**
```dart
// ❌ MEMORY LEAK
class MyWidget extends StatefulWidget {
  final controller = TextEditingController();
  // Nunca chama controller.dispose()
}

// ✅ CORRETO
class MyWidget extends StatefulWidget {
  TextEditingController? _controller;

  @override
  void dispose() {
    _controller?.dispose(); // Libera memória!
    super.dispose();
  }
}
```

---

## 🚨 Problemas Identificados no Disciplinum

### AppMonitoringService
```dart
// ❌ PROBLEMAS ENCONTRADOS:
StreamSubscription? _accessibilitySubscription; // ✅ Tem cancel()
Timer? _monitorTimer; // ✅ Tem cancel()

// Mas precisa garantir dispose() completo!
```

### CountdownService
```dart
// ✅ BOM: Já tem dispose() implementado
void dispose() {
  for (final timer in _timers.values) {
    timer.cancel();
  }
  _timers.clear();
  _activeCountdowns.clear();
}
```

---

## 🔧 Como Prevenir Memory Leaks

### Regra de Ouro: **Sempre faça dispose()**

```dart
class MyService {
  StreamSubscription? _sub1;
  StreamSubscription? _sub2;
  Timer? _timer;
  TextEditingController? _controller;

  void dispose() {
    // 1. Cancelar streams
    _sub1?.cancel();
    _sub2?.cancel();
    
    // 2. Cancelar timers
    _timer?.cancel();
    
    // 3. Descartar controllers
    _controller?.dispose();
    
    // 4. Limpar collections
    _someMap.clear();
    _someList.clear();
  }
}
```

### Pattern: Automatic Dispose com Widgets
```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = someStream.listen((data) => setState(() {}));
  }

  @override
  void dispose() {
    _subscription?.cancel(); // ESSENCIAL!
    super.dispose();
  }
}
```

---

## 🛠️ Ferramentas de Debug

### 1. **Flutter Inspector**
```bash
flutter run --profile
# Abra Flutter Inspector > Memory
```

### 2. **Dart DevTools**
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### 3. **Logs de GC (como você viu)**
```
I/disciplinum.app: Background young concurrent mark compact GC freed 45MB
```
Se isso aparece repetidamente → **Memory Leak!**

---

## 📋 Checklist Anti-Memory Leak

### Para Services:
- [ ] Todo `StreamSubscription` tem `.cancel()`?
- [ ] Todo `Timer` tem `.cancel()`?
- [ ] Método `dispose()` implementado?
- [ ] Collections limpas no dispose?

### Para Widgets:
- [ ] `TextEditingController.dispose()`?
- [ ] `AnimationController.dispose()`?
- [ ] `FocusNode.dispose()`?
- [ ] `StreamSubscription.cancel()`?

### Para AppMonitoringService (Correção Necessária):
```dart
// Adicionar método dispose completo
void dispose() {
  _monitorTimer?.cancel();
  _accessibilitySubscription?.cancel();
  _violationStartByApp.clear();
  // ... limpar outros resources
}
```

---

## 🎯 Solução Imediata para o Disciplinum

### 1. **Corrigir AppMonitoringService**
```dart
class AppMonitoringService {
  // ... existing code ...
  
  /// 🚨 MÉTODO FALTANTE!
  void dispose() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
    
    _accessibilitySubscription?.cancel();
    _accessibilitySubscription = null;
    
    _violationStartByApp.clear();
    monitoredApps.clear();
    
    LoggerService.instance.i('AppMonitoringService disposed');
  }
}
```

### 2. **Verificar Todos os Services**
- CountdownService ✅ (já tem dispose)
- AppMonitoringService ❌ (precisa de dispose)
- Outros services? 🔍 (verificar)

### 3. **Adicionar Dispose Global**
```dart
// Em algum lugar central (ex: no logout ou app exit)
void disposeAllServices() {
  Get.find<AppMonitoringService>()?.dispose();
  Get.find<CountdownService>()?.dispose();
  // ... outros services
}
```

---

## ⚡ Performance Tips

1. **Use const** sempre que possível
2. **Evite rebuilds desnecessários**
3. **Use ListView.builder** para listas longas
4. **Limpe cache periodicamente** (já implementado!)
5. **Monitore memória** em desenvolvimento

---

## 📊 Monitoramento

### Adicionar ao LoggerService:
```dart
static void logMemoryUsage(String context) {
  // Logar uso de memória periodicamente
  // Ajudar a identificar leaks
}
```

### Alertas Automáticos:
```dart
if (memoryUsage > threshold) {
  LoggerService.instance.w('⚠️ Alta memória detectada: $context');
}
```

---

## ✅ Resumo

**Memory Leak = Recursos não liberados**
**Solução = Sempre chamar dispose()**
**Prevenção = Pattern de gerenciamento de recursos**

Implemente essas correções e o app ficará muito mais estável! 🚀
