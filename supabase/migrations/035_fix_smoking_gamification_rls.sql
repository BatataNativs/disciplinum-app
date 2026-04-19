-- Migration: Fix RLS policies for smoking_gamification_states
-- Date: 2026-04-19
-- Problem: Supabase RLS was blocking access to smoking_gamification_states table
-- Solution: Create proper RLS policies for authenticated users (safely, only if not exists)

-- Enable RLS on the table (if not already enabled)
ALTER TABLE IF EXISTS smoking_gamification_states ENABLE ROW LEVEL SECURITY;

-- Create policies safely using DO block (avoiding errors if policy already exists)
DO $$
BEGIN
  -- SELECT policy
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'smoking_gamification_states' 
    AND policyname = 'Users can view own smoking gamification'
  ) THEN
    CREATE POLICY "Users can view own smoking gamification"
      ON smoking_gamification_states
      FOR SELECT
      USING (auth.uid() = user_id);
  END IF;

  -- INSERT policy
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'smoking_gamification_states' 
    AND policyname = 'Users can insert own smoking gamification'
  ) THEN
    CREATE POLICY "Users can insert own smoking gamification"
      ON smoking_gamification_states
      FOR INSERT
      WITH CHECK (auth.uid() = user_id);
  END IF;

  -- UPDATE policy
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'smoking_gamification_states' 
    AND policyname = 'Users can update own smoking gamification'
  ) THEN
    CREATE POLICY "Users can update own smoking gamification"
      ON smoking_gamification_states
      FOR UPDATE
      USING (auth.uid() = user_id)
      WITH CHECK (auth.uid() = user_id);
  END IF;

  -- DELETE policy
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'smoking_gamification_states' 
    AND policyname = 'Users can delete own smoking gamification'
  ) THEN
    CREATE POLICY "Users can delete own smoking gamification"
      ON smoking_gamification_states
      FOR DELETE
      USING (auth.uid() = user_id);
  END IF;
END $$;

-- Also fix RLS for user_module_settings (if needed)
ALTER TABLE IF EXISTS user_module_settings ENABLE ROW LEVEL SECURITY;

-- Create policies safely for user_module_settings
DO $$
BEGIN
  -- SELECT policy
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'user_module_settings' 
    AND policyname = 'Users can view own module settings'
  ) THEN
    CREATE POLICY "Users can view own module settings"
      ON user_module_settings
      FOR SELECT
      USING (auth.uid() = user_id);
  END IF;

  -- INSERT policy
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'user_module_settings' 
    AND policyname = 'Users can insert own module settings'
  ) THEN
    CREATE POLICY "Users can insert own module settings"
      ON user_module_settings
      FOR INSERT
      WITH CHECK (auth.uid() = user_id);
  END IF;

  -- UPDATE policy
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'user_module_settings' 
    AND policyname = 'Users can update own module settings'
  ) THEN
    CREATE POLICY "Users can update own module settings"
      ON user_module_settings
      FOR UPDATE
      USING (auth.uid() = user_id)
      WITH CHECK (auth.uid() = user_id);
  END IF;

  -- DELETE policy
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'user_module_settings' 
    AND policyname = 'Users can delete own module settings'
  ) THEN
    CREATE POLICY "Users can delete own module settings"
      ON user_module_settings
      FOR DELETE
      USING (auth.uid() = user_id);
  END IF;
END $$;
