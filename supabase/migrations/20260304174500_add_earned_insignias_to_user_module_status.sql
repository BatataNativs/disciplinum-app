-- Adiciona a coluna earned_insignias à tabela user_module_status para persistência de conquistas
-- Esta coluna armazena os identificadores das insígnias conquistadas pelo usuário em cada módulo (ex: 'ferro', 'bronze', etc).

DO $$ 
BEGIN 
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'user_module_status' 
        AND column_name = 'earned_insignias'
    ) THEN
        ALTER TABLE user_module_status ADD COLUMN earned_insignias TEXT[] DEFAULT '{}';
    END IF;
END $$;

-- Comentário na coluna para documentação
COMMENT ON COLUMN user_module_status.earned_insignias IS 'Lista de IDs das insígnias conquistadas pelo usuário em cada módulo.';
