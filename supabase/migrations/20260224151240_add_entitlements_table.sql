-- Tabela para sincronizar entitlements (compras IAP e desbloqueios por Ads)
CREATE TABLE user_entitlements (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  entitlement_type TEXT NOT NULL, -- 'motivation_phrases', 'custom_notifications', 'dark_mode', 'ad_free', etc.
  niche_id INTEGER, -- null para globais, id para específicos
  source TEXT NOT NULL, -- 'iap', 'ad', 'manual'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE, -- para consumíveis como ad_free_lite
  metadata JSONB DEFAULT '{}'::jsonb, -- dados adicionais como purchase_token, etc.
  
  UNIQUE(user_id, entitlement_type, niche_id)
);

-- Índices para performance
CREATE INDEX idx_user_entitlements_user_id ON user_entitlements(user_id);
CREATE INDEX idx_user_entitlements_type ON user_entitlements(entitlement_type);
CREATE INDEX idx_user_entitlements_expires ON user_entitlements(expires_at) WHERE expires_at IS NOT NULL;

-- RLS (Row Level Security)
ALTER TABLE user_entitlements ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança
CREATE POLICY "Users can view own entitlements" ON user_entitlements
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own entitlements" ON user_entitlements
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own entitlements" ON user_entitlements
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own entitlements" ON user_entitlements
  FOR DELETE USING (auth.uid() = user_id);