-- Hanya perbaiki kolom + refresh cache (tanpa menyentuh policy)
-- Gunakan jika setup_user_products.sql gagal karena policy sudah ada

alter table public.user_products
  add column if not exists user_id uuid references auth.users (id) on delete cascade;
alter table public.user_products add column if not exists title text;
alter table public.user_products add column if not exists price numeric;
alter table public.user_products add column if not exists description text;
alter table public.user_products add column if not exists category text;
alter table public.user_products add column if not exists image_url text;
alter table public.user_products
  add column if not exists created_at timestamptz default now();

do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'user_products'
      and column_name = 'image'
  ) then
    update public.user_products
    set image_url = image
    where image_url is null and image is not null;
  end if;
end $$;

notify pgrst, 'reload schema';
