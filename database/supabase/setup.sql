-- ==========================================
-- TFG ClassNexus - Base de Datos (Fase 1)
-- ==========================================

-- 1. Tabla de Perfiles (Extensión de auth.users)
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  first_name TEXT,
  last_name TEXT,
  avatar_url TEXT,
  role_id INTEGER, -- (Se enlazará luego a public.roles)
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);

-- Habilitar RLS en public.profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Política: Un usuario puede ver cualquier perfil (útil para el chat / alumnos listados)
CREATE POLICY "Perfiles son visibles por todos los logueados"
  ON public.profiles FOR SELECT
  USING ( auth.role() = 'authenticated' );

-- Política: Un usuario solo puede actualizar su propio perfil
CREATE POLICY "Usuarios pueden actualizar su propio perfil"
  ON public.profiles FOR UPDATE
  USING ( auth.uid() = id );

-- 2. Función y Trigger: Automáticamente crear un 'profile' al registrar en Auth
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, first_name, last_name, avatar_url)
  VALUES (new.id, new.raw_user_meta_data->>'first_name', new.raw_user_meta_data->>'last_name', new.raw_user_meta_data->>'avatar_url');
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- ==========================================
-- Fin del script Fase 1 - Auth Base
-- ==========================================
