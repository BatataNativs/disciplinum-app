# Guia: Adicionando Novas Features

## 🎯 **Overview**

Este guia mostra como adicionar novas features ao Disciplinum seguindo a arquitetura Feature-First implementada.

## 📋 **Checklist Inicial**

Antes de começar, verifique:

- [ ] Feature está bem definida e delimitada
- [ ] Dependencies externas identificadas
- [ ] UI/UX design aprovado
- [ ] Test cases planejados
- [ ] Documentação necessária

## 🚀 **Passo a Passo**

### **1. Criar Estrutura Base**

Use o template para criar a estrutura:

```bash
# Substitua 'new_feature' pelo nome da sua feature
mkdir -p features/new_feature/{domain/{entities,services,repositories},data/{repositories,datasources},presentation/{controllers,widgets,screens}}
```

### **2. Domain Layer**

#### **2.1 Entities**
Crie as entidades de domínio em `domain/entities/`:

```dart
// domain/entities/[feature]_entity.dart
import 'package:equatable/equatable.dart';

class FeatureEntity extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;
  
  const FeatureEntity({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, createdAt];
}
```

#### **2.2 Repository Interface**
```dart
// domain/repositories/[feature]_repository.dart
abstract class FeatureRepository {
  Future<List<FeatureEntity>> getAll();
  Future<FeatureEntity?> getById(String id);
  Future<void> save(FeatureEntity entity);
  Future<void> delete(String id);
}
```

#### **2.3 Domain Services**
```dart
// domain/services/[feature]_service.dart
class FeatureService {
  final FeatureRepository _repository;
  
  FeatureService(this._repository);
  
  Future<List<FeatureEntity>> getAllFeatures() => _repository.getAll();
  
  Future<FeatureEntity> createFeature(String name) async {
    final entity = FeatureEntity(
      id: _generateId(),
      name: name,
      createdAt: DateTime.now(),
    );
    await _repository.save(entity);
    return entity;
  }
  
  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}
```

### **3. Data Layer**

#### **3.1 Datasources**
```dart
// data/datasources/local_[feature]_datasource.dart
class LocalFeatureDatasource {
  static const String _key = 'features';
  
  Future<List<FeatureEntity>> getAll() async {
    // Implementação com SharedPreferences/SQLite
  }
  
  Future<FeatureEntity?> getById(String id) async {
    // Implementação local
  }
  
  Future<void> save(FeatureEntity entity) async {
    // Implementação local
  }
  
  Future<void> delete(String id) async {
    // Implementação local
  }
}
```

#### **3.2 Repository Implementation**
```dart
// data/repositories/[feature]_repository_impl.dart
class FeatureRepositoryImpl implements FeatureRepository {
  final LocalFeatureDatasource _localDatasource;
  final CloudFeatureDatasource? _cloudDatasource;
  
  FeatureRepositoryImpl(
    this._localDatasource, 
    [this._cloudDatasource]
  );
  
  @override
  Future<List<FeatureEntity>> getAll() async {
    return await _localDatasource.getAll();
  }
  
  @override
  Future<FeatureEntity?> getById(String id) async {
    return await _localDatasource.getById(id);
  }
  
  @override
  Future<void> save(FeatureEntity entity) async {
    await _localDatasource.save(entity);
    if (_cloudDatasource != null) {
      await _cloudDatasource!.save(entity);
    }
  }
  
  @override
  Future<void> delete(String id) async {
    await _localDatasource.delete(id);
    if (_cloudDatasource != null) {
      await _cloudDatasource!.delete(id);
    }
  }
}
```

### **4. Presentation Layer**

#### **4.1 Controller**
```dart
// presentation/controllers/[feature]_controller.dart
class FeatureController extends ChangeNotifier {
  final FeatureService _service;
  
  List<FeatureEntity> _features = [];
  bool _isLoading = false;
  String? _error;
  
  List<FeatureEntity> get features => _features;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  FeatureController(this._service);
  
  Future<void> loadFeatures() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _features = await _service.getAllFeatures();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> createFeature(String name) async {
    try {
      await _service.createFeature(name);
      await loadFeatures();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> deleteFeature(String id) async {
    try {
      await _service.deleteFeature(id);
      await loadFeatures();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
```

#### **4.2 Widgets**
```dart
// presentation/widgets/[feature]_card.dart
class FeatureCard extends StatelessWidget {
  final FeatureEntity feature;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  
  const FeatureCard({
    super.key,
    required this.feature,
    this.onTap,
    this.onDelete,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(feature.name),
        subtitle: Text(
          'Criado em ${DateFormat('dd/MM/yyyy').format(feature.createdAt)}',
        ),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onDelete,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}

// presentation/widgets/[feature]_form.dart
class FeatureForm extends StatefulWidget {
  final Function(String) onSubmit;
  
  const FeatureForm({super.key, required this.onSubmit});
  
  @override
  State<FeatureForm> createState() => _FeatureFormState();
}

class _FeatureFormState extends State<FeatureForm> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Nome da Feature',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira um nome';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onSubmit(_controller.text);
                  _controller.clear();
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### **4.3 Screen**
```dart
// presentation/screens/[feature]_list_screen.dart
class FeatureListScreen extends StatelessWidget {
  const FeatureListScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FeatureController(getIt<FeatureService>()),
      child: Consumer<FeatureController>(
        builder: (context, controller, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Minhas Features'),
            ),
            body: RefreshIndicator(
              onRefresh: () => controller.loadFeatures(),
              child: _buildBody(controller),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showAddDialog(context, controller),
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildBody(FeatureController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (controller.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Erro: ${controller.error}'),
            ElevatedButton(
              onPressed: controller.loadFeatures,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    
    if (controller.features.isEmpty) {
      return const Center(
        child: Text('Nenhuma feature encontrada'),
      );
    }
    
    return ListView.builder(
      itemCount: controller.features.length,
      itemBuilder: (context, index) {
        final feature = controller.features[index];
        return FeatureCard(
          feature: feature,
          onTap: () => _navigateToDetail(context, feature),
          onDelete: () => _confirmDelete(context, controller, feature),
        );
      },
    );
  }
  
  void _showAddDialog(BuildContext context, FeatureController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Feature'),
        content: FeatureForm(
          onSubmit: (name) {
            controller.createFeature(name);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
  
  void _navigateToDetail(BuildContext context, FeatureEntity feature) {
    // Navegar para tela de detalhes
  }
  
  void _confirmDelete(
    BuildContext context, 
    FeatureController controller, 
    FeatureEntity feature,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja excluir "${feature.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteFeature(feature.id);
              Navigator.of(context).pop();
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
```

### **5. Barrel Exports**

Crie arquivos de exportação para facilitar imports:

```dart
// domain/entities.dart
export '[feature]_entity.dart';

// domain/repositories.dart
export '[feature]_repository.dart';

// domain/services.dart
export '[feature]_service.dart';

// domain.dart
export 'entities.dart';
export 'repositories.dart';
export 'services.dart';

// data/repositories.dart
export '[feature]_repository_impl.dart';

// data/datasources.dart
export 'local_[feature]_datasource.dart';

// presentation/controllers.dart
export '[feature]_controller.dart';

// presentation/widgets.dart
export '[feature]_card.dart';
export '[feature]_form.dart';

// presentation/screens.dart
export '[feature]_list_screen.dart';

// feature.dart
export 'domain.dart';
export 'data/repositories.dart';
export 'data/datasources.dart';
export 'presentation/controllers.dart';
export 'presentation/widgets.dart';
export 'presentation/screens.dart';
```

### **6. Dependency Injection**

Registre as dependências em `app/injection.dart`:

```dart
// Adicionar às dependências existentes
getIt.registerLazySingleton<FeatureRepository>(
  () => FeatureRepositoryImpl(
    getIt<LocalFeatureDatasource>(),
    getIt<CloudFeatureDatasource>(),
  ),
);

getIt.registerLazySingleton<FeatureService>(
  () => FeatureService(getIt<FeatureRepository>()),
);

getIt.registerFactory<FeatureController>(
  () => FeatureController(getIt<FeatureService>()),
);
```

### **7. Navigation**

Adicione a rota em `app/router.dart`:

```dart
// Adicionar ao mapa de rotas
case '/feature_list':
  return MaterialPageRoute(
    builder: (_) => const FeatureListScreen(),
  );
```

### **8. Tests**

#### **Unit Tests**
```dart
// test/features/feature/domain/services/feature_service_test.dart
void main() {
  group('FeatureService', () {
    late FeatureRepository mockRepository;
    late FeatureService featureService;
    
    setUp(() {
      mockRepository = MockFeatureRepository();
      featureService = FeatureService(mockRepository);
    });
    
    test('should create feature successfully', () async {
      // Arrange
      const name = 'Test Feature';
      when(mockRepository.save(any))
          .thenAnswer((_) async {});
      
      // Act
      final result = await featureService.createFeature(name);
      
      // Assert
      expect(result.name, equals(name));
      verify(mockRepository.save(any)).called(1);
    });
  });
}
```

#### **Widget Tests**
```dart
// test/features/feature/presentation/widgets/feature_card_test.dart
void main() {
  testWidgets('FeatureCard displays feature information', (tester) async {
    // Arrange
    const feature = FeatureEntity(
      id: '1',
      name: 'Test Feature',
      createdAt: DateTime(2023, 1, 1),
    );
    
    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FeatureCard(feature: feature),
        ),
      ),
    );
    
    // Assert
    expect(find.text('Test Feature'), findsOneWidget);
    expect(find.text('Criado em 01/01/2023'), findsOneWidget);
  });
}
```

## 📋 **Checklist Final**

Após implementar, verifique:

- [ ] Estrutura de diretórios criada corretamente
- [ ] Domain layer sem dependências externas
- [ ] Repository pattern implementado
- [ ] Controller com state management adequado
- [ ] Widgets reutilizáveis e testáveis
- [ ] Barrel exports funcionando
- [ ] Dependency injection configurada
- [ ] Navigation integrada
- [ ] Testes unitários e widget criados
- [ ] Documentação atualizada

## 🚀 **Deploy**

1. **Code Review**: Peça review do time
2. **Tests**: Execute todos os testes
3. **Build**: Verifique se build funciona
4. **Integration**: Teste com features existentes
5. **Release**: Merge para main branch

## 📚 **Referências**

- [Feature-First Architecture Guide](../architecture/feature-first.md)
- [Testing Best Practices](testing.md)
- [Dependency Injection](dependency-injection.md)

---

**Pronto!** Sua nova feature está integrada à arquitetura Disciplinum.
