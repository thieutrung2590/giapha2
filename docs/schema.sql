-- ==========================================
-- TRIGGERS (FIXED)
-- ==========================================

-- 1. Updated At Triggers (GIỮ NGUYÊN)
DROP TRIGGER IF EXISTS tr_profiles_updated_at ON public.profiles;
CREATE TRIGGER tr_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();

DROP TRIGGER IF EXISTS tr_persons_updated_at ON public.persons;
CREATE TRIGGER tr_persons_updated_at BEFORE UPDATE ON public.persons FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();

DROP TRIGGER IF EXISTS tr_person_details_private_updated_at ON public.person_details_private;
CREATE TRIGGER tr_person_details_private_updated_at BEFORE UPDATE ON public.person_details_private FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();

DROP TRIGGER IF EXISTS tr_relationships_updated_at ON public.relationships;
CREATE TRIGGER tr_relationships_updated_at BEFORE UPDATE ON public.relationships FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();

DROP TRIGGER IF EXISTS tr_custom_events_updated_at ON public.custom_events;
CREATE TRIGGER tr_custom_events_updated_at BEFORE UPDATE ON public.custom_events FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();


-- ==========================================
-- 2. HANDLE NEW USER (FIX TRIỆT ĐỂ)
-- ==========================================

DROP FUNCTION IF EXISTS public.handle_new_user CASCADE;

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger 
LANGUAGE plpgsql
SECURITY DEFINER 
SET search_path = public
AS $$
DECLARE
  admin_exists boolean;
BEGIN
  -- KHÔNG dùng auth.users nữa
  SELECT EXISTS (
    SELECT 1 FROM public.profiles WHERE role = 'admin'
  ) INTO admin_exists;

  INSERT INTO public.profiles (id, role, is_active)
  VALUES (
    NEW.id, 
    CASE 
      WHEN NOT admin_exists THEN 'admin'::public.user_role_enum 
      ELSE 'member'::public.user_role_enum 
    END,
    true
  );

  RETURN NEW;
END;
$$;


-- ==========================================
-- 3. XÓA AUTO CONFIRM LỖI
-- ==========================================

DROP FUNCTION IF EXISTS public.handle_first_user_confirmation CASCADE;
DROP TRIGGER IF EXISTS on_auth_user_created_confirm ON auth.users;


-- ==========================================
-- 4. TRIGGER TẠO PROFILE
-- ==========================================

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW 
EXECUTE FUNCTION public.handle_new_user();
