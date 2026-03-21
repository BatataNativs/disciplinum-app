-- SISTEMA MELHORADO DE VERIFICAÇÃO DE SENHAS FRACAS
-- Versão 2.0 - Sem conflitos com auth.users

-- 1. Manter tabela de senhas comprometidas (já existe)
-- A tabela common_compromised_passwords já foi criada e será mantida

-- 2. Criar função segura de verificação (sem triggers automáticos)
CREATE OR REPLACE FUNCTION verify_password_strength(password_text TEXT)
RETURNS TABLE(is_strong BOOLEAN, reason TEXT) AS $$
DECLARE
    password_hash TEXT;
    is_compromised BOOLEAN;
    password_length INTEGER;
BEGIN
    -- Verificar comprimento mínimo
    password_length := length(password_text);
    IF password_length < 8 THEN
        RETURN QUERY SELECT FALSE, 'Senha deve ter pelo menos 8 caracteres'::TEXT;
        RETURN;
    END IF;
    
    -- Calcular hash SHA-256
    password_hash := encode(sha256(password_text::bytea), 'hex');
    
    -- Verificar se está na lista de senhas comprometidas/comuns
    SELECT EXISTS(
        SELECT 1 FROM common_compromised_passwords ccp 
        WHERE ccp.password_hash = password_hash
    ) INTO is_compromised;
    
    IF is_compromised THEN
        RETURN QUERY SELECT FALSE, 'Senha muito comum ou comprometida. Escolha uma senha mais forte.'::TEXT;
        RETURN;
    END IF;
    
    -- Verificar complexidade básica
    IF password_text ~* '[A-Z]' AND password_text ~* '[a-z]' AND password_text ~* '[0-9]' THEN
        RETURN QUERY SELECT TRUE, 'Senha forte'::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'Senha deve conter letras maiúsculas, minúsculas e números'::TEXT;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public;

-- 3. Criar função para validação no lado do app (chamada manual)
CREATE OR REPLACE FUNCTION validate_user_password_safe(user_id UUID, password_text TEXT)
RETURNS BOOLEAN AS $$
DECLARE
    validation_result RECORD;
BEGIN
    -- Verificar força da senha
    SELECT * INTO validation_result 
    FROM verify_password_strength(password_text)
    LIMIT 1;
    
    -- Se não for forte, registrar log e retornar false
    IF NOT validation_result.is_strong THEN
        INSERT INTO password_validation_logs (user_id, password_hash, validation_reason, created_at)
        VALUES (user_id, encode(sha256(password_text::bytea), 'hex'), validation_result.reason, NOW());
        RETURN FALSE;
    END IF;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public;

-- 4. Criar tabela de logs de validação (opcional)
CREATE TABLE IF NOT EXISTS password_validation_logs (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id),
    password_hash VARCHAR(64),
    validation_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_password_validation_logs_user_id ON password_validation_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_password_validation_logs_created_at ON password_validation_logs(created_at);

-- 5. Função para admin adicionar senhas comprometidas
CREATE OR REPLACE FUNCTION add_compromised_password_safe(password_text TEXT)
RETURNS VOID AS $$
DECLARE
    password_hash TEXT;
BEGIN
    password_hash := encode(sha256(password_text::bytea), 'hex');
    
    INSERT INTO common_compromised_passwords (password_hash, is_common)
    VALUES (password_hash, TRUE)
    ON CONFLICT (password_hash) DO NOTHING;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public;

-- 6. Log da implementação
DO $$
BEGIN
    RAISE NOTICE 'Sistema melhorado de verificação de senhas implementado';
    RAISE NOTICE 'Funções disponíveis:';
    RAISE NOTICE '- verify_password_strength() para verificação manual';
    RAISE NOTICE '- validate_user_password_safe() para validação controlada';
    RAISE NOTICE '- add_compromised_password_safe() para admin';
    RAISE NOTICE 'Nenhum trigger automático - sem conflitos com auth.users';
END $$;
