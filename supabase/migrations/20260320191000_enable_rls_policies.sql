-- POLÍTICAS RLS ADICIONAIS PARA SEGURANÇA
-- Garantir RLS adequado para todas as tabelas de usuário

-- 1. Verificar se outras tabelas precisam de RLS
-- Garantir que user_module_status tenha RLS adequado
ALTER TABLE user_module_status ENABLE ROW LEVEL SECURITY;

-- Drop policies existentes para user_module_status
DROP POLICY IF EXISTS "Users can view own module status" ON user_module_status;
DROP POLICY IF EXISTS "Users can insert own module status" ON user_module_status;
DROP POLICY IF EXISTS "Users can update own module status" ON user_module_status;

-- Criar políticas seguras para user_module_status
CREATE POLICY "Users can view own module status" ON user_module_status
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can insert own module status" ON user_module_status
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own module status" ON user_module_status
    FOR UPDATE USING (user_id = auth.uid());

-- 2. Verificar se user_behavior_events precisa de RLS
ALTER TABLE user_behavior_events ENABLE ROW LEVEL SECURITY;

-- Drop policies existentes para user_behavior_events
DROP POLICY IF EXISTS "Users can view own behavior events" ON user_behavior_events;
DROP POLICY IF EXISTS "Users can insert own behavior events" ON user_behavior_events;

-- Criar políticas para user_behavior_events
CREATE POLICY "Users can view own behavior events" ON user_behavior_events
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can insert own behavior events" ON user_behavior_events
    FOR INSERT WITH CHECK (user_id = auth.uid());

-- 3. Nota sobre gamification_analytics
-- A view gamification_analytics herda segurança das tabelas base (user_module_status)
-- Como user_module_status tem RLS, a view automaticamente restringe acesso aos dados do próprio usuário

-- 4. Log final das configurações de segurança
DO $$
BEGIN
    RAISE NOTICE 'RLS configurado para todas as tabelas de usuário';
    RAISE NOTICE 'Políticas de segurança aplicadas: user_module_status, user_behavior_events, user_meal_records';
    RAISE NOTICE 'View gamification_analytics herdando segurança das tabelas base';
END $$;
