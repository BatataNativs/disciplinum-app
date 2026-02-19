# Disciplinum — Performance Audit Report (Flutter)

Escopo: auditoria **estática + estrutural** baseada no código-fonte atual. **Não substitui profiling** (muitos itens abaixo são *hipóteses técnicas — requer profiling dinâmico*).

## 0) Contexto de execução (evidência)
- **Entrypoint / boot**
  - `lib/main.dart:53-143`
    - `SharedPreferences.getInstance()` é aguardado antes do `runApp` (`main.dart:56`).
    - Inicialização de Ads (`_Ads.initAtStartup()` em `main.dart:76`).
    - `initNotifications()` é aguardado antes do `runApp` (`main.dart:79`).
    - `Supabase.initialize(...)` é aguardado antes do `runApp` (`main.dart:81-85`).
    - `PrivacyService.initAtStartup()` aguardado (`main.dart:87`).
- **State management / DI**
  - `MultiProvider` em `main.dart:93-140` com múltiplos `ChangeNotifierProvider`s (ThemeController, GamificationService, AdService, ProcrastinationService, SpendingService, ReadingService, AuthService, IapService).

**Risco geral**: startup com múltiplos `await` + inicializações que fazem platform channel/IO pode causar **first-frame jank** ou atraso perceptível no splash -> primeira tela.

---

## 1) BUILD & REBUILD STORMS

### 1.1 Consumer amplo no Home reconstruindo árvore grande
- **Evidência**
  - `lib/screens/home/home_screen.dart:363-401`
  - `Consumer<GamificationService>` envolve o `ListView.separated` da home.
  - Dentro do `builder`:
    - Calcula `activeNiches = NicheId.values.where(...).toList()` (`home_screen.dart:367-369`).
    - Cria `allCategories = List.from(categories)` (`home_screen.dart:372-373`).
- **Por que pode gerar jank**
  - `GamificationService` tende a chamar `notifyListeners()` com frequência (ex.: timers/monitoramento/restore). Cada `notifyListeners()` pode reconstruir a seção inteira (ListView + cards), gerando **rebuild storms**.
- **Tipo**: CPU bound (build), potencial Layout bound.
- **Severidade**: **Alto** (tela principal, alta frequência).
- **Ganho esperado**: reduzir reconstruções desnecessárias; melhora de frame build time (principalmente em aparelhos mid/low).
- **Nota**: hipótese forte; requer medir `rebuild`/`frame build` em DevTools.

### 1.2 Título com `ShaderMask` + stroke paint na Home
- **Evidência**
  - `lib/screens/home/home_screen.dart:325-357`
  - Usa `Stack` com `Text` com `foreground: Paint()..style=stroke` + `ShaderMask`.
- **Por que pode gerar jank**
  - `ShaderMask` normalmente implica layer/composição e pode gerar **custo de rasterização** em alguns GPUs.
- **Tipo**: GPU bound / compositing.
- **Severidade**: **Médio** (uma vez por frame na home, mas área pequena).

### 1.3 Padrão repetido em `HomeScreenGuest`
- **Evidência**
  - `lib/screens/home/home_screen_guest.dart:195-356` repete o mesmo padrão de UI da Home.
- **Por que importa**
  - Mesmos riscos de rebuild/composição duplicados em outra rota.
- **Tipo**: CPU/GPU.
- **Severidade**: **Médio**.

---

## 2) LAYOUT & MEASURE (custos de layout/measure)

### 2.1 `LayoutBuilder` em grid quadrado (Desafio da Poupança)
- **Evidência**
  - `lib/screens/modules/7_moneySavingChallenge/money_saving_challenge_screen.dart:1460-1495`
  - `LayoutBuilder` calcula `size = constraints.maxWidth` e constrói um `SizedBox(width:size,height:size)`.
- **Por que pode gerar jank**
  - `LayoutBuilder` por si não é vilão, mas combinado com:
    - `GridView.builder` com muitas células
    - `AnimatedContainer` por célula
  pode aumentar custo de layout + raster por interação.
- **Tipo**: Layout bound + GPU bound.
- **Severidade**: **Médio**.

### 2.2 `ListView.separated` vertical contendo `ListView` horizontal (Home)
- **Evidência**
  - `home_screen.dart:380-399` + `home_screen.dart:461-479` / `504-524`.
- **Risco**
  - Nested scroll views pode gerar mais trabalho de layout/scroll; com poucos itens geralmente ok.
- **Severidade**: **Baixo/Médio** (depende do número de categorias/módulos).

---

## 3) ALOCAÇÃO POR FRAME (objetos temporários)

### 3.1 List/Sort em build (ReadingStats)
- **Evidência**
  - `lib/screens/modules/9_reading/reading_stats_screen.dart:154-156`
  - `sortedDates = weeklyData.keys.toList()..sort();`
- **Por que pode gerar jank**
  - Em rebuilds frequentes, `.toList()` + `.sort()` aloca e custa CPU.
  - Também há múltiplos cálculos no build do gráfico (ex.: `reduce` e `fold` em `:159-160`, e `weeklyData.values.reduce` novamente em `:197-199` e `:268-271`).
- **Tipo**: CPU bound (build) + alocação.
- **Severidade**: **Médio** (tela de stats; frequência depende de `notifyListeners`).
- **Correção típica**: memoização / pré-cálculo no service / `Selector`.

### 3.2 Filtragem em build (Minha estante)
- **Evidência**
  - `lib/screens/modules/9_reading/my_shelf_screen.dart:113-115`
  - `activeBooks = service.books.where((b) => !b.isCompleted).toList()` em `build`.
- **Tipo**: CPU bound (build), alocação.
- **Severidade**: **Baixo/Médio** (lista pode crescer, mas geralmente pequena).

---

## 4) GPU & COMPOSITING (layers, blur, clipping)

### 4.1 `BackdropFilter` (blur) + `ClipRRect` em cards (NeonCard)
- **Evidência**
  - `lib/widgets/home/neon_card.dart:59-80` (ClipRRect + BackdropFilter blur sigma 5)
  - Gradiente `Positioned.fill` em `:83-99`
  - `Opacity` no conteúdo em `:115-120`
- **Por que pode gerar jank**
  - `BackdropFilter` geralmente força render em offscreen e pode ser caro (dependendo da área filtrada) e **escala mal** quando existem muitos cards na tela.
  - `ClipRRect` pode forçar clipping e impactar raster.
  - `Opacity` pode induzir `saveLayer` dependendo do contexto.
- **Tipo**: GPU bound / compositing / raster.
- **Severidade**: **Crítico/Alto** se a Home renderiza muitos `NeonCard`s simultaneamente (padrão do app).
- **Hipótese técnica**: requer profiling raster (`Raster thread`) e `PerformanceOverlay`.

### 4.2 `BackdropFilter` no BottomNavBar
- **Evidência**
  - `lib/widgets/home/bottom_nav_bar.dart:79-99` (ClipRRect + BackdropFilter blur sigma 10 + sombra blur 20)
- **Impacto**
  - Rodapé aparece em várias telas; custo constante por frame durante scroll/anim.
- **Tipo**: GPU bound.
- **Severidade**: **Alto**.

### 4.3 `ShaderMask` no título da Home
- **Evidência**
  - `home_screen.dart:339-356` (ShaderMask com LinearGradient)
- **Tipo**: GPU bound.
- **Severidade**: **Médio**.

---

## 5) SHADERS & FIRST-FRAME JANK

### 5.1 Warm-up inexistente para blur/shaders (hipótese)
- **Evidência**
  - Uso de `BackdropFilter` e `ShaderMask` (citados acima).
  - Não foi encontrado código de warm-up (`ShaderWarmUp`, `SkSL`) no material lido.
- **Risco**
  - Primeira vez que blur/shader/efeitos aparecem pode causar travada curta (shader compilation).
- **Tipo**: Shader warm-up.
- **Severidade**: **Médio**.
- **Hipótese técnica — requer profiling dinâmico**: observar `shader compilation` em profile e jank ao navegar para telas com NeonCard/nav.

---

## 6) IMAGENS & ASSETS

### 6.1 `Image.asset` sem `cacheWidth/cacheHeight`
- **Evidência**
  - `home_screen.dart:319-322` logo.
  - `home_screen.dart:232-236` ícone do módulo.
  - `onboarding_screen.dart:198-234` múltiplas imagens grandes.
  - `bottom_nav_bar.dart:179-187` asset no ícone.
- **Risco**
  - Decodificação de imagens grandes + upload de textura pode gerar picos.
- **Tipo**: CPU/GPU (decode + upload) + memória.
- **Severidade**: **Médio**.
- **Hipótese**: depende do tamanho real dos assets (requer inspeção de bytes e profiling de memória + raster).

### 6.2 Ícones de apps via `Image.memory`
- **Evidência**
  - `screens/select_apps_screen.dart:60-63` (aparece no grep; não lido por completo aqui).
  - `InstalledAppService.getAppIcon` usa `InstalledApps.getAppInfo` e cache (`installed_app_service.dart:55-87`).
- **Risco**
  - Ícones em memória podem pressionar memória; dependendo do número de apps exibidos simultaneamente.
- **Tipo**: Memory pressure + CPU (decode) + GPU upload.
- **Severidade**: **Alto** em telas com lista grande de apps.

---

## 7) SÍNCRONO NO UI ISOLATE (CPU-bound / IO)

### 7.1 JSON decode em services no init (UI isolate)
- **Evidência**
  - `PreferencesService` faz `jsonDecode` repetidamente (`preferences_service.dart:93-99`, `197-203`, etc.).
  - `ProcrastinationService._loadData` decodifica JSON potencialmente grande (`procrastination_service.dart:44-81`, `98-130`).
  - `ReadingService._loadData` decodifica lista de livros e streak (`reading_service.dart:41-69`).
  - `MoneySavingChallengeService.getChallenges` faz `jsonDecode` e conversões (`money_saving_challenge_service.dart:42-67`, `225-265`).
- **Por que pode gerar jank**
  - Em dispositivos lentos, decodificar JSON grande no main isolate durante abertura/rebuild pode causar travadas.
- **Tipo**: CPU bound.
- **Severidade**: **Alto** (depende do volume de dados e quando roda).
- **Hipótese técnica**: requer medir p95 frame time durante carregamento/primeiro open.

### 7.2 Startup com múltiplos awaits antes do `runApp`
- **Evidência**
  - `main.dart:56-91`.
- **Impacto**
  - Atraso no primeiro frame e sensação de app “lento para abrir”.
- **Tipo**: IO blocking / platform channel.
- **Severidade**: **Alto**.

---

## 8) MEMORY & LIFECYCLE

### 8.1 `InstalledAppService` cache de ícones sem limite
- **Evidência**
  - `installed_app_service.dart:11-14` caches `_cachedApps`, `_iconCache`, `_pendingRequests`.
- **Risco**
  - Cache infinito pode crescer com o número de apps; risco de OOM em devices low-end.
- **Tipo**: Memory pressure.
- **Severidade**: **Médio/Alto**.

### 8.2 `HomeScreen` lifecycle observers ok, mas faz trabalho no `didChangeDependencies`
- **Evidência**
  - `home_screen.dart:51-77` addPostFrameCallback + permission flow.
- **Risco**
  - Pode ser reexecutado em cenários de dependências mudando; há guard `_permissionsChecked`, bom.
- **Tipo**: CPU/IO.
- **Severidade**: **Baixo/Médio**.

---

## 9) HOT PATHS identificados (prioridade de profiling)
1. **Home**
   - `Consumer<GamificationService>` (rebuild storms) + muitos `NeonCard`.
2. **NeonCard / BottomNavBar**
   - `BackdropFilter`/blur e clipping.
3. **Startup**
   - `initNotifications`, `Supabase.initialize`, privacy, ads antes do `runApp`.
4. **Select apps / lista de apps**
   - `Image.memory` de ícones + caching.
5. **Stats screens**
   - `fl_chart` e cálculos/sorts em build.

---

## 10) Recomendações iniciais de profiling (sem mudança de código)
- Rodar **profile mode** e coletar:
  - `Frame build time` (UI thread) e `Raster time`.
  - Jank count e p95/p99.
- Comparar navegação:
  - Boot -> Home
  - Scroll na Home
  - Abrir módulo com muitos cards
  - Abrir tela com blur (NavBar sempre) + transições
  - Abrir Select apps

---

## Apêndice — Itens que requerem profiling dinâmico
- Custo real de `BackdropFilter` em dispositivos alvo (varia muito por GPU e área filtrada).
- Volume real de dados decodificados via JSON nos services.
- Frequência real de `notifyListeners()` no `GamificationService` (há timers/monitoramento; arquivo é grande e precisa inspeção orientada a eventos com DevTools).
