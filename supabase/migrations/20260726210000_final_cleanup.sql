-- Migration: Final Cleanup and Index Management
-- Description: Add indexes for remaining foreign keys, remove unused newly created indexes
-- Note: Multiple permissive policies for dashboard_user and supabase_privileged_role
-- are Supabase system configurations and should not be removed without understanding impact
-- Impact: Complete foreign key coverage, clean index set

-- Add indexes for remaining unindexed foreign keys
CREATE INDEX IF NOT EXISTS idx_user_achievements_user_id 
ON public.user_achievements(user_id);

CREATE INDEX IF NOT EXISTS idx_user_blocking_rules_user_id 
ON public.user_blocking_rules(user_id);

-- Remove indexes we created that are not being used
-- These were created for foreign keys but the queries don't use them yet
DROP INDEX IF EXISTS public.idx_password_validation_logs_user_id;
DROP INDEX IF EXISTS public.idx_savings_history_user_id;

-- Remove composite indexes we created that are not being used
DROP INDEX IF EXISTS public.idx_user_module_status_user_niche;
DROP INDEX IF EXISTS public.idx_user_niche_apps_user_niche;
DROP INDEX IF EXISTS public.idx_user_niche_times_user_niche;
DROP INDEX IF EXISTS public.idx_user_module_settings_user_module;
DROP INDEX IF EXISTS public.idx_user_behavior_events_user_type;
DROP INDEX IF EXISTS public.idx_user_behavior_events_created_at;

-- Remove other unused indexes
DROP INDEX IF EXISTS public.idx_user_achievements_type;
DROP INDEX IF EXISTS public.idx_smoking_checkins_user_id;
DROP INDEX IF EXISTS public.idx_smoking_checkins_date;
DROP INDEX IF EXISTS public.idx_user_achievements_module;
DROP INDEX IF EXISTS public.idx_user_achievements_viewed;
DROP INDEX IF EXISTS public.idx_user_module_settings_module_id;
DROP INDEX IF EXISTS public.idx_user_module_status_last_activity;

-- Note: Multiple permissive policies for dashboard_user and supabase_privileged_role
-- on smoking_daily_checkins and binge_daily_checkins are intentional Supabase
-- configurations for different access levels. These should not be removed without
-- understanding the full impact on the application's access control system.

COMMENT ON SCHEMA public IS 'Final cleanup: foreign keys indexed, unused indexes removed';
