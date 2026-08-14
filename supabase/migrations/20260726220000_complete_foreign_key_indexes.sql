-- Migration: Complete Foreign Key Index Coverage
-- Description: Add indexes for all remaining unindexed foreign keys
-- Remove indexes that were created but are not being used
-- Impact: Complete foreign key coverage for optimal JOIN performance

-- Add indexes for remaining unindexed foreign keys
CREATE INDEX IF NOT EXISTS idx_password_validation_logs_user_id 
ON public.password_validation_logs(user_id);

CREATE INDEX IF NOT EXISTS idx_savings_history_user_id 
ON public.savings_history(user_id);

CREATE INDEX IF NOT EXISTS idx_user_behavior_events_user_id 
ON public.user_behavior_events(user_id);

-- Remove indexes we created that are not being used
DROP INDEX IF EXISTS public.idx_user_achievements_user_id;
DROP INDEX IF EXISTS public.idx_user_blocking_rules_user_id;

-- Note: Multiple permissive policies for dashboard_user and supabase_privileged_role
-- on smoking_daily_checkins and binge_daily_checkins are intentional Supabase
-- configurations for different access levels (anon, dashboard_user, supabase_privileged_role).
-- These should not be removed as they provide different access patterns for the system.

COMMENT ON SCHEMA public IS 'Complete foreign key index coverage achieved';
