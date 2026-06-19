# Guia de Migração: Sistema Binário → Múltiplos Temas

## Resumo da Implementação

A estrutura base para múltiplos temas foi criada. Agora é necessário refatorar as telas para usar o novo sistema.

## Arquivos Criados/Modificados

### 1. Novos Arquivos

- `lib/core/theme/app_theme.dart` - Enum com os temas disponíveis
- `lib/core/theme/theme_controller_new.dart` - Controller usando StateNotifier

### 2. Arquivos Modificados

- `lib/core/theme/app_themes.dart` - Adicionados `pinkTheme` e `halloweenTheme`
- `lib/core/di/providers.dart` - Provider atualizado para StateNotifier
- `lib/main.dart` - Usa `themeController.themeData` dinamicamente

## Como Migrar as Telas

### ANTES (Sistema Binário isDark)

```dart
@override
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  return Scaffold(
    backgroundColor: isDark ? Colors.black : Colors.white,
    body: Text(
      'Título',
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
      ),
    ),
  );
}
```

### DEPOIS (Sistema ThemeData)

**Opção 1: Usar Theme.of(context) diretamente (Recomendado)**

```dart
@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  
  return Scaffold(
    backgroundColor: theme.scaffoldBackgroundColor, // ← Automático
    body: Text(
      'Título',
      style: theme.textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurface, // ← Cores do tema atual
      ),
    ),
  );
}
```

**Opção 2: Usar Extension Helper (Ver abaixo)**

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: context.surfaceColor, // ← Via extension
    body: Text(
      'Título',
      style: TextStyle(color: context.onSurfaceColor),
    ),
  );
}
```

## Extension Helper (Opcional)

Crie em `lib/core/theme/theme_extensions.dart`:

```dart
import 'package:flutter/material.dart';

extension ThemeExtensions on BuildContext {
  // Cores de superfície
  Color get surfaceColor => Theme.of(this).colorScheme.surface;
  Color get onSurfaceColor => Theme.of(this).colorScheme.onSurface;
  
  // Cores primárias
  Color get primaryColor => Theme.of(this).colorScheme.primary;
  Color get onPrimaryColor => Theme.of(this).colorScheme.onPrimary;
  
  // Cores de fundo
  Color get scaffoldBgColor => Theme.of(this).scaffoldBackgroundColor;
  
  // Textos
  TextStyle? get bodyLarge => Theme.of(this).textTheme.bodyLarge;
  TextStyle? get bodyMedium => Theme.of(this).textTheme.bodyMedium;
  TextStyle? get titleLarge => Theme.of(this).textTheme.titleLarge;
}
```

## Mapeamento de Cores isDark → ThemeData

| Cores isDark | Propriedade ThemeData |
|--------------|----------------------|
| `isDark ? Colors.white : Colors.black87` | `colorScheme.onSurface` |
| `isDark ? Colors.white70 : Colors.black54` | `colorScheme.onSurface.withValues(0.7)` |
| `isDark ? Colors.white38 : Colors.black38` | `colorScheme.onSurface.withValues(0.38)` |
| `isDark ? Colors.black : Colors.white` | `colorScheme.surface` |
| `isDark ? Colors.grey[900] : Colors.grey[50]` | `colorScheme.surface` |
| Fundo escuro (0xFF0F0F0F, etc) | `theme.scaffoldBackgroundColor` |

## Exemplo Completo de Refatoração

### Arquivo: `lojinha_screen.dart` (exemplo parcial)

**ANTES:**
```dart
@override
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  return Scaffold(
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
            ? [const Color(0xFF0F0F0F), const Color(0xFF1A1A2E)]
            : [const Color(0xFFF5F7FA), const Color(0xFFE3EAF5)],
        ),
      ),
      child: Text(
        'Funcionalidades',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    ),
  );
}
```

**DEPOIS:**
```dart
@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  
  return Scaffold(
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // Usa cores do tema ou define cores específicas por tema
          colors: _getGradientColors(theme),
        ),
      ),
      child: Text(
        'Funcionalidades',
        style: theme.textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
    ),
  );
}

List<Color> _getGradientColors(ThemeData theme) {
  // Pode customizar por tema se necessário
  return [
    theme.scaffoldBackgroundColor,
    theme.colorScheme.surface,
  ];
}
```

## Próximos Passos

1. ✅ Estrutura base criada (4 temas: light, dark, pink, halloween)
2. 🔄 Refatorar telas principais (remover isDark checks)
3. 🔄 Atualizar `theme_options_dialog.dart` para usar novos temas
4. 🔄 Adicionar persistência de tema comprado (IAP)

## Notas Importantes

- O `ThemeController` mantém compatibilidade com `isDarkMode` getter
- O tema **Dark** preserva todas as cores atuais do `isDark`
- O tema **Light** preserva todas as cores atuais do tema padrão
- Temas **Pink** e **Halloween** são novos e podem ser ajustados
