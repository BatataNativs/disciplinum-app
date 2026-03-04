# 📱 Guia Completo: Publicando Disciplinum na Google Play Store

> **Versão**: 2.0  
> **Data**: Março 2026  
> **App**: Disciplinum  
> **Autor**: Gerado por IA para Douglas

---

## 📋 Índice

1. [Visão Geral e Custos](#1-visão-geral-e-custos)
2. [Pré-requisitos](#2-pré-requisitos)
3. [Criar Conta de Desenvolvedor](#3-criar-conta-de-desenvolvedor)
4. [Gerar Keystore de Assinatura](#4-gerar-keystore-de-assinatura)
5. [Configurar Build de Release](#5-configurar-build-de-release)
6. [Gerar o App Bundle](#6-gerar-o-app-bundle)
7. [Criar App na Play Console](#7-criar-app-na-play-console)
8. [Upload para Internal Testing](#8-upload-para-internal-testing)
9. [Configurar In-App Purchase](#9-configurar-in-app-purchase)
10. [Adicionar Testadores](#10-adicionar-testadores)
11. [Testar Compras In-App](#11-testar-compras-in-app)
12. [Checklist Final](#12-checklist-final)
13. [Problemas Comuns](#13-problemas-comuns)

---

## 1. Visão Geral e Custos

### 💰 Custos

| Item | Valor | Frequência |
| ------ | ------- | ------------ |
| Taxa de desenvolvedor Google | **$25 USD** | Única (vitalícia) |
| Upload de apps | Grátis | - |
| Testes (Internal/Closed/Open) | Grátis | - |
| Publicação em Produção | Grátis | - |

### 📊 Faixas de Teste

| Faixa | Limite | Aprovação | Visibilidade |
| ------- | -------- | ----------- | -------------- |
| **Internal Testing** | 100 testadores | Instantânea | Só convidados |
| **Closed Testing** | Ilimitado | ~3 dias | Grupos/Links |
| **Open Testing** | Ilimitado | ~3 dias | Qualquer um pode entrar |
| **Production** | Ilimitado | ~3-7 dias | Pública na loja |

> **Recomendação**: Comece pelo **Internal Testing** - é instantâneo e perfeito para testar IAP.

---

## 2. Pré-requisitos

### ✅ Checklist antes de começar

- [ ] Conta Google (pode ser a mesma do Gmail)
- [ ] Cartão de crédito/débito internacional (para pagar $25)
- [ ] Java JDK instalado (para gerar keystore)
- [ ] Flutter SDK configurado
- [ ] App funcionando em modo debug
- [ ] Ícone do app configurado (512x512 PNG)
- [ ] Screenshots do app (mínimo 2)

### 📁 Arquivos que você vai gerar

```text
disciplinum_app/
├── android/
│   ├── app/
│   │   └── upload-keystore.jks    ← Chave de assinatura (NUNCA COMPARTILHE!)
│   └── key.properties             ← Configurações da chave
├── build/
│   └── app/
│       └── outputs/
│           └── bundle/
│               └── release/
│                   └── app-release.aab  ← Arquivo para upload
```

---

## 3. Criar Conta de Desenvolvedor

### Passo a passo

1. **Acesse**: <https://play.google.com/console>

2. **Clique em "Começar"** ou "Get Started"

3. **Escolha o tipo de conta**:
   - **Pessoal**: Para você mesmo
   - **Organização**: Para empresas (exige verificação)

   > Para começar, escolha **Pessoal** - é mais rápido.

4. **Preencha os dados**:
   - Nome do desenvolvedor (aparece na loja)
   - Endereço de e-mail de contato
   - Site (opcional)
   - Telefone

5. **Pague a taxa de $25**:
   - Aceita cartão de crédito/débito internacional
   - Pagamento único, não é assinatura

6. **Aguarde aprovação**:
   - Geralmente instantânea ou em algumas horas
   - Em casos raros, pode levar até 48h

### ⚠️ Dicas importantes

- Use um nome de desenvolvedor **profissional** (aparece publicamente)
- O e-mail de contato será **visível** para usuários
- Guarde bem suas credenciais!

---

## 4. Gerar Keystore de Assinatura

### O que é Keystore?

É uma "chave digital" que assina seu app. **IMPORTANTÍSSIMO**:

- ⚠️ Se você perder a keystore, **nunca mais poderá atualizar seu app**
- ⚠️ Faça backup em lugar seguro (Google Drive, OneDrive, etc.)
- ⚠️ Nunca compartilhe com ninguém

### Gerando a Keystore

Abra o terminal **como Administrador** e rode:

```powershell
# Navegue até a pasta android do projeto
cd c:\Users\dougl\dev\projetos\Disciplinum\disciplinum_app\android\app

# Gere a keystore
keytool -genkey -v -keystore upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### Respondendo as perguntas

O comando vai pedir várias informações:

```text
Enter keystore password: [CRIE UMA SENHA FORTE - ANOTE!]
Re-enter new password: [REPITA A SENHA]
What is your first and last name? Douglas [SEU NOME]
What is the name of your organizational unit? Development
What is the name of your organization? Disciplinum
What is the name of your City or Locality? [SUA CIDADE]
What is the name of your State or Province? [SEU ESTADO]
What is the two-letter country code? BR
Is CN=Douglas, OU=Development, O=Disciplinum, L=..., ST=..., C=BR correct? yes
```

### 📝 ANOTE ESTAS INFORMAÇÕES (MUITO IMPORTANTE!)

```text
KEYSTORE FILE: upload-keystore.jks
KEYSTORE PASSWORD: _________________ (anote!)
KEY ALIAS: upload
KEY PASSWORD: _________________ (anote!)
```

> 💡 **Dica**: Salve essas informações em um gerenciador de senhas (1Password, Bitwarden, etc.)

### Criando key.properties

Crie o arquivo `android/key.properties`:

```properties
storePassword=SUA_SENHA_AQUI
keyPassword=SUA_SENHA_AQUI
keyAlias=upload
storeFile=app/upload-keystore.jks
```

### ⚠️ Adicione ao .gitignore

Abra `android/.gitignore` e adicione:

```text
key.properties
app/upload-keystore.jks
```

---

## 5. Configurar Build de Release

### Editando android/app/build.gradle

Abra `android/app/build.gradle` e faça as seguintes alterações:

#### 1. Adicione no topo (antes de `android {`)

```groovy
// Carrega as propriedades da keystore
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

#### 2. Dentro de `android {`, adicione (antes de `buildTypes`)

```groovy
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
```

#### 3. Modifique o `buildTypes`

```groovy
buildTypes {
    release {
        signingConfig signingConfigs.release
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

### Exemplo completo do build.gradle (seção relevante)

```groovy
// No topo do arquivo, após os plugins
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    namespace "com.example.disciplinum" // Seu package name
    compileSdk 34
    
    // ... outras configs ...

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

---

## 6. Gerar o App Bundle

### Limpando build anterior

```powershell
cd c:\Users\dougl\dev\projetos\Disciplinum\disciplinum_app
flutter clean
flutter pub get
```

### Gerando o AAB (Android App Bundle)

```powershell
flutter build appbundle --release
```

### Onde encontrar o arquivo

O arquivo gerado estará em:

```text
build\app\outputs\bundle\release\app-release.aab
```

> **Tamanho esperado**: Entre 15-50 MB dependendo das dependências

### Verificando a assinatura

```powershell
# Verifique se está assinado corretamente
keytool -printcert -jarfile build\app\outputs\bundle\release\app-release.aab
```

Deve mostrar informações do certificado que você criou.

---

## 7. Criar App na Play Console

### Acessando a Play Console

1. Vá para: <https://play.google.com/console>
2. Faça login com sua conta de desenvolvedor

### Criando novo app

1. Clique em **"Criar app"**

2. **Preencha os detalhes**:
   - **Nome do app**: Disciplinum
   - **Idioma padrão**: Português (Brasil)
   - **Tipo**: App (não Jogo)
   - **Gratuito ou Pago**: Gratuito (com compras no app)

3. **Declarações**:
   - ✅ Diretrizes de conteúdo do desenvolvedor
   - ✅ Leis de exportação dos EUA

4. Clique em **"Criar app"**

### Preenchendo informações obrigatórias

Após criar, você precisa preencher várias seções:

#### 📝 Ficha do app (Store Listing)

- **Título**: Disciplinum
- **Descrição breve** (80 chars):

  ```text
  Controle seus hábitos, bloqueie distrações e conquiste medalhas!
  ```

- **Descrição completa** (4000 chars):

  ```text
  Disciplinum é seu companheiro de autocontrole e disciplina pessoal.
  
  🎯 MÓDULOS DE AUTOCONTROLE:
  
  • Pare de Fumar: Rastrei tempo limpo e dinheiro economizado
  • Compulsão Alimentar: Acompanhe e registre refeições
  • Desafio da Economia: Controle e gere o hábito de poupar
  
  💎 EXPERIÊNCIA PREMIUM:
  
  • Design moderno com efeitos Neon e temas Claro/Escuro
  • Estatísticas de calendário mensais para cada módulo
  • Personalização de notificações e fases motivacionais
  
  🔒 PRIVACIDADE E DADOS:
  
  • Login seguro com e-mail 
  • Sincronização em nuvem e histórico preservado
  
  Comece sua jornada de disciplina hoje!
  ```

#### 🖼️ Recursos gráficos

| Recurso | Tamanho | Obrigatório |
| --------- | --------- | ------------- |
| Ícone | 512x512 PNG | ✅ Sim |
| Feature Graphic | 1024x500 PNG | ✅ Sim |
| Screenshots (telefone) | Mín. 2, 16:9 ou 9:16 | ✅ Sim |
| Screenshots (tablet) | Mín. 1 | Opcional |

> 💡 **Dica**: Use o Figma ou Canva para criar a Feature Graphic

#### 🔒 Política de privacidade

Você precisa de uma URL com política de privacidade. Opções:

- Criar uma página no GitHub Pages (grátis)
- Usar serviços como TermsFeed ou Iubenda
- Criar uma página simples em qualquer hospedagem

#### 📊 Classificação de conteúdo

1. Vá em **Política** → **Classificação de conteúdo**
2. Preencha o questionário (perguntas sobre violência, conteúdo sexual, etc.)
3. Para Disciplinum, provavelmente será **Livre** ou **10+**

#### 💰 Configuração de monetização

1. Vá em **Monetização** → **Produtos no app**
2. Configure depois de fazer o primeiro upload (Seção 9)

---

## 8. Upload para Internal Testing

### Configurando o Internal Testing

1. No menu lateral, vá em **Teste** → **Teste interno**

2. Clique em **"Criar nova versão"**

3. **Google Play App Signing**:
   - Na primeira vez, você precisa aceitar o "App Signing by Google Play"
   - Isso é **obrigatório** e **recomendado**
   - O Google gerencia a chave de assinatura final

4. **Upload do AAB**:
   - Clique em "Fazer upload"
   - Selecione o arquivo `app-release.aab`
   - Aguarde o processamento

5. **Notas da versão**:

   ```text
   Versão 0.1.0 - Teste Interno
   - Primeira versão para testes internos
   - Funcionalidades principais implementadas
   - Teste de compras in-app
   ```

6. Clique em **"Salvar"**, depois **"Revisar versão"**

7. Clique em **"Iniciar lançamento para Teste interno"**

### ⏱️ Tempo de disponibilização

- **Internal Testing**: Geralmente **instantâneo** ou até 1 hora
- Closed/Open Testing: 1-3 dias
- Production: 3-7 dias (primeira vez pode ser mais)

---

## 9. Configurar In-App Purchase

### Criando o produto

1. Vá em **Monetização** → **Produtos no app** → **Produtos gerenciados**

2. Clique em **"Criar produto"**

3. **Preencha os detalhes**:

   | Campo | Valor |
   | ------- | ------- |
   | ID do produto | `dark_mode_unlock` |
   | Nome | Modo Escuro Premium |
   | Descrição | Desbloqueie o modo escuro permanentemente |
   | Preço | R$ 9,99 (ou o valor que preferir) |

   > **Dica:** O projeto possui outros produtos no código que você precisará criar com ID idênticos: `ad_free_unlock`, `ad_free_lite`, `custom_notifications_unlock`, `motivation_phrases_unlock`.

4. Clique em **"Salvar"** e depois **"Ativar"**

### ⚠️ Importante sobre o ID do produto

O ID do produto (`dark_mode_unlock`) deve ser **exatamente igual** ao que está no código do app:

```dart
// No seu iap_service.dart
static const String productIdDarkMode = 'dark_mode_unlock';
```

---

## 10. Adicionar Testadores

### Configurando lista de testadores

1. Vá em **Teste** → **Teste interno**

2. Na aba **"Testadores"**, clique em **"Criar lista de e-mails"**

3. **Nome da lista**: "Equipe de Teste"

4. **Adicione e-mails**:
   - Seu próprio e-mail
   - E-mails de amigos/família que vão testar

   > ⚠️ Os e-mails devem ser contas Google (Gmail)

5. Clique em **"Salvar alterações"**

### Compartilhando o link de teste

1. Na página de Teste interno, copie o **"Link de convite"**

2. Envie para seus testadores

3. Eles precisam:
   - Clicar no link
   - Aceitar o convite
   - Baixar o app pela Play Store

---

## 11. Testar Compras In-App

### Configurando testadores de licença

Para testar compras sem cobrar de verdade:

1. Vá em **Configurações** → **Testadores de licença**

2. Adicione os e-mails dos testadores

3. Esses usuários podem fazer "compras de teste" sem serem cobrados

### Como funciona o teste

1. Testador baixa o app via link de teste
2. Ao tentar comprar, aparece **"Este é um item de teste"**
3. A compra é processada normalmente, mas **não cobra**
4. Você pode testar todo o fluxo de IAP

### Verificando compras

1. Vá em **Monetização** → **Estatísticas de monetização**
2. Você pode ver as compras de teste realizadas
3. Também pode reverter compras de teste para testar novamente

---

## 12. Checklist Final

### ✅ Antes de começar

- [ ] Conta Google pronta
- [ ] $25 disponíveis para pagamento
- [ ] App funcionando localmente

### ✅ Configuração inicial

- [ ] Conta de desenvolvedor criada
- [ ] Keystore gerada e backupeada
- [ ] `key.properties` criado
- [ ] `build.gradle` configurado
- [ ] Arquivos sensíveis no `.gitignore`

### ✅ Build

- [ ] `flutter clean` executado
- [ ] `flutter build appbundle --release` com sucesso
- [ ] AAB gerado e verificado

### ✅ Play Console

- [ ] App criado na Play Console
- [ ] Informações da loja preenchidas
- [ ] Recursos gráficos enviados
- [ ] Classificação de conteúdo definida
- [ ] Política de privacidade adicionada

### ✅ Internal Testing

- [ ] AAB uploaded
- [ ] Testadores adicionados
- [ ] Link de convite compartilhado

### ✅ In-App Purchase

- [ ] Produto criado e ativado
- [ ] ID do produto igual ao código
- [ ] Testadores de licença configurados

---

## 13. Problemas Comuns

### ❌ "Keystore was tampered with, or password was incorrect"

**Causa**: Senha incorreta no `key.properties`

**Solução**: Verifique se a senha está exatamente como você digitou ao criar a keystore

---

### ❌ "App not published yet"

**Causa**: O app ainda não está disponível na faixa de teste

**Solução**: Aguarde alguns minutos após publicar - Internal Testing geralmente leva até 1 hora

---

### ❌ "License check failed"

**Causa**: A conta de teste não está na lista de testadores de licença

**Solução**: Adicione o e-mail em Configurações → Testadores de licença

---

### ❌ "Item not found" (In-App Purchase)

**Causa**: O ID do produto não coincide ou o produto não está ativo

**Solução**:

1. Verifique se o ID é exatamente igual no código e na Play Console
2. Certifique-se de que o produto está "Ativo"
3. Aguarde ~1 hora após criar o produto

---

### ❌ Build falha com erro de ProGuard

**Causa**: Regras de ProGuard faltando

**Solução**: Crie `android/app/proguard-rules.pro`:

```proguard
-keep class io.flutter.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
```

---

## 📚 Links Úteis

- [Google Play Console](https://play.google.com/console)
- [Documentação Flutter - Build Release](https://docs.flutter.dev/deployment/android)
- [Documentação In-App Purchase](https://pub.dev/packages/in_app_purchase)
- [Gerador de Política de Privacidade](https://www.termsfeed.com/privacy-policy-generator/)

---

## 🎉 Parabéns

Se você seguiu todos os passos, seu app está pronto para testes na Google Play Store!

**Próximos passos sugeridos**:

1. Teste bem no Internal Testing
2. Corrija bugs encontrados
3. Evolua para Closed Testing (mais testadores)
4. Quando estiver confiante, lance em Production!

---

> **Guardou a keystore em lugar seguro?** Este é o lembrete mais importante de todo o guia! 🔐

---

Guia gerado originalmente em Dezembro 2024 (Revisado em Março 2026) para o app Disciplinum
