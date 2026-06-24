# Especificação Funcional - Sistema de Gamificação Disciplinum

## Status de Implementação (2026-06-24)

- ✅ Reading: 100% implementado (Plugin Architecture)
- ✅ Money Saving: 100% implementado (Plugin Architecture)
- ✅ BingeEating: 100% implementado (Plugin Architecture)
- ✅ Adult Content: 100% implementado (Plugin Architecture)
- ✅ Diet: 100% implementado (Plugin Architecture)
- ✅ Procrastination: 100% implementado (Plugin Architecture)
- ✅ Smoking: 100% implementado (Plugin Architecture)
- ✅ Focus: 100% implementado (Plugin Architecture)
- ✅ Spending: 100% implementado (Plugin Architecture)
- ✅ Digital Detox (Jejum Digital): 100% implementado (Plugin Architecture)

**Progresso:** 10/10 módulos (100%)

---

## Arquitetura de Plugins

### Visão Geral

O objetivo final da gamificação do Disciplinum é transformar cada módulo em um **plugin independente**. Cada pasta de módulo deve ter sua própria pasta `gamification`, contendo toda a gamificação relacionada exclusivamente àquele módulo.

### Estrutura de Diretórios

```
lib/features/modules/[nome do módulo]/gamification/
```

### Benefícios da Arquitetura Plugin

- **Independência:** Módulos funcionam isoladamente
- **Escalabilidade:** Facilita inclusão de novos módulos
- **Manutenibilidade:** Exclusão de módulos sem afetar outros
- **Organização:** Cada classe, função e objeto pertence ao seu módulo

### Plano de Migração

1. Migrar toda gamificação para pastas locais dos módulos
2. Remover pasta central `lib/features/gamification`
3. Validar independência total de cada plugin

---

## Sistema de Gamificação por Módulo

### Lógica Especial para Múltiplas Ocorrências

Para módulos que permitem múltiplas ocorrências simultâneas (ex: Desafio da Poupança com várias metas), não faz sentido ter um único ciclo de insígnias. Ao concluir uma meta (100% do grid), o usuário ganha a insígnia Disciplinum e, consequentemente, uma medalha de Bronze. Isso permite recompensas progressivas por cada desafio concluído.

---

## Parar de Fumar (Smoking)

### Unidade de Medida
Check-ins diários positivos consecutivos. O usuário define horário para check-in (preferencialmente antes de dormir) e responde se conseguiu se controlar no dia.

### Insígnias

| Insígnia | Requisito |
|----------|-----------|
| 🪵 Madeira | Configurar e ativar o módulo |
| 🥈 Ferro | 1 dia com check-in positivo |
| 🥈 Alumínio | 2 dias com check-in positivo |
| 🥇 Latão | 3 dias com check-in positivo |
| 🥉 Bronze | 5 dias com check-in positivo |
| 🥈 Prata | 10 dias com check-in positivo |
| 🥇 Ouro | 15 dias com check-in positivo |
| 💎 Diamante | 20 dias com check-in positivo |
| 🎱 Disciplinum | 30 dias com check-in positivo |

### Medalhas

| Medalha | Requisito |
|---------|-----------|
| Bronze | 1 insígnia Disciplinum |
| Prata | 2 insígnias Disciplinum |
| Ouro | 3 insígnias Disciplinum |
| Diamante | 4 insígnias Disciplinum |

### Marcos Especiais de Saúde

Sem insígnias ou medalhas. Usam notificações e celebrações com confetes ao abrir o app.

| Marco | Tempo | Mensagem |
|-------|-------|----------|
| Pressão arterial normal | 20 minutos | "Parabéns 🎊! Sua pressão arterial e frequência cardíaca têm potencial de melhora após 20 minutos. Continue!" |
| Sem monóxido de carbono | 1 dia | "Parabéns 🎊! Seus níveis de monóxido de carbono no sangue podem diminuir drasticamente após 1 dia. Continue!" |
| Olfato e paladar melhoram | 2 dias | "Parabéns 🎊! Olfato e paladar costumam melhorar após 2 dias. Aproveite. E continue!" |
| Respiração mais fácil | 3 dias | "Parabéns 🎊! Sua respiração tende a melhorar após 3 dias. Provavelmente vai conseguir dormir melhor. E continue!" |
| Circulação melhora | 14 dias | "Parabéns 🎊! Sua circulação tende a melhorar após 14 dias. Tente caminhar mais após isso. Continue!" |
| Função pulmonar + 10% | 90 dias | "Parabéns 🎊! Sua função pulmonar pode ter tido uma melhora de uns 10% após 90 dias. Aproveite mais a vida! E continue em frente!" |

### Marcos Especiais de Economia

| Marco | Mensagem |
|-------|----------|
| Economizou 1 maço | "Parabéns 🎊! Economizou o valor de 1 maço" |
| Economizou 2 maços | "Parabéns 🎊! Economizou o valor de 2 maços" |
| Economizou 5 maços | "Parabéns 🎊! Economizou o valor de 5 maços" |
| Economizou 10 maços | "Parabéns 🎊! Economizou o valor de 10 maços" |
| Economizou 20 maços | "Parabéns 🎊! Economizou o valor de 20 maços" |
| Economizou 30 maços | "Parabéns 🎊! Economizou o valor de 30 maços" |

---

## Compulsão Alimentar (BingeEating)

### Unidade de Medida
Dias sem quebrar regras (não abrir apps selecionados). Verificação no primeiro segundo do dia seguinte.

### Insígnias

| Insígnia | Requisito |
|----------|-----------|
| 🪵 Madeira | Configurar e ativar o módulo |
| 🥈 Ferro | 1 dia sem abrir apps bloqueados |
| 🥈 Alumínio | 2 dias sem abrir apps bloqueados |
| 🥇 Latão | 3 dias sem abrir apps bloqueados |
| 🥉 Bronze | 5 dias sem abrir apps bloqueados |
| 🥈 Prata | 10 dias sem abrir apps bloqueados |
| 🥇 Ouro | 15 dias sem abrir apps bloqueados |
| 💎 Diamante | 20 dias sem abrir apps bloqueados |
| 🎱 Disciplinum | 30 dias sem abrir apps bloqueados |

### Medalhas

| Medalha | Requisito |
|---------|-----------|
| Bronze | 1 insígnia Disciplinum |
| Prata | 2 insígnias Disciplinum |
| Ouro | 3 insígnias Disciplinum |
| Diamante | 4 insígnias Disciplinum |

---

## Dieta (Diet)

### Unidade de Medida
Dias consecutivos cumprindo todos os horários de refeição selecionados. O usuário configura horários e responde via notificação rápida (30 minutos após cada refeição) se fez a refeição. Ao responder da última refeição do dia, recebe a insígnia/medalha correspondente.

### Insígnias

| Insígnia | Requisito |
|----------|-----------|
| 🪵 Madeira | Configurar e ativar o módulo |
| 🥈 Ferro | 1 dia cumprindo horários |
| 🥈 Alumínio | 2 dias cumprindo horários |
| 🥇 Latão | 4 dias cumprindo horários |
| 🥉 Bronze | 8 dias cumprindo horários |
| 🥈 Prata | 12 dias cumprindo horários |
| 🥇 Ouro | 18 dias cumprindo horários |
| 💎 Diamante | 26 dias cumprindo horários |
| 🎱 Disciplinum | 30 dias cumprindo horários |

### Medalhas

| Medalha | Requisito |
|---------|-----------|
| Bronze | 1 insígnia Disciplinum |
| Prata | 2 insígnias Disciplinum |
| Ouro | 3 insígnias Disciplinum |
| Diamante | 4 insígnias Disciplinum |

---

## Controle de Gastos (Spending)

### Unidade de Medida
Contas pagas dentro do mês. Verificação diária: se violou regra, reseta gamificação (mantendo insígnia Madeira).

### Insígnias

| Insígnia | Requisito |
|----------|-----------|
| 🪵 Madeira | Configurar e ativar o módulo |
| 🥈 Ferro | Todas as contas pagas no mês atual |
| 🥈 Alumínio | Todas as contas pagas em 2 meses |
| 🥇 Latão | Todas as contas pagas em 3 meses |
| 🥉 Bronze | Todas as contas pagas em 4 meses |
| 🥈 Prata | Todas as contas pagas em 6 meses |
| 🥇 Ouro | Todas as contas pagas em 8 meses |
| 💎 Diamante | Todas as contas pagas em 10 meses |
| 🎱 Disciplinum | Todas as contas pagas em 12 meses |

### Medalhas

| Medalha | Requisito |
|---------|-----------|
| Bronze | Ganhou insígnia Latão |
| Prata | Ganhou insígnia Ouro |
| Ouro | Ganhou insígnia Diamante |
| Diamante | Ganhou insígnia Disciplinum |

---

## Desafio da Poupança (Money Saving)

### Unidade de Medida
Porcentagem de preenchimento do grid do desafio/meta. Lógica especial: cada desafio concluído (100% do grid) gera uma insígnia Disciplinum e consequentemente uma medalha.

### Insígnias

| Insígnia | Requisito |
|----------|-----------|
| 🪵 Madeira | Configurar e ativar o módulo |
| 🥈 Ferro | 5% da grid de um desafio preenchida |
| 🥈 Alumínio | 10% da grid de um desafio preenchida |
| 🥇 Latão | 15% da grid de um desafio preenchida |
| 🥉 Bronze | 20% da grid de um desafio preenchida |
| 🥈 Prata | 40% da grid de um desafio preenchida |
| 🥇 Ouro | 60% da grid de um desafio preenchida |
| 💎 Diamante | 80% da grid de um desafio preenchida |
| 🎱 Disciplinum | 100% da grid de um desafio preenchida |

### Medalhas

| Medalha | Requisito |
|---------|-----------|
| Bronze | 1 desafio concluído |
| Prata | 2 desafios concluídos |
| Ouro | 3 desafios concluídos |
| Diamante | 4 desafios concluídos |

---

## Foco e Produtividade (Focus)

### Unidade de Medida
Períodos de foco respeitados. Usuário configura faixa de tempo (início e fim), seleciona apps a bloquear. No primeiro segundo após o horário final, se não clicou em "Entrar no app", conta como período respeitado.

### Insígnias

| Insígnia | Requisito |
|----------|-----------|
| 🪵 Madeira | Configurar e ativar o módulo |
| 🥈 Ferro | 1 período de foco respeitado |
| 🥈 Alumínio | 2 períodos de foco respeitados |
| 🥇 Latão | 3 períodos de foco respeitados |
| 🥉 Bronze | 4 períodos de foco respeitados |
| 🥈 Prata | 5 períodos de foco respeitados |
| 🥇 Ouro | 6 períodos de foco respeitados |
| 💎 Diamante | 9 períodos de foco respeitados |
| 🎱 Disciplinum | 10 períodos de foco respeitados |

### Medalhas

| Medalha | Requisito |
|---------|-----------|
| Bronze | Ganhou insígnia Latão |
| Prata | Ganhou insígnia Ouro |
| Ouro | Ganhou insígnia Diamante |
| Diamante | Ganhou insígnia Disciplinum |

---

## Evitar Procrastinação (Procrastination)

### Unidade de Medida
Dias consecutivos concluindo todas as tarefas do dia.

**Regra especial:** Se não houver tarefas configuradas no dia, a gamificação permanece como está (sem somas positivas ou negativas).

### Insígnias

| Insígnia | Requisito |
|----------|-----------|
| 🪵 Madeira | Configurar e ativar o módulo |
| 🥈 Ferro | Todas as tarefas do dia concluídas em 1 dia |
| 🥈 Alumínio | Todas as tarefas do dia concluídas em 2 dias |
| 🥇 Latão | Todas as tarefas do dia concluídas em 3 dias |
| 🥉 Bronze | Todas as tarefas do dia concluídas em 5 dias |
| 🥈 Prata | Todas as tarefas do dia concluídas em 12 dias |
| 🥇 Ouro | Todas as tarefas do dia concluídas em 18 dias |
| 💎 Diamante | Todas as tarefas do dia concluídas em 25 dias |
| 🎱 Disciplinum | Todas as tarefas do dia concluídas em 30 dias |

### Medalhas

| Medalha | Requisito |
|---------|-----------|
| Bronze | 1 insígnia Disciplinum |
| Prata | 2 insígnias Disciplinum |
| Ouro | 3 insígnias Disciplinum |
| Diamante | 4 insígnias Disciplinum |

---

## Evitar Conteúdo Adulto (Adult Content)

### Unidade de Medida
Dias sem quebrar regras (não abrir apps selecionados). Verificação no primeiro segundo do dia seguinte.

### Insígnias

| Insígnia | Requisito |
|----------|-----------|
| 🪵 Madeira | Configurar e ativar o módulo |
| 🥈 Ferro | 1 dia sem abrir apps bloqueados |
| 🥈 Alumínio | 2 dias sem abrir apps bloqueados |
| 🥇 Latão | 3 dias sem abrir apps bloqueados |
| 🥉 Bronze | 5 dias sem abrir apps bloqueados |
| 🥈 Prata | 10 dias sem abrir apps bloqueados |
| 🥇 Ouro | 15 dias sem abrir apps bloqueados |
| 💎 Diamante | 20 dias sem abrir apps bloqueados |
| 🎱 Disciplinum | 30 dias sem abrir apps bloqueados |

### Medalhas

| Medalha | Requisito |
|---------|-----------|
| Bronze | 1 insígnia Disciplinum |
| Prata | 2 insígnias Disciplinum |
| Ouro | 3 insígnias Disciplinum |
| Diamante | 4 insígnias Disciplinum |

---

## Leitura (Reading)

### Unidade de Medida
Progresso de leitura baseado em porcentagem de páginas lidas do primeiro livro cadastrado.

### Insígnias

| Insígnia | Requisito |
|----------|-----------|
| 🪵 Madeira | Configurar e ativar o módulo |
| 🥈 Ferro | 2% lido do total de páginas do primeiro livro |
| 🥈 Alumínio | 5% lido do total de páginas do primeiro livro |
| 🥇 Latão | 10% lido do total de páginas do primeiro livro |
| 🥉 Bronze | 50% de um livro concluído |
| 🥈 Prata | 80% de um livro concluído |
| 🥇 Ouro | 1 livro concluído |
| 💎 Diamante | 2 livros concluídos |
| 🎱 Disciplinum | 3 livros concluídos |

### Medalhas

| Medalha | Requisito |
|---------|-----------|
| Bronze | 1 insígnia Disciplinum |
| Prata | 2 insígnias Disciplinum |
| Ouro | 3 insígnias Disciplinum |
| Diamante | 4 insígnias Disciplinum |

---

## Jejum Digital (Digital Detox)

### Unidade de Medida
Limite de uso configurado respeitado (verificação diária).

### Insígnias

| Insígnia | Requisito |
|----------|-----------|
| 🪵 Madeira | Configurar e ativar o módulo |
| 🥈 Ferro | 1 dia respeitando os limites |
| 🥈 Alumínio | 2 dias respeitando os limites |
| 🥇 Latão | 3 dias respeitando os limites |
| 🥉 Bronze | 5 dias respeitando os limites |
| 🥈 Prata | 10 dias respeitando os limites |
| 🥇 Ouro | 15 dias respeitando os limites |
| 💎 Diamante | 20 dias respeitando os limites |
| � Disciplinum | 30 dias respeitando os limites |

### Medalhas

Baseadas em número de insígnias Disciplinum obtidas (sem interrupções do streak).

| Medalha | Requisito |
|---------|-----------|
| Bronze | 1 insígnia Disciplinum |
| Prata | 2 insígnias Disciplinum |
| Ouro | 3 insígnias Disciplinum |
| Diamante | 4 insígnias Disciplinum |

### Regras Gerais de Contagem

O sistema opera com dois contadores independentes:

#### 1. Streak Principal
- Conta dias válidos consecutivos
- Usado para insígnias e medalhas

#### 2. Ciclo de 7 Dias (Quebra de Jejum)
- Conta dias válidos consecutivos
- Utilizado para concessão de Quebras de Jejum

### Tipos de Dia

**Dia Válido:**
- Respeitou todos os limites
- +1 no streak
- +1 no ciclo de 7 dias

**Dia de Quebra de Jejum:**
- Uso livre (acima dos limites)
- Considerado dia neutro
- Não soma e não interrompe: streak e ciclo de 7 dias

**Dia de Falha:**
- Descumprimento das regras
- streak = 0
- ciclo de 7 dias = 0

### Sistema de Quebras de Jejum

Sistema de recompensa por consistência.

#### Aquisição
- A cada 7 dias válidos consecutivos → ganha 1 Quebra de Jejum

#### Uso
- Concede 1 dia completo de uso livre
- Durante esse dia:
  - Progresso é pausado
  - Não conta como dia válido
  - Não quebra streak
  - Não afeta insígnias ou medalhas

#### Regra Central
Dias de quebra de jejum são ignorados pelos contadores. A contagem continua normalmente a partir do próximo dia válido, sem reinício.

#### Armazenamento e Limites
- Máximo de 1 Quebra de Jejum armazenada
- Se o usuário já possuir 1: não acumula outra até utilizar

#### Restrição de Uso
Após utilizar uma Quebra de Jejum: é necessário completar novos 7 dias válidos para obter outra.

### Notificações

- Ao completar 7 dias → notificação de recompensa
- Botão: "Ver no app" (leva à tela de Quebras de Jejum)
- Aviso de término da quebra: notificação 5 minutos antes
- Encerramento automático ao final do dia

### Exemplo de Funcionamento

| Dia | Tipo | Streak | Ciclo 7 dias |
|-----|------|--------|--------------|
| 1 | Válido | 1 | 1 |
| 2 | Válido | 2 | 2 |
| 3 | Válido | 3 | 3 |
| 4 | Válido | 4 | 4 |
| 5 | Válido | 5 | 5 |
| 6 | Válido | 6 | 6 |
| 7 | Válido | 7 | 7 → ganha quebra 🎁 |
| 8 | Quebra | 7 | 7 (inalterado) |
| 9 | Válido | 8 | 1 |

---

## Regras Gerais

### Observação 1
Emojis são meramente ilustrativos. As insígnias e medalhas têm seus próprios assets.

### Observação 2
Manter as lógicas de reset:
- Se o usuário descumprir regra → reseta tudo
- Se tiver recaída → reseta tudo
- Se desativar o módulo → reseta tudo
- Mantém apenas a insígnia Madeira
- Perde as medalhas também

**Remover:** Questão de "medalha máxima alcançada" se ainda existir no código.

### Observação 3
**Remover completamente:**
- Lógica do grace period
- Menções ao grace period
- Qualquer referência relacionada

Futuramente será pensado em algo assim, mas por agora, remover totalmente.