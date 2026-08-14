-- Migration: Harden auth security
-- Description: Enforce RLS for public.users and add a safe self-service delete_user RPC

-- ============================================
-- 1. RLS PARA public.users
-- ============================================

ALTER TABLE IF EXISTS public.users ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
DROP POLICY IF EXISTS "Users can delete own profile" ON public.users;

CREATE POLICY "Users can view own profile" ON public.users
  FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can delete own profile" ON public.users
  FOR DELETE
  USING (auth.uid() = id);

-- ============================================
-- 2. RPC SEGURA PARA EXCLUIR CONTA
-- ============================================

CREATE OR REPLACE FUNCTION public.delete_user(user_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
BEGIN
  IF auth.uid() IS NULL OR auth.uid() <> user_id THEN
    RAISE EXCEPTION 'permission denied';
  END IF;

  DELETE FROM public.users
  WHERE id = user_id;

  DELETE FROM auth.users
  WHERE id = user_id;
END;
$$;

REVOKE ALL ON FUNCTION public.delete_user(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.delete_user(UUID) TO authenticated;

