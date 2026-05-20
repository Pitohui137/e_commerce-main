-- Riwayat pembelian (checkout) — jalankan di Supabase SQL Editor
-- Dashboard → SQL Editor → paste → Run

create table if not exists public.purchase_history (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  payment_method text not null,
  subtotal numeric(14, 2) not null check (subtotal >= 0),
  shipping_fee numeric(14, 2) not null default 15000 check (shipping_fee >= 0),
  total numeric(14, 2) not null check (total >= 0),
  recipient_name text not null,
  phone text not null,
  street text not null,
  city text not null,
  province text not null,
  postal_code text not null,
  items jsonb not null default '[]'::jsonb,
  status text not null default 'proses_pengantaran'
    check (status in ('proses_pengantaran', 'diterima')),
  created_at timestamptz not null default now()
);

create index if not exists purchase_history_user_id_idx
  on public.purchase_history (user_id);

create index if not exists purchase_history_created_at_idx
  on public.purchase_history (created_at desc);

alter table public.purchase_history enable row level security;

drop policy if exists "purchase_history_select_own" on public.purchase_history;
create policy "purchase_history_select_own"
  on public.purchase_history
  for select
  to authenticated
  using (auth.uid() = user_id);

drop policy if exists "purchase_history_insert_own" on public.purchase_history;
create policy "purchase_history_insert_own"
  on public.purchase_history
  for insert
  to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "purchase_history_update_own" on public.purchase_history;
create policy "purchase_history_update_own"
  on public.purchase_history
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
