# Guia de Renovação de ID do AdMob (Por Inatividade)

## O Problema: ID "Expirado"

É comum durante o ciclo de desenvolvimento que o tempo até o lançamento se alongue. O Google AdMob tem uma política em que **blocos de anúncios que ficam 6 meses sem receber impressões são automaticamente marcados como "Inativos"**. 

Uma vez inativos por falta de uso, **não é possível reativá-los** clicando em um botão. 

No entanto, isso não é uma punição ou banimento da sua conta. É apenas uma limpeza de rotina nos servidores do Google.

---

## O que fazer DURANTE o desenvolvimento (Agora)

> [!IMPORTANT]
> **Não faça nada.** Continue usando o aplicativo exatamente como está.

Durante o desenvolvimento, o seu aplicativo **já está configurado para exibir Anúncios de Teste do Google** (os IDs genéricos que começam com `ca-app-pub-3940256099942544/...`). Isso é extremamente recomendável e obrigatório para evitar que o Google bana a sua conta por tráfego inválido (você mesmo clicando ou visualizando os próprios anúncios antes do app estar nas lojas). Os IDs de teste **nunca expiram**.

---

## O que fazer ANTES DO LANÇAMENTO (Produção)

Quando você estiver prestes a compilar a versão final que irá para a Google Play Store, você precisará gerar novos IDs de bloco de anúncios para substituir os antigos inativos.

Siga o passo a passo completo:

### Passo 1: Arquivar o Bloco Antigo
1. Acesse o seu painel do [Google AdMob](https://admob.google.com/).
2. No menu lateral, clique em **Aplicativos** e selecione o `Disciplinum`.
3. Clique em **Blocos de Anúncios**.
4. Você verá o seu antigo bloco de anúncios (provavelmente com um ícone de alerta indicando que está Inativo).
5. Selecione a caixa de seleção ao lado dele e, no menu superior, clique em **Arquivar** (isso limpa o painel para não gerar confusão).

### Passo 2: Criar o Novo Bloco
1. Ainda na tela de **Blocos de Anúncios**, clique no botão azul **Adicionar bloco de anúncios**.
2. Escolha o formato desejado. Por exemplo, para anúncios de rodapé, escolha **Banner**.
3. Dê um nome claro para o bloco (ex: `Banner - Tela de Configurações V2` ou `Disciplinum_Banner_Producao`).
4. Clique em **Criar bloco de anúncios**.

### Passo 3: Copiar e Inserir no Aplicativo
1. O AdMob exibirá uma tela de sucesso com dois IDs. O primeiro é o **ID do Aplicativo** (esse geralmente não muda, mas verifique se continua o mesmo) e o segundo é o **ID do Bloco de Anúncios** recém-criado (no formato `ca-app-pub-XXXXXXXXX/YYYYYYYYY`).
2. Copie o **ID do Bloco de Anúncios**.
3. No seu projeto Flutter, abra os arquivos onde os seus segredos de produção ficam armazenados (geralmente `secrets/prod.json` ou as variáveis no seu arquivo `.env`).
4. Substitua o ID antigo pelo ID novo.
5. Gere o pacote de lançamento (AAB/APK) apontando para esse arquivo de configuração de produção.

> [!TIP]
> **Atenção:** Novos blocos de anúncio recém-criados podem demorar de **1 a 2 horas** para começarem a exibir anúncios reais. Se o app for aberto logo após a criação, o bloco pode ficar em branco temporariamente. Isso é normal e se estabiliza assim que os servidores do Google propagam o novo ID.
