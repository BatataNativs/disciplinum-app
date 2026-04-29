-- Adiciona coluna setting_value à tabela user_module_settings
-- Esta coluna é usada para armazenar valores de configuração como timestamps

ALTER TABLE user_module_settings 
ADD COLUMN IF NOT EXISTS setting_value TEXT;

-- Adiciona comentário para documentação
COMMENT ON COLUMN user_module_settings.setting_value IS 'Valor da configuração (ex: timestamp ISO8601)';
