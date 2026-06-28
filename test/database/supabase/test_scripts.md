-- =============================================================================
-- SCRIPTS SQL DE VERIFICAÇÃO — Disciplinum (Supabase)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- TESTE 1: FK de password_validation_logs deve ser CASCADE
-- -----------------------------------------------------------------------------
SELECT
  '1 - FK password_validation_logs' AS teste,
  CASE
    WHEN rc.delete_rule = 'CASCADE' THEN '✅ ON DELETE CASCADE'
    ELSE '❌ FALHOU — ainda é: ' || rc.delete_rule
  END AS resultado
FROM information_schema.table_constraints tc
JOIN information_schema.referential_constraints rc ON tc.constraint_name = rc.constraint_name
WHERE tc.table_schema = 'public'
  AND tc.table_name = 'password_validation_logs'
  AND tc.constraint_type = 'FOREIGN KEY';

-- -----------------------------------------------------------------------------
-- TESTE 2: Todas as tabelas com user_id devem ter ON DELETE CASCADE
-- -----------------------------------------------------------------------------
SELECT
  '2 - Cascades completos' AS teste,
  tc.table_name,
  CASE
    WHEN rc.delete_rule = 'CASCADE' THEN '✅ CASCADE'
    ELSE '❌ ' || rc.delete_rule
  END AS resultado
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name AND tc.table_schema = kcu.table_schema
JOIN information_schema.referential_constraints rc
  ON tc.constraint_name = rc.constraint_name
JOIN information_schema.constraint_column_usage ccu
  ON rc.unique_constraint_name = ccu.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'public'
  AND kcu.column_name = 'user_id'
ORDER BY tc.table_name;

-- -----------------------------------------------------------------------------
-- TESTE 3: Funções SECURITY DEFINER bloqueadas para anon/authenticated
-- -----------------------------------------------------------------------------
SELECT
  '3 - SECURITY DEFINER bloqueadas' AS teste,
  p.proname AS funcao,
  r.rolname AS role,
  CASE
    WHEN has_function_privilege(r.oid, p.oid, 'EXECUTE') = false THEN '✅ BLOQUEADA'
    ELSE '❌ EXPOSTA — revogar!'
  END AS resultado
FROM pg_proc p
JOIN pg_roles r ON r.rolname IN ('anon', 'authenticated')
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'public'
  AND p.proname IN (
    'add_compromised_password','add_compromised_password_safe','delete_user',
    'ensure_schema_version','handle_new_user','is_password_compromised',
    'rls_auto_enable','update_module_status_activity_date',
    'update_module_status_last_updated','update_module_status_updated_at',
    'update_updated_at_column','validate_user_password_safe','verify_password_strength'
  )
ORDER BY p.proname, r.rolname;

-- -----------------------------------------------------------------------------
-- TESTE 4: RLS habilitado em todas as tabelas públicas
-- -----------------------------------------------------------------------------
SELECT
  '4 - RLS habilitado' AS teste,
  tablename,
  CASE
    WHEN rowsecurity THEN '✅ RLS ON'
    ELSE '❌ RLS OFF'
  END AS resultado
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;

-- -----------------------------------------------------------------------------
-- TESTE 5: Policies otimizadas com (SELECT auth.uid())
-- -----------------------------------------------------------------------------
SELECT
  '5 - RLS initplan otimizado' AS teste,
  tablename,
  policyname,
  cmd,
  CASE
    -- "Service role" policies não referenciam auth.uid() — isso é correto
    WHEN policyname ILIKE '%service role%' THEN
      'ℹ️ Service role — não usa auth.uid() (correto)'

    -- Formato otimizado: Postgres armazena (SELECT auth.uid()) como ( SELECT auth.uid() AS uid)
    WHEN qual    ILIKE '%( SELECT auth.uid() AS uid)%'
      OR qual    ILIKE '%(SELECT auth.uid() AS uid)%'
      OR with_check ILIKE '%( SELECT auth.uid() AS uid)%'
      OR with_check ILIKE '%(SELECT auth.uid() AS uid)%'
      THEN
      '✅ OTIMIZADA — (SELECT auth.uid())'

    -- Formato não otimizado: auth.uid() chamado diretamente (sem subselect)
    WHEN qual    LIKE '%auth.uid()%'
      OR with_check LIKE '%auth.uid()%'
      THEN
      '❌ NÃO otimizada — auth.uid() direto'

    ELSE 'ℹ️ Sem referência a auth.uid()'
  END AS resultado
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename IN (
    'users','user_module_status','user_module_settings',
    'user_niche_apps','user_niche_times','savings_history',
    'user_meal_records','smoking_daily_checkins','binge_daily_checkins',
    'user_entitlements','user_blocked_apps'
  )
ORDER BY tablename, policyname;

-- -----------------------------------------------------------------------------
-- TESTE 6: Índice em savings_history(user_id)
-- -----------------------------------------------------------------------------
SELECT
  '6 - Índice savings_history.user_id' AS teste,
  CASE
    WHEN COUNT(*) > 0 THEN '✅ Índice existe'
    ELSE '❌ Índice não encontrado'
  END AS resultado
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename = 'savings_history'
  AND indexname = 'idx_savings_history_user_id';

-- -----------------------------------------------------------------------------
-- TESTE 7: Políticas RLS do bucket avatars no storage
-- -----------------------------------------------------------------------------
SELECT
  '7 - Storage avatars RLS' AS teste,
  policyname,
  cmd AS operacao,
  '✅ Existe' AS resultado
FROM pg_policies
WHERE schemaname = 'storage' AND tablename = 'objects'
ORDER BY policyname;

-- -----------------------------------------------------------------------------
-- TESTE 8: Função delete_user deleta via auth.uid()
-- -----------------------------------------------------------------------------
SELECT
  '8 - delete_user() corpo' AS teste,
  CASE
    WHEN prosrc LIKE '%DELETE FROM auth.users WHERE id = auth.uid()%'
      OR prosrc LIKE '%DELETE FROM auth.users%current_user_id%'
    THEN '✅ Deleta o próprio usuário via auth.uid()'
    ELSE '⚠️ Revisar corpo da função manualmente'
  END AS resultado
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'public' AND p.proname = 'delete_user';

-- =============================================================================
-- FIM — Todos os ✅ = projeto em conformidade
-- =====================================================