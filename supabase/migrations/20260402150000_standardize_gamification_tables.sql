-- Migration: Standardize all gamification tables
-- Description: Padroniza estrutura, constraints, RLS e triggers das 9 tabelas de gamificação
-- Created: 2026-04-02

-- ============================================
-- 1. PADRONIZAR DEFAULT '{}' em state_data
-- ============================================

-- Smoking (001) - adicionar DEFAULT
ALTER TABLE smoking_gamification_states 
  ALTER COLUMN state_data SET DEFAULT '{}';

-- Focus (002) - adicionar DEFAULT  
ALTER TABLE focus_gamification_states 
  ALTER COLUMN state_data SET DEFAULT '{}';

-- Procrastination (007) - adicionar DEFAULT
ALTER TABLE procrastination_gamification_states 
  ALTER COLUMN state_data SET DEFAULT '{}';

-- Spending (008) - adicionar DEFAULT
ALTER TABLE spending_gamification_states 
  ALTER COLUMN state_data SET DEFAULT '{}';

-- Atualizar registros existentes que tenham NULL (caso existam)
UPDATE smoking_gamification_states SET state_data = '{}' WHERE state_data IS NULL;
UPDATE focus_gamification_states SET state_data = '{}' WHERE state_data IS NULL;
UPDATE procrastination_gamification_states SET state_data = '{}' WHERE state_data IS NULL;
UPDATE spending_gamification_states SET state_data = '{}' WHERE state_data IS NULL;
UPDATE diet_gamification_states SET state_data = '{}' WHERE state_data IS NULL;
UPDATE money_saving_gamification_states SET state_data = '{}' WHERE state_data IS NULL;
UPDATE adult_content_gamification_states SET state_data = '{}' WHERE state_data IS NULL;
UPDATE binge_eating_gamification_states SET state_data = '{}' WHERE state_data IS NULL;
UPDATE reading_gamification_states SET state_data = '{}' WHERE state_data IS NULL;

-- ============================================
-- 2. PADRONIZAR TIPO TIMESTAMP (TIMESTAMPTZ)
-- ============================================

-- Alterar todas para TIMESTAMPTZ para consistência
ALTER TABLE diet_gamification_states 
  ALTER COLUMN created_at TYPE TIMESTAMPTZ,
  ALTER COLUMN updated_at TYPE TIMESTAMPTZ;

ALTER TABLE adult_content_gamification_states 
  ALTER COLUMN created_at TYPE TIMESTAMPTZ,
  ALTER COLUMN updated_at TYPE TIMESTAMPTZ;

ALTER TABLE binge_eating_gamification_states 
  ALTER COLUMN created_at TYPE TIMESTAMPTZ,
  ALTER COLUMN updated_at TYPE TIMESTAMPTZ;

ALTER TABLE reading_gamification_states 
  ALTER COLUMN created_at TYPE TIMESTAMPTZ,
  ALTER COLUMN updated_at TYPE TIMESTAMPTZ;

-- ============================================
-- 3. ADICIONAR UNIQUE(user_id) AUSENTES
-- ============================================

-- Verificar e remover duplicatas antes de adicionar constraint
-- (Necessário para evitar erro se houver duplicatas)

-- Smoking - adicionar UNIQUE
-- Primeiro, remover duplicatas mantendo a mais recente
DELETE FROM smoking_gamification_states a USING smoking_gamification_states b
  WHERE a.user_id = b.user_id AND a.id < b.id;
ALTER TABLE smoking_gamification_states 
  ADD CONSTRAINT unique_smoking_user_id UNIQUE (user_id);

-- Focus - adicionar UNIQUE
DELETE FROM focus_gamification_states a USING focus_gamification_states b
  WHERE a.user_id = b.user_id AND a.id < b.id;
ALTER TABLE focus_gamification_states 
  ADD CONSTRAINT unique_focus_user_id UNIQUE (user_id);

-- Diet - adicionar UNIQUE
DELETE FROM diet_gamification_states a USING diet_gamification_states b
  WHERE a.user_id = b.user_id AND a.id < b.id;
ALTER TABLE diet_gamification_states 
  ADD CONSTRAINT unique_diet_user_id UNIQUE (user_id);

-- Money Saving - adicionar UNIQUE
DELETE FROM money_saving_gamification_states a USING money_saving_gamification_states b
  WHERE a.user_id = b.user_id AND a.id < b.id;
ALTER TABLE money_saving_gamification_states 
  ADD CONSTRAINT unique_money_saving_user_id UNIQUE (user_id);

-- Adult Content - adicionar UNIQUE
DELETE FROM adult_content_gamification_states a USING adult_content_gamification_states b
  WHERE a.user_id = b.user_id AND a.id < b.id;
ALTER TABLE adult_content_gamification_states 
  ADD CONSTRAINT unique_adult_content_user_id UNIQUE (user_id);

-- Binge Eating - adicionar UNIQUE
DELETE FROM binge_eating_gamification_states a USING binge_eating_gamification_states b
  WHERE a.user_id = b.user_id AND a.id < b.id;
ALTER TABLE binge_eating_gamification_states 
  ADD CONSTRAINT unique_binge_eating_user_id UNIQUE (user_id);

-- Reading - adicionar UNIQUE
DELETE FROM reading_gamification_states a USING reading_gamification_states b
  WHERE a.user_id = b.user_id AND a.id < b.id;
ALTER TABLE reading_gamification_states 
  ADD CONSTRAINT unique_reading_user_id UNIQUE (user_id);

-- ============================================
-- 4. FUNÇÃO GENÉRICA DE UPDATED_AT ÚNICA
-- ============================================

-- Criar função genérica se não existir (já existe do smoking)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- ============================================
-- 5. RECRIAR TRIGGERS USANDO FUNÇÃO GENÉRICA
-- ============================================

-- Smoking - já usa função genérica, apenas garantir
DROP TRIGGER IF EXISTS update_smoking_gamification_states_updated_at ON smoking_gamification_states;
CREATE TRIGGER update_smoking_gamification_states_updated_at
    BEFORE UPDATE ON smoking_gamification_states
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Focus - recriar com função genérica
DROP TRIGGER IF EXISTS update_focus_gamification_states_updated_at ON focus_gamification_states;
CREATE TRIGGER update_focus_gamification_states_updated_at
    BEFORE UPDATE ON focus_gamification_states
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Procrastination - recriar com função genérica
DROP TRIGGER IF EXISTS procrastination_gamification_states_updated_at ON procrastination_gamification_states;
DROP FUNCTION IF EXISTS update_procrastination_gamification_states_updated_at();
CREATE TRIGGER update_procrastination_gamification_states_updated_at
    BEFORE UPDATE ON procrastination_gamification_states
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Spending - recriar com função genérica
DROP TRIGGER IF EXISTS spending_gamification_states_updated_at ON spending_gamification_states;
DROP FUNCTION IF EXISTS update_spending_gamification_states_updated_at();
CREATE TRIGGER update_spending_gamification_states_updated_at
    BEFORE UPDATE ON spending_gamification_states
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Diet - recriar com função genérica
DROP TRIGGER IF EXISTS trigger_update_diet_gamification_states_updated_at ON diet_gamification_states;
DROP FUNCTION IF EXISTS update_diet_gamification_states_updated_at();
CREATE TRIGGER update_diet_gamification_states_updated_at
    BEFORE UPDATE ON diet_gamification_states
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Money Saving - recriar com função genérica
DROP TRIGGER IF EXISTS update_money_saving_gamification_updated_at ON money_saving_gamification_states;
DROP FUNCTION IF EXISTS update_money_saving_gamification_updated_at();
CREATE TRIGGER update_money_saving_gamification_updated_at
    BEFORE UPDATE ON money_saving_gamification_states
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Adult Content - recriar com função genérica
DROP TRIGGER IF EXISTS trigger_update_adult_content_gamification_states_updated_at ON adult_content_gamification_states;
DROP FUNCTION IF EXISTS update_adult_content_gamification_states_updated_at();
CREATE TRIGGER update_adult_content_gamification_states_updated_at
    BEFORE UPDATE ON adult_content_gamification_states
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Binge Eating - recriar com função genérica
DROP TRIGGER IF EXISTS trigger_update_binge_eating_gamification_states_updated_at ON binge_eating_gamification_states;
DROP FUNCTION IF EXISTS update_binge_eating_gamification_states_updated_at();
CREATE TRIGGER update_binge_eating_gamification_states_updated_at
    BEFORE UPDATE ON binge_eating_gamification_states
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Reading - recriar com função genérica
DROP TRIGGER IF EXISTS trigger_update_reading_gamification_states_updated_at ON reading_gamification_states;
DROP FUNCTION IF EXISTS update_reading_gamification_states_updated_at();
CREATE TRIGGER update_reading_gamification_states_updated_at
    BEFORE UPDATE ON reading_gamification_states
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 6. PADRONIZAR RLS POLICIES (adicionar DELETE onde falta)
-- ============================================

-- Smoking - adicionar política DELETE
CREATE POLICY "Users can delete their own smoking gamification states"
    ON smoking_gamification_states FOR DELETE
    USING (auth.uid() = user_id);

-- Focus - adicionar política DELETE
CREATE POLICY "Users can delete their own focus gamification states"
    ON focus_gamification_states FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- 7. GARANTIR NOT NULL em timestamps
-- ============================================

-- Aplicar NOT NULL onde estiver faltando
ALTER TABLE diet_gamification_states 
  ALTER COLUMN created_at SET NOT NULL,
  ALTER COLUMN updated_at SET NOT NULL;

ALTER TABLE adult_content_gamification_states 
  ALTER COLUMN created_at SET NOT NULL,
  ALTER COLUMN updated_at SET NOT NULL;

ALTER TABLE binge_eating_gamification_states 
  ALTER COLUMN created_at SET NOT NULL,
  ALTER COLUMN updated_at SET NOT NULL;

ALTER TABLE reading_gamification_states 
  ALTER COLUMN created_at SET NOT NULL,
  ALTER COLUMN updated_at SET NOT NULL;

-- ============================================
-- 8. ADICIONAR ÍNDICE GIN ONDE FALTAR
-- ============================================

-- Smoking - adicionar GIN
CREATE INDEX IF NOT EXISTS idx_smoking_gamification_states_state_data_gin 
    ON smoking_gamification_states USING GIN(state_data);

-- Focus - adicionar GIN
CREATE INDEX IF NOT EXISTS idx_focus_gamification_states_state_data_gin 
    ON focus_gamification_states USING GIN(state_data);

-- Procrastination - adicionar GIN
CREATE INDEX IF NOT EXISTS idx_procrastination_gamification_states_state_data_gin 
    ON procrastination_gamification_states USING GIN(state_data);

-- Spending - adicionar GIN
CREATE INDEX IF NOT EXISTS idx_spending_gamification_states_state_data_gin 
    ON spending_gamification_states USING GIN(state_data);

-- Money Saving - adicionar GIN
CREATE INDEX IF NOT EXISTS idx_money_saving_gamification_states_state_data_gin 
    ON money_saving_gamification_states USING GIN(state_data);

-- ============================================
-- 9. COMENTÁRIOS PADRONIZADOS
-- ============================================

COMMENT ON TABLE smoking_gamification_states IS 'Stores gamification progress and achievements for Smoking module';
COMMENT ON TABLE focus_gamification_states IS 'Stores gamification progress and achievements for Focus module';
COMMENT ON TABLE procrastination_gamification_states IS 'Stores gamification progress and achievements for Procrastination module';
COMMENT ON TABLE spending_gamification_states IS 'Stores gamification progress and achievements for Spending module';
COMMENT ON TABLE money_saving_gamification_states IS 'Stores gamification progress and achievements for Money Saving module';
