-- Migration: Optimize Remaining RLS Policies for Performance
-- Description: Replace auth.uid() with (select auth.uid()) for remaining tables
-- This fixes additional 52 performance warnings across 13 tables
-- Impact: Significant performance improvement at scale

-- User Achievements
DROP POLICY IF EXISTS user_achievements_select ON public.user_achievements;
DROP POLICY IF EXISTS user_achievements_insert ON public.user_achievements;
DROP POLICY IF EXISTS user_achievements_update ON public.user_achievements;
DROP POLICY IF EXISTS user_achievements_delete ON public.user_achievements;

CREATE POLICY user_achievements_select ON public.user_achievements
  FOR SELECT TO authenticated
  USING ((select auth.uid()) = user_id);

CREATE POLICY user_achievements_insert ON public.user_achievements
  FOR INSERT TO authenticated
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY user_achievements_update ON public.user_achievements
  FOR UPDATE TO authenticated
  USING ((select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY user_achievements_delete ON public.user_achievements
  FOR DELETE TO authenticated
  USING ((select auth.uid()) = user_id);

-- User Behavior Events
DROP POLICY IF EXISTS user_behavior_events_select ON public.user_behavior_events;
DROP POLICY IF EXISTS user_behavior_events_insert ON public.user_behavior_events;
DROP POLICY IF EXISTS user_behavior_events_update ON public.user_behavior_events;
DROP POLICY IF EXISTS user_behavior_events_delete ON public.user_behavior_events;

CREATE POLICY user_behavior_events_select ON public.user_behavior_events
  FOR SELECT TO authenticated
  USING ((select auth.uid()) = user_id);

CREATE POLICY user_behavior_events_insert ON public.user_behavior_events
  FOR INSERT TO authenticated
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY user_behavior_events_update ON public.user_behavior_events
  FOR UPDATE TO authenticated
  USING ((select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY user_behavior_events_delete ON public.user_behavior_events
  FOR DELETE TO authenticated
  USING ((select auth.uid()) = user_id);

-- User Blocking Rules
DROP POLICY IF EXISTS user_blocking_rules_select ON public.user_blocking_rules;
DROP POLICY IF EXISTS user_blocking_rules_insert ON public.user_blocking_rules;
DROP POLICY IF EXISTS user_blocking_rules_update ON public.user_blocking_rules;
DROP POLICY IF EXISTS user_blocking_rules_delete ON public.user_blocking_rules;

CREATE POLICY user_blocking_rules_select ON public.user_blocking_rules
  FOR SELECT TO authenticated
  USING ((select auth.uid()) = user_id);

CREATE POLICY user_blocking_rules_insert ON public.user_blocking_rules
  FOR INSERT TO authenticated
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY user_blocking_rules_update ON public.user_blocking_rules
  FOR UPDATE TO authenticated
  USING ((select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY user_blocking_rules_delete ON public.user_blocking_rules
  FOR DELETE TO authenticated
  USING ((select auth.uid()) = user_id);

-- User Blocked Apps
DROP POLICY IF EXISTS user_blocked_apps_select ON public.user_blocked_apps;
DROP POLICY IF EXISTS user_blocked_apps_insert ON public.user_blocked_apps;
DROP POLICY IF EXISTS user_blocked_apps_update ON public.user_blocked_apps;
DROP POLICY IF EXISTS user_blocked_apps_delete ON public.user_blocked_apps;

CREATE POLICY user_blocked_apps_select ON public.user_blocked_apps
  FOR SELECT TO authenticated
  USING ((select auth.uid()) = user_id);

CREATE POLICY user_blocked_apps_insert ON public.user_blocked_apps
  FOR INSERT TO authenticated
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY user_blocked_apps_update ON public.user_blocked_apps
  FOR UPDATE TO authenticated
  USING ((select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY user_blocked_apps_delete ON public.user_blocked_apps
  FOR DELETE TO authenticated
  USING ((select auth.uid()) = user_id);

-- User Entitlements
DROP POLICY IF EXISTS user_entitlements_select ON public.user_entitlements;
DROP POLICY IF EXISTS user_entitlements_insert ON public.user_entitlements;
DROP POLICY IF EXISTS user_entitlements_update ON public.user_entitlements;
DROP POLICY IF EXISTS user_entitlements_delete ON public.user_entitlements;

CREATE POLICY user_entitlements_select ON public.user_entitlements
  FOR SELECT TO authenticated
  USING ((select auth.uid()) = user_id);

CREATE POLICY user_entitlements_insert ON public.user_entitlements
  FOR INSERT TO authenticated
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY user_entitlements_update ON public.user_entitlements
  FOR UPDATE TO authenticated
  USING ((select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY user_entitlements_delete ON public.user_entitlements
  FOR DELETE TO authenticated
  USING ((select auth.uid()) = user_id);

-- User Module Status
DROP POLICY IF EXISTS user_module_status_select ON public.user_module_status;
DROP POLICY IF EXISTS user_module_status_insert ON public.user_module_status;
DROP POLICY IF EXISTS user_module_status_update ON public.user_module_status;
DROP POLICY IF EXISTS user_module_status_delete ON public.user_module_status;

CREATE POLICY user_module_status_select ON public.user_module_status
  FOR SELECT TO authenticated
  USING ((select auth.uid()) = user_id);

CREATE POLICY user_module_status_insert ON public.user_module_status
  FOR INSERT TO authenticated
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY user_module_status_update ON public.user_module_status
  FOR UPDATE TO authenticated
  USING ((select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY user_module_status_delete ON public.user_module_status
  FOR DELETE TO authenticated
  USING ((select auth.uid()) = user_id);

-- User Niche Apps
DROP POLICY IF EXISTS user_niche_apps_select ON public.user_niche_apps;
DROP POLICY IF EXISTS user_niche_apps_insert ON public.user_niche_apps;
DROP POLICY IF EXISTS user_niche_apps_update ON public.user_niche_apps;
DROP POLICY IF EXISTS user_niche_apps_delete ON public.user_niche_apps;

CREATE POLICY user_niche_apps_select ON public.user_niche_apps
  FOR SELECT TO authenticated
  USING ((select auth.uid()) = user_id);

CREATE POLICY user_niche_apps_insert ON public.user_niche_apps
  FOR INSERT TO authenticated
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY user_niche_apps_update ON public.user_niche_apps
  FOR UPDATE TO authenticated
  USING ((select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY user_niche_apps_delete ON public.user_niche_apps
  FOR DELETE TO authenticated
  USING ((select auth.uid()) = user_id);

-- User Niche Times
DROP POLICY IF EXISTS user_niche_times_select ON public.user_niche_times;
DROP POLICY IF EXISTS user_niche_times_insert ON public.user_niche_times;
DROP POLICY IF EXISTS user_niche_times_update ON public.user_niche_times;
DROP POLICY IF EXISTS user_niche_times_delete ON public.user_niche_times;

CREATE POLICY user_niche_times_select ON public.user_niche_times
  FOR SELECT TO authenticated
  USING ((select auth.uid()) = user_id);

CREATE POLICY user_niche_times_insert ON public.user_niche_times
  FOR INSERT TO authenticated
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY user_niche_times_update ON public.user_niche_times
  FOR UPDATE TO authenticated
  USING ((select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY user_niche_times_delete ON public.user_niche_times
  FOR DELETE TO authenticated
  USING ((select auth.uid()) = user_id);

-- User Meal Records
DROP POLICY IF EXISTS user_meal_records_select ON public.user_meal_records;
DROP POLICY IF EXISTS user_meal_records_insert ON public.user_meal_records;
DROP POLICY IF EXISTS user_meal_records_update ON public.user_meal_records;
DROP POLICY IF EXISTS user_meal_records_delete ON public.user_meal_records;

CREATE POLICY user_meal_records_select ON public.user_meal_records
  FOR SELECT TO authenticated
  USING ((select auth.uid()) = user_id);

CREATE POLICY user_meal_records_insert ON public.user_meal_records
  FOR INSERT TO authenticated
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY user_meal_records_update ON public.user_meal_records
  FOR UPDATE TO authenticated
  USING ((select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY user_meal_records_delete ON public.user_meal_records
  FOR DELETE TO authenticated
  USING ((select auth.uid()) = user_id);

-- Savings History
DROP POLICY IF EXISTS savings_history_select ON public.savings_history;
DROP POLICY IF EXISTS savings_history_insert ON public.savings_history;
DROP POLICY IF EXISTS savings_history_update ON public.savings_history;
DROP POLICY IF EXISTS savings_history_delete ON public.savings_history;

CREATE POLICY savings_history_select ON public.savings_history
  FOR SELECT TO authenticated
  USING ((select auth.uid()) = user_id);

CREATE POLICY savings_history_insert ON public.savings_history
  FOR INSERT TO authenticated
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY savings_history_update ON public.savings_history
  FOR UPDATE TO authenticated
  USING ((select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY savings_history_delete ON public.savings_history
  FOR DELETE TO authenticated
  USING ((select auth.uid()) = user_id);

-- Smoking Daily Checkins
DROP POLICY IF EXISTS "Users can manage their own smoking checkins" ON public.smoking_daily_checkins;

CREATE POLICY "Users can manage their own smoking checkins"
  ON public.smoking_daily_checkins
  FOR ALL
  USING ((select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) = user_id);

-- Binge Daily Checkins
DROP POLICY IF EXISTS "Users can manage their own binge checkins" ON public.binge_daily_checkins;

CREATE POLICY "Users can manage their own binge checkins"
  ON public.binge_daily_checkins
  FOR ALL
  USING ((select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) = user_id);

-- Password Validation Logs
DROP POLICY IF EXISTS password_validation_logs_select ON public.password_validation_logs;
DROP POLICY IF EXISTS password_validation_logs_insert ON public.password_validation_logs;
DROP POLICY IF EXISTS password_validation_logs_update ON public.password_validation_logs;
DROP POLICY IF EXISTS password_validation_logs_delete ON public.password_validation_logs;

CREATE POLICY password_validation_logs_select ON public.password_validation_logs
  FOR SELECT TO authenticated
  USING ((select auth.uid()) = user_id);

CREATE POLICY password_validation_logs_insert ON public.password_validation_logs
  FOR INSERT TO authenticated
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY password_validation_logs_update ON public.password_validation_logs
  FOR UPDATE TO authenticated
  USING ((select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY password_validation_logs_delete ON public.password_validation_logs
  FOR DELETE TO authenticated
  USING ((select auth.uid()) = user_id);
