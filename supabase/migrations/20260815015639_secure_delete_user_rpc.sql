-- Migration: 20260815015639_secure_delete_user_rpc.sql
-- Description: RPC seguro para exclusão de conta pelo próprio usuário

create or replace function public.delete_user(user_id uuid)
returns void
language plpgsql
security definer
set search_path = public, auth, storage
as $$
begin
  if auth.uid() is null or auth.uid() <> user_id then
    raise exception 'not authorized';
  end if;

  if exists (
    select 1
    from storage.objects
    where owner_id = user_id::text
  ) then
    raise exception 'USER_HAS_STORAGE_OBJECTS';
  end if;

  delete from auth.users
  where id = user_id;
end;
$$;

grant execute on function public.delete_user(uuid) to authenticated;
