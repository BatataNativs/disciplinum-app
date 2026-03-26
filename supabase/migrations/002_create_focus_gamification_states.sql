-- Migration: Create focus_gamification_states table
-- Para armazenar estado de gamificação do módulo Focus na nuvem

CREATE TABLE IF NOT EXISTS focus_gamification_states (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    state_data JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_focus_gamification_states_user_id ON focus_gamification_states(user_id);
CREATE INDEX IF NOT EXISTS idx_focus_gamification_states_updated_at ON focus_gamification_states(updated_at);

-- RLS (Row Level Security) - apenas o dono pode ver/alterar seus dados
ALTER TABLE focus_gamification_states ENABLE ROW LEVEL SECURITY;

-- Política para usuários autenticados verem seus próprios dados
CREATE POLICY "Users can view their own focus gamification states"
    ON focus_gamification_states FOR SELECT
    USING (auth.uid() = user_id);

-- Política para usuários autenticados inserirem seus próprios dados
CREATE POLICY "Users can insert their own focus gamification states"
    ON focus_gamification_states FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Política para usuários autenticados atualizarem seus próprios dados
CREATE POLICY "Users can update their own focus gamification states"
    ON focus_gamification_states FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Trigger para atualizar updated_at automaticamente (reutiliza função existente)
CREATE TRIGGER update_focus_gamification_states_updated_at
    BEFORE UPDATE ON focus_gamification_states
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Comentários da tabela
COMMENT ON TABLE focus_gamification_states IS 'Tabela para armazenar estado de gamificação do módulo Focus';
COMMENT ON COLUMN focus_gamification_states.state_data IS 'Dados JSON do estado de gamificação (insígnias, medalhas, tempo de foco, etc)';
COMMENT ON COLUMN focus_gamification_states.user_id IS 'ID do usuário dono do estado';
COMMENT ON COLUMN focus_gamification_states.created_at IS 'Data de criação do registro';
COMMENT ON COLUMN focus_gamification_states.updated_at IS 'Data da última atualização do registro';
