-- Migration: 20260929153500_secure_entitlements_and_cleanup_password_logs.sql
-- Description: Blindagem da tabela user_entitlements contra auto-concessao de licencas
--              e remocao de tabelas/funcoes legadas de log de senhas e hashes inseguros.

-- ==============================================================================
-- 1. BLINDAGEM DE USER_ENTITLEMENTS (CONTROLE DE ACESSO / IDOR / BOLA)
-- ==============================================================================

-- Garante que RLS esta ativado
ALTER TABLE IF EXISTS public.user_entitlements ENABLE ROW LEVEL SECURITY;

-- Remove politicas permissivas que permitiam ao client inserir, alterar ou deletar entitlements
DROP POLICY IF EXISTS "Users can insert own entitlements" ON public.user_entitlements;
DROP POLICY IF EXISTS "Users can update own entitlements" ON public.user_entitlements;
DROP POLICY IF EXISTS "Users can delete own entitlements" ON public.user_entitlements;
DROP POLICY IF EXISTS user_entitlements_insert ON public.user_entitlements;
DROP POLICY IF EXISTS user_entitlements_update ON public.user_entitlements;
DROP POLICY IF EXISTS user_entitlements_delete ON public.user_entitlements;
DROP POLICY IF EXISTS user_entitlements_select ON public.user_entitlements;

-- Apenas leitura e permitida para usuarios autenticados consultarem seus proprios direitos.
-- Insercoes e atualizacoes devem ser feitas exclusivamente via backend (service_role ou webhooks confiaveis).
CREATE POLICY user_entitlements_select ON public.user_entitlements
  FOR SELECT TO authenticated
  USING ((select auth.uid()) = user_id);

-- Revoga privilegios diretos de escrita para roles publicas e anonimas
REVOKE INSERT, UPDATE, DELETE ON public.user_entitlements FROM authenticated;
REVOKE ALL ON public.user_entitlements FROM anon;

-- ==============================================================================
-- 2. REMOCAO DE FUNCOES E TABELAS LEGADAS DE SENHAS INSEGURAS
-- ==============================================================================

-- Remove a funcao RPC com privilege escalation (SECURITY DEFINER sem controle de admin)
DROP FUNCTION IF EXISTS public.add_compromised_password_safe(text);

-- Remove as funcoes RPC que recebiam senha em texto puro e geravam hashes SHA-256 puros
DROP FUNCTION IF EXISTS public.validate_user_password_safe(uuid, text);
DROP FUNCTION IF EXISTS public.verify_password_strength(text);

-- Remove a tabela que armazenava logs com hashes SHA-256 de senhas digitadas
DROP TABLE IF EXISTS public.password_validation_logs CASCADE;

-- Remove a tabela legada de senhas fracas misturadas com MD5
DROP TABLE IF EXISTS public.common_compromised_passwords CASCADE;
