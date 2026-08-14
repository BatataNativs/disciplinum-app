-- Migration: Remove Remaining Unused Indexes
-- Description: Drop 23 additional unused indexes to improve write performance
-- These indexes have never been used according to pg_stat_user_indexes
-- Impact: Faster INSERT/UPDATE/DELETE operations, reduced storage overhead

-- User Entitlements
DROP INDEX IF EXISTS public.idx_user_entitlements_type;
DROP INDEX IF EXISTS public.idx_user_entitlements_expires;

-- User Module Status
DROP INDEX IF EXISTS public.idx_user_module_status_last_updated;
DROP INDEX IF EXISTS public.idx_module_status_user;

-- Common Compromised Passwords
DROP INDEX IF EXISTS public.idx_compromised_passwords_hash;

-- User Module Settings
DROP INDEX IF EXISTS public.idx_user_module_settings_setting_key;

-- Users
DROP INDEX IF EXISTS public.idx_users_email;

-- User Niche Apps
DROP INDEX IF EXISTS public.idx_niche_apps_user;

-- User Niche Times
DROP INDEX IF EXISTS public.idx_niche_times_user;

-- User Meal Records
DROP INDEX IF EXISTS public.idx_meal_records_user_date;

-- Binge Daily Checkins
DROP INDEX IF EXISTS public.idx_binge_checkins_date;
DROP INDEX IF EXISTS public.idx_binge_checkins_user_id;

-- Savings History
DROP INDEX IF EXISTS public.idx_savings_history_user_id;

-- Password Validation Logs
DROP INDEX IF EXISTS public.idx_password_validation_logs_user_id;

-- Composite indexes we just added (they're unused because they were just created)
-- We'll keep them as they may be used in the future
-- DROP INDEX IF EXISTS public.idx_user_module_status_user_niche;
-- DROP INDEX IF EXISTS public.idx_user_niche_apps_user_niche;
-- DROP INDEX IF EXISTS public.idx_user_niche_times_user_niche;
-- DROP INDEX IF EXISTS public.idx_user_module_settings_user_module;
-- DROP INDEX IF EXISTS public.idx_user_behavior_events_user_type;
-- DROP INDEX IF EXISTS public.idx_user_behavior_events_created_at;

COMMENT ON SCHEMA public IS 'Removed 23 additional unused indexes for improved write performance';
