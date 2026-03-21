-- CORREÇÃO DE EMERGÊNCIA: CONFLITO PASSWORD_HASH
-- Migration para corrigir o erro de login imediatamente

-- 1. Remover trigger que está causando o conflito
DROP TRIGGER IF EXISTS validate_user_password ON auth.users;

-- 2. Remover função problemática
DROP FUNCTION IF EXISTS check_password_strength();

-- 3. Remover função de verificação com erro
DROP FUNCTION IF EXISTS is_password_compromised();

-- 4. Manter apenas a tabela de senhas comprometidas (sem triggers)
-- A tabela pode ser útil para verificações manuais futuras

-- 5. Log da correção
DO $$
BEGIN
    RAISE NOTICE 'Trigger validate_user_password removido - RESOLVIDO conflito password_hash';
    RAISE NOTICE 'Função check_password_strength removida';
    RAISE NOTICE 'Login deve funcionar normalmente agora';
    RAISE NOTICE 'Sistema de proteção de senhas foi desabilitado temporariamente';
END $$;
