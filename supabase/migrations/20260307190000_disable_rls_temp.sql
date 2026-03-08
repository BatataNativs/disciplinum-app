-- Migração temporária para desabilitar RLS enquanto as políticas não são criadas
-- Isso permite que o app funcione imediatamente

-- Desabilitar RLS nas tabelas principais
ALTER TABLE user_niche_apps DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_niche_times DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_module_status DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_entitlements DISABLE ROW LEVEL SECURITY;

-- Garantir que o usuário anônimo pode acessar as tabelas
GRANT ALL ON user_niche_apps TO anon;
GRANT ALL ON user_niche_times TO anon;
GRANT ALL ON user_module_status TO anon;
GRANT ALL ON user_entitlements TO anon;

-- Habilitar novamente sem políticas (temporário)
ALTER TABLE user_niche_apps ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_niche_times ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_module_status ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_entitlements ENABLE ROW LEVEL SECURITY;
