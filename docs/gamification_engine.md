# Gamification Engine Architecture Document

## Overview

The Gamification Engine in Disciplinum is a modular system that tracks user progress, awards achievements, and provides motivational feedback across different habit modules. Each module has its own independent gamification system following a consistent pattern, with a global system for cross-module achievements.

## Architecture Philosophy

### Plugin-Based Design

Each habit module (Reading, Money Saving, Smoking, etc.) operates as an independent plugin with its own:
- Gamification entity (Isar @collection)
- Repository for data access
- StateNotifier for state management
- Achievement system
- Streak tracking

This design ensures:
- **Zero coupling** between modules
- **Independent persistence** per module
- **Flexible activation/deactivation**
- **Easy addition of new modules**

## Core Components

### 1. Module Gamification Entity

Each module has its own gamification entity stored in Isar:

#### Example: ReadingGamificationEntity

```dart
@collection
class ReadingGamificationEntity {
  @Id()
  int id = 1; // Fixed ID for singleton pattern

  @Index()
  String userId;

  // Streak tracking
  int currentStreak;
  int longestStreakDays;

  // Achievement tracking
  List<String> unlockedAchievements;

  // Statistics
  int totalBooksRead;
  int totalPagesRead;
  int totalReadingDays;

  // Timestamps
  DateTime lastActivityDate;
  DateTime createdAt;
  DateTime updatedAt;
}
```

### 2. Gamification Repository

Each module has a repository for data access:

```dart
class ReadingGamificationRepository {
  final Isar _isar;

  Future<ReadingGamificationEntity?> getGamification(String userId) async {
    return await _isar.readingGamificationEntitys
        .where()
        .userIdEqualTo(userId)
        .findFirst();
  }

  Future<void> saveGamification(ReadingGamificationEntity entity) async {
    await _isar.writeTxn(() async {
      await _isar.readingGamificationEntitys.put(entity);
    });
  }

  Future<void> incrementStreak(String userId) async {
    // Implementation
  }

  Future<void> unlockAchievement(String userId, String achievementId) async {
    // Implementation
  }
}
```

### 3. Gamification Notifier (StateNotifier)

Each module uses Riverpod StateNotifier for state management:

```dart
class ReadingGamificationNotifier extends StateNotifier<ReadingGamificationState> {
  final ReadingGamificationRepository _repository;

  ReadingGamificationNotifier(this._repository)
      : super(ReadingGamificationState.initial());

  Future<void> loadGamification(String userId) async {
    state = state.copyWith(isLoading: true);
    try {
      final entity = await _repository.getGamification(userId);
      if (entity != null) {
        state = state.fromEntity(entity);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> recordActivity(String userId) async {
    // Update streak, check achievements, etc.
  }

  Future<void> resetProgress(String userId) async {
    // Reset gamification while preserving certain data
  }
}
```

### 4. State Management

Each module has its own state class:

```dart
class ReadingGamificationState {
  final bool isLoading;
  final String? error;
  final int currentStreak;
  final int longestStreakDays;
  final List<String> unlockedAchievements;
  final int totalBooksRead;
  final int totalPagesRead;
  final int totalReadingDays;

  // ... methods for copying, fromEntity, etc.
}
```

## Achievement System

### Achievement Types

#### 1. Streak Achievements
Awarded for consecutive days of activity:
- **Madeira**: 3 days streak (preserved on reset)
- **Bronze**: 7 days streak
- **Silver**: 14 days streak
- **Gold**: 30 days streak
- **Platinum**: 60 days streak
- **Diamond**: 90 days streak

#### 2. Milestone Achievements
Awarded for reaching specific goals:
- **First Step**: Complete first activity
- **Century**: 100 activities completed
- **Millionaire**: 1000 activities completed

#### 3. Special Achievements
Module-specific achievements:
- **Reading**: "Bookworm" (10 books read)
- **Money Saving**: "Saver" (R$1000 saved)
- **Smoking**: "Smoke-Free" (30 days without smoking)

### Achievement Unlocking Logic

```dart
void _checkAchievements(String userId) {
  final currentStreak = state.currentStreak;
  final achievements = List<String>.from(state.unlockedAchievements);

  // Check streak achievements
  if (currentStreak >= 3 && !achievements.contains('madeira')) {
    _unlockAchievement(userId, 'madeira');
  }
  if (currentStreak >= 7 && !achievements.contains('bronze')) {
    _unlockAchievement(userId, 'bronze');
  }
  // ... more checks
}

Future<void> _unlockAchievement(String userId, String achievementId) async {
  final updatedAchievements = [...state.unlockedAchievements, achievementId];
  state = state.copyWith(unlockedAchievements: updatedAchievements);
  
  await _repository.unlockAchievement(userId, achievementId);
  
  // Notify global achievement system
  EventBus.publish(AchievementUnlockedEvent(
    moduleId: 'reading',
    achievementId: achievementId,
  ));
}
```

## Streak Tracking

### Streak Calculation

```dart
int calculateStreak(DateTime lastActivity, DateTime today) {
  if (lastActivity == null) return 0;
  
  final difference = today.difference(lastActivity).inDays;
  
  if (difference == 0) {
    // Activity today, streak continues
    return currentStreak;
  } else if (difference == 1) {
    // Activity yesterday, increment streak
    return currentStreak + 1;
  } else {
    // Gap of 2+ days, streak reset
    return 0;
  }
}
```

### Streak Preservation

When resetting progress, certain achievements (like "Madeira") are preserved to encourage users to try again:

```dart
Future<void> resetProgress(String userId) async {
  final preservedAchievements = state.unlockedAchievements
      .where((a) => a == 'madeira')
      .toList();
  
  state = ReadingGamificationState.initial()
      .copyWith(unlockedAchievements: preservedAchievements);
  
  await _repository.saveGamification(state.toEntity(userId));
}
```

## Global Achievement System

### EventBus Integration

The global EventBus handles cross-module achievement events:

```dart
// Achievement event
class AchievementUnlockedEvent {
  final String moduleId;
  final String achievementId;
  final DateTime unlockedAt;
}

// Publishing event
EventBus.publish(AchievementUnlockedEvent(
  moduleId: 'reading',
  achievementId: 'bronze',
  unlockedAt: DateTime.now(),
));

// Listening to events
EventBus.on<AchievementUnlockedEvent>((event) {
  _showAchievementNotification(event);
  _updateGlobalStats(event);
});
```

### GlobalAchievementListener Widget

A global widget listens to achievement events and shows notifications:

```dart
class GlobalAchievementListener extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EventBusListener<AchievementUnlockedEvent>(
      onEvent: (event) {
        _showAchievementDialog(context, event);
      },
      child: widget.child,
    );
  }
}
```

## Module-Specific Gamification

### Reading Module

**Entity**: `ReadingGamificationEntity`
**Metrics**:
- Books read
- Pages read
- Reading days
- Current streak
- Longest streak

**Achievements**:
- "Bookworm" (10 books)
- "Page Turner" (1000 pages)
- "Daily Reader" (7-day streak)

### Money Saving Module

**Entity**: `MoneySavingModuleState`
**Metrics**:
- Total saved
- Challenges completed
- Current streak
- Longest streak

**Achievements**:
- "Saver" (R$100 saved)
- "Thousandaire" (R$1000 saved)
- "Challenge Master" (5 challenges)

### Smoking Module

**Entity**: `SmokingGamificationEntity`
**Metrics**:
- Days smoke-free
- Cigarettes avoided
- Money saved
- Current streak

**Achievements**:
- "Smoke-Free" (7 days)
- "Quitter" (30 days)
- "Freedom" (90 days)

### Digital Detox Module

**Entity**: `DigitalDetoxGamificationEntity`
**Metrics**:
- Apps blocked
- Time saved
- Current streak
- Longest streak

**Achievements**:
- "Digital Minimalist" (10 apps blocked)
- "Time Master" (1 hour saved)
- "Focus Champion" (7-day streak)

## Data Persistence

### Isar Database

Each module's gamification data is stored in its own Isar collection:

```dart
// Reading
@collection
class ReadingGamificationEntity { ... }

// Money Saving
@collection
class MoneySavingModuleState { ... }

// Smoking
@collection
class SmokingGamificationEntity { ... }
```

### Cloud Sync (Supabase)

Gamification data is synced with Supabase for backup and cross-device sync:

```dart
class GamificationSyncService {
  Future<void> syncToCloud(String userId) async {
    final localData = await _repository.getGamification(userId);
    await supabase.from('gamification').upsert({
      'user_id': userId,
      'module_id': 'reading',
      'data': jsonEncode(localData.toJson()),
    });
  }

  Future<void> syncFromCloud(String userId) async {
    final response = await supabase
        .from('gamification')
        .select()
        .eq('user_id', userId)
        .eq('module_id', 'reading')
        .single();
    
    if (response != null) {
      final entity = ReadingGamificationEntity.fromJson(response['data']);
      await _repository.saveGamification(entity);
    }
  }
}
```

## Integration with App Lock

When an app is blocked by the native App Lock system, it triggers gamification updates:

```dart
// AppLockService listens to accessibility events
void _handleAccessibilityEvent(Map event) {
  if (event['type'] == 'app_blocked') {
    final moduleId = event['moduleId'];
    _handleAppBlockedForGamification(moduleId);
  }
}

Future<void> _handleAppBlockedForGamification(String moduleId) async {
  switch (moduleId) {
    case 'instagram':
    case 'facebook':
      await _updateDigitalDetoxGamification();
      break;
    // ... other modules
  }
}
```

## Performance Optimization

### 1. Lazy Loading

Gamification data is loaded on-demand when a module is activated:

```dart
Future<void> activateModule(String userId) async {
  await loadGamification(userId);
  state = state.copyWith(isActive: true);
}
```

### 2. Selective Updates

Only relevant state is updated to minimize rebuilds:

```dart
// Bad - updates entire state
state = state.copyWith(currentStreak: newStreak);

// Good - uses Riverpod's select
final streak = ref.watch(
  readingGamificationStateProvider.select((s) => s.currentStreak)
);
```

### 3. Debounced Writes

Gamification updates are debounced to reduce database writes:

```dart
Timer? _debounceTimer;

void _scheduleSave() {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(Duration(seconds: 2), () {
    _repository.saveGamification(state.toEntity(userId));
  });
}
```

## Testing Strategy

### Unit Tests

Test individual components in isolation:

```dart
test('calculateStreak increments for consecutive days', () {
  final streak = calculateStreak(
    DateTime.now().subtract(Duration(days: 1)),
    DateTime.now(),
  );
  expect(streak, 1);
});

test('calculateStreak resets for gap > 1 day', () {
  final streak = calculateStreak(
    DateTime.now().subtract(Duration(days: 2)),
    DateTime.now(),
  );
  expect(streak, 0);
});
```

### Integration Tests

Test the complete gamification flow:

```dart
test('complete gamification flow', () async {
  await notifier.recordActivity(userId);
  expect(state.currentStreak, 1);
  expect(state.unlockedAchievements, contains('madeira'));
  
  await notifier.recordActivity(userId);
  expect(state.currentStreak, 2);
});
```

## Future Enhancements

### Planned Features

1. **Cross-Module Achievements**: Achievements that require progress in multiple modules
2. **Leaderboards**: Compare progress with other users
3. **Achievement Sharing**: Share achievements on social media
4. **Dynamic Difficulty**: Adjust achievement requirements based on user behavior
5. **Achievement Categories**: Group achievements by type (streaks, milestones, special)

### Technical Debt

1. **Test Coverage**: Increase to 80%+
2. **Achievement Localization**: Support multiple languages
3. **Achievement Animations**: Add visual effects for unlocking
4. **Achievement History**: Track when achievements were unlocked

## Conclusion

The Gamification Engine in Disciplinum uses a modular, plugin-based architecture that allows each habit module to have its own independent gamification system while maintaining consistency across the application. The use of Isar for local persistence, Riverpod for state management, and EventBus for cross-module communication provides a flexible, scalable system that can be extended with new modules and achievements.

---

**Document Version**: 1.0  
**Last Updated**: May 2026  
**Maintained By**: Disciplinum Development Team
