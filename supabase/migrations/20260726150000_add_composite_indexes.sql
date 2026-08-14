-- Migration: Add Composite Indexes for Common Queries
-- Description: Add composite indexes for frequently used query patterns
-- These indexes improve performance for queries filtering by user_id + other columns
-- Impact: Faster queries for user-specific data retrieval

-- User Module Status: user_id + niche_id is a common query pattern
CREATE INDEX IF NOT EXISTS idx_user_module_status_user_niche 
ON public.user_module_status(user_id, niche_id);

-- User Niche Apps: user_id + niche_id is a common query pattern
CREATE INDEX IF NOT EXISTS idx_user_niche_apps_user_niche 
ON public.user_niche_apps(user_id, niche_id);

-- User Niche Times: user_id + niche_id is a common query pattern
CREATE INDEX IF NOT EXISTS idx_user_niche_times_user_niche 
ON public.user_niche_times(user_id, niche_id);

-- User Module Settings: user_id + module_id is a common query pattern
CREATE INDEX IF NOT EXISTS idx_user_module_settings_user_module 
ON public.user_module_settings(user_id, module_id);

-- User Behavior Events: user_id + event_type is a common query pattern
CREATE INDEX IF NOT EXISTS idx_user_behavior_events_user_type 
ON public.user_behavior_events(user_id, event_type);

-- User Behavior Events: created_at for time-based queries
CREATE INDEX IF NOT EXISTS idx_user_behavior_events_created_at 
ON public.user_behavior_events(created_at DESC);

COMMENT ON SCHEMA public IS 'Added composite indexes for common query patterns';
