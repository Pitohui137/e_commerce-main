-- Aman dijalankan ulang (Supabase Dashboard → SQL Editor → Run)

-- Tabel produk jualan user
create table if not exists public.user_products (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  title text not null,
  price numeric not null check (price >= 0),
  description text not null,
  category text not null,
  image_url text not null,
  created_at timestamptz not null default now()
);

-- Jika tabel sudah ada tanpa kolom lengkap (mis. tanpa image_url)
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

create index if not exists user_products_user_id_idx
  on public.user_products (user_id);

alter table public.user_products enable row level security;

drop policy if exists "user_products_select_own" on public.user_products;
create policy "user_products_select_own"
  on public.user_products for select
  using (auth.uid() = user_id);

drop policy if exists "user_products_insert_own" on public.user_products;
create policy "user_products_insert_own"
  on public.user_products for insert
  with check (auth.uid() = user_id);

drop policy if exists "user_products_delete_own" on public.user_products;
create policy "user_products_delete_own"
  on public.user_products for delete
  using (auth.uid() = user_id);

-- Bucket foto produk
insert into storage.buckets (id, name, public)
values ('product-images', 'product-images', true)
on conflict (id) do nothing;

drop policy if exists "product_images_select_public" on storage.objects;
create policy "product_images_select_public"
  on storage.objects for select
  using (bucket_id = 'product-images');

drop policy if exists "product_images_insert_own_folder" on storage.objects;
create policy "product_images_insert_own_folder"
  on storage.objects for insert
  with check (
    bucket_id = 'product-images'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

drop policy if exists "product_images_delete_own_folder" on storage.objects;
create policy "product_images_delete_own_folder"
  on storage.objects for delete
  using (
    bucket_id = 'product-images'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

notify pgrst, 'reload schema';
