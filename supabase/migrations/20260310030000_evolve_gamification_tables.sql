-- Migração Zero Downtime para evoluir tabelas de gamificação existentes
-- Usa IF NOT EXISTS para manter compatibilidade

-- Evoluir user_module_status (tabela existente)
ALTER TABLE user_module_status 
ADD COLUMN IF NOT EXISTS current_xp INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_achievements INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS module_specific_data JSONB DEFAULT '{}'::jsonb,
ADD COLUMN IF NOT EXISTS last_activity_date TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS last_updated TIMESTAMPTZ DEFAULT NOW();

-- Adicionar índices para as novas colunas
CREATE INDEX IF NOT EXISTS idx_user_module_status_current_xp ON user_module_status(current_xp) WHERE current_xp > 0;
CREATE INDEX IF NOT EXISTS idx_user_module_status_last_activity ON user_module_status(last_activity_date) WHERE last_activity_date IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_user_module_status_last_updated ON user_module_status(last_updated) WHERE last_updated IS NOT NULL;

-- Criar função para atualizar last_updated automaticamente
CREATE OR REPLACE FUNCTION update_module_status_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_updated = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Criar trigger para atualizar last_updated (só se não existir)
DROP TRIGGER IF EXISTS update_user_module_status_updated_at ON user_module_status;
CREATE TRIGGER update_user_module_status_updated_at 
    BEFORE UPDATE ON user_module_status 
    FOR EACH ROW EXECUTE FUNCTION update_module_status_updated_at();

-- Criar trigger para atualizar last_activity_date quando houver mudanças
CREATE OR REPLACE FUNCTION update_module_status_activity_date()
RETURNS TRIGGER AS $$
BEGIN
    -- Atualiza last_activity_date apenas se houver mudança relevante
    IF (
        OLD.consecutive_days IS DISTINCT FROM NEW.consecutive_days OR
        OLD.current_medal IS DISTINCT FROM NEW.current_medal OR
        OLD.is_active IS DISTINCT FROM NEW.is_active OR
        OLD.current_xp IS DISTINCT FROM NEW.current_xp
    ) THEN
        NEW.last_activity_date = NOW();
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Criar trigger para activity date (só se não existir)
DROP TRIGGER IF EXISTS update_user_module_status_activity_date ON user_module_status;
CREATE TRIGGER update_user_module_status_activity_date 
    BEFORE UPDATE ON user_module_status 
    FOR EACH ROW EXECUTE FUNCTION update_module_status_activity_date();

-- View para analytics de gamificação (facilita consultas complexas)
CREATE OR REPLACE VIEW gamification_analytics AS
SELECT 
    u.id as user_id,
    u.email,
    COUNT(ums.id) as active_modules,
    COALESCE(SUM(ums.consecutive_days), 0) as total_consecutive_days,
    COALESCE(SUM(ums.current_xp), 0) as total_xp,
    COALESCE(SUM(ums.total_achievements), 0) as total_achievements,
    MAX(ums.last_activity_date) as last_activity,
    COUNT(CASE WHEN ums.is_active = true THEN 1 END) as currently_active_modules
FROM auth.users u
LEFT JOIN user_module_status ums ON u.id = ums.user_id
GROUP BY u.id, u.email;

-- Função para calcular XP baseado em streaks e medalhas
CREATE OR REPLACE FUNCTION calculate_module_xp(
    p_consecutive_days INTEGER,
    p_current_medal TEXT
) RETURNS INTEGER AS $$
DECLARE
    xp_from_days INTEGER;
    xp_from_medal INTEGER;
    total_xp INTEGER;
BEGIN
    -- XP baseado em dias consecutivos: 10 XP por dia
    xp_from_days := p_consecutive_days * 10;
    
    -- XP baseado em medalha
    xp_from_medal := CASE p_current_medal
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

-- Trigger para recalcular XP automaticamente
CREATE OR REPLACE FUNCTION auto_update_module_xp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.current_xp := calculate_module_xp(NEW.consecutive_days, NEW.current_medal);
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para auto-update XP (só se não existir)
DROP TRIGGER IF EXISTS auto_update_module_xp_trigger ON user_module_status;
CREATE TRIGGER auto_update_module_xp_trigger 
    BEFORE INSERT OR UPDATE ON user_module_status 
    FOR EACH ROW EXECUTE FUNCTION auto_update_module_xp();
