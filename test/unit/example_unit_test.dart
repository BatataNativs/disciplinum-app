import 'package:flutter_test/flutter_test.dart';

/// Exemplo de teste unitário genérico
/// 
/// Este é um template para testes unitários. Copie e adapte conforme necessário.
/// Substitua a classe de exemplo pela classe real que deseja testar.
void main() {
  group('Exemplo de Teste Unitário', () {
    test('deve calcular streak corretamente para dias consecutivos', () {
      // Arrange
      final lastActivity = DateTime.now().subtract(const Duration(days: 1));
      final today = DateTime.now();
      
      // Act
      final difference = today.difference(lastActivity).inDays;
      
      // Assert
      expect(difference, 1);
    });

    test('deve resetar streak para gap maior que 1 dia', () {
      // Arrange
      final lastActivity = DateTime.now().subtract(const Duration(days: 2));
      final today = DateTime.now();
      
      // Act
      final difference = today.difference(lastActivity).inDays;
      
      // Assert
      expect(difference, 2);
      expect(difference > 1, true);
    });

    test('deve desbloquear conquista quando streak atinge meta', () {
      // Arrange
      final currentStreak = 7;
      final requiredStreak = 7;
      final unlockedAchievements = <String>[];
      
      // Act
      if (currentStreak >= requiredStreak && !unlockedAchievements.contains('bronze')) {
        unlockedAchievements.add('bronze');
      }
      
      // Assert
      expect(unlockedAchievements, contains('bronze'));
      expect(unlockedAchievements.length, 1);
    });

    test('deve preservar conquista madeira ao resetar progresso', () {
      // Arrange
      final achievements = ['madeira', 'bronze', 'silver'];
      
      // Act
      final preserved = achievements.where((a) => a == 'madeira').toList();
      
      // Assert
      expect(preserved, contains('madeira'));
      expect(preserved.length, 1);
    });
  });
}
