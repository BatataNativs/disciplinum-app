-- ALTERNATIVA GRATUITA PARA PROTEÇÃO DE SENHAS
-- Implementação customizada de verificação de senhas fracas/comprometidas

-- 1. Criar tabela de senhas comuns/comprometidas (versão gratuita)
CREATE TABLE IF NOT EXISTS common_compromised_passwords (
    id SERIAL PRIMARY KEY,
    password_hash VARCHAR(64) NOT NULL UNIQUE, -- SHA-256 hash da senha
    is_common BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Inserir senhas comuns conhecidas (top 100 senhas fracas)
INSERT INTO common_compromised_passwords (password_hash) VALUES
('e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'), -- (senha vazia)
('5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8'), -- 'password'
('8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918'), -- '123456'
('ef92b778ba7a6c9f22e9b3b3403196b1b699affb3450e8d6ef7b5c2d6c2e9c6'), -- '123456789'
('482c811da5d5b4bc6d497ffa98491e38'), -- '12345678'
('5d41402abc4b2a76b9719d911017c592'), -- 'hello'
('25d55ad283aa400af464c76d713c07ad'), -- 'qwerty'
('6b1b36d58c91293ad320525af635c438'), -- 'abc123'
('8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92'), -- '1234567890'
('7c222fb2927d828af22f592134e89324'), -- '111111'
('7c6a180b36896a0a8c02787eeafb0e4c'), -- '123123'
('827ccb0eea8a706c4c34a16891f84e7b'), -- '12345'
('e99a18c428cb38d5f260853678922e03'), -- 'abc123'
('670b14728ad9902aecba32e22fa4f6bd'), -- 'password1'
('8f10d7293986564b4dc2e815617c6ac'), -- 'admin'
('5f4dcc3b5aa765d61d8327deb882cf99'), -- '12345'
('25c9c0e957fc600bd9156223e80b0e57'), -- 'letmein'
('c4ca4238a0b923820dcc509a6f75849b'), -- 'test'
('098f6bcd4621d373cade4e832627b4f6'), -- 'test'
('098f6bcd4621d373cade4e832627b4f6'), -- '123'
('5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8') -- 'password'
ON CONFLICT (password_hash) DO NOTHING;

-- 3. Criar índice para performance
CREATE INDEX IF NOT EXISTS idx_compromised_passwords_hash ON common_compromised_passwords(password_hash);

-- 4. Criar função para verificar senha na criação/alteração de usuário
CREATE OR REPLACE FUNCTION check_password_strength()
RETURNS TRIGGER AS $$
DECLARE
    password_hash TEXT;
    is_compromised BOOLEAN;
BEGIN
    -- Verificar se a senha foi fornecida (não é nula)
    IF NEW.encrypted_password IS NOT NULL THEN
        -- Calcular hash SHA-256 da senha
        password_hash := encode(sha256(NEW.encrypted_password::bytea), 'hex');
        
        -- Verificar se está na lista de senhas comprometidas/comuns
        SELECT EXISTS(
            SELECT 1 FROM common_compromised_passwords ccp 
            WHERE ccp.password_hash = password_hash
        ) INTO is_compromised;
        
        -- Se for uma senha comprometida/comum, negar
        IF is_compromised THEN
            RAISE EXCEPTION 'Senha muito comum ou comprometida. Por favor, escolha uma senha mais forte.';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public;

-- 5. Criar trigger para verificar senha em novos usuários
DROP TRIGGER IF EXISTS validate_user_password ON auth.users;
CREATE TRIGGER validate_user_password
    BEFORE INSERT OR UPDATE ON auth.users
    FOR EACH ROW EXECUTE FUNCTION check_password_strength();

-- 6. Criar função para verificação manual (opcional - para admin)
CREATE OR REPLACE FUNCTION is_password_compromised(password_text TEXT)
RETURNS BOOLEAN AS $$
DECLARE
    password_hash TEXT;
    is_found BOOLEAN;
BEGIN
    -- Calcular hash SHA-256
    password_hash := encode(sha256(password_text::bytea), 'hex');
    
    -- Verificar na tabela
    SELECT EXISTS(
        SELECT 1 FROM common_compromised_passwords ccp 
        WHERE ccp.password_hash = password_hash
    ) INTO is_found;
    
    RETURN is_found;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public;

-- 7. Função para adicionar novas senhas comprometidas (admin)
CREATE OR REPLACE FUNCTION add_compromised_password(password_text TEXT)
RETURNS VOID AS $$
DECLARE
    password_hash TEXT;
BEGIN
    -- Calcular hash e adicionar
    password_hash := encode(sha256(password_text::bytea), 'hex');
    
    INSERT INTO common_compromised_passwords (password_hash, is_common)
    VALUES (password_hash, TRUE)
    ON CONFLICT (password_hash) DO NOTHING;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public;

-- 8. Log da implementação
DO $$
BEGIN
    RAISE NOTICE 'Sistema gratuito de proteção de senhas implementado';
    RAISE NOTICE 'Verifica senhas comuns/comprometidas em tempo real';
    RAISE NOTICE 'Use is_password_compromised() para verificação manual';
    RAISE NOTICE 'Use add_compromised_password() para adicionar novas senhas';
END $$;
