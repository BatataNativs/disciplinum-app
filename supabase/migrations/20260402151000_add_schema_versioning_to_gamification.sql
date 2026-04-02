-- Migration: Add JSONB Schema Versioning
-- Description: Adiciona campo _schema_version ao state_data de todas as tabelas de gamificação
-- Created: 2026-04-02

-- ============================================
-- 1. ATUALIZAR state_data EXISTENTE COM _schema_version
-- ============================================

-- Smoking
UPDATE smoking_gamification_states 
SET state_data = jsonb_set(
    COALESCE(state_data, '{}'::jsonb),
    '{_schema_version}',
    '1'::jsonb,
    true
)
WHERE state_data->>'_schema_version' IS NULL;

-- Focus
UPDATE focus_gamification_states 
SET state_data = jsonb_set(
    COALESCE(state_data, '{}'::jsonb),
    '{_schema_version}',
    '1'::jsonb,
    true
)
WHERE state_data->>'_schema_version' IS NULL;

-- Procrastination
UPDATE procrastination_gamification_states 
SET state_data = jsonb_set(
    COALESCE(state_data, '{}'::jsonb),
    '{_schema_version}',
    '1'::jsonb,
    true
)
WHERE state_data->>'_schema_version' IS NULL;

-- Spending
UPDATE spending_gamification_states 
SET state_data = jsonb_set(
    COALESCE(state_data, '{}'::jsonb),
    '{_schema_version}',
    '1'::jsonb,
    true
)
WHERE state_data->>'_schema_version' IS NULL;

-- Diet
UPDATE diet_gamification_states 
SET state_data = jsonb_set(
    COALESCE(state_data, '{}'::jsonb),
    '{_schema_version}',
    '1'::jsonb,
    true
)
WHERE state_data->>'_schema_version' IS NULL;

-- Money Saving
UPDATE money_saving_gamification_states 
SET state_data = jsonb_set(
    COALESCE(state_data, '{}'::jsonb),
    '{_schema_version}',
    '1'::jsonb,
    true
)
WHERE state_data->>'_schema_version' IS NULL;

-- Adult Content
UPDATE adult_content_gamification_states 
SET state_data = jsonb_set(
    COALESCE(state_data, '{}'::jsonb),
    '{_schema_version}',
    '1'::jsonb,
    true
)
WHERE state_data->>'_schema_version' IS NULL;

-- Binge Eating
UPDATE binge_eating_gamification_states 
SET state_data = jsonb_set(
    COALESCE(state_data, '{}'::jsonb),
    '{_schema_version}',
    '1'::jsonb,
    true
)
WHERE state_data->>'_schema_version' IS NULL;

-- Reading
UPDATE reading_gamification_states 
SET state_data = jsonb_set(
    COALESCE(state_data, '{}'::jsonb),
    '{_schema_version}',
    '1'::jsonb,
    true
)
WHERE state_data->>'_schema_version' IS NULL;

-- ============================================
-- 2. CRIAR FUNÇÃO HELPER PARA VERSIONAMENTO
-- ============================================

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
$$ LANGUAGE plpgsql;

-- ============================================
-- 3. APLICAR TRIGGER DE VERSIONAMENTO EM TODAS AS TABELAS
-- ============================================

-- Smoking
DROP TRIGGER IF EXISTS ensure_smoking_schema_version ON smoking_gamification_states;
CREATE TRIGGER ensure_smoking_schema_version
    BEFORE INSERT OR UPDATE ON smoking_gamification_states
    FOR EACH ROW
    EXECUTE FUNCTION ensure_schema_version();

-- Focus
DROP TRIGGER IF EXISTS ensure_focus_schema_version ON focus_gamification_states;
CREATE TRIGGER ensure_focus_schema_version
    BEFORE INSERT OR UPDATE ON focus_gamification_states
    FOR EACH ROW
    EXECUTE FUNCTION ensure_schema_version();

-- Procrastination
DROP TRIGGER IF EXISTS ensure_procrastination_schema_version ON procrastination_gamification_states;
CREATE TRIGGER ensure_procrastination_schema_version
    BEFORE INSERT OR UPDATE ON procrastination_gamification_states
    FOR EACH ROW
    EXECUTE FUNCTION ensure_schema_version();

-- Spending
DROP TRIGGER IF EXISTS ensure_spending_schema_version ON spending_gamification_states;
CREATE TRIGGER ensure_spending_schema_version
    BEFORE INSERT OR UPDATE ON spending_gamification_states
    FOR EACH ROW
    EXECUTE FUNCTION ensure_schema_version();

-- Diet
DROP TRIGGER IF EXISTS ensure_diet_schema_version ON diet_gamification_states;
CREATE TRIGGER ensure_diet_schema_version
    BEFORE INSERT OR UPDATE ON diet_gamification_states
    FOR EACH ROW
    EXECUTE FUNCTION ensure_schema_version();

-- Money Saving
DROP TRIGGER IF EXISTS ensure_money_saving_schema_version ON money_saving_gamification_states;
CREATE TRIGGER ensure_money_saving_schema_version
    BEFORE INSERT OR UPDATE ON money_saving_gamification_states
    FOR EACH ROW
    EXECUTE FUNCTION ensure_schema_version();

-- Adult Content
DROP TRIGGER IF EXISTS ensure_adult_content_schema_version ON adult_content_gamification_states;
CREATE TRIGGER ensure_adult_content_schema_version
    BEFORE INSERT OR UPDATE ON adult_content_gamification_states
    FOR EACH ROW
    EXECUTE FUNCTION ensure_schema_version();

-- Binge Eating
DROP TRIGGER IF EXISTS ensure_binge_eating_schema_version ON binge_eating_gamification_states;
CREATE TRIGGER ensure_binge_eating_schema_version
    BEFORE INSERT OR UPDATE ON binge_eating_gamification_states
    FOR EACH ROW
    EXECUTE FUNCTION ensure_schema_version();

-- Reading
DROP TRIGGER IF EXISTS ensure_reading_schema_version ON reading_gamification_states;
CREATE TRIGGER ensure_reading_schema_version
    BEFORE INSERT OR UPDATE ON reading_gamification_states
    FOR EACH ROW
    EXECUTE FUNCTION ensure_schema_version();

-- ============================================
-- 4. ADICIONAR METADADOS DE MÓDULO
-- ============================================

-- Adicionar _module_id a todos os registros existentes
UPDATE smoking_gamification_states SET state_data = jsonb_set(state_data, '{_module_id}', '"smoking"'::jsonb, true) WHERE state_data->>'_module_id' IS NULL;
UPDATE focus_gamification_states SET state_data = jsonb_set(state_data, '{_module_id}', '"focus"'::jsonb, true) WHERE state_data->>'_module_id' IS NULL;
UPDATE procrastination_gamification_states SET state_data = jsonb_set(state_data, '{_module_id}', '"procrastination"'::jsonb, true) WHERE state_data->>'_module_id' IS NULL;
UPDATE spending_gamification_states SET state_data = jsonb_set(state_data, '{_module_id}', '"spending"'::jsonb, true) WHERE state_data->>'_module_id' IS NULL;
UPDATE diet_gamification_states SET state_data = jsonb_set(state_data, '{_module_id}', '"diet"'::jsonb, true) WHERE state_data->>'_module_id' IS NULL;
UPDATE money_saving_gamification_states SET state_data = jsonb_set(state_data, '{_module_id}', '"money_saving"'::jsonb, true) WHERE state_data->>'_module_id' IS NULL;
UPDATE adult_content_gamification_states SET state_data = jsonb_set(state_data, '{_module_id}', '"adult_content"'::jsonb, true) WHERE state_data->>'_module_id' IS NULL;
UPDATE binge_eating_gamification_states SET state_data = jsonb_set(state_data, '{_module_id}', '"binge_eating"'::jsonb, true) WHERE state_data->>'_module_id' IS NULL;
UPDATE reading_gamification_states SET state_data = jsonb_set(state_data, '{_module_id}', '"reading"'::jsonb, true) WHERE state_data->>'_module_id' IS NULL;

-- ============================================
-- 5. COMENTÁRIOS SOBRE VERSIONAMENTO
-- ============================================

COMMENT ON FUNCTION ensure_schema_version() IS 'Garante que todo state_data tenha _schema_version definido';
