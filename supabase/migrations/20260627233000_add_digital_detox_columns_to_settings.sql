-- Migration to add Digital Detox configuration columns to user_module_settings

ALTER TABLE user_module_settings
  -- Apps Monitorados
  ADD COLUMN IF NOT EXISTS monitored_apps TEXT[] DEFAULT '{}',

  -- FASE 2: Bloqueio por horário
  ADD COLUMN IF NOT EXISTS enable_time_window BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS allowed_start_time TEXT DEFAULT '08:00',
  ADD COLUMN IF NOT EXISTS allowed_end_time TEXT DEFAULT '22:00',
  ADD COLUMN IF NOT EXISTS block_on_weekends BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS weekend_allowed_start_time TEXT,
  ADD COLUMN IF NOT EXISTS weekend_allowed_end_time TEXT,

  -- FASE 3: Limite de tempo diário
  ADD COLUMN IF NOT EXISTS enable_daily_limit BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS daily_limit_minutes INTEGER DEFAULT 60,
  ADD COLUMN IF NOT EXISTS limit_type TEXT DEFAULT 'global',
  ADD COLUMN IF NOT EXISTS warn_before_limit_minutes INTEGER DEFAULT 5,

  -- FASE 4: Notificação pré-detox e Streaks
  ADD COLUMN IF NOT EXISTS enable_pre_detox_warning BOOLEAN DEFAULT true,
  ADD COLUMN IF NOT EXISTS pre_detox_warning_minutes INTEGER DEFAULT 5,
  ADD COLUMN IF NOT EXISTS pre_detox_warning_message TEXT,
  
  ADD COLUMN IF NOT EXISTS current_disciplined_streak INTEGER DEFAULT 0,
  ADD COLUMN IF NOT EXISTS longest_disciplined_streak INTEGER DEFAULT 0,
  ADD COLUMN IF NOT EXISTS total_disciplined_days INTEGER DEFAULT 0,
  ADD COLUMN IF NOT EXISTS last_disciplined_date TIMESTAMPTZ,

  -- FASE 6A: Horas cumulativas
  ADD COLUMN IF NOT EXISTS enable_rollover_minutes BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS max_rollover_minutes INTEGER DEFAULT 60,
  ADD COLUMN IF NOT EXISTS rollover_expiration_days INTEGER DEFAULT 7,

  -- FASE 6B: Limite Semanal
  ADD COLUMN IF NOT EXISTS enable_weekly_limit BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS weekly_limit_minutes INTEGER DEFAULT 540,
  ADD COLUMN IF NOT EXISTS weekly_limit_strategy TEXT DEFAULT 'flexible',

  -- FASE 6C: Sessões Controladas
  ADD COLUMN IF NOT EXISTS enable_session_mode BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS session_duration_minutes INTEGER DEFAULT 10,
  ADD COLUMN IF NOT EXISTS session_cooldown_hours INTEGER DEFAULT 2,
  ADD COLUMN IF NOT EXISTS max_sessions_per_day INTEGER DEFAULT 4,
  ADD COLUMN IF NOT EXISTS session_daily_limit_minutes INTEGER DEFAULT 40,

  -- FASE 7: Quebra de Jejum
  ADD COLUMN IF NOT EXISTS fasting_break_days_required INTEGER DEFAULT 7,
  ADD COLUMN IF NOT EXISTS fasting_break_validity_days INTEGER DEFAULT 30;
