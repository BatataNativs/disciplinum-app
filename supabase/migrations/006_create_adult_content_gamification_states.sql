-- Migration: Create adult_content_gamification_states table
-- Description: Table to store gamification state for Adult Content module

-- Create the table
CREATE TABLE IF NOT EXISTS adult_content_gamification_states (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    state_data JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_adult_content_gamification_states_user_id 
    ON adult_content_gamification_states(user_id);

CREATE INDEX IF NOT EXISTS idx_adult_content_gamification_states_updated_at 
    ON adult_content_gamification_states(updated_at DESC);

-- Create GIN index for JSONB queries
CREATE INDEX IF NOT EXISTS idx_adult_content_gamification_states_state_data_gin 
    ON adult_content_gamification_states USING GIN(state_data);

-- Enable Row Level Security
ALTER TABLE adult_content_gamification_states ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
-- 1. Users can read their own data
CREATE POLICY "Users can read own adult content gamification states" 
    ON adult_content_gamification_states FOR SELECT 
    USING (auth.uid() = user_id);

-- 2. Users can insert their own data
CREATE POLICY "Users can insert own adult content gamification states" 
    ON adult_content_gamification_states FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- 3. Users can update their own data
CREATE POLICY "Users can update own adult content gamification states" 
    ON adult_content_gamification_states FOR UPDATE 
    USING (auth.uid() = user_id);

-- 4. Users can delete their own data
CREATE POLICY "Users can delete own adult content gamification states" 
    ON adult_content_gamification_states FOR DELETE 
    USING (auth.uid() = user_id);

-- Create trigger to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_adult_content_gamification_states_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_adult_content_gamification_states_updated_at
    BEFORE UPDATE ON adult_content_gamification_states
    FOR EACH ROW
    EXECUTE FUNCTION update_adult_content_gamification_states_updated_at();

-- Add comments for documentation
COMMENT ON TABLE adult_content_gamification_states IS 'Stores gamification progress and achievements for Adult Content module';
COMMENT ON COLUMN adult_content_gamification_states.user_id IS 'Reference to the user who owns this gamification state';
COMMENT ON COLUMN adult_content_gamification_states.state_data IS 'JSONB containing earned insignias, medals, streaks, and other gamification data';
COMMENT ON COLUMN adult_content_gamification_states.created_at IS 'When this gamification state was first created';
COMMENT ON COLUMN adult_content_gamification_states.updated_at IS 'When this gamification state was last updated';

-- Example JSON structure for state_data:
-- {
--   "consecutiveDays": 5,
--   "disciplinumCount": 3,
--   "earnedInsignias": ["Controle Iniciado", "Primeiro Dia", "Dois Dias", "Três Dias", "Cinco Dias"],
--   "earnedMedalhas": ["Controle Bronze", "Controle Prata"],
--   "isActive": true,
--   "lastUpdated": "2024-03-27T10:30:00.000Z"
-- }
