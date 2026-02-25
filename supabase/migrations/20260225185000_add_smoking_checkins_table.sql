-- Tabela para registrar os check-ins diários do módulo Parar de Fumar
-- Cada registro representa um dia em que o usuário respondeu "Sim" ao check-in
CREATE TABLE IF NOT EXISTS public.smoking_daily_checkins (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  check_date DATE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, check_date)
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_smoking_checkins_user_id ON public.smoking_daily_checkins(user_id);
CREATE INDEX IF NOT EXISTS idx_smoking_checkins_date ON public.smoking_daily_checkins(user_id, check_date);

-- RLS (Row Level Security)
ALTER TABLE public.smoking_daily_checkins ENABLE ROW LEVEL SECURITY;

-- Política única para todas as operações do próprio usuário
CREATE POLICY "Users can manage their own smoking checkins"
  ON public.smoking_daily_checkins
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
