# Portofolio Analisis Data Toko Buku (SQL & Python)

Repositori ini berisi kumpulan skrip otomatisasi dan analisis data *end-to-end* untuk mengevaluasi performa operasional toko buku dan perilaku pelanggan. Proyek ini menggabungkan kekuatan ekstraksi data SQL dengan manipulasi dan visualisasi data menggunakan Python.

## 🛠️ Tech Stack
- **Database:** PostgreSQL
- **Koneksi Database:** SQLAlchemy (`create_engine`)
- **Manipulasi Data:** Python (Pandas)
- **Visualisasi Data:** Python (Matplotlib)

---

## 📁 Proyek 1: Analisis Performa Kategori Buku
Skrip ini mengevaluasi kategori buku mana yang menjadi penyumbang omzet utama dan mana yang membutuhkan strategi promosi tambahan.
- **Ekstraksi SQL:** Menggunakan `GROUP BY` dan `JOIN` untuk menghitung total omzet per kategori secara efisien.
- **Feature Engineering:** Menggunakan `df.apply()` untuk melabeli kategori menjadi "Bintang Utama" (Omzet $\ge$ Rp 400.000) dan "Butuh Promosi".
- **Visualisasi:** Menghasilkan *Bar Chart* dinamis menggunakan Matplotlib dengan *custom legend patches*.

## 📁 Proyek 2: Segmentasi Pelanggan (RFM Analysis)
Skrip ini bertujuan untuk mengidentifikasi pelanggan bernilai tinggi dan mereka yang berisiko berhenti berbelanja (*churn*).
- **Analisis Waktu:** Menghitung *Moving Average* (Rata-rata bergerak) dengan teknik *resampling* untuk menangani data transaksi yang bolong.
- **Logika RFM:** Mengelompokkan pelanggan berdasarkan *Recency* (waktu terakhir beli), *Frequency* (jumlah beli), dan *Monetary* (total uang yang dihabiskan) ke dalam segmen seperti 'Sultan Beresiko Hilang' atau 'Juara/VIP'.

---

## 🚀 Cara Menjalankan Proyek Ini di Komputer Anda (Reproducibility)
Agar skrip Python dapat berjalan dengan baik, Anda perlu menyiapkan database lokal Anda terlebih dahulu:

1. Instal PostgreSQL di komputer Anda.
2. Buat sebuah database baru (misalnya dengan nama `ilham.afuw` atau nama lain, lalu sesuaikan di skrip Python).
3. Jalankan file `setup_toko_buku.sql` yang ada di repositori ini ke dalam database Anda. File ini akan secara otomatis:
   - Membuat skema `toko_buku`.
   - Membuat tabel `buku`, `pelanggan`, dan `pesanan`.
   - Mengisi tabel tersebut dengan data *dummy* agar analisis bisa berjalan.
4. Sesuaikan *connection string* (`postgresql://username:password@localhost:5432/nama_db`) pada variabel `engine` di file Python dengan kredensial database lokal Anda.
5. Jalankan skrip `.py` atau sel di `.ipynb` untuk melihat tabel hasil dan pop-up visualisasi.
