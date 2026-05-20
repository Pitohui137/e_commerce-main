-- Tambah status pesanan (untuk tabel yang sudah ada)
-- Jalankan di Supabase SQL Editor jika purchase_history sudah dibuat sebelumnya

alter table public.purchase_history
  add column if not exists status text not null default 'proses_pengantaran'
  check (status in ('proses_pengantaran', 'diterima'));

-- Pesanan lama (sebelum fitur status) dianggap sudah diterima
update public.purchase_history
  set status = 'diterima';

drop policy if exists "purchase_history_update_own" on public.purchase_history;
create policy "purchase_history_update_own"
  on public.purchase_history
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
