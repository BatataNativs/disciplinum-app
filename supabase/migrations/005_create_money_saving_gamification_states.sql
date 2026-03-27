-- Migration para criar tabela de estados de gamificação do módulo Money Saving Challenge
-- Armazena progresso, conquistas e estatísticas de economia

-- Criar tabela
CREATE TABLE IF NOT EXISTS money_saving_gamification_states (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    state_data JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_money_saving_gamification_user_id ON money_saving_gamification_states(user_id);
CREATE INDEX IF NOT EXISTS idx_money_saving_gamification_updated_at ON money_saving_gamification_states(updated_at);

-- Políticas RLS (Row Level Security)
ALTER TABLE money_saving_gamification_states ENABLE ROW LEVEL SECURITY;

-- Política para usuários lerem apenas seus próprios dados
CREATE POLICY "Users can read own money saving gamification states" ON money_saving_gamification_states
    FOR SELECT USING (auth.uid() = user_id);

-- Política para usuários inserirem apenas seus próprios dados
CREATE POLICY "Users can insert own money saving gamification states" ON money_saving_gamification_states
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Política para usuários atualizarem apenas seus próprios dados
CREATE POLICY "Users can update own money saving gamification states" ON money_saving_gamification_states
    FOR UPDATE USING (auth.uid() = user_id);

-- Política para usuários deletarem apenas seus próprios dados
CREATE POLICY "Users can delete own money saving gamification states" ON money_saving_gamification_states
    FOR DELETE USING (auth.uid() = user_id);

-- Trigger para atualizar o campo updated_at automaticamente
CREATE OR REPLACE FUNCTION update_money_saving_gamification_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_money_saving_gamification_updated_at
    BEFORE UPDATE ON money_saving_gamification_states
    FOR EACH ROW
    EXECUTE FUNCTION update_money_saving_gamification_updated_at();

-- Comentários para documentação
COMMENT ON TABLE money_saving_gamification_states IS 'Tabela para armazenar estados de gamificação do módulo Money Saving Challenge';
COMMENT ON COLUMN money_saving_gamification_states.user_id IS 'ID do usuário dono do estado de gamificação';
COMMENT ON COLUMN money_saving_gamification_states.state_data IS 'Dados JSON do estado de gamificação (insignias, medalhas, streak, etc.)';
COMMENT ON COLUMN money_saving_gamification_states.created_at IS 'Data de criação do registro';
COMMENT ON COLUMN money_saving_gamification_states.updated_at IS 'Data da última atualização do registro';

-- Exemplo de estrutura do campo state_data:
-- {
--   "earnedInsignias": ["Economista Inicial", "Poupador Semanal"],
--   "earnedMedalhas": ["Bronze Economista"],
--   "consecutiveDays": 15,
--   "disciplinumCount": 2,
--   "totalSavedAmount": 1500.50,
--   "bestStreak": 30,
--   "lastSavingDate": "2024-03-27T10:30:00.000Z",
--   "startDate": "2024-03-01T00:00:00.000Z",
--   "isActive": true,
--   "lastUpdated": "2024-03-27T10:30:00.000Z"
-- }
