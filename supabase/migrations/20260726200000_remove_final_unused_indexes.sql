-- Migration: Remove Final Unused Indexes
-- Description: Remove remaining unused indexes that have never been used
-- Note: Some indexes we just created (password_validation_logs_user_id, savings_history_user_id)
-- are marked as unused because they were just created. We'll keep them as they may be used.
-- Impact: Reduced storage overhead, improved write performance

-- User Blocked Apps
DROP INDEX IF EXISTS public.idx_user_blocked_apps_user_id;
DROP INDEX IF EXISTS public.idx_user_blocked_apps_package_name;
DROP INDEX IF EXISTS public.idx_user_blocked_apps_expires_at;

-- User Blocking Rules
DROP INDEX IF EXISTS public.idx_user_blocking_rules_user_id;
DROP INDEX IF EXISTS public.idx_user_blocking_rules_active;

-- Spending Gamification States
DROP INDEX IF EXISTS public.idx_spending_gamification_states_state_data_gin;

-- Money Saving Gamification States
DROP INDEX IF EXISTS public.idx_money_saving_gamification_states_state_data_gin;

-- User Behavior Events (keeping composite indexes we just created)
DROP INDEX IF EXISTS public.idx_user_behavior_events_user_id;
DROP INDEX IF EXISTS public.idx_user_behavior_events_type;
DROP INDEX IF EXISTS public.idx_user_behavior_events_module;
DROP INDEX IF EXISTS public.idx_user_behavior_events_created_at;
DROP INDEX IF EXISTS public.idx_user_behavior_events_session;

-- User Retention Metrics
DROP INDEX IF EXISTS public.idx_user_retention_metrics_user_id;
DROP INDEX IF EXISTS public.idx_user_retention_metrics_date;
DROP INDEX IF EXISTS public.idx_user_retention_metrics_active_modules;

-- User Achievements
DROP INDEX IF EXISTS public.idx_user_achievements_user_id;
DROP INDEX IF EXISTS public.idx_user_achievements_achievement_id;

-- User Module Settings
DROP INDEX IF EXISTS public.idx_user_module_settings_user_id;

-- User Module Status
DROP INDEX IF EXISTS public.idx_user_module_status_user_id;

-- User Niche Apps
DROP INDEX IF EXISTS public.idx_user_niche_apps_user_id;

-- User Niche Times
DROP INDEX IF EXISTS public.idx_user_niche_times_user_id;

-- User Entitlements
DROP INDEX IF EXISTS public.idx_user_entitlements_user_id;

-- Note: We're keeping the following indexes we just created:
-- - idx_password_validation_logs_user_id (for foreign key)
-- - idx_savings_history_user_id (for foreign key)
-- - idx_user_module_status_user_niche (composite)
-- - idx_user_niche_apps_user_niche (composite)
-- - idx_user_niche_times_user_niche (composite)
-- - idx_user_module_settings_user_module (composite)
-- - idx_user_behavior_events_user_type (composite)
-- - idx_user_behavior_events_created_at (composite)

COMMENT ON SCHEMA public IS 'Removed final batch of unused indexes';
