-- REMOÇÃO DEFINITIVA DAS COLUNAS DE XP/PONTOS
-- Esta migração remove completamente as colunas de XP/pontos que não serão utilizadas

-- 1. Remover colunas de XP da tabela user_module_status se existirem
ALTER TABLE user_module_status 
DROP COLUMN IF EXISTS current_xp,
DROP COLUMN IF EXISTS total_points,
DROP COLUMN IF EXISTS daily_points,
DROP COLUMN IF EXISTS last_daily_reset,
DROP COLUMN IF EXISTS current_level,
DROP COLUMN IF EXISTS current_level_xp,
DROP COLUMN IF EXISTS next_level_xp;

-- 2. Log da remoção
DO $$
BEGIN
    RAISE NOTICE 'Colunas de XP/pontos removidas da tabela user_module_status';
END $$;
