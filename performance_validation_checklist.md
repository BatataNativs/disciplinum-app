# Disciplinum — Performance Validation Checklist

Checklist para validar performance **com evidência** (profile mode + métricas), antes/depois das otimizações propostas.

---

## 1) Preparação
- [ ] Fechar apps pesados no device/emulador.
- [ ] Preferir **device físico** (Android mid/low) para perceber jank real.
- [ ] Garantir que está testando a mesma build (sem hot reload) em comparações.

---

## 2) Build mode correto

### 2.1 Rodar em Profile
- [ ] `flutter run --profile`
- [ ] Alternativa: `flutter run --profile --trace-skia` (para investigar raster/shaders).

### 2.2 Nunca concluir com base em Debug
- [ ] Debug distorce timings (asserts, VM overhead, service extensions).

---

## 3) Métricas principais (o que medir)

### 3.1 Frame timings
- [ ] **UI thread frame time** (build)
- [ ] **Raster thread frame time**
- [ ] p50 / p95 / p99
- [ ] # de frames acima de 16ms (60Hz) e 8ms (120Hz)

### 3.2 Jank & stutter
- [ ] Jank count
- [ ] Stutter durante scroll (home, listas)

### 3.3 Memória
- [ ] Memória total
- [ ] Crescimento contínuo (leaks)
- [ ] Picos ao abrir tela de apps / ícones

### 3.4 GPU / shader compilation
- [ ] Primeira navegação para telas com blur/shader (NeonCard/NavBar)
- [ ] Eventos de shader compilation (se visível no tooling)

---

## 4) Cenários padronizados (scripts de teste)

> Rode sempre o mesmo “roteiro” e capture as métricas.

### Script A — Startup / First frame
- [ ] Iniciar app (cold start)
- [ ] Medir tempo até Home interativa
- [ ] Observar travadas no primeiro frame

### Script B — Home scroll
- [ ] Scroll vertical na Home por 20-30s
- [ ] Abrir e fechar 3 módulos (push/pop)
- [ ] Medir p95 UI/raster durante scroll

### Script C — Efeitos de blur
- [ ] Manter Home aberta com muitos cards visíveis
- [ ] Alternar dark mode / navegar entre tabs (se aplicável)
- [ ] Verificar raster spikes (BackdropFilter)

### Script D — Select apps (ícones)
- [ ] Abrir tela de seleção de apps
- [ ] Scroll rápido 30s
- [ ] Medir memória e GC

### Script E — Stats screens
- [ ] Abrir Reading stats
- [ ] Interagir com gráfico (tooltips)
- [ ] Verificar rebuilds e stutter

---

## 5) Ferramentas e como coletar evidência

### 5.1 Flutter DevTools
- [ ] **Performance** tab: timeline, frame chart, CPU/GPU
- [ ] **Rebuild Stats** (se habilitado): identificar storms
- [ ] **Memory** tab: alocações/picos

### 5.2 Performance overlay (rápido no device)
- [ ] Ativar `PerformanceOverlay` para inspeção rápida (sem deep trace)

---

## 6) Critérios de sucesso (exemplos)

Defina metas por tela, por exemplo:
- [ ] **Home scroll**: p95 UI < 16ms e p95 Raster < 16ms
- [ ] **Select apps**: sem crescimento de memória contínuo ao scroll; p95 < 16ms
- [ ] **Startup**: redução perceptível do tempo até primeira interação (medir e registrar)

---

## 7) Template de comparação (antes/depois)

Para cada mudança implantada:
- [ ] Link/commit da mudança
- [ ] Device usado (modelo, Android versão, refresh rate)
- [ ] Script executado (A-E)
- [ ] p50/p95/p99 UI
- [ ] p50/p95/p99 Raster
- [ ] Memória pico
- [ ] Observações visuais (stutter/jank)

---

## 8) Observações finais
- Se a hipótese envolve `BackdropFilter` / blur, **a evidência principal** é o **Raster thread**.
- Se a hipótese envolve JSON decode e loops, **a evidência principal** é o **UI thread** + spikes durante loads.
