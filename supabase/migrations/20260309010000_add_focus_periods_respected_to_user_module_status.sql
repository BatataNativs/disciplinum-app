-- Adiciona a coluna focus_periods_respected à tabela user_module_status para controle de períodos de foco
-- Esta coluna armazena o número de períodos de foco respeitados pelo usuário no módulo de foco

DO $$ 
BEGIN 
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'user_module_status' 
        AND column_name = 'focus_periods_respected'
    ) THEN
        ALTER TABLE user_module_status ADD COLUMN focus_periods_respected INTEGER DEFAULT 0;
    END IF;
END $$;

-- Comentário na coluna para documentação
COMMENT ON COLUMN user_module_status.focus_periods_respected IS 'Número de períodos de foco respeitados pelo usuário no módulo de foco.';
