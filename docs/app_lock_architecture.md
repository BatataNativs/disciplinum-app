# App Lock Architecture Document

## Overview

The App Lock system in Disciplinum is a native Android implementation that monitors and blocks access to specific applications based on user-defined rules and module configurations. It uses Android's AccessibilityService for real-time app detection and a native LockActivity for displaying lock screens.

## Architecture Components

### 1. Native Android Layer

#### AccessibilityMonitorService
**Location**: `android/app/src/main/kotlin/com/disciplinum/app/AccessibilityMonitorService.kt`

**Purpose**: Monitors app usage changes in real-time using Android's AccessibilityService.

**Key Features**:
- Monitors `TYPE_WINDOW_STATE_CHANGED` events
- Instant event detection (notificationTimeout=0)
- Debounce mechanism (50ms) to prevent duplicate events
- Asynchronous event processing to avoid blocking the accessibility thread
- Integration with LockDecisionEngine for blocking decisions

**Configuration**: `android/app/src/main/res/xml/accessibility_service_config.xml`
```xml
<accessibility-service
    android:accessibilityEventTypes="typeWindowStateChanged"
    android:accessibilityFeedbackType="feedbackGeneric"
    android:accessibilityFlags="flagDefault|flagIncludeNotImportantViews|flagRetrieveInteractiveWindows|flagReportViewIds"
    android:canRetrieveWindowContent="true"
    android:notificationTimeout="0" />
```

#### LockDecisionEngine
**Location**: `android/app/src/main/kotlin/com/disciplinum/lock/LockDecisionEngine.kt`

**Purpose**: Decides whether an app should be blocked based on module configuration, time restrictions, and violation counts.

**Decision Logic**:
```kotlin
data class LockDecision(
    val shouldLock: Boolean,
    val moduleId: String,
    val reason: String
)

fun shouldLockApp(packageName: String): LockDecision?
```

**Factors Considered**:
- Module active state
- Time restrictions (if configured)
- Violation count thresholds
- Package name to module ID mapping
- User preferences

#### LockActivity
**Location**: `android/app/src/main/kotlin/com/disciplinum/lock/LockActivity.kt`

**Purpose**: Displays a native lock screen overlay when an app is blocked.

**Features**:
- FlutterActivity subclass for Flutter UI integration
- Receives package name, module ID, and module name via Intent
- Passes data to Flutter via `initial_route`
- Configured with appropriate flags for lock screen behavior

**Manifest Declaration**:
```xml
<activity
    android:name=".lock.LockActivity"
    android:theme="@style/Theme.AppCompat.NoActionBar"
    android:excludeFromRecents="true"
    android:taskAffinity=""
    android:launchMode="singleTask"
    android:showOnLockScreen="true"
    android:turnScreenOn="true" />
```

### 2. Flutter Integration Layer

#### AppLockMethodChannel
**Location**: `android/app/src/main/kotlin/com/disciplinum/channels/AppLockMethodChannel.kt`

**Purpose**: Provides MethodChannel for Flutter to configure the native App Lock system.

**Channel Name**: `com.disciplinum.app/app_lock`

**Methods**:
- `updateMonitoredApps`: Update list of monitored package names
- `updateActiveModules`: Update list of active module IDs
- `updateModuleConfig`: Update configuration for a specific module
- `updateViolationCount`: Update violation count for a module
- `isAccessibilityEnabled`: Check if accessibility service is enabled
- `openAccessibilitySettings`: Open system accessibility settings
- `hasOverlayPermission`: Check overlay permission
- `requestOverlayPermission`: Request overlay permission
- `closeBlockedApp`: Close a blocked app
- `bringToForeground`: Bring Disciplinum to foreground

#### EventChannel Integration
**Channel Name**: `com.disciplinum.app/accessibility`

**Purpose**: Sends events from native AccessibilityService to Flutter for gamification updates.

**Event Types**:
```dart
{
  "type": "app_blocked",
  "packageName": "com.instagram.android",
  "moduleId": "instagram",
  "reason": "Module active and time restricted"
}
```

```dart
{
  "type": "app_opened",
  "packageName": "com.whatsapp",
  "reason": "Not monitored"
}
```

### 3. Flutter Platform Services

#### AppLockPlatformService
**Location**: `lib/platform/app_lock/app_lock_platform_service.dart`

**Purpose**: Flutter-side wrapper for native App Lock MethodChannel.

**Methods**:
- `updateMonitoredApps(List<String> packageNames)`
- `updateActiveModules(List<String> moduleIds)`
- `updateModuleConfig(String moduleId, Map<String, dynamic> config)`
- `updateViolationCount(String moduleId, int count)`
- `isAccessibilityEnabled()`
- `openAccessibilitySettings()`
- `hasOverlayPermission()`
- `requestOverlayPermission()`
- `closeBlockedApp(String packageName)`
- `bringToForeground()`

#### InstalledAppService
**Location**: `lib/platform/app_lock/installed_app_service.dart`

**Purpose**: Manages installed apps information and icons.

**Features**:
- Caches app list for fast access
- LRU cache for app icons (max 200 entries)
- Async icon fetching with pending request deduplication
- System app filtering option

### 4. Flutter Application Layer

#### AppLockService
**Location**: `lib/features/app_lock/domain/services/app_lock_service.dart`

**Purpose**: Main Flutter service for App Lock functionality.

**Responsibilities**:
- Listens to accessibility events via EventChannel
- Processes `app_blocked` events for gamification updates
- Updates module gamification based on blocked apps
- Manages lock screen display (legacy, now mostly native)

**Event Processing**:
```dart
void _handleAccessibilityEvent(Map event) {
  final type = event['type'];
  if (type == 'app_blocked') {
    final moduleId = event['moduleId'];
    _handleAppBlockedForGamification(packageName, moduleId);
  }
}
```

## Data Flow

### App Blocking Flow

```
1. User opens monitored app
   ↓
2. AccessibilityMonitorService detects TYPE_WINDOW_STATE_CHANGED
   ↓
3. LockDecisionEngine evaluates if should block
   ↓
4. If should block:
   - Start LockActivity (native lock screen)
   - Send "app_blocked" event to Flutter
   ↓
5. Flutter receives event
   - Updates gamification (streaks, medals, etc.)
   - Logs the blocking event
```

### Configuration Flow

```
1. Flutter (AppLockPlatformService)
   ↓
2. MethodChannel (com.disciplinum.app/app_lock)
   ↓
3. AppLockMethodChannel (native)
   ↓
4. LockDecisionEngine (updates configuration)
```

### Event Flow

```
1. AccessibilityMonitorService (native)
   ↓
2. EventChannel (com.disciplinum.app/accessibility)
   ↓
3. AppLockService (Flutter)
   ↓
4. Gamification Notifiers
   ↓
5. UI Update
```

## Module Integration

Each habit module can integrate with App Lock by:

1. **Adding Package Names**: Configure which apps to monitor
   ```dart
   await AppLockPlatformService.updateMonitoredApps([
     'com.instagram.android',
     'com.facebook.katana',
   ]);
   ```

2. **Activating Module**: Mark module as active for blocking
   ```dart
   await AppLockPlatformService.updateActiveModules([
     'instagram',
     'facebook',
   ]);
   ```

3. **Setting Configuration**: Configure time restrictions, violation limits
   ```dart
   await AppLockPlatformService.updateModuleConfig('instagram', {
     'timeRestriction': {'start': '09:00', 'end': '18:00'},
     'maxViolations': 3,
   });
   ```

4. **Handling Events**: Listen to blocked app events for gamification
   ```dart
   // Handled automatically by AppLockService
   ```

## Permissions Required

### AndroidManifest.xml

```xml
<!-- Accessibility Service -->
<uses-permission android:name="android.permission.BIND_ACCESSIBILITY_SERVICE" />

<!-- System Alert Window (for LockActivity overlay) -->
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />

<!-- Foreground Service (for background monitoring) -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />

<!-- Package Usage Stats (alternative monitoring method) -->
<uses-permission android:name="android.permission.PACKAGE_USAGE_STATS" />

<!-- Query All Packages (for app listing) -->
<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" />
```

## Performance Optimizations

### 1. Instant Event Detection
- `notificationTimeout="0"` in accessibility config
- No artificial delay in event processing

### 2. Debounce Mechanism
- 50ms debounce to prevent duplicate events
- Prevents rapid-fire events for same app

### 3. Asynchronous Processing
- Event processing on main thread via Handler
- Does not block accessibility service thread

### 4. Icon Caching
- LRU cache for app icons (max 200 entries)
- Async fetching with request deduplication
- Reduces redundant native calls

## Error Handling

### Native Layer
- Try-catch blocks around all native operations
- Graceful degradation on errors
- Logging via Android Log

### Flutter Layer
- MethodChannel error handling
- EventChannel error handling
- Fallback to non-blocking mode on errors

## Security Considerations

### 1. Accessibility Service
- Requires explicit user consent
- Must be enabled in system settings
- Subject to Google Play policies

### 2. Overlay Permission
- Required for LockActivity display
- Must be granted by user
- Can be revoked at any time

### 3. Foreground Service
- Requires notification
- Subject to battery optimization
- Can be killed by system

## Testing Strategy

### Unit Tests
- Test LockDecisionEngine logic
- Test AppLockPlatformService methods
- Test InstalledAppService caching

### Integration Tests
- Test AccessibilityService event flow
- Test MethodChannel communication
- Test EventChannel event delivery

### Manual Tests
- Test on real Android devices
- Test with various Android versions
- Test with different accessibility settings

## Future Enhancements

### Planned Features
1. **UsageStats Fallback**: Use UsageStatsManager as alternative to AccessibilityService
2. **Smart Blocking**: AI-based blocking decisions
3. **Grace Periods**: Allow temporary app access
4. **Custom Lock Screens**: User-customizable lock screens
5. **Statistics**: Detailed blocking statistics

### Technical Debt
1. **iOS Support**: Currently Android-only
2. **Testing**: Limited automated test coverage
3. **Documentation**: Need more detailed API docs

## Troubleshooting

### Common Issues

#### AccessibilityService Not Working
- Check if service is enabled in system settings
- Verify notificationTimeout is 0
- Check AndroidManifest.xml service declaration
- Review accessibility service config XML

#### LockActivity Not Showing
- Verify overlay permission is granted
- Check LockActivity manifest flags
- Verify LockDecisionEngine returns shouldLock=true
- Check for crashes in native logs

#### Events Not Reaching Flutter
- Verify EventChannel is set up in MainActivity
- Check eventSink is not null
- Verify event format matches expected structure
- Check for errors in Flutter logs

## Conclusion

The App Lock architecture leverages native Android capabilities for real-time app monitoring and blocking, with Flutter providing the UI and gamification layer. The separation of concerns between native decision-making and Flutter gamification allows for a flexible, maintainable system that can be extended with new modules and features.

---

**Document Version**: 1.0  
**Last Updated**: May 2026  
**Maintained By**: Disciplinum Development Team
