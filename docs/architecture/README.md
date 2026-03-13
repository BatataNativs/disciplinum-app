# Arquitetura Disciplinum

## 📋 **Visão Geral**

O Disciplinum utiliza uma arquitetura **Feature-First** com princípios **Clean Architecture**, otimizada para escalabilidade e manutenibilidade seguindo as melhores práticas Flutter 2024.

## 🏗️ **Estrutura de Diretórios**

```
lib/
├── app/                          # Configurações globais
│   ├── bootstrap.dart            # Inicialização do app
│   └── router.dart               # Configuração de navegação
├── core/                         # Serviços reutilizáveis
│   ├── config/                   # Feature flags e configurações
│   ├── constants/                # Constantes do app
│   ├── navigation/               # Serviço de navegação
│   ├── events/                   # EventBus para comunicação
│   ├── logging/                  # Logger estruturado
│   ├── analytics/                # Analytics e métricas
│   └── storage/                  # Storage local
├── infrastructure/               # Camada de dados
│   ├── repositories/             # Abstração de dados
│   └── datasources/              # Fontes de dados (local/cloud)
├── features/                     # Funcionalidades do app
│   ├── gamification/             # Sistema de gamificação
│   │   ├── domain/               # Lógica de negócio
│   │   │   ├── entities/         # Entidades
│   │   │   └── services/         # Serviços de domínio
│   │   └── presentation/         # UI e controllers
│   │       ├── controllers/      # State management
│   │       ├── widgets/          # Componentes de UI
│   │       └── screens/          # Telas
│   ├── auth/                     # Autenticação
│   ├── modules/                  # Módulos de hábitos
│   │   ├── smoking/              # Tabagismo
│   │   ├── focus/                # Foco e produtividade
│   │   └── ...                   # Outros módulos
│   └── ...                      # Outras features
├── shared/                       # Componentes compartilhados
│   ├── widgets/                  # UI reutilizável
│   ├── models/                   # Models compartilhados
│   └── utils/                    # Utilitários
└── test/                         # Testes
```

## 🎯 **Princípios Arquiteturais**

### 1. **Feature-First Organization**
- Cada feature é autocontida
- Arquivos relacionados agrupados por funcionalidade
- Facilita navegação e manutenção

### 2. **Separation of Concerns**
- **Domain Layer**: Lógica de negócio pura
- **Data Layer**: Persistência e APIs
- **Presentation Layer**: UI e state management

### 3. **Single Source of Truth (SSOT)**
- Repository pattern para dados
- Unidirectional data flow
- State imutável

### 4. **Dependency Inversion**
- Interfaces em domain layer
- Implementações em infrastructure
- Injeção de dependências

## 🔄 **Fluxo de Dados**

```
UI (Presentation) → Controller → Service → Repository → DataSource
                ←            ←         ←           ←
```

1. **User Action** dispara evento no controller
2. **Controller** chama service de domínio
3. **Service** processa lógica de negócio
4. **Repository** abstrai acesso a dados
5. **DataSource** implementa persistência
6. **State Update** notifica UI via ChangeNotifier/RxBloc

## 📦 **Componentes Chave**

### Core Services
- **LoggerService**: Logging estruturado com níveis
- **AnalyticsService**: Event tracking e métricas
- **NavigationService**: Navegação centralizada
- **EventBus**: Comunicação desacoplada

### Infrastructure
- **ModuleRepository**: Abstração de dados de módulos
- **LocalModuleDatasource**: Cache local
- **CloudModuleDatasource**: Sincronização Supabase

### Features
- **Gamification**: Conquistas, medalhas, streaks
- **Auth**: Autenticação e perfil
- **Modules**: Hábitos específicos (smoking, focus, etc.)

## 🚀 **Adicionando Nova Feature**

1. **Criar estrutura base**:
```bash
features/nova_feature/
├── domain/
│   ├── entities/
│   └── services/
├── data/
│   ├── repositories/
│   └── datasources/
└── presentation/
    ├── controllers/
    ├── widgets/
    └── screens/
```

2. **Implementar entidades** em `domain/entities/`
3. **Criar serviços** em `domain/services/`
4. **Implementar repository** em `data/repositories/`
5. **Criar UI** em `presentation/`
6. **Registrar no router** e providers

## 🧪 **Test Strategy**

- **Unit Tests**: Domain layer (entities, services)
- **Integration Tests**: Repositories e datasources
- **Widget Tests**: UI components
- **E2E Tests**: Fluxos críticos do usuário

## 📊 **Métricas e Monitoramento**

- **Logging**: Estruturado com context
- **Analytics**: Eventos de usuário e performance
- **Error Tracking**: Centralizado com stack traces
- **Performance**: Tempo de carregamento e memória

## 🔧 **Configuração**

### Feature Flags
- Controle de funcionalidades via `FeatureFlags`
- Deploy incremental
- A/B testing suporte

### Environment
- Development: Debug logging + mock data
- Production: Otimizado + analytics
- Staging: Testes de integração

## 📚 **Referências**

- [Flutter Architecture Guide](https://docs.flutter.dev/app-architecture)
- [Clean Architecture Principles](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture/)
- [Feature-First Pattern](https://dev.to/princetomarappdev/mastering-flutter-architecture-from-clean-to-feature-first-for-faster-scalable-development-4605)

---

**Status**: ✅ **Arquitetura Enterprise-Level Implementada** - Base sólida para crescimento sustentável.
