-- Migration: Create spending_gamification_states table
-- Para armazenar estado de gamificação do módulo Spending na nuvem

CREATE TABLE IF NOT EXISTS spending_gamification_states (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    state_data JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(user_id)
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_spending_gamification_states_user_id ON spending_gamification_states(user_id);
CREATE INDEX IF NOT EXISTS idx_spending_gamification_states_updated_at ON spending_gamification_states(updated_at);

-- RLS (Row Level Security) - apenas o dono pode ver/alterar seus dados
ALTER TABLE spending_gamification_states ENABLE ROW LEVEL SECURITY;

-- Política para usuários autenticados verem seus próprios dados
CREATE POLICY "Users can view their own spending gamification states"
    ON spending_gamification_states FOR SELECT
    USING (auth.uid() = user_id);

-- Política para usuários autenticados inserirem seus próprios dados
CREATE POLICY "Users can insert their own spending gamification states"
    ON spending_gamification_states FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Política para usuários autenticados atualizarem seus próprios dados
CREATE POLICY "Users can update their own spending gamification states"
    ON spending_gamification_states FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Política para usuários autenticados deletarem seus próprios dados
CREATE POLICY "Users can delete their own spending gamification states"
    ON spending_gamification_states FOR DELETE
    USING (auth.uid() = user_id);

-- Trigger para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_spending_gamification_states_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER spending_gamification_states_updated_at
    BEFORE UPDATE ON spending_gamification_states
    FOR EACH ROW
    EXECUTE FUNCTION update_spending_gamification_states_updated_at();

-- Comentários
COMMENT ON TABLE spending_gamification_states IS 'Tabela para armazenar estado de gamificação do módulo Spending';
COMMENT ON COLUMN spending_gamification_states.state_data IS 'Dados JSON do estado de gamificação (insígnias, medalhas, streak, etc.)';
