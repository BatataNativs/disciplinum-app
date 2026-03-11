-- Correção de inconsistência: current_medal -> max_medal
-- Esta migração corrige funções e triggers que referenciam um campo inexistente

-- 1. Atualizar função de atividade
CREATE OR REPLACE FUNCTION update_module_status_activity_date()
RETURNS TRIGGER AS $$
BEGIN
    -- Usa max_medal em vez de current_medal
    IF (
        OLD.consecutive_days IS DISTINCT FROM NEW.consecutive_days OR
        OLD.max_medal IS DISTINCT FROM NEW.max_medal OR
        OLD.is_active IS DISTINCT FROM NEW.is_active OR
        OLD.current_xp IS DISTINCT FROM NEW.current_xp
    ) THEN
        NEW.last_activity_date = NOW();
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 2. Atualizar função de XP
CREATE OR REPLACE FUNCTION calculate_module_xp(
    p_consecutive_days INTEGER,
    p_max_medal TEXT
) RETURNS INTEGER AS $$
DECLARE
    xp_from_days INTEGER;
    xp_from_medal INTEGER;
    total_xp INTEGER;
BEGIN
    xp_from_days := p_consecutive_days * 10;
    
    xp_from_medal := CASE p_max_medal
        WHEN 'bronze' THEN 50
        WHEN 'prata' THEN 150
        WHEN 'ouro' THEN 300
        WHEN 'diamante' THEN 500
        ELSE 0
    END;
    
    total_xp := xp_from_days + xp_from_medal;
    RETURN total_xp;
END;
$$ LANGUAGE plpgsql;

-- 3. Atualizar trigger de XP para passar max_medal
CREATE OR REPLACE FUNCTION auto_update_module_xp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.current_xp := calculate_module_xp(NEW.consecutive_days, NEW.max_medal);
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 4. Recriar triggers para garantir que usem as funções atualizadas
DROP TRIGGER IF EXISTS update_user_module_status_activity_date ON user_module_status;
CREATE TRIGGER update_user_module_status_activity_date 
    BEFORE UPDATE ON user_module_status 
    FOR EACH ROW EXECUTE FUNCTION update_module_status_activity_date();

DROP TRIGGER IF EXISTS auto_update_module_xp_trigger ON user_module_status;
CREATE TRIGGER auto_update_module_xp_trigger 
    BEFORE INSERT OR UPDATE ON user_module_status 
    FOR EACH ROW EXECUTE FUNCTION auto_update_module_xp();
