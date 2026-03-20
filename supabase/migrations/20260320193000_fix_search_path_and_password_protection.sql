-- CORREÇÃO DE SEARCH_PATH EM FUNÇÕES E HABILITAR PROTEÇÃO DE SENHAS
-- Corrigir warnings de segurança do painel do Supabase

-- 1. Remover triggers que dependem das funções primeiro
-- Triggers que usam update_updated_at_column
DROP TRIGGER IF EXISTS update_user_blocked_apps_updated_at ON user_blocked_apps;
DROP TRIGGER IF EXISTS update_user_blocking_rules_updated_at ON user_blocking_rules;
DROP TRIGGER IF EXISTS update_user_retention_metrics_updated_at ON user_retention_metrics;
DROP TRIGGER IF EXISTS set_updated_at ON auth.users;
DROP TRIGGER IF EXISTS update_user_module_status_updated_at ON user_module_status;
DROP TRIGGER IF EXISTS update_module_status_updated_at_trigger ON user_module_status;
DROP TRIGGER IF EXISTS update_user_module_status_activity_date ON user_module_status;

-- 2. Agora pode remover as funções com segurança
DROP FUNCTION IF EXISTS update_updated_at_column();
DROP FUNCTION IF EXISTS update_module_status_updated_at();
DROP FUNCTION IF EXISTS update_module_status_activity_date();

-- 3. Recriar funções com search_path explícito e seguro

-- Função update_updated_at_column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public;

-- Função update_module_status_updated_at
CREATE OR REPLACE FUNCTION update_module_status_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public;

-- Função update_module_status_activity_date
CREATE OR REPLACE FUNCTION update_module_status_activity_date()
RETURNS TRIGGER AS $$
BEGIN
    -- Monitora apenas mudanças reais em campos que existem no Dart
    IF (
        OLD.consecutive_days IS DISTINCT FROM NEW.consecutive_days OR
        OLD.max_medal IS DISTINCT FROM NEW.max_medal OR
        OLD.is_active IS DISTINCT FROM NEW.is_active
    ) THEN
        NEW.last_activity_date = NOW();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public;

-- 4. Recriar triggers que usam essas funções
-- Trigger para auth.users
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON auth.users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger para user_module_status
CREATE TRIGGER update_module_status_updated_at_trigger
    BEFORE UPDATE ON user_module_status
    FOR EACH ROW EXECUTE FUNCTION update_module_status_updated_at();

-- Trigger para activity date
CREATE TRIGGER update_user_module_status_activity_date 
    BEFORE UPDATE ON user_module_status 
    FOR EACH ROW EXECUTE FUNCTION update_module_status_activity_date();

-- Recriar triggers para outras tabelas que usam update_updated_at_column
CREATE TRIGGER update_user_blocked_apps_updated_at
    BEFORE UPDATE ON user_blocked_apps
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_blocking_rules_updated_at
    BEFORE UPDATE ON user_blocking_rules
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_retention_metrics_updated_at
    BEFORE UPDATE ON user_retention_metrics
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 5. Habilitar proteção de senhas comprometidas via SQL
-- Nota: Esta configuração pode precisar ser feita via painel do Supabase também
-- Mas vamos tentar via SQL primeiro

-- Verificar configuração atual do auth
DO $$
BEGIN
    -- Tentar habilitar leaked password protection
    -- Esta configuração pode não estar disponível via SQL em todas as versões
    RAISE NOTICE 'Para habilitar proteção de senhas comprometidas, vá em:';
    RAISE NOTICE '1. Dashboard do Supabase > Authentication > Settings';
    RAISE NOTICE '2. Enable "Leaked password protection"';
    RAISE NOTICE '3. Configure HaveIBeenPwned.org integration';
END $$;

-- 6. Log das correções
DO $$
BEGIN
    RAISE NOTICE 'Funções corrigidas com search_path seguro: update_updated_at_column, update_module_status_updated_at, update_module_status_activity_date';
    RAISE NOTICE 'Triggers recriados com funções seguras';
    RAISE NOTICE 'Proteção de senhas comprometidas: configure via painel do Supabase';
END $$;
