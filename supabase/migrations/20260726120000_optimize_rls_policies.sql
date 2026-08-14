-- Migration: Optimize RLS Policies for Performance
-- Description: Replace auth.uid() with (select auth.uid()) to prevent re-evaluation per row
-- This fixes 56 performance warnings across 9 gamification tables
-- Impact: Significant performance improvement at scale

-- Drop existing policies and recreate with optimized syntax

-- Adult Content Gamification States
DROP POLICY IF EXISTS adult_content_gamification_states_select ON public.adult_content_gamification_states;
DROP POLICY IF EXISTS adult_content_gamification_states_insert ON public.adult_content_gamification_states;
DROP POLICY IF EXISTS adult_content_gamification_states_update ON public.adult_content_gamification_states;
DROP POLICY IF EXISTS adult_content_gamification_states_delete ON public.adult_content_gamification_states;

CREATE POLICY adult_content_gamification_states_select ON public.adult_content_gamification_states
  FOR SELECT TO authenticated
  USING ((select auth.uid()) = user_id);

CREATE POLICY adult_content_gamification_states_insert ON public.adult_content_gamification_states
  FOR INSERT TO authenticated
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY adult_content_gamification_states_update ON public.adult_content_gamification_states
  FOR UPDATE TO authenticated
  USING ((select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY adult_content_gamification_states_delete ON public.adult_content_gamification_states
  FOR DELETE TO authenticated
  USING ((select auth.uid()) = user_id);

-- Binge Eating Gamification States
DROP POLICY IF EXISTS binge_eating_gamification_states_select ON public.binge_eating_gamification_states;
DROP POLICY IF EXISTS binge_eating_gamification_states_insert ON public.binge_eating_gamification_states;
DROP POLICY IF EXISTS binge_eating_gamification_states_update ON public.binge_eating_gamification_states;
DROP POLICY IF EXISTS binge_eating_gamification_states_delete ON public.binge_eating_gamification_states;

CREATE POLICY binge_eating_gamification_states_select ON public.binge_eating_gamification_states
  FOR SELECT TO authenticated
  USING ((select auth.uid()) = user_id);

CREATE POLICY binge_eating_gamification_states_insert ON public.binge_eating_gamification_states
  FOR INSERT TO authenticated
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY binge_eating_gamification_states_update ON public.binge_eating_gamification_states
  FOR UPDATE TO authenticated
  USING ((select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY binge_eating_gamification_states_delete ON public.binge_eating_gamification_states
  FOR DELETE TO authenticated
  USING ((select auth.uid()) = user_id);

-- Diet Gamification States
DROP POLICY IF EXISTS diet_gamification_states_select ON public.diet_gamification_states;
DROP POLICY IF EXISTS diet_gamification_states_insert ON public.diet_gamification_states;
DROP POLICY IF EXISTS diet_gamification_states_update ON public.diet_gamification_states;
DROP POLICY IF EXISTS diet_gamification_states_delete ON public.diet_gamification_states;

CREATE POLICY diet_gamification_states_select ON public.diet_gamification_states
  FOR SELECT TO authenticated
  USING ((select auth.uid()) = user_id);

CREATE POLICY diet_gamification_states_insert ON public.diet_gamification_states
  FOR INSERT TO authenticated
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY diet_gamification_states_update ON public.diet_gamification_states
  FOR UPDATE TO authenticated
  USING ((select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY diet_gamification_states_delete ON public.diet_gamification_states
  FOR DELETE TO authenticated
  USING ((select auth.uid()) = user_id);

-- Focus Gamification States
DROP POLICY IF EXISTS focus_gamification_states_select ON public.focus_gamification_states;
DROP POLICY IF EXISTS focus_gamification_states_insert ON public.focus_gamification_states;
DROP POLICY IF EXISTS focus_gamification_states_update ON public.focus_gamification_states;
DROP POLICY IF EXISTS focus_gamification_states_delete ON public.focus_gamification_states;

CREATE POLICY focus_gamification_states_select ON public.focus_gamification_states
  FOR SELECT TO authenticated
  USING ((select auth.uid()) = user_id);

CREATE POLICY focus_gamification_states_insert ON public.focus_gamification_states
  FOR INSERT TO authenticated
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY focus_gamification_states_update ON public.focus_gamification_states
  FOR UPDATE TO authenticated
  USING ((select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY focus_gamification_states_delete ON public.focus_gamification_states
  FOR DELETE TO authenticated
  USING ((select auth.uid()) = user_id);

-- Money Saving Gamification States
DROP POLICY IF EXISTS money_saving_gamification_states_select ON public.money_saving_gamification_states;
DROP POLICY IF EXISTS money_saving_gamification_states_insert ON public.money_saving_gamification_states;
DROP POLICY IF EXISTS money_saving_gamification_states_update ON public.money_saving_gamification_states;
DROP POLICY IF EXISTS money_saving_gamification_states_delete ON public.money_saving_gamification_states;

CREATE POLICY money_saving_gamification_states_select ON public.money_saving_gamification_states
  FOR SELECT TO authenticated
  USING ((select auth.uid()) = user_id);

CREATE POLICY money_saving_gamification_states_insert ON public.money_saving_gamification_states
  FOR INSERT TO authenticated
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY money_saving_gamification_states_update ON public.money_saving_gamification_states
  FOR UPDATE TO authenticated
  USING ((select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY money_saving_gamification_states_delete ON public.money_saving_gamification_states
  FOR DELETE TO authenticated
  USING ((select auth.uid()) = user_id);

-- Procrastination Gamification States
DROP POLICY IF EXISTS procrastination_gamification_states_select ON public.procrastination_gamification_states;
DROP POLICY IF EXISTS procrastination_gamification_states_insert ON public.procrastination_gamification_states;
DROP POLICY IF EXISTS procrastination_gamification_states_update ON public.procrastination_gamification_states;
DROP POLICY IF EXISTS procrastination_gamification_states_delete ON public.procrastination_gamification_states;

CREATE POLICY procrastination_gamification_states_select ON public.procrastination_gamification_states
  FOR SELECT TO authenticated
  USING ((select auth.uid()) = user_id);

CREATE POLICY procrastination_gamification_states_insert ON public.procrastination_gamification_states
  FOR INSERT TO authenticated
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY procrastination_gamification_states_update ON public.procrastination_gamification_states
  FOR UPDATE TO authenticated
  USING ((select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY procrastination_gamification_states_delete ON public.procrastination_gamification_states
  FOR DELETE TO authenticated
  USING ((select auth.uid()) = user_id);

-- Reading Gamification States
DROP POLICY IF EXISTS reading_gamification_states_select ON public.reading_gamification_states;
DROP POLICY IF EXISTS reading_gamification_states_insert ON public.reading_gamification_states;
DROP POLICY IF EXISTS reading_gamification_states_update ON public.reading_gamification_states;
DROP POLICY IF EXISTS reading_gamification_states_delete ON public.reading_gamification_states;

CREATE POLICY reading_gamification_states_select ON public.reading_gamification_states
  FOR SELECT TO authenticated
  USING ((select auth.uid()) = user_id);

CREATE POLICY reading_gamification_states_insert ON public.reading_gamification_states
  FOR INSERT TO authenticated
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY reading_gamification_states_update ON public.reading_gamification_states
  FOR UPDATE TO authenticated
  USING ((select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY reading_gamification_states_delete ON public.reading_gamification_states
  FOR DELETE TO authenticated
  USING ((select auth.uid()) = user_id);

-- Smoking Gamification States
DROP POLICY IF EXISTS smoking_gamification_states_select ON public.smoking_gamification_states;
DROP POLICY IF EXISTS smoking_gamification_states_insert ON public.smoking_gamification_states;
DROP POLICY IF EXISTS smoking_gamification_states_update ON public.smoking_gamification_states;
DROP POLICY IF EXISTS smoking_gamification_states_delete ON public.smoking_gamification_states;

CREATE POLICY smoking_gamification_states_select ON public.smoking_gamification_states
  FOR SELECT TO authenticated
  USING ((select auth.uid()) = user_id);

CREATE POLICY smoking_gamification_states_insert ON public.smoking_gamification_states
  FOR INSERT TO authenticated
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY smoking_gamification_states_update ON public.smoking_gamification_states
  FOR UPDATE TO authenticated
  USING ((select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY smoking_gamification_states_delete ON public.smoking_gamification_states
  FOR DELETE TO authenticated
  USING ((select auth.uid()) = user_id);

-- Spending Gamification States
DROP POLICY IF EXISTS spending_gamification_states_select ON public.spending_gamification_states;
DROP POLICY IF EXISTS spending_gamification_states_insert ON public.spending_gamification_states;
DROP POLICY IF EXISTS spending_gamification_states_update ON public.spending_gamification_states;
DROP POLICY IF EXISTS spending_gamification_states_delete ON public.spending_gamification_states;

CREATE POLICY spending_gamification_states_select ON public.spending_gamification_states
  FOR SELECT TO authenticated
  USING ((select auth.uid()) = user_id);

CREATE POLICY spending_gamification_states_insert ON public.spending_gamification_states
  FOR INSERT TO authenticated
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY spending_gamification_states_update ON public.spending_gamification_states
  FOR UPDATE TO authenticated
  USING ((select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) = user_id);

CREATE POLICY spending_gamification_states_delete ON public.spending_gamification_states
  FOR DELETE TO authenticated
  USING ((select auth.uid()) = user_id);

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

COMMENT ON SCHEMA public IS 'RLS policies optimized for performance - auth.uid() replaced with (select auth.uid())';
