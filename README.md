# e_commerce

## Fitur Jual (tambah produk)

Agar tombol **Jual** berfungsi, jalankan skrip SQL di Supabase:

1. Buka [Supabase Dashboard](https://supabase.com/dashboard) → project Anda → **SQL Editor**
2. Salin isi file `supabase/setup_user_products.sql` lalu **Run**
3. Pastikan bucket Storage `product-images` ada (public)

**Error `Could not find the 'image_url' column`?**  
Tabel `user_products` sudah ada tapi kolomnya tidak lengkap. Jalankan juga `supabase/fix_user_products_columns.sql`, lalu coba simpan produk lagi.

Setelah itu: login → tab **Jual** → **+ Jual** → isi form → **Upload & Simpan Produk**.

### Katalog Produk (semua user)

Agar produk dari **Jual** muncul di tab **Produk** untuk semua akun, jalankan:

`supabase/user_products_public_catalog.sql`

Tanpa skrip ini, setiap user hanya melihat produk miliknya sendiri di tab Produk.

## Riwayat pembelian (checkout + Supabase)

Agar checkout menyimpan pesanan ke database:

1. Buka Supabase Dashboard → **SQL Editor**
2. Jalankan isi file `supabase/setup_purchase_history.sql`
3. Tabel `purchase_history` akan dibuat dengan RLS (hanya user login yang bisa baca/tulis pesanannya sendiri)

**Tabel sudah ada tanpa kolom status?** Jalankan juga `supabase/add_purchase_history_status.sql`.

Setelah itu: isi keranjang → **Checkout** → bayar → status **Proses pengantaran**.  
Di **Profil** → **Pesanan Aktif** → tekan **Pesanan Diterima** setelah barang sampai.  
Baru kemudian pesanan muncul di **Riwayat Pembelian**.

