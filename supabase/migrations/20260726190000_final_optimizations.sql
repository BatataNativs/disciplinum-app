-- Migration: Final Optimizations
-- Description: Fix remaining RLS policies, add missing indexes, remove last unused indexes
-- Impact: Complete performance optimization

-- User Retention Metrics RLS Policies
DROP POLICY IF EXISTS user_retention_metrics_select ON public.user_retention_metrics;
DROP POLICY IF EXISTS user_retention_metrics_insert ON public.user_retention_metrics;
DROP POLICY IF EXISTS user_retention_metrics_update ON public.user_retention_metrics;
DROP POLICY IF EXISTS user_retention_metrics_delete ON public.user_retention_metrics;

CREATE POLICY user_retention_metrics_select ON public.user_retention_metrics
  FOR SELECT TO authenticated
  USING ((select auth.uid()) = user_id);

CREATE POLICY user_retention_metrics_insert ON public.user_retention_metrics
  FOR INSERT TO authenticated
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY user_retention_metrics_update ON public.user_retention_metrics
  FOR UPDATE TO authenticated
  USING ((select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY user_retention_metrics_delete ON public.user_retention_metrics
  FOR DELETE TO authenticated
  USING ((select auth.uid()) = user_id);

-- Add indexes for unindexed foreign keys
CREATE INDEX IF NOT EXISTS idx_password_validation_logs_user_id 
ON public.password_validation_logs(user_id);

CREATE INDEX IF NOT EXISTS idx_savings_history_user_id 
ON public.savings_history(user_id);

-- Remove remaining unused indexes from gamification tables
DROP INDEX IF EXISTS public.idx_diet_gamification_states_updated_at;
DROP INDEX IF EXISTS public.idx_adult_content_gamification_states_updated_at;
DROP INDEX IF EXISTS public.idx_binge_eating_gamification_states_updated_at;
DROP INDEX IF EXISTS public.idx_reading_gamification_states_updated_at;
DROP INDEX IF EXISTS public.idx_smoking_gamification_states_state_data_gin;
DROP INDEX IF EXISTS public.idx_focus_gamification_states_state_data_gin;
DROP INDEX IF EXISTS public.idx_procrastination_gamification_states_state_data_gin;

COMMENT ON SCHEMA public IS 'Final optimizations completed';
