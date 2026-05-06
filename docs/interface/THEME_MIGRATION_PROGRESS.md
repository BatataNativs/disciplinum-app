# Progresso da Migração de Temas

## Status Atual

### ✅ Concluído

1. **Estrutura Base dos Temas**
   - `lib/core/theme/app_theme.dart` - Enum com 4 temas
   - `lib/core/theme/theme_controller_new.dart` - Controller sem isDarkMode
   - `lib/core/theme/app_themes.dart` - Tema Dark completo (cores extraídas)

2. **Providers Atualizados**
   - `lib/core/di/providers.dart` - StateNotifierProvider para ThemeController
   - `lib/main.dart` - Usa themeController.themeData dinamicamente

3. **Widgets Compartilhados Migrados** ✅
   - `lib/shared/widgets/cards/niche_info_card.dart` - ✅ SEM parâmetro isDark
   - `lib/shared/widgets/buttons/modern_start_button.dart` - ✅ SEM parâmetro isDark
   - `lib/shared/widgets/lists/list_action_tile.dart` - ✅ SEM parâmetro isDark

4. **Telas Migradas**
   - `lib/features/profile/presentation/widgets/theme_options_dialog.dart` - ✅
   - `lib/features/settings/presentation/screens/settings_screen.dart` - ✅
   - `lib/features/modules/diet/presentation/screens/diet_settings_screen.dart` - ✅ (4 ocorrências)
   - `lib/features/modules/adult_content/presentation/screens/avoid_adult_content_screen.dart` - ✅ (4 ocorrências)
   - `lib/features/modules/reading/presentation/screens/reading_screen.dart` - ✅ (3 ocorrências)
   - `lib/features/modules/diet/presentation/screens/diet_notifications_screen.dart` - ✅ (1 ocorrência)
   - `lib/features/modules/focus/presentation/screens/focus_screen.dart` - ✅ (36 ocorrências)
   - `lib/features/modules/binge_eating/presentation/screens/binge_eating_screen.dart` - ✅ (8 ocorrências)
   - `lib/features/modules/binge_eating/presentation/screens/binge_eating_notifications_screen.dart` - ✅ (12+ ocorrências)

5. **Widgets Compartilhados Migrados**
   - `lib/shared/widgets/common/how_it_works_section.dart` - ✅ (1 ocorrência)

6. **Widgets de Módulos Migrados**
   - `lib/features/modules/binge_eating/presentation/widgets/binge_eating_actions_widget.dart` - ✅ (6 ocorrências)
   - `lib/features/modules/binge_eating/presentation/widgets/binge_eating_tab_content.dart` - ✅ (10+ ocorrências)
   - `lib/features/modules/binge_eating/presentation/widgets/binge_eating_segmented_control.dart` - ✅ (2 ocorrências)
   - `lib/features/modules/binge_eating/presentation/widgets/binge_eating_header_widget.dart` - ✅ (2 ocorrências)

### 🔧 Em Andamento / Quebrado

Arquivos que ainda precisam ser migrados (contêm `isDark`):

```
lib/features/modules/money_saving/presentation/widgets/money_saving_tab_content.dart (3 ocorrências)
lib/features/modules/money_saving/presentation/widgets/money_saving_actions_widget.dart (5 ocorrências)
lib/features/modules/money_saving/presentation/screens/money_saving_challenge_screen.dart (1 ocorrência)
lib/features/modules/smoking/presentation/screens/stop_smoking_screen_riverpod.dart (1 ocorrência)
lib/features/modules/smoking/presentation/widgets/stop_smoking_tab_content.dart (5 ocorrências)
lib/features/modules/spending/presentation/widgets/spending_tab_content.dart (5 ocorrências)
lib/features/onboarding/presentation/screens/onboarding_screen.dart (5+ ocorrências - MUITO EXTENSO)
lib/features/modules/procrastination/presentation/widgets/task_creation_dialog.dart (4 ocorrências)
```

### 📋 Próximos Passos Necessários

#### 1. Migrar Widgets Compartilhados (que recebem isDark)

- [ ] `ModernStartButton` - recebe isDark em ~20 lugares
- [ ] `ListActionTile` (shared) - recebe isDark em ~10 lugares
- [ ] `ListActionTile` (money_saving) - duplicado?
- [ ] Verificar outros widgets em `lib/shared/widgets/`

#### 2. Migrar Telas Principais (com mais ocorrências de isDark)

**Prioridade Alta (5+ ocorrências):**
- [ ] `lib/features/modules/diet/presentation/screens/diet_settings_screen.dart`
- [ ] `lib/features/onboarding/presentation/screens/onboarding_screen.dart`

**Prioridade Média (4 ocorrências):**
- [ ] `lib/features/modules/adult_content/presentation/screens/avoid_adult_content_screen.dart`
- [ ] `lib/features/modules/focus/presentation/screens/focus_screen.dart`
- [ ] `lib/features/modules/procrastination/presentation/widgets/task_creation_dialog.dart`

**Prioridade Normal (3 ocorrências):**
- [ ] `lib/features/modules/money_saving/presentation/screens/money_saving_challenge_screen.dart`
- [ ] `lib/features/modules/reading/presentation/screens/reading_screen.dart`
- [ ] `lib/features/modules/smoking/presentation/screens/stop_smoking_screen.dart`
- [ ] `lib/features/settings/presentation/screens/how_it_works_screen.dart`

**Prioridade Baixa (1-2 ocorrências):**
- [ ] ~60 arquivos restantes

### 🎯 Estimativa de Tempo

| Tarefa | Arquivos | Tempo Estimado |
|--------|----------|----------------|
| Migrar widgets compartilhados | ~5 | 1-2 horas |
| Migrar telas principais (5+ occ) | ~5 | 2-3 horas |
| Migrar telas médias (3-4 occ) | ~15 | 3-4 horas |
| Migrar telas pequenas (1-2 occ) | ~60 | 4-6 horas |
| Testes e ajustes | - | 1-2 horas |
| **TOTAL** | **~85 arquivos** | **11-17 horas** |

### ⚠️ Decisão Necessária

Como o trabalho é extenso (11-17 horas), preciso confirmar:

**Opção A: Migração Completa**
- Eu continuo migrando TUDO, arquivo por arquivo
- Tempo estimado: várias sessões
- Resultado: Código limpo, sem isDark em lugar nenhum

**Opção B: Migração Parcial (Recomendada para não parar o projeto)**
- Migro apenas os widgets compartilhados principais primeiro
- Depois migro as 5-10 telas mais importantes
- O restante migra gradualmente quando você for trabalhar em cada tela
- Resultado: Projeto continua funcionando, migração incremental

**Qual abordagem você prefere?**
