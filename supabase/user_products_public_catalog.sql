-- Katalog Produk: semua user bisa melihat produk dari semua penjual
-- Tab Jual tetap hanya mengelola produk sendiri (insert/delete dengan user_id)
-- Jalankan di Supabase SQL Editor

alter table public.user_products enable row level security;

-- Ganti policy SELECT yang membatasi per user (jika ada)
drop policy if exists "user_products_select_own" on public.user_products;
drop policy if exists "Users can view own products" on public.user_products;
drop policy if exists "user_products_select_public" on public.user_products;

create policy "user_products_select_public"
  on public.user_products
  for select
  to authenticated
  using (true);

-- Pastikan insert/delete tetap milik user sendiri (abaikan error jika sudah ada)
drop policy if exists "user_products_insert_own" on public.user_products;
create policy "user_products_insert_own"
  on public.user_products
  for insert
  to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "user_products_delete_own" on public.user_products;
create policy "user_products_delete_own"
  on public.user_products
  for delete
  to authenticated
  using (auth.uid() = user_id);
