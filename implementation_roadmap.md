# Disciplinum — Implementation Roadmap (Performance)

Este documento traduz os achados do `performance_audit_report.md` em um plano de implantação **priorizado**, com matriz Impacto x Esforço, fases e critérios de validação.

> Importante: este roadmap **não aplica mudanças**. Ele propõe intervenções e como validar.

---

## Matriz Impacto x Esforço (priorização)

### Quadrante A — Alto impacto / Baixo esforço (faça primeiro)
1. **Reduzir rebuild storms na Home**
   - **Impacto**: alto (tela principal)
   - **Esforço**: baixo/médio
2. **Pré-cálculo/memoização em telas de estatística** (ex.: `ReadingStatsScreen`)
   - **Impacto**: médio
   - **Esforço**: baixo
3. **Introduzir limites/estratégia de cache para ícones de apps**
   - **Impacto**: alto (memória e scroll)
   - **Esforço**: médio

### Quadrante B — Alto impacto / Alto esforço (planejar com cuidado)
1. **Revisar uso de blur (`BackdropFilter`) em larga escala**
   - **Impacto**: alto (GPU/raster)
   - **Esforço**: alto (redesign/UX)
2. **Mover JSON parsing pesado para isolates (`compute`)**
   - **Impacto**: alto (jank em loads)
   - **Esforço**: médio/alto
3. **Revisar pipeline de startup (defer init)**
   - **Impacto**: alto (first-frame)
   - **Esforço**: médio

### Quadrante C — Baixo impacto / Baixo esforço (quick wins quando sobrar tempo)
- Const-ify de widgets onde possível
- Pequenas otimizações de loops/alocações no build

### Quadrante D — Baixo impacto / Alto esforço (evitar inicialmente)
- Refatorações arquiteturais grandes sem evidência de ganho

---

## FASE 1 — Correções de alto impacto e baixo risco

### 1.1 Reduzir rebuild storms na Home
- **Objetivo**
  - Evitar reconstrução de grandes seções da Home quando mudanças do `GamificationService` não afetam tudo.
- **Arquivos afetados**
  - `lib/screens/home/home_screen.dart`
  - `lib/screens/home/home_screen_guest.dart`
  - (potencial) `lib/services/gamification/gamification_service.dart`
- **Estratégia**
  - Trocar `Consumer<GamificationService>` amplo por `Selector`/`context.select` para observar apenas:
    - lista de módulos ativos (`Set<NicheId>`)
    - medalhas pendentes (se necessário)
  - Extrair widgets estáticos para `const` e/ou `child:` do Consumer.
- **Exemplo (antes/depois)**

Antes (padrão atual, simplificado):
```dart
Consumer<GamificationService>(
  builder: (_, g, __) {
    final active = NicheId.values.where(g.isModuleActive).toList();
    return ListView(...);
  },
)
```

Depois (proposta):
```dart
final active = context.select<GamificationService, Set<NicheId>>(
  (g) => g.activeModulesSnapshot,
);
return HomeBody(activeModules: active);
```
- **Risco**: baixo (refator de UI)
- **Tempo estimado**: 2-4h
- **Métrica de validação**
  - Reduzir contagem de rebuilds (DevTools: Rebuild Stats)
  - Reduzir `build` p95 na Home

### 1.2 Memoização de cálculos em `ReadingStatsScreen`
- **Objetivo**
  - Evitar `toList()+sort+reduce` em cada rebuild.
- **Arquivos afetados**
  - `lib/screens/modules/9_reading/reading_stats_screen.dart`
  - `lib/services/9_reading/reading_service.dart`
- **Estratégia**
  - Mover agregações para o service e cachear até mudança em `_books`/logs.
  - Ou usar `Selector` para passar `weeklyData` já ordenado.
- **Risco**: baixo
- **Tempo estimado**: 1-2h
- **Métrica**
  - Reduzir tempo de build em tela de stats

### 1.3 Limitar cache de ícones de apps
- **Objetivo**
  - Evitar crescimento indefinido de `_iconCache`.
- **Arquivos afetados**
  - `lib/misc/system_stuff/installed_app_service.dart`
  - telas que exibem lista de apps (ex.: `select_apps_screen.dart`)
- **Estratégia**
  - Implementar LRU simples (cap por ex. 100-300 ícones)
  - Adicionar opção de `cacheWidth/cacheHeight` ao renderizar preview
- **Risco**: médio (pode afetar UX se cache pequeno)
- **Tempo**: 3-6h
- **Métrica**
  - Menor uso de memória (DevTools memory)
  - Scroll mais estável

---

## FASE 2 — Correções estruturais moderadas

### 2.1 Startup: deferir inicializações não-críticas
- **Objetivo**
  - Reduzir tempo até primeiro frame.
- **Arquivos afetados**
  - `lib/main.dart`
- **Estratégia**
  - Manter `ensureInitialized` + prefs + route, mas:
    - mover ads init / privacy init / review check para `postFrameCallback` ou background
    - avaliar `initNotifications` como lazy (depende do app)
- **Risco**: médio (pode quebrar módulos que dependem de notificações cedo)
- **Tempo**: 4-8h
- **Métrica**
  - Time to first frame / time to interactive

### 2.2 `compute` para JSON decode pesado
- **Objetivo**
  - Evitar travadas ao carregar grandes payloads.
- **Arquivos afetados**
  - `procrastination_service.dart`, `reading_service.dart`, `money_saving_challenge_service.dart`, `preferences_service.dart`
- **Estratégia**
  - Usar `compute(parseFn, jsonString)`
  - Atenção a tipos: funções top-level, payload serializável
- **Risco**: médio
- **Tempo**: 1-2 dias
- **Métrica**
  - p95 frame time durante loads

---

## FASE 3 — Otimizações avançadas

### 3.1 Reavaliar blur e glassmorphism
- **Objetivo**
  - Reduzir raster time e overdraw.
- **Arquivos afetados**
  - `lib/widgets/home/neon_card.dart`
  - `lib/widgets/home/bottom_nav_bar.dart`
- **Estratégia**
  - Alternativas:
    - reduzir sigma
    - reduzir área filtrada
    - substituir por gradiente + noise texture estática
    - usar blur apenas em destaque (não em lista)
- **Risco**: alto (impacta identidade visual)
- **Tempo**: 1-3 dias
- **Métrica**
  - Raster p95/p99 < 16ms em devices alvo

### 3.2 Estratégia de shader warm-up
- **Objetivo**
  - Evitar travadas na primeira vez que efeitos aparecem.
- **Estratégia**
  - Warm-up via `ShaderWarmUp` (Flutter) / capturar SkSL (dependendo do pipeline)
- **Risco**: médio

---

## FASE 4 — Melhorias arquiteturais opcionais

### 4.1 Refinar granularidade de providers
- **Objetivo**
  - Evitar que `notifyListeners()` em serviços grandes afete UI ampla.
- **Estratégia**
  - Split de `GamificationService` em sub-stores (status, medals, monitoring)
- **Risco**: alto
- **Tempo**: 1-2 semanas

---

## Critérios de “Definition of Done” (DoD)
- `Home`: reduzir rebuilds e manter p95 build+raster < 16ms (target 60fps)
- `Select apps`: scroll sem GC/jank perceptível
- `Startup`: reduzir tempo até primeira interação perceptível
