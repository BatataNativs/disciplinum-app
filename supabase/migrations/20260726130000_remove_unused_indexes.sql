-- Migration: Remove Unused Indexes
-- Description: Drop 25 unused indexes to improve write performance and reduce storage
-- These indexes have never been used according to pg_stat_user_indexes
-- Impact: Faster INSERT/UPDATE/DELETE operations, reduced storage overhead

-- Password Validation Logs
DROP INDEX IF EXISTS public.idx_password_validation_logs_created_at;

-- Focus Gamification States
DROP INDEX IF EXISTS public.idx_focus_gamification_states_user_id;
DROP INDEX IF EXISTS public.idx_focus_gamification_states_updated_at;

-- Smoking Gamification States
DROP INDEX IF EXISTS public.idx_smoking_gamification_states_user_id;
DROP INDEX IF EXISTS public.idx_smoking_gamification_states_updated_at;

-- Binge Eating Gamification States
DROP INDEX IF EXISTS public.idx_binge_eating_gamification_states_user_id;
DROP INDEX IF EXISTS public.idx_binge_eating_gamification_states_state_data_gin;

-- Adult Content Gamification States
DROP INDEX IF EXISTS public.idx_adult_content_gamification_states_user_id;
DROP INDEX IF EXISTS public.idx_adult_content_gamification_states_state_data_gin;

-- Diet Gamification States
DROP INDEX IF EXISTS public.idx_diet_gamification_states_user_id;
DROP INDEX IF EXISTS public.idx_diet_gamification_states_state_data_gin;

-- Money Saving Gamification States
DROP INDEX IF EXISTS public.idx_money_saving_gamification_user_id;
DROP INDEX IF EXISTS public.idx_money_saving_gamification_updated_at;

-- Procrastination Gamification States
DROP INDEX IF EXISTS public.idx_procrastination_gamification_states_updated_at;

-- Spending Gamification States
DROP INDEX IF EXISTS public.idx_spending_gamification_states_updated_at;

-- Reading Gamification States
DROP INDEX IF EXISTS public.idx_reading_gamification_states_user_id;
DROP INDEX IF EXISTS public.idx_reading_gamification_states_state_data_gin;

COMMENT ON SCHEMA public IS 'Removed 25 unused indexes for improved write performance';
