# 🛍️ Vernique — Aplikasi E-Commerce Fashion Mobile

> Tugas UTS Mata Kuliah Pemrograman Mobile  
> **Abyan Farhan**

---

## 📱 Tentang Aplikasi

**Vernique** adalah aplikasi mobile e-commerce fashion berbasis Flutter yang memungkinkan pengguna berperan sebagai pembeli sekaligus penjual. Katalog produk diambil dari [FakeStore API](https://fakestoreapi.com) dan dikombinasikan dengan produk yang diunggah langsung oleh pengguna melalui Supabase.

---

## ✨ Fitur Utama

| Fitur | Keterangan |
|---|---|
| 🔐 Autentikasi | Registrasi & login dengan email/password via Supabase Auth |
| 🛒 Katalog Produk | Grid produk fashion dengan filter kategori & pencarian real-time |
| 🛍️ Keranjang Belanja | Tambah, ubah kuantitas, hapus produk — tersimpan secara lokal |
| 💳 Checkout | Form alamat pengiriman + pilihan metode pembayaran (Bank, GoPay, OVO, DANA, COD) |
| 📦 Manajemen Pesanan | Pantau pesanan aktif & konfirmasi penerimaan barang |
| 📜 Riwayat Pembelian | Riwayat pesanan yang sudah dikonfirmasi diterima |
| 🏪 Jual Produk | Upload foto produk dari kamera/galeri, langsung tampil di katalog publik |

---

## 🏗️ Arsitektur

Aplikasi menggunakan pola **BLoC/Cubit** dengan pemisahan layer yang jelas:

```
UI (Widget/Screen)
    ↓ panggil method
Cubit (Business Logic)
    ↓ akses data
Repository (Abstraksi data)
    ↓ fetch/store
Service / API
(FakeStore API & Supabase)
```

### Struktur Folder

```
lib/
├── app/                    # Router & Theme
├── core/                   # Widget umum, utils, error handling
├── data/
│   ├── models/             # Data class (Product, Order, Cart, dll)
│   ├── repositories/       # Akses data (Auth, Cart, Order, Product, dll)
│   └── services/           # API client & ImagePicker
└── features/
    ├── auth/               # Login & Register
    ├── home/               # Katalog produk & Home screen
    ├── cart/               # Keranjang belanja
    ├── checkout/           # Proses checkout & sukses
    ├── order_history/      # Pesanan aktif & riwayat
    ├── jual/               # Tab jual produk milik user
    ├── insert_product/     # Form upload produk baru
    └── product_detail/     # Halaman detail produk
```

---

## 🛠️ Tech Stack

| Teknologi | Versi | Kegunaan |
|---|---|---|
| Flutter | 3.38+ | Framework UI mobile |
| Dart | 3.5+ | Bahasa pemrograman |
| flutter_bloc | 9.1.1 | State management (BLoC/Cubit) |
| supabase_flutter | 2.12+ | Auth, Database, Storage |
| dio | 5.9 | HTTP client (FakeStore API) |
| shared_preferences | 2.5+ | Penyimpanan lokal (keranjang & alamat) |
| image_picker | 1.2 | Pilih gambar dari kamera/galeri |
| cached_network_image | 3.4 | Cache gambar dari network |
| equatable | 2.0 | Perbandingan objek state |
| intl | 0.20 | Format tanggal & mata uang IDR |

---

## 🚀 Cara Menjalankan

### 1. Clone repository

```bash
git clone https://github.com/abyanfarhan/vernique.git
cd vernique
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Setup Supabase

Buka [Supabase Dashboard](https://supabase.com/dashboard) → project kamu → **SQL Editor**, lalu jalankan file SQL berikut secara berurutan:

```bash
# 1. Buat tabel riwayat pembelian
supabase/setup_purchase_history.sql

# 2. Tambah kolom status (jika tabel sudah ada sebelumnya)
supabase/add_purchase_history_status.sql

# 3. Setup katalog produk publik
supabase/user_products_public_catalog.sql
```

Pastikan juga bucket Storage bernama `product-images` sudah dibuat dan diset **public**.

### 4. Jalankan aplikasi

```bash
flutter run
```

---

## 🗄️ Skema Database Supabase

### Tabel `purchase_history`
Menyimpan data pesanan setiap pengguna.

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | uuid | Primary key |
| user_id | uuid | Referensi ke auth.users |
| payment_method | text | Metode pembayaran |
| subtotal | numeric | Total sebelum ongkir |
| shipping_fee | numeric | Biaya ongkir (default Rp 15.000) |
| total | numeric | Total keseluruhan |
| recipient_name | text | Nama penerima |
| phone | text | Nomor telepon |
| street, city, province, postal_code | text | Detail alamat |
| items | jsonb | Array item pesanan |
| status | text | `proses_pengantaran` / `diterima` |
| created_at | timestamptz | Waktu pembuatan |

### Tabel `user_products`
Menyimpan produk yang dijual oleh pengguna.

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | uuid | Primary key |
| user_id | uuid | Pemilik produk |
| title | text | Nama produk |
| price | numeric | Harga (IDR) |
| description | text | Deskripsi produk |
| category | text | Kategori fashion |
| image_url | text | URL foto di Supabase Storage |
| created_at | timestamptz | Waktu upload |

---

## 📸 Screenshot Aplikasi

| Halaman Login | Halaman Home | Halaman Checkout |
|:---:|:---:|:---:|
| *!(imgreadme/image.png)* | *!(imgreadme/image-1.png)* | *!(imgreadme/image-2.png)* |

| Keranjang | Pesanan Aktif | Jual Produk |
|:---:|:---:|:---:|
| *!(imgreadme/image-3.png)* | *!(imgreadme/image-4.png)* | *!(imgreadme/image-5.png)* |

---

## ⚠️ Catatan Penting

- Harga produk dari FakeStore API menggunakan **USD**, dikonversi otomatis ke **IDR** dengan kurs `1 USD = Rp 16.000`
- Ongkir menggunakan biaya flat **Rp 15.000** untuk simulasi
- Fitur pembayaran bersifat **simulasi** — tidak ada transaksi keuangan nyata

---

## 👤 Informasi Pengembang

|---|---|
| **Nama** | Abyan Farhan |
| **Mata Kuliah** | Pemrograman Mobile |
| **Semester 6** | Kelas MA1 |
| **Kampus** | ITB Swadharma |

---

## 📄 Lisensi

Proyek ini dibuat untuk keperluan akademik (Tugas UTS). Tidak untuk digunakan secara komersial.