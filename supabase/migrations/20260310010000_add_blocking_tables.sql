-- Migração Zero Downtime para adicionar tabelas de blocking
-- Mantém todas as tabelas existentes funcionando

-- Tabela para apps bloqueados por usuário
CREATE TABLE user_blocked_apps (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  package_name TEXT NOT NULL, -- 'com.instagram.android'
  app_name TEXT NOT NULL,     -- 'Instagram'
  blocking_reason TEXT,       -- 'focus_session', 'procrastination', 'adult_content'
  is_temporary BOOLEAN DEFAULT false,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(user_id, package_name)
);

-- Tabela para regras de bloqueio personalizadas
CREATE TABLE user_blocking_rules (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  rule_name TEXT NOT NULL,
  blocked_packages TEXT[], -- Array de package_names para bloquear
  trigger_conditions JSONB DEFAULT '{}'::jsonb, -- {'time_range': '09:00-17:00', 'weekdays': [1,2,3,4,5]}
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX idx_user_blocked_apps_user_id ON user_blocked_apps(user_id);
CREATE INDEX idx_user_blocked_apps_package_name ON user_blocked_apps(package_name);
CREATE INDEX idx_user_blocked_apps_expires_at ON user_blocked_apps(expires_at) WHERE expires_at IS NOT NULL;

CREATE INDEX idx_user_blocking_rules_user_id ON user_blocking_rules(user_id);
CREATE INDEX idx_user_blocking_rules_active ON user_blocking_rules(is_active) WHERE is_active = true;

-- RLS (Row Level Security)
ALTER TABLE user_blocked_apps ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_blocking_rules ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança para user_blocked_apps
CREATE POLICY "Users can view own blocked apps" ON user_blocked_apps
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own blocked apps" ON user_blocked_apps
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own blocked apps" ON user_blocked_apps
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own blocked apps" ON user_blocked_apps
  FOR DELETE USING (auth.uid() = user_id);

-- Políticas de segurança para user_blocking_rules
CREATE POLICY "Users can view own blocking rules" ON user_blocking_rules
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own blocking rules" ON user_blocking_rules
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own blocking rules" ON user_blocking_rules
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own blocking rules" ON user_blocking_rules
  FOR DELETE USING (auth.uid() = user_id);

-- Trigger para atualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_user_blocked_apps_updated_at 
    BEFORE UPDATE ON user_blocked_apps 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_blocking_rules_updated_at 
    BEFORE UPDATE ON user_blocking_rules 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
