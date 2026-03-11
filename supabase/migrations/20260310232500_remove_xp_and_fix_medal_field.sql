-- REMOÇÃO DO SISTEMA DE XP E CORREÇÃO DE MEDALHAS
-- Esta migração remove a lógica de XP (não será utilizada) e corrige a trigger de atividade.

-- 1. Remover triggers e funções de XP
DROP TRIGGER IF EXISTS auto_update_module_xp_trigger ON user_module_status;
DROP FUNCTION IF EXISTS auto_update_module_xp();
DROP FUNCTION IF EXISTS calculate_module_xp(INTEGER, TEXT);

-- 2. Corrigir função de atividade (Remover XP e usar max_medal)
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
$$ language 'plpgsql';

-- 3. Garantir que a trigger de atividade esteja vinculada à função corrigida
DROP TRIGGER IF EXISTS update_user_module_status_activity_date ON user_module_status;
CREATE TRIGGER update_user_module_status_activity_date 
    BEFORE UPDATE ON user_module_status 
    FOR EACH ROW EXECUTE FUNCTION update_module_status_activity_date();

-- 4. Opcional: Limpar colunas de XP se você não quiser mantê-las na tabela
-- ALTER TABLE user_module_status DROP COLUMN IF EXISTS current_xp;
-- ALTER TABLE user_module_status DROP COLUMN IF EXISTS total_achievements;
