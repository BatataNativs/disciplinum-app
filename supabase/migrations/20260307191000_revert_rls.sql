-- Reverter migração temporária e voltar ao RLS padrão
-- Isso remove os GRANT ALL e volta ao comportamento seguro com políticas

-- Remover permissões amplas do usuário anônimo
REVOKE ALL ON user_niche_apps FROM anon;
REVOKE ALL ON user_niche_times FROM anon;
REVOKE ALL ON user_module_status FROM anon;
REVOKE ALL ON user_entitlements FROM anon;

-- Manter RLS habilitado (com políticas padrão)
-- As políticas padrão já devem existir ou ser criadas posteriormente
