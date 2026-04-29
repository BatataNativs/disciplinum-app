-- Adiciona constraint UNIQUE para permitir upsert no CloudSyncService
-- Isso resolve o erro: "there is no unique or exclusion constraint matching the ON CONFLICT specification"

-- Primeiro, remove duplicatas se existirem (mantém o mais recente)
WITH duplicates AS (
  SELECT id,
         ROW_NUMBER() OVER (PARTITION BY user_id, module_id, setting_key ORDER BY updated_at DESC) as rn
  FROM user_module_settings
)
DELETE FROM user_module_settings
WHERE id IN (SELECT id FROM duplicates WHERE rn > 1);

-- Adiciona a constraint UNIQUE
ALTER TABLE user_module_settings
ADD CONSTRAINT unique_user_module_setting 
UNIQUE (user_id, module_id, setting_key);
