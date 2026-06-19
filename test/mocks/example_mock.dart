import 'package:flutter_test/flutter_test.dart';

/// Exemplo de mock para testes
/// 
/// Este é um template para criar mocks. Copie e adapte conforme necessário.
/// Use mocks para isolar dependências externas em testes unitários.

/// Mock de Repository
class MockGamificationRepository {
  final Map<String, dynamic> _data = {};

  Future<Map<String, dynamic>?> getGamification(String userId) async {
    return _data[userId];
  }

  Future<void> saveGamification(String userId, Map<String, dynamic> data) async {
    _data[userId] = data;
  }

  Future<void> clear() async {
    _data.clear();
  }
}

/// Mock de Service
class MockNotificationService {
  List<String> scheduledNotifications = [];

  Future<void> scheduleNotification(int id, String title, String body) async {
    scheduledNotifications.add('$id:$title:$body');
  }

  Future<void> cancelNotification(int id) async {
    scheduledNotifications.removeWhere((n) => n.startsWith('$id:'));
  }

  void clear() {
    scheduledNotifications.clear();
  }
}

/// Mock de Platform Service
class MockPlatformService {
  bool accessibilityEnabled = true;
  bool overlayPermissionGranted = true;

  Future<bool> isAccessibilityEnabled() async {
    return accessibilityEnabled;
  }

  Future<bool> hasOverlayPermission() async {
    return overlayPermissionGranted;
  }

  Future<void> requestOverlayPermission() async {
    overlayPermissionGranted = true;
  }
}

/// Exemplo de uso de mock em teste
void main() {
  group('Mock Repository', () {
    test('deve salvar e recuperar dados', () async {
      // Arrange
      final mock = MockGamificationRepository();
      const userId = 'test_user';
      final data = {'streak': 5};

      // Act
      await mock.saveGamification(userId, data);
      final retrieved = await mock.getGamification(userId);

      // Assert
      expect(retrieved, equals(data));
    });

    test('deve retornar null para usuário inexistente', () async {
      // Arrange
      final mock = MockGamificationRepository();

      // Act
      final retrieved = await mock.getGamification('nonexistent');

      // Assert
      expect(retrieved, isNull);
    });
  });

  group('Mock Notification Service', () {
    test('deve agendar notificação', () async {
      // Arrange
      final mock = MockNotificationService();

      // Act
      await mock.scheduleNotification(1, 'Test', 'Body');

      // Assert
      expect(mock.scheduledNotifications.length, 1);
      expect(mock.scheduledNotifications.first, '1:Test:Body');
    });

    test('deve cancelar notificação', () async {
      // Arrange
      final mock = MockNotificationService();
      await mock.scheduleNotification(1, 'Test', 'Body');

      // Act
      await mock.cancelNotification(1);

      // Assert
      expect(mock.scheduledNotifications, isEmpty);
    });
  });
}
