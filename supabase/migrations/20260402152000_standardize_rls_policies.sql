-- Migration: Standardize RLS Policies for All Gamification Tables
-- Description: Cria políticas RLS padronizadas para todas as 9 tabelas de gamificação
-- Created: 2026-04-02
-- Depends: 20260402150000_standardize_gamification_tables.sql

-- ============================================
-- 1. TEMPLATE DE POLÍTICAS RLS
-- ============================================

-- Políticas padronizadas para cada tabela:
-- 1. SELECT: usuários só veem seus próprios dados
-- 2. INSERT: usuários só inserem seus próprios dados  
-- 3. UPDATE: usuários só atualizam seus próprios dados
-- 4. DELETE: usuários só deletam seus próprios dados

-- ============================================
-- 2. SMOKING_GAMIFICATION_STATES
-- ============================================

-- Remover políticas existentes (se houver)
DROP POLICY IF EXISTS "Users can only see their own smoking data" ON smoking_gamification_states;
DROP POLICY IF EXISTS "Users can only insert their own smoking data" ON smoking_gamification_states;
DROP POLICY IF EXISTS "Users can only update their own smoking data" ON smoking_gamification_states;
DROP POLICY IF EXISTS "Users can only delete their own smoking data" ON smoking_gamification_states;

-- Criar políticas
CREATE POLICY "Users can only see their own smoking data" ON smoking_gamification_states
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can only insert their own smoking data" ON smoking_gamification_states
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can only update their own smoking data" ON smoking_gamification_states
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can only delete their own smoking data" ON smoking_gamification_states
  FOR DELETE USING (auth.uid() = user_id);

-- ============================================
-- 3. FOCUS_GAMIFICATION_STATES
-- ============================================

DROP POLICY IF EXISTS "Users can only see their own focus data" ON focus_gamification_states;
DROP POLICY IF EXISTS "Users can only insert their own focus data" ON focus_gamification_states;
DROP POLICY IF EXISTS "Users can only update their own focus data" ON focus_gamification_states;
DROP POLICY IF EXISTS "Users can only delete their own focus data" ON focus_gamification_states;

CREATE POLICY "Users can only see their own focus data" ON focus_gamification_states
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can only insert their own focus data" ON focus_gamification_states
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can only update their own focus data" ON focus_gamification_states
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can only delete their own focus data" ON focus_gamification_states
  FOR DELETE USING (auth.uid() = user_id);

-- ============================================
-- 4. DIET_GAMIFICATION_STATES
-- ============================================

DROP POLICY IF EXISTS "Users can only see their own diet data" ON diet_gamification_states;
DROP POLICY IF EXISTS "Users can only insert their own diet data" ON diet_gamification_states;
DROP POLICY IF EXISTS "Users can only update their own diet data" ON diet_gamification_states;
DROP POLICY IF EXISTS "Users can only delete their own diet data" ON diet_gamification_states;

CREATE POLICY "Users can only see their own diet data" ON diet_gamification_states
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can only insert their own diet data" ON diet_gamification_states
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can only update their own diet data" ON diet_gamification_states
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can only delete their own diet data" ON diet_gamification_states
  FOR DELETE USING (auth.uid() = user_id);

-- ============================================
-- 5. MONEY_SAVING_GAMIFICATION_STATES
-- ============================================

DROP POLICY IF EXISTS "Users can only see their own money_saving data" ON money_saving_gamification_states;
DROP POLICY IF EXISTS "Users can only insert their own money_saving data" ON money_saving_gamification_states;
DROP POLICY IF EXISTS "Users can only update their own money_saving data" ON money_saving_gamification_states;
DROP POLICY IF EXISTS "Users can only delete their own money_saving data" ON money_saving_gamification_states;

CREATE POLICY "Users can only see their own money_saving data" ON money_saving_gamification_states
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can only insert their own money_saving data" ON money_saving_gamification_states
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can only update their own money_saving data" ON money_saving_gamification_states
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can only delete their own money_saving data" ON money_saving_gamification_states
  FOR DELETE USING (auth.uid() = user_id);

-- ============================================
-- 6. READING_GAMIFICATION_STATES
-- ============================================

DROP POLICY IF EXISTS "Users can only see their own reading data" ON reading_gamification_states;
DROP POLICY IF EXISTS "Users can only insert their own reading data" ON reading_gamification_states;
DROP POLICY IF EXISTS "Users can only update their own reading data" ON reading_gamification_states;
DROP POLICY IF EXISTS "Users can only delete their own reading data" ON reading_gamification_states;

CREATE POLICY "Users can only see their own reading data" ON reading_gamification_states
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can only insert their own reading data" ON reading_gamification_states
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can only update their own reading data" ON reading_gamification_states
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can only delete their own reading data" ON reading_gamification_states
  FOR DELETE USING (auth.uid() = user_id);

-- ============================================
-- 7. BINGE_EATING_GAMIFICATION_STATES
-- ============================================

DROP POLICY IF EXISTS "Users can only see their own binge_eating data" ON binge_eating_gamification_states;
DROP POLICY IF EXISTS "Users can only insert their own binge_eating data" ON binge_eating_gamification_states;
DROP POLICY IF EXISTS "Users can only update their own binge_eating data" ON binge_eating_gamification_states;
DROP POLICY IF EXISTS "Users can only delete their own binge_eating data" ON binge_eating_gamification_states;

CREATE POLICY "Users can only see their own binge_eating data" ON binge_eating_gamification_states
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can only insert their own binge_eating data" ON binge_eating_gamification_states
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can only update their own binge_eating data" ON binge_eating_gamification_states
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can only delete their own binge_eating data" ON binge_eating_gamification_states
  FOR DELETE USING (auth.uid() = user_id);

-- ============================================
-- 8. ADULT_CONTENT_GAMIFICATION_STATES
-- ============================================

DROP POLICY IF EXISTS "Users can only see their own adult_content data" ON adult_content_gamification_states;
DROP POLICY IF EXISTS "Users can only insert their own adult_content data" ON adult_content_gamification_states;
DROP POLICY IF EXISTS "Users can only update their own adult_content data" ON adult_content_gamification_states;
DROP POLICY IF EXISTS "Users can only delete their own adult_content data" ON adult_content_gamification_states;

CREATE POLICY "Users can only see their own adult_content data" ON adult_content_gamification_states
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can only insert their own adult_content data" ON adult_content_gamification_states
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can only update their own adult_content data" ON adult_content_gamification_states
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can only delete their own adult_content data" ON adult_content_gamification_states
  FOR DELETE USING (auth.uid() = user_id);

-- ============================================
-- 9. PROCRASTINATION_GAMIFICATION_STATES
-- ============================================

DROP POLICY IF EXISTS "Users can only see their own procrastination data" ON procrastination_gamification_states;
DROP POLICY IF EXISTS "Users can only insert their own procrastination data" ON procrastination_gamification_states;
DROP POLICY IF EXISTS "Users can only update their own procrastination data" ON procrastination_gamification_states;
DROP POLICY IF EXISTS "Users can only delete their own procrastination data" ON procrastination_gamification_states;

CREATE POLICY "Users can only see their own procrastination data" ON procrastination_gamification_states
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can only insert their own procrastination data" ON procrastination_gamification_states
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can only update their own procrastination data" ON procrastination_gamification_states
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can only delete their own procrastination data" ON procrastination_gamification_states
  FOR DELETE USING (auth.uid() = user_id);

-- ============================================
-- 10. SPENDING_GAMIFICATION_STATES
-- ============================================

DROP POLICY IF EXISTS "Users can only see their own spending data" ON spending_gamification_states;
DROP POLICY IF EXISTS "Users can only insert their own spending data" ON spending_gamification_states;
DROP POLICY IF EXISTS "Users can only update their own spending data" ON spending_gamification_states;
DROP POLICY IF EXISTS "Users can only delete their own spending data" ON spending_gamification_states;

CREATE POLICY "Users can only see their own spending data" ON spending_gamification_states
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can only insert their own spending data" ON spending_gamification_states
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can only update their own spending data" ON spending_gamification_states
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can only delete their own spending data" ON spending_gamification_states
  FOR DELETE USING (auth.uid() = user_id);

-- ============================================
-- 11. VERIFICAÇÃO FINAL
-- ============================================

-- Verificar que todas as tabelas têm RLS ativo
SELECT 
  schemaname,
  tablename,
  rowsecurity AS rls_enabled
FROM pg_tables
WHERE tablename LIKE '%_gamification_states'
ORDER BY tablename;
