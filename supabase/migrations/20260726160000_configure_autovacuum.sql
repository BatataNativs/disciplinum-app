-- Migration: Configure Aggressive Autovacuum for High-Write Tables
-- Description: Configure autovacuum settings for tables with high write activity
-- This prevents table bloat and keeps statistics up-to-date
-- Impact: Improved performance and reduced storage overhead over time

-- User Behavior Events: High write frequency (analytics events)
ALTER TABLE public.user_behavior_events SET (
  autovacuum_vacuum_scale_factor = 0.1,
  autovacuum_analyze_scale_factor = 0.05,
  autovacuum_vacuum_threshold = 1000,
  autovacuum_analyze_threshold = 500
);

-- Cloud Sync Queue: High write/delete frequency
ALTER TABLE public.cloud_sync_queue SET (
  autovacuum_vacuum_scale_factor = 0.1,
  autovacuum_analyze_scale_factor = 0.05,
  autovacuum_vacuum_threshold = 500,
  autovacuum_analyze_threshold = 250
);

-- Password Validation Logs: High write frequency
ALTER TABLE public.password_validation_logs SET (
  autovacuum_vacuum_scale_factor = 0.1,
  autovacuum_analyze_scale_factor = 0.05,
  autovacuum_vacuum_threshold = 500,
  autovacuum_analyze_threshold = 250
);

-- Gamification States: Moderate write frequency
ALTER TABLE public.smoking_gamification_states SET (
  autovacuum_vacuum_scale_factor = 0.2,
  autovacuum_analyze_scale_factor = 0.1
);

ALTER TABLE public.focus_gamification_states SET (
  autovacuum_vacuum_scale_factor = 0.2,
  autovacuum_analyze_scale_factor = 0.1
);

ALTER TABLE public.binge_eating_gamification_states SET (
  autovacuum_vacuum_scale_factor = 0.2,
  autovacuum_analyze_scale_factor = 0.1
);

ALTER TABLE public.diet_gamification_states SET (
  autovacuum_vacuum_scale_factor = 0.2,
  autovacuum_analyze_scale_factor = 0.1
);

ALTER TABLE public.money_saving_gamification_states SET (
  autovacuum_vacuum_scale_factor = 0.2,
  autovacuum_analyze_scale_factor = 0.1
);

ALTER TABLE public.adult_content_gamification_states SET (
  autovacuum_vacuum_scale_factor = 0.2,
  autovacuum_analyze_scale_factor = 0.1
);

ALTER TABLE public.procrastination_gamification_states SET (
  autovacuum_vacuum_scale_factor = 0.2,
  autovacuum_analyze_scale_factor = 0.1
);

ALTER TABLE public.spending_gamification_states SET (
  autovacuum_vacuum_scale_factor = 0.2,
  autovacuum_analyze_scale_factor = 0.1
);

ALTER TABLE public.reading_gamification_states SET (
  autovacuum_vacuum_scale_factor = 0.2,
  autovacuum_analyze_scale_factor = 0.1
);

COMMENT ON SCHEMA public IS 'Configured aggressive autovacuum for high-write tables';
