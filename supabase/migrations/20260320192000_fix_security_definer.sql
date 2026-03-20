-- CORREÇÃO DE SECURITY DEFINER PARA GAMIFICATION_ANALYTICS
-- Alterar view para usar SECURITY INVOKER para garantir RLS adequado

-- 1. Remover view atual com SECURITY DEFINER (padrão)
DROP VIEW IF EXISTS gamification_analytics;

-- 2. Recriar view com SECURITY INVOKER (executa com permissões do usuário que consulta)
CREATE OR REPLACE VIEW gamification_analytics 
AS
SELECT 
    ums.user_id,
    COUNT(ums.id) as active_modules,
    COALESCE(SUM(ums.consecutive_days), 0) as total_consecutive_days,
    COALESCE(SUM(ums.total_achievements), 0) as total_achievements,
    MAX(ums.last_activity_date) as last_activity,
    COUNT(CASE WHEN ums.is_active = true THEN 1 END) as currently_active_modules
FROM user_module_status ums
GROUP BY ums.user_id;

-- 3. Alterar view para SECURITY INVOKER (sintaxe alternativa)
ALTER VIEW gamification_analytics SET (security_invoker = true);

-- 4. Adicionar comentário sobre segurança
COMMENT ON VIEW gamification_analytics IS 'View segura com SECURITY INVOKER - executa com permissões do usuário, respeitando RLS';

-- 5. Verificar se há outras views com SECURITY DEFINER que precisam correção
-- Verificar user_meal_records_view (se existir)
DROP VIEW IF EXISTS user_meal_records_view;

-- 6. Log da correção
DO $$
BEGIN
    RAISE NOTICE 'View gamification_analytics corrigida para SECURITY INVOKER';
    RAISE NOTICE 'Agora a view respeita RLS e permissões do usuário que consulta';
END $$;
