-- Migration: Correção de Search Path - ASSINATURA CORRIGIDA
-- Description: Corrige search_path mantendo assinatura exata das funções
-- Created: 2026-04-02
-- NOTA: A função ensure_schema_version retorna TRIGGER (não void!)

-- ============================================
-- 1. REMOVER TRIGGERS DEPENDENTES PRIMEIRO
-- ============================================

-- Remover todos os triggers que dependem de ensure_schema_version
DROP TRIGGER IF EXISTS ensure_smoking_schema_version ON smoking_gamification_states;
DROP TRIGGER IF EXISTS ensure_focus_schema_version ON focus_gamification_states;
DROP TRIGGER IF EXISTS ensure_procrastination_schema_version ON procrastination_gamification_states;
DROP TRIGGER IF EXISTS ensure_spending_schema_version ON spending_gamification_states;
DROP TRIGGER IF EXISTS ensure_diet_schema_version ON diet_gamification_states;
DROP TRIGGER IF EXISTS ensure_money_saving_schema_version ON money_saving_gamification_states;
DROP TRIGGER IF EXISTS ensure_adult_content_schema_version ON adult_content_gamification_states;
DROP TRIGGER IF EXISTS ensure_binge_eating_schema_version ON binge_eating_gamification_states;
DROP TRIGGER IF EXISTS ensure_reading_schema_version ON reading_gamification_states;

-- Remover trigger que depende de update_module_status_last_updated
DROP TRIGGER IF EXISTS update_user_module_status_last_updated ON user_module_status;

-- Remover triggers que dependem de update_module_status_updated_at
DROP TRIGGER IF EXISTS update_module_status_updated_at_trigger ON user_module_status;
DROP TRIGGER IF EXISTS update_user_module_status_updated_at ON user_module_status;

-- Remover TODOS os triggers que dependem de update_updated_at_column
DROP TRIGGER IF EXISTS set_updated_at ON auth.users;
DROP TRIGGER IF EXISTS update_user_blocked_apps_updated_at ON user_blocked_apps;
DROP TRIGGER IF EXISTS update_user_blocking_rules_updated_at ON user_blocking_rules;
DROP TRIGGER IF EXISTS update_user_retention_metrics_updated_at ON user_retention_metrics;
DROP TRIGGER IF EXISTS update_smoking_gamification_states_updated_at ON smoking_gamification_states;
DROP TRIGGER IF EXISTS update_focus_gamification_states_updated_at ON focus_gamification_states;
DROP TRIGGER IF EXISTS update_procrastination_gamification_states_updated_at ON procrastination_gamification_states;
DROP TRIGGER IF EXISTS update_spending_gamification_states_updated_at ON spending_gamification_states;
DROP TRIGGER IF EXISTS update_diet_gamification_states_updated_at ON diet_gamification_states;
DROP TRIGGER IF EXISTS update_money_saving_gamification_updated_at ON money_saving_gamification_states;
DROP TRIGGER IF EXISTS update_adult_content_gamification_states_updated_at ON adult_content_gamification_states;
DROP TRIGGER IF EXISTS update_binge_eating_gamification_states_updated_at ON binge_eating_gamification_states;
DROP TRIGGER IF EXISTS update_reading_gamification_states_updated_at ON reading_gamification_states;

-- ============================================
-- 2. REMOVER FUNÇÕES (AGORA SEM DEPENDÊNCIAS)
-- ============================================

DROP FUNCTION IF EXISTS ensure_schema_version();
DROP FUNCTION IF EXISTS update_module_status_last_updated();
DROP FUNCTION IF EXISTS update_module_status_updated_at();
DROP FUNCTION IF EXISTS update_updated_at_column();

-- ============================================
-- 3. RECRIAR FUNÇÕES COM SEARCH_PATH SEGURO
-- ============================================

-- 3.1 ensure_schema_version - RETORNA TRIGGER (não void!)
CREATE OR REPLACE FUNCTION ensure_schema_version()
RETURNS TRIGGER AS $$
BEGIN
    -- Se state_data não tiver _schema_version, adicionar versão 1
    IF NEW.state_data->>'_schema_version' IS NULL THEN
        NEW.state_data = jsonb_set(
            COALESCE(NEW.state_data, '{}'::jsonb),
            '{_schema_version}',
            '1'::jsonb,
            true
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public;

-- 3.2 update_module_status_last_updated
CREATE OR REPLACE FUNCTION update_module_status_last_updated()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_updated = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public;

-- 3.3 update_module_status_updated_at
CREATE OR REPLACE FUNCTION update_module_status_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public;

-- 3.4 update_updated_at_column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public;

-- ============================================
-- 4. RECRIAR TRIGGERS
-- ============================================

-- Triggers de schema_version para todas as tabelas de gamificação
CREATE TRIGGER ensure_smoking_schema_version
    BEFORE INSERT OR UPDATE ON smoking_gamification_states
    FOR EACH ROW EXECUTE FUNCTION ensure_schema_version();

CREATE TRIGGER ensure_focus_schema_version
    BEFORE INSERT OR UPDATE ON focus_gamification_states
    FOR EACH ROW EXECUTE FUNCTION ensure_schema_version();

CREATE TRIGGER ensure_procrastination_schema_version
    BEFORE INSERT OR UPDATE ON procrastination_gamification_states
    FOR EACH ROW EXECUTE FUNCTION ensure_schema_version();

CREATE TRIGGER ensure_spending_schema_version
    BEFORE INSERT OR UPDATE ON spending_gamification_states
    FOR EACH ROW EXECUTE FUNCTION ensure_schema_version();

CREATE TRIGGER ensure_diet_schema_version
    BEFORE INSERT OR UPDATE ON diet_gamification_states
    FOR EACH ROW EXECUTE FUNCTION ensure_schema_version();

CREATE TRIGGER ensure_money_saving_schema_version
    BEFORE INSERT OR UPDATE ON money_saving_gamification_states
    FOR EACH ROW EXECUTE FUNCTION ensure_schema_version();

CREATE TRIGGER ensure_adult_content_schema_version
    BEFORE INSERT OR UPDATE ON adult_content_gamification_states
    FOR EACH ROW EXECUTE FUNCTION ensure_schema_version();

CREATE TRIGGER ensure_binge_eating_schema_version
    BEFORE INSERT OR UPDATE ON binge_eating_gamification_states
    FOR EACH ROW EXECUTE FUNCTION ensure_schema_version();

CREATE TRIGGER ensure_reading_schema_version
    BEFORE INSERT OR UPDATE ON reading_gamification_states
    FOR EACH ROW EXECUTE FUNCTION ensure_schema_version();

-- Trigger para user_module_status
DROP TRIGGER IF EXISTS update_module_status_updated_at_trigger ON user_module_status;
CREATE TRIGGER update_module_status_updated_at_trigger
    BEFORE UPDATE ON user_module_status
    FOR EACH ROW EXECUTE FUNCTION update_module_status_updated_at();

-- Triggers de updated_at para outras tabelas
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON auth.users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_blocked_apps_updated_at
    BEFORE UPDATE ON user_blocked_apps
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_blocking_rules_updated_at
    BEFORE UPDATE ON user_blocking_rules
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_retention_metrics_updated_at
    BEFORE UPDATE ON user_retention_metrics
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_smoking_gamification_states_updated_at
    BEFORE UPDATE ON smoking_gamification_states
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_focus_gamification_states_updated_at
    BEFORE UPDATE ON focus_gamification_states
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_procrastination_gamification_states_updated_at
    BEFORE UPDATE ON procrastination_gamification_states
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_spending_gamification_states_updated_at
    BEFORE UPDATE ON spending_gamification_states
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_diet_gamification_states_updated_at
    BEFORE UPDATE ON diet_gamification_states
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_money_saving_gamification_updated_at
    BEFORE UPDATE ON money_saving_gamification_states
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_adult_content_gamification_states_updated_at
    BEFORE UPDATE ON adult_content_gamification_states
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_binge_eating_gamification_states_updated_at
    BEFORE UPDATE ON binge_eating_gamification_states
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reading_gamification_states_updated_at
    BEFORE UPDATE ON reading_gamification_states
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger para last_updated (se a coluna existir)
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'user_module_status' 
        AND column_name = 'last_updated'
    ) THEN
        DROP TRIGGER IF EXISTS update_module_status_last_updated_trigger ON user_module_status;
        CREATE TRIGGER update_module_status_last_updated_trigger
            BEFORE UPDATE ON user_module_status
            FOR EACH ROW EXECUTE FUNCTION update_module_status_last_updated();
    END IF;
END $$;

-- ============================================
-- 5. POLÍTICAS RLS PARA TABELAS DE SENHAS
-- ============================================

ALTER TABLE IF EXISTS common_compromised_passwords ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS password_validation_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow read access to authenticated users" ON common_compromised_passwords;
DROP POLICY IF EXISTS "Allow insert for service role only" ON common_compromised_passwords;
DROP POLICY IF EXISTS "Allow update for service role only" ON common_compromised_passwords;
DROP POLICY IF EXISTS "Allow delete for service role only" ON common_compromised_passwords;

DROP POLICY IF EXISTS "Users can only see their own password validation logs" ON password_validation_logs;
DROP POLICY IF EXISTS "Users can only insert their own password validation logs" ON password_validation_logs;
DROP POLICY IF EXISTS "Service role can manage all password validation logs" ON password_validation_logs;

CREATE POLICY "Allow read access to authenticated users" ON common_compromised_passwords
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow insert for service role only" ON common_compromised_passwords
  FOR INSERT TO service_role WITH CHECK (true);

CREATE POLICY "Allow update for service role only" ON common_compromised_passwords
  FOR UPDATE TO service_role USING (true);

CREATE POLICY "Allow delete for service role only" ON common_compromised_passwords
  FOR DELETE TO service_role USING (true);

CREATE POLICY "Users can only see their own password validation logs" ON password_validation_logs
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can only insert their own password validation logs" ON password_validation_logs
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Service role can manage all password validation logs" ON password_validation_logs
  FOR ALL TO service_role USING (true);

-- ============================================
-- 4. LOG DAS CORREÇÕES
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'CORREÇÕES DE SEGURANÇA APLICADAS';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
    RAISE NOTICE 'Funções corrigidas com search_path seguro:';
    RAISE NOTICE '  - ensure_schema_version';
    RAISE NOTICE '  - update_module_status_last_updated';
    RAISE NOTICE '  - update_module_status_updated_at';
    RAISE NOTICE '  - update_updated_at_column';
    RAISE NOTICE '';
    RAISE NOTICE 'Políticas RLS criadas para:';
    RAISE NOTICE '  - common_compromised_passwords';
    RAISE NOTICE '  - password_validation_logs';
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
END $$;
