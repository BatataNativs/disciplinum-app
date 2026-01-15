# Solução de Problemas: Erro ao Criar ou Logar Conta

O erro `Database error saving new user` que está ocorrendo no app é um erro **servidor-side** do Supabase. Ele acontece quando um "Trigger" (gatilho) no banco de dados falha ao tentar executar uma ação após um novo usuário ser criado na tabela de autenticação (`auth.users`).

Isso é extremamente comum após implementar a funcionalidade de exclusão de conta, pois muitas vezes o usuário é removido da autenticação (`auth.users`) mas seus dados permanecem na tabela pública (`public.users`), causando conflito ao tentar criar a conta novamente.

## Causa Provável 1: Registro Órfão (Mais Provável)

Se a sua função `delete_user` removeu o usuário apenas da tabela de autenticação, mas não da tabela `public.users`, agora existe um "registro órfão". Quando você tenta criar a conta novamente com o mesmo email, o Trigger `handle_new_user` tenta inserir um novo registro em `public.users`, mas falha porque já existe um registro lá (provavelmente violando uma regra de unicidade de email ou ID, dependendo de como o trigger foi feito).

### Como Corrigir

Acesse o **SQL Editor** do seu painel Supabase e execute os seguintes comandos para investigar e limpar:

```sql
-- 1. Verifique se o usuário existe na tabela pública mas NÃO na tabela de auth
SELECT * FROM public.users 
WHERE id NOT IN (SELECT id FROM auth.users);

-- 2. Se encontrar registros órfãos, você pode deletá-los (CUIDADO: isso apaga dados do usuário)
DELETE FROM public.users 
WHERE id NOT IN (SELECT id FROM auth.users);
```

### Prevenção Futura (Corrigir a função de delete)

Para evitar que isso aconteça novamente, sua função `delete_user` ou a estrutura do banco deve garantir que tudo seja apagado em cascata.

**Opção A: Configurar Foreign Key com CASCADE (Recomendado)**
Se a tabela `public.users` tiver uma chave estrangeira para `auth.users`, configure-a com `ON DELETE CASCADE`. Assim, ao deletar de `auth`, o `public` apaga sozinho.

```sql
-- Exemplo de como alterar a tabela para adicionar CASCADE
ALTER TABLE public.users
DROP CONSTRAINT IF EXISTS users_id_fkey,
ADD CONSTRAINT users_id_fkey
FOREIGN KEY (id)
REFERENCES auth.users(id)
ON DELETE CASCADE;
```

**Opção B: Atualizar a função RPC delete_user**
Se você usa uma função RPC para deletar, garanta que ela apague ambos.

```sql
CREATE OR REPLACE FUNCTION delete_user()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Apaga da tabela pública primeiro (se não tiver cascade)
  DELETE FROM public.users WHERE id = auth.uid();
  
  -- Apaga da tabela de autenticação
  DELETE FROM auth.users WHERE id = auth.uid();
END;
$$;
```

## Causa Provável 2: Permissões do Trigger

Se você alterou recentemente a função `handle_new_user` (ou similar) que é chamada pelo trigger de criação de usuário, verifique se ela está definida como `SECURITY DEFINER`.

Se ela for `SECURITY INVOKER` (padrão), ela tenta rodar com as permissões do usuário que está sendo criado (que ainda não tem permissão de inserir na tabela `public.users` se o RLS estiver ativo e restrito).

### Como Corrigir

```sql
-- Garanta que a função do trigger tenha SECURITY DEFINER
ALTER FUNCTION public.handle_new_user() SECURITY DEFINER;
```

## Resumo da Ação Necessária

1.  Abra o Supabase Dashboard.
2.  Vá em **SQL Editor**.
3.  Rode o script de limpeza de usuários órfãos.
4.  Rode o script para adicionar `ON DELETE CASCADE` na foreign key para evitar recorrência.
