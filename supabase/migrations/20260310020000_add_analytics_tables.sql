-- Migração Zero Downtime para adicionar tabelas de analytics
-- Mantém todas as tabelas existentes funcionando

-- Tabela para eventos de comportamento do usuário
CREATE TABLE user_behavior_events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  event_type TEXT NOT NULL, -- 'module_started', 'focus_completed', 'app_blocked', 'check_in', 'relapse'
  module_niche_id INTEGER, -- Referência para NicheId (1-9)
  event_data JSONB DEFAULT '{}'::jsonb, -- Dados específicos do evento: {'duration': 1500, 'interruptions': 0}
  session_id TEXT, -- Para agrupar eventos da mesma sessão
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela para métricas de retenção calculadas
CREATE TABLE user_retention_metrics (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  metric_date DATE NOT NULL,
  active_modules INTEGER DEFAULT 0, -- Módulos ativos no dia
  total_focus_minutes INTEGER DEFAULT 0, -- Minutos de foco acumulados
  longest_streak INTEGER DEFAULT 0, -- Maior streak atual
  total_checkins INTEGER DEFAULT 0, -- Total de check-ins no dia
  total_relapses INTEGER DEFAULT 0, -- Total de recaídas no dia
  app_blocks_triggered INTEGER DEFAULT 0, -- Vezes que bloqueio foi acionado
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(user_id, metric_date)
);

-- Tabela para conquistas detalhadas (evolução da gamificação)
CREATE TABLE user_achievements (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  achievement_type TEXT NOT NULL, -- 'streak_7_days', 'focus_100_minutes', 'first_month_smoke_free'
  module_niche_id INTEGER, -- Null para conquistas globais
  achievement_data JSONB DEFAULT '{}'::jsonb, -- Dados específicos: {'target_days': 7, 'completed_days': 7}
  earned_at TIMESTAMPTZ DEFAULT NOW(),
  is_viewed BOOLEAN DEFAULT false, -- Se usuário já viu esta conquista
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX idx_user_behavior_events_user_id ON user_behavior_events(user_id);
CREATE INDEX idx_user_behavior_events_type ON user_behavior_events(event_type);
CREATE INDEX idx_user_behavior_events_module ON user_behavior_events(module_niche_id);
CREATE INDEX idx_user_behavior_events_created_at ON user_behavior_events(created_at);
CREATE INDEX idx_user_behavior_events_session ON user_behavior_events(session_id) WHERE session_id IS NOT NULL;

CREATE INDEX idx_user_retention_metrics_user_id ON user_retention_metrics(user_id);
CREATE INDEX idx_user_retention_metrics_date ON user_retention_metrics(metric_date);
CREATE INDEX idx_user_retention_metrics_active_modules ON user_retention_metrics(active_modules) WHERE active_modules > 0;

CREATE INDEX idx_user_achievements_user_id ON user_achievements(user_id);
CREATE INDEX idx_user_achievements_type ON user_achievements(achievement_type);
CREATE INDEX idx_user_achievements_module ON user_achievements(module_niche_id);
CREATE INDEX idx_user_achievements_viewed ON user_achievements(is_viewed) WHERE is_viewed = false;

-- RLS (Row Level Security)
ALTER TABLE user_behavior_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_retention_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança para user_behavior_events
CREATE POLICY "Users can view own behavior events" ON user_behavior_events
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own behavior events" ON user_behavior_events
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Políticas de segurança para user_retention_metrics
CREATE POLICY "Users can view own retention metrics" ON user_retention_metrics
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own retention metrics" ON user_retention_metrics
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own retention metrics" ON user_retention_metrics
  FOR UPDATE USING (auth.uid() = user_id);

-- Políticas de segurança para user_achievements
CREATE POLICY "Users can view own achievements" ON user_achievements
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own achievements" ON user_achievements
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own achievements" ON user_achievements
  FOR UPDATE USING (auth.uid() = user_id);

-- Trigger para atualizar updated_at
CREATE TRIGGER update_user_retention_metrics_updated_at 
    BEFORE UPDATE ON user_retention_metrics 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
