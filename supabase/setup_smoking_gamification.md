# Setup do Supabase para Smoking Gamification

## 📋 Pré-requisitos
- Projeto Supabase criado
- Auth configurado
- Permissões de administrador

## 🗄️ Migration SQL

Execute o seguinte SQL no painel do Supabase (SQL Editor):

```sql
-- Migration: Create smoking_gamification_states table
-- Para armazenar estado de gamificação do módulo Smoking na nuvem

CREATE TABLE IF NOT EXISTS smoking_gamification_states (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    state_data JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_smoking_gamification_states_user_id ON smoking_gamification_states(user_id);
CREATE INDEX IF NOT EXISTS idx_smoking_gamification_states_updated_at ON smoking_gamification_states(updated_at);

-- RLS (Row Level Security) - apenas o dono pode ver/alterar seus dados
ALTER TABLE smoking_gamification_states ENABLE ROW LEVEL SECURITY;

-- Política para usuários autenticados verem seus próprios dados
CREATE POLICY "Users can view their own smoking gamification states"
    ON smoking_gamification_states FOR SELECT
    USING (auth.uid() = user_id);

-- Política para usuários autenticados inserirem seus próprios dados
CREATE POLICY "Users can insert their own smoking gamification states"
    ON smoking_gamification_states FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Política para usuários autenticados atualizarem seus próprios dados
CREATE POLICY "Users can update their own smoking gamification states"
    ON smoking_gamification_states FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Trigger para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_smoking_gamification_states_updated_at
    BEFORE UPDATE ON smoking_gamification_states
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Comentários da tabela
COMMENT ON TABLE smoking_gamification_states IS 'Tabela para armazenar estado de gamificação do módulo Smoking';
COMMENT ON COLUMN smoking_gamification_states.state_data IS 'Dados JSON do estado de gamificação (insígnias, medalhas, streak, etc)';
COMMENT ON COLUMN smoking_gamification_states.user_id IS 'ID do usuário dono do estado';
COMMENT ON COLUMN smoking_gamification_states.created_at IS 'Data de criação do registro';
COMMENT ON COLUMN smoking_gamification_states.updated_at IS 'Data da última atualização do registro';
```

## 🔧 Verificação de Schema

Após executar a migration, verifique se a tabela foi criada:

```sql
-- Verificar estrutura da tabela
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'smoking_gamification_states'
ORDER BY ordinal_position;

-- Verificar políticas RLS
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'smoking_gamification_states';

-- Verificar triggers
SELECT event_object_table, trigger_name, action_timing, action_condition, action_orientation
FROM information_schema.triggers 
WHERE event_object_table = 'smoking_gamification_states';
```

## 🧪 Teste de Conectividade

Use este código Dart para testar a conexão:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> testSmokingGamificationConnection() async {
  try {
    final supabase = Supabase.instance.client;
    
    // Testar inserção
    final testData = {
      'user_id': supabase.auth.currentUser?.id,
      'state_data': {
        'earnedInsignias': ['test_insignia'],
        'earnedMedalhas': ['test_medalha'],
        'consecutivePositiveDays': 5,
        'disciplinumCount': 1,
        'dailyCost': 10.0,
        'packCost': 25.0
      },
    };
    
    final result = await supabase
        .from('smoking_gamification_states')
        .insert(testData)
        .select()
        .single();
    
    print('✅ Inserção bem-sucedida: $result');
    
    // Testar consulta
    final userId = supabase.auth.currentUser?.id;
    final states = await supabase
        .from('smoking_gamification_states')
        .select('*')
        .eq('user_id', userId);
    
    print('✅ Consulta bem-sucedida: ${states.length} registros');
    
    // Limpar teste
    await supabase
        .from('smoking_gamification_states')
        .delete()
        .eq('id', result['id']);
    
    print('✅ Limpeza concluída');
    
  } catch (e) {
    print('❌ Erro: $e');
  }
}
```

## 📊 Estrutura do JSON state_data

O campo `state_data` armazena:

```json
{
  "earnedInsignias": ["first_day", "week_warrior", "month_champion"],
  "earnedMedalhas": ["bronze_discipline", "silver_consistency"],
  "consecutivePositiveDays": 15,
  "disciplinumCount": 3,
  "lastPositiveCheckIn": "2024-03-25T20:00:00.000Z",
  "startDate": "2024-03-01T00:00:00.000Z",
  "dailyCost": 15.50,
  "packCost": 35.00,
  "createdAt": "2024-03-25T20:00:00.000Z",
  "updatedAt": "2024-03-25T20:00:00.000Z"
}
```

## 🚀 Deploy Checklist

- [ ] Executar migration SQL no Supabase
- [ ] Verificar criação da tabela
- [ ] Confirmar políticas RLS
- [ ] Testar conectividade com app
- [ ] Validar sincronização
- [ ] Testar fallback offline-first

## 🔍 Troubleshooting

### Erros Comuns:

1. **"relation 'auth.users' does not exist"**
   - Execute: `CREATE EXTENSION IF NOT EXISTS "uuid-ossp";`

2. **"permission denied for table smoking_gamification_states"**
   - Verifique se as políticas RLS foram criadas
   - Confirme se o usuário está autenticado

3. **"column 'state_data' does not exist"**
   - Verifique se a migration foi executada completamente
   - Confirme o nome da tabela

4. **"JSON value is not valid"**
   - Valide o JSON antes de enviar
   - Use `json.encode()` do Dart

## 📱 Integração com App

O repositório já está configurado para:
- ✅ Salvar automaticamente no Supabase após salvar localmente
- ✅ Carregar do Supabase se não encontrar dados locais
- ✅ Sincronização bidirecional
- ✅ Tratamento de erros robusto
