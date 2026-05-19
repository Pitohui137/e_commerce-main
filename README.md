# e_commerce

## Fitur Jual (tambah produk)

Agar tombol **Jual** berfungsi, jalankan skrip SQL di Supabase:

1. Buka [Supabase Dashboard](https://supabase.com/dashboard) → project Anda → **SQL Editor**
2. Salin isi file `supabase/setup_user_products.sql` lalu **Run**
3. Pastikan bucket Storage `product-images` ada (public)

**Error `Could not find the 'image_url' column`?**  
Tabel `user_products` sudah ada tapi kolomnya tidak lengkap. Jalankan juga `supabase/fix_user_products_columns.sql`, lalu coba simpan produk lagi.

Setelah itu: login → tab **Jual** → **+ Jual** → isi form → **Upload & Simpan Produk**.

