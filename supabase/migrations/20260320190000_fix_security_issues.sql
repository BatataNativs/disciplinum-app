-- CORREÇÃO DE SEGURANÇA - REMOVER EXPOSIÇÃO DE DADOS DO AUTH.USERS
-- Esta migração corrige problemas de segurança expostos pelo painel do Supabase

-- 1. Remover view gamification_analytics que expõe auth.users
DROP VIEW IF EXISTS gamification_analytics;

-- 2. Criar view segura sem expor dados sensíveis do auth.users
CREATE OR REPLACE VIEW gamification_analytics AS
SELECT 
    ums.user_id,
    COUNT(ums.id) as active_modules,
    COALESCE(SUM(ums.consecutive_days), 0) as total_consecutive_days,
    COALESCE(SUM(ums.total_achievements), 0) as total_achievements,
    MAX(ums.last_activity_date) as last_activity,
    COUNT(CASE WHEN ums.is_active = true THEN 1 END) as currently_active_modules
FROM user_module_status ums
GROUP BY ums.user_id;

-- 3. Remover colunas de XP que não existem mais (referência à view antiga)
-- Nota: current_xp foi removido na migração anterior, então não incluímos aqui

-- 4. Adicionar comentário de segurança na view
COMMENT ON VIEW gamification_analytics IS 'View segura para analytics de gamificação sem expor dados do auth.users';

-- 5. Verificar RLS (Row Level Security) para user_meal_records
-- Garantir que usuários só podem ver seus próprios registros

-- Drop policy existente se houver
DROP POLICY IF EXISTS "Users can view own meal records" ON user_meal_records;
DROP POLICY IF EXISTS "Users can insert own meal records" ON user_meal_records;
DROP POLICY IF EXISTS "Users can update own meal records" ON user_meal_records;
DROP POLICY IF EXISTS "Users can delete own meal records" ON user_meal_records;

-- Criar políticas RLS seguras
CREATE POLICY "Users can view own meal records" ON user_meal_records
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own meal records" ON user_meal_records
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own meal records" ON user_meal_records
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own meal records" ON user_meal_records
    FOR DELETE USING (auth.uid() = user_id);

-- 6. Garantir que RLS está ativado para user_meal_records
ALTER TABLE user_meal_records ENABLE ROW LEVEL SECURITY;

-- 7. Log das correções
DO $$
BEGIN
    RAISE NOTICE 'Segurança atualizada: view gamification_analytics sem exposição de auth.users';
    RAISE NOTICE 'RLS configurado para user_meal_records';
END $$;
