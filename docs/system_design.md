# Disciplinum - System Design Document

## Overview

Disciplinum is a Flutter-based self-discipline application that helps users build healthy habits through gamification, app blocking, and behavioral tracking. The app uses a modular architecture with Clean Architecture principles, Riverpod for state management, and Isar for local persistence.

## Architecture Overview

### High-Level Architecture

```text
┌─────────────────────────────────────────────────────────────┐
│                      Presentation Layer                      │
│  (Flutter UI - Screens, Widgets, Controllers, Notifiers)    │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                      Application Layer                       │
│  (Business Logic - Use Cases, Controllers, State Notifiers)  │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                         Domain Layer                         │
│  (Entities, Value Objects, Domain Services, Repositories)   │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                       Infrastructure Layer                     │
│  (Data Access, External Services, Platform Integration)       │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                       Platform Layer                         │
│  (Native Android/iOS Services, Device APIs, Background)      │
└─────────────────────────────────────────────────────────────┘
```

## Project Structure

```text
lib/
├── app/                          # Application-level setup
│   ├── bootstrap.dart             # Service initialization
│   ├── router/                   # Navigation configuration
│   ├── auth_navigation_listener.dart
│   └── error_recovery_screen.dart
├── core/                         # Core shared functionality
│   ├── di/                       # Dependency Injection (Riverpod providers)
│   ├── database/                 # ObjectBox database setup
│   ├── events/                   # EventBus for typed events
│   ├── gamification/             # Global gamification system
│   ├── logging/                  # LoggerService
│   ├── network/                  # Network health, DNS resolver
│   ├── storage/                  # Storage abstraction
│   └── background/               # Background services
├── features/                     # Feature modules
│   ├── app_lock/                 # App Lock functionality
│   ├── modules/                  # Habit modules (smoking, reading, etc.)
│   │   ├── smoking/
│   │   ├── reading/
│   │   ├── money_saving/
│   │   ├── binge_eating/
│   │   ├── adult_content/
│   │   ├── digital_detox/
│   │   ├── diet/
│   │   ├── focus/
│   │   ├── procrastination/
│   │   └── spending/
│   ├── home/                     # Home screen
│   ├── profile/                  # User profile
│   └── onboarding/               # Onboarding flow
├── infrastructure/               # External integrations
│   ├── ads/                      # AdMob integration
│   ├── cloud/                     # Supabase sync
│   ├── iap/                       # In-app purchases
│   ├── monitoring/               # App monitoring
│   ├── notifications/            # Push notifications
│   ├── permissions/              # Device permissions
│   ├── repositories/             # Data repositories
│   ├── review/                    # App review prompts
│   └── user_privacy/             # Privacy/LGPD compliance
├── platform/                     # Native platform services
│   ├── app_lock/                 # Native App Lock services
│   ├── background/               # Background service controllers
│   └── device/                   # Device info and permissions
├── shared/                       # Shared models and utilities
│   ├── models/                   # Shared data models
│   └── repositories/             # Shared repositories
└── main.dart                     # Application entry point
```

## Technology Stack

### Core Technologies

- **Framework**: Flutter 3.x
- **Language**: Dart 3.x
- **State Management**: Riverpod (flutter_riverpod)
- **Local Database**: Isar 3.x (Object Database)
- **Backend**: Supabase (PostgreSQL, Auth, Storage)
- **Analytics**: Firebase Analytics + Crashlytics
- **Ads**: Google Mobile Ads (AdMob)

### Key Libraries

- **State Management**: flutter_riverpod
- **Persistence**: isar, isar_flutter_libs
- **Networking**: dio, supabase_flutter
- **Local Notifications**: flutter_local_notifications
- **Authentication**: supabase_auth
- **In-App Purchases**: in_app_purchase
- **Device Info**: device_info_plus, platform_device_info
- **Permissions**: permission_handler
- **Background Services**: flutter_background_service

## Module Architecture

Each habit module follows a consistent structure:

```text
modules/{module_name}/
├── data/                        # Data layer (if needed)
├── domain/                      # Domain layer
│   ├── entities/               # Domain entities
│   └── services/               # Domain services
├── gamification/               # Gamification system
│   ├── data/                   # Gamification data
│   ├── domain/                 # Gamification entities
│   │   ├── entities/
│   │   └── services/
│   └── presentation/           # Gamification UI
│       └── widgets/
├── presentation/               # Presentation layer
│   ├── screens/                # UI screens
│   ├── widgets/                # Reusable widgets
│   ├── controllers/            # View controllers
│   └── notifiers/              # Riverpod StateNotifiers
└── discipline/                 # Discipline-specific logic
```

## Data Flow

### 1. User Action Flow

```text
User Action → UI Widget → Controller/Notifier → Domain Service → Repository → Isar/Supabase
```

### 2. App Lock Flow

```text
AccessibilityService (Native) → LockDecisionEngine → LockActivity (Native) → Flutter EventChannel → Gamification Update
```

### 3. Gamification Flow

```text
User Action → Module Notifier → Gamification Notifier → Repository → Isar → Achievement Check → UI Update
```

## State Management

### Riverpod Architecture

- **Providers**: Defined in `core/di/providers.dart`
- **State Notifiers**: Located in each module's `presentation/notifiers/`
- **Global State**: Managed via Riverpod's ProviderScope
- **Local State**: Managed by individual StateNotifiers

### Key Providers

- `authServiceProvider`: Authentication state
- `themeControllerProvider`: Theme management
- `seenOnboardingProvider`: Onboarding completion
- Module-specific providers (e.g., `readingGamificationNotifierProvider`)

## Persistence Strategy

### Local Storage (Isar)

- **Primary Database**: Isar Object Database
- **Collections**: Each module has its own @collection entities
- **Queries**: Optimized with indexes for fast lookups
- **Sync**: Background sync with Supabase when online

### Cloud Storage (Supabase)

- **Authentication**: Supabase Auth
- **Database**: PostgreSQL via Supabase
- **Storage**: User data backup and sync
- **Real-time**: Not currently used (planned)

### Caching Strategy

- **In-Memory**: Riverpod providers cache state
- **Disk**: Isar for persistent data
- **Network**: Dio with caching headers

## Native Platform Integration

### Android Native Components

- **AccessibilityService**: Monitors app usage for App Lock
- **LockActivity**: Native lock screen overlay
- **LockDecisionEngine**: Native decision logic for blocking
- **ForegroundService**: Background monitoring
- **MethodChannel/EventChannel**: Flutter-Android communication

### Platform Services (lib/platform/)

- **app_lock/**: Native App Lock services
- **background/**: Background service controllers
- **device/**: Device info and permission services

## Security & Privacy

### Data Protection

- **Local Encryption**: Isar data encrypted at rest (planned)
- **Secure Storage**: Sensitive data in encrypted storage
- **Privacy Compliance**: LGPD-compliant consent management

### Authentication

- **Supabase Auth**: JWT-based authentication
- **Session Management**: Secure token storage
- **Offline Support**: Local auth fallback

## Performance Optimization

### Startup Optimization

- **Lazy Loading**: Services initialized on-demand
- **Async Initialization**: Non-blocking service startup
- **Error Recovery**: Graceful degradation on failures

### Runtime Optimization

- **Selective Rebuilds**: Riverpod's ref.watch() for granular updates
- **Debouncing**: Event debouncing for rapid actions
- **Memory Management**: Proper cleanup in dispose()

### Background Optimization

- **Throttling**: Adaptive polling intervals
- **Battery Optimization**: Respect device battery saver
- **Resource Management**: Minimal background resource usage

## Error Handling

### Global Error Handling

- **Flutter Errors**: Caught via FlutterError.onError
- **Platform Errors**: Caught via Isolate error listener
- **Logging**: All errors logged via LoggerService
- **Recovery**: ErrorRecoveryScreen for critical failures

### Error Recovery Strategy

1. **Non-Critical Errors**: Log and continue
2. **Critical Errors**: Show ErrorRecoveryScreen
3. **Network Errors**: Graceful degradation to offline mode
4. **Storage Errors**: Fallback to in-memory state

## Testing Strategy

### Unit Tests

- **Domain Logic**: Test business rules in isolation
- **Services**: Test service methods with mocks
- **Notifiers**: Test state changes

### Widget Tests

- **UI Components**: Test widget rendering
- **User Interactions**: Test user flows
- **State Changes**: Verify UI updates

### Integration Tests

- **End-to-End**: Test complete user flows
- **API Integration**: Test Supabase integration
- **Platform Integration**: Test native services

## Deployment

### Build Configuration

- **Debug**: Development builds with logging
- **Profile**: Performance testing builds
- **Release**: Production builds optimized

### CI/CD

- **Automated Builds**: GitHub Actions (planned)
- **Testing**: Automated test runs
- **Deployment**: Automated Play Store deployment (planned)

## Monitoring

### Crash Reporting

- **Firebase Crashlytics**: Crash reporting
- **LoggerService**: Structured logging
- **Error Tracking**: Error context and stack traces

### Analytics

- **Firebase Analytics**: User behavior tracking
- **Custom Events**: Module-specific events
- **Privacy**: Opt-out available

## Future Enhancements

### Planned Features

1. **Real-time Sync**: WebSocket integration with Supabase
2. **Machine Learning**: Habit prediction and recommendations
3. **Social Features**: Community challenges and leaderboards
4. **Advanced Analytics**: Detailed usage insights
5. **Cross-Platform**: iOS support

### Technical Debt

1. **Test Coverage**: Increase to 80%+
2. **Documentation**: Complete API documentation
3. **Performance**: Optimize cold start time
4. **Accessibility**: Improve screen reader support

## Conclusion

Disciplinum uses a modern, scalable architecture with Clean Architecture principles, Riverpod for state management, and Isar for local persistence. The modular design allows for easy addition of new habit modules while maintaining code quality and testability.

---

**Document Version**: 1.0  
**Last Updated**: May 2026  
**Maintained By**: Disciplinum Development Team
