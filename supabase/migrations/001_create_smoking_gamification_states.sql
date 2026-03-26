-- Migration: Create smoking_gamification_states table
-- Para armazenar estado de gamificação do módulo Smoking na nuvem

CREATE TABLE IF NOT EXISTS smoking_gamification_states (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    state_data JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_smoking_gamification_states_user_id ON smoking_gamification_states(user_id);
CREATE INDEX IF NOT EXISTS idx_smoking_gamification_states_updated_at ON smoking_gamification_states(updated_at);

-- RLS (Row Level Security) - apenas o dono pode ver/alterar seus dados
ALTER TABLE smoking_gamification_states ENABLE ROW LEVEL SECURITY;

-- Política para usuários autenticados verem seus próprios dados
CREATE POLICY "Users can view their own smoking gamification states"
    ON smoking_gamification_states FOR SELECT
    USING (auth.uid() = user_id);

-- Política para usuários autenticados inserirem seus próprios dados
CREATE POLICY "Users can insert their own smoking gamification states"
    ON smoking_gamification_states FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Política para usuários autenticados atualizarem seus próprios dados
CREATE POLICY "Users can update their own smoking gamification states"
    ON smoking_gamification_states FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Trigger para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_smoking_gamification_states_updated_at
    BEFORE UPDATE ON smoking_gamification_states
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Comentários da tabela
COMMENT ON TABLE smoking_gamification_states IS 'Tabela para armazenar estado de gamificação do módulo Smoking';
COMMENT ON COLUMN smoking_gamification_states.state_data IS 'Dados JSON do estado de gamificação (insígnias, medalhas, streak, etc)';
COMMENT ON COLUMN smoking_gamification_states.user_id IS 'ID do usuário dono do estado';
COMMENT ON COLUMN smoking_gamification_states.created_at IS 'Data de criação do registro';
COMMENT ON COLUMN smoking_gamification_states.updated_at IS 'Data da última atualização do registro';
