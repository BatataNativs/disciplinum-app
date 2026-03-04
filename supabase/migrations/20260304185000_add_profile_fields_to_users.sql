-- Migration: Adicionar campos de biografia e privacidade à tabela users
-- Descrição: Alinha o banco de dados com o novo modelo UserProfile.dart

DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='bio') THEN
        ALTER TABLE public.users ADD COLUMN bio TEXT;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='show_email') THEN
        ALTER TABLE public.users ADD COLUMN show_email BOOLEAN DEFAULT TRUE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='show_avatar') THEN
        ALTER TABLE public.users ADD COLUMN show_avatar BOOLEAN DEFAULT TRUE;
    END IF;
END $$;
