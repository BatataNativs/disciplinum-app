# Política de Privacidade — Disciplinum

**Última atualização:** 29 de setembro de 2026

O **Disciplinum** valoriza a sua privacidade e adota uma arquitetura **100% Local-First**, onde seus dados pertencem exclusivamente a você. Esta Política de Privacidade explica de forma transparente como seus dados são tratados no aplicativo, em **estrita conformidade com a Lei Geral de Proteção de Dados (Lei nº 13.709/2018 - LGPD)**.

Ao utilizar o Disciplinum, você concorda com as práticas descritas nesta política.

---

## 🔒 1. Princípio Fundamental: Armazenamento 100% Local (Local-First)

Diferente de aplicativos convencionais que enviam seus hábitos, rotinas e anotações para servidores remotos na nuvem, o **Disciplinum opera com armazenamento prioritariamente local**:
- Seus dados de hábitos, metas, diários, check-ins, progresso de módulos e configurações de perfil são gravados **direta e exclusivamente no banco de dados interno do seu dispositivo** (via ObjectBox).
- **Não possuímos servidores de banco de dados na nuvem** coletando ou armazenando seus hábitos ou anotações pessoais.
- Seus dados nunca saem do seu aparelho sem que você decida explicitamente exportar um arquivo de backup.

---

## 📋 2. Dados que Tratamos e Suas Finalidades

| Tipo de Dado | Exemplos | Onde Fica Armazenado | Finalidade | Base Legal (LGPD) |
|---|---|---|---|---|
| **Perfil e Preferências** | Nome (ou como gostaria de ser chamado), gênero (opcional), avatar e frase motivacional | Exclusivamente na memória interna do aparelho | Personalização da interface e experiência no app | Consentimento / Execução de Contrato (Art. 7º, I e V) |
| **Hábitos e Módulos** | Hábitos criados, rotinas, check-ins diários, histórico, anotações de diários e medalhas | Exclusivamente no banco de dados local (ObjectBox) | Funcionamento principal do aplicativo e gamificação | Execução de Contrato (Art. 7º, V) |
| **Autenticação e Segurança** | Bloqueio biométrico (impressão digital/facial) ou PIN local | Hardware seguro do dispositivo (Android BiometricPrompt) | Proteger o acesso ao aplicativo contra pessoas não autorizadas | Legítimo Interesse / Segurança (Art. 7º, IX) |
| **Arquivos de Backup** | Arquivo exportado em formato JSON com todos os dados locais | No local que o usuário escolher (Google Drive pessoal, e-mail, cartão SD) | Permitir migração de aparelho e segurança contra perda de dados | Controle exclusivo do Usuário |
| **Identificadores de Dispositivo** | ID de Publicidade (AdID), modelo do aparelho e versão do sistema | Google AdMob | Exibição de anúncios sustentadores do app | Consentimento (Art. 7º, I) |
| **Diagnóstico de Erros (Opcional)** | Relatórios de falhas anônimos (via Firebase Crashlytics) | Servidores do Firebase | Correção de bugs e estabilidade técnica | Consentimento (Art. 7º, I) |

> ⚠️ **O que NÃO coletamos:**
> - **Nenhum dado biométrico:** O Disciplinum **NÃO** tem acesso, não armazena e não transmite sua impressão digital ou dados faciais. A autenticação biométrica é gerida exclusivamente pelo sistema operacional do seu celular.
> - **Nenhum dado de localização GPS.**
> - **Nenhum número de telefone ou lista de contatos.**
> - **Nenhuma informação de cartão de crédito:** Todas as transações financeiras são processadas de forma isolada e segura pelo **Google Play Billing**.

---

## 🔐 3. Autenticação e Bloqueio por Biometria

O Disciplinum oferece a opção de ativar o **Bloqueio por Biometria** para maior segurança e privacidade:
- O bloqueio utiliza a API oficial e segura do sistema operacional (`Android BiometricPrompt`).
- O aplicativo apenas recebe uma confirmação booleana do sistema operacional (*"autenticação bem-sucedida"* ou *"falha"*).
- Você pode desativar ou ativar o bloqueio biométrico a qualquer momento na tela de **Configurações > Segurança e Acesso**.

---

## 💾 4. Backups, Portabilidade e Retenção de Dados

Por ser um aplicativo local-first:
- **Você tem controle absoluto sobre seus dados:** Eles permanecem no seu celular enquanto o aplicativo estiver instalado.
- **Exportação Manual:** Na tela **Configurações > Backup e Restauração**, você pode gerar a qualquer momento uma cópia completa dos seus dados em formato `.json`. Você escolhe onde guardar esse arquivo (Google Drive, e-mail, pasta interna, etc.).
- **Restauração:** Em caso de troca de celular ou restauração, basta selecionar o arquivo `.json` gerado para restabelecer imediatamente todos os seus hábitos e histórico.
- **Exclusão Definitiva:** Para apagar todos os seus dados, basta utilizar a opção **Deletar Conta** no perfil, limpar os dados do aplicativo nas configurações do Android ou desinstalar o app. Como os dados não ficam armazenados em nenhum servidor nosso, a exclusão local é imediata e irreversível.

---

## 🔄 5. Compartilhamento com Terceiros (Serviços Essenciais)

Não vendemos nem comercializamos quaisquer dados pessoais. Os únicos terceiros envolvidos fornecem serviços técnicos de apoio e monetização estritamente necessários:

| Serviço | Dados Tratados | Finalidade | Política de Privacidade |
|---|---|---|---|
| **Google AdMob** | ID de Publicidade (AdID), dados técnicos anônimos | Exibição de anúncios sustentadores | [policies.google.com/privacy](https://policies.google.com/privacy) |
| **Firebase Crashlytics** | Logs de erro anônimos e modelo do aparelho | Monitoramento de estabilidade e correção de falhas | [firebase.google.com/support/privacy](https://firebase.google.com/support/privacy) |
| **Google Play Billing** | Confirmação de assinatura/compra (sem dados bancários) | Processamento de compras no app | [payments.google.com](https://payments.google.com) |

---

## ⚖️ 6. Seus Direitos (LGPD)

A LGPD assegura a você direitos fundamentais sobre seus dados pessoais:
1. **Acesso e Correção:** Você visualiza e edita diretamente no aplicativo todos os seus hábitos, preferências e dados de perfil.
2. **Eliminação de Dados:** Você pode eliminar permanentemente todos os registros a qualquer momento limpando o aplicativo ou excluindo sua conta localmente.
3. **Portabilidade:** Você pode exportar seus dados a qualquer hora em formato estruturado (JSON).
4. **Revogação de Consentimento:** Você pode desligar anúncios personalizados ou desativar o envio de diagnósticos em **Configurações > Análise de uso e erros**.

Para quaisquer esclarecimentos adicionais relativos à privacidade, você pode contatar nosso encarregado pelo e-mail: **disciplinum.app@gmail.com**.

---

## 📱 7. Gestão de Anúncios e Telemetria

- **Anúncios Personalizados:** Na primeira execução, o formulário de consentimento (Google UMP) permite escolher entre anúncios personalizados ou genéricos. Você também pode alterar isso nas [Configurações de Anúncios do Google](https://adssettings.google.com).
- **Análise de Uso e Erros:** O envio de telemetria pode ser ativado ou desativado a qualquer momento em **Configurações > Análise de uso e erros**.

---

## 💳 8. Compras no Aplicativo (In-App Purchases)

O Disciplinum é gratuito para uso geral e pode disponibilizar recursos adicionais ou planos mediante compra no aplicativo:
- Todas as transações são intermediadas com exclusividade pelo **Google Play Billing**.
- Não temos acesso aos seus dados financeiros ou de cartão de crédito.
- O gerenciamento e cancelamento de assinaturas devem ser feitos diretamente no aplicativo da **Google Play Store**.

---

## 👶 9. Uso por Menores

- O aplicativo é destinado a usuários com 13 anos ou mais.
- Menores de 18 anos devem contar com a orientação e consentimento dos pais ou responsáveis legais.
- Não coletamos dados de menores intencionalmente.

---

## 📞 10. Contato e Transparência

Dúvidas, sugestões ou solicitações relativas à privacidade podem ser encaminhadas para:
- **E-mail:** [disciplinum.app@gmail.com](mailto:disciplinum.app@gmail.com)
- **Repositório de Transparência:** [https://github.com/BatataNativs/disciplinum-legal](https://github.com/BatataNativs/disciplinum-legal)

---
**Disciplinum — 2026**  
*Desenvolvido por Douglas Natividade*
