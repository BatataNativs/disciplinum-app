-- Fix for updated_at trigger error
-- The trigger was referencing NEW.updated_at but the column doesn't exist in user_module_status

-- First, drop the problematic trigger if it exists
DROP TRIGGER IF EXISTS update_user_module_status_updated_at ON user_module_status;

-- Check if the column exists, and if not, add it
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name='user_module_status' 
        AND column_name='updated_at'
    ) THEN
        ALTER TABLE user_module_status 
        ADD COLUMN updated_at TIMESTAMPTZ DEFAULT NOW();
    END IF;
END $$;

-- Recreate the trigger with correct column name
CREATE OR REPLACE FUNCTION update_module_status_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger only if it doesn't exist
CREATE TRIGGER update_user_module_status_updated_at 
    BEFORE UPDATE ON user_module_status 
    FOR EACH ROW EXECUTE FUNCTION update_module_status_updated_at();

-- Also ensure last_updated column exists and is updated
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name='user_module_status' 
        AND column_name='last_updated'
    ) THEN
        ALTER TABLE user_module_status 
        ADD COLUMN last_updated TIMESTAMPTZ DEFAULT NOW();
    END IF;
END $$;

-- Update the existing trigger to also update last_updated
CREATE OR REPLACE FUNCTION update_module_status_last_updated()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_updated = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Ensure trigger exists for last_updated
DROP TRIGGER IF EXISTS update_user_module_status_last_updated ON user_module_status;
CREATE TRIGGER update_user_module_status_last_updated 
    BEFORE UPDATE ON user_module_status 
    FOR EACH ROW EXECUTE FUNCTION update_module_status_last_updated();
