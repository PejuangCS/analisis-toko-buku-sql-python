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

## 🚀 Cara Penggunaan
1. Pastikan server PostgreSQL sedang berjalan dan skema `toko_buku` sudah memiliki data.
2. Sesuaikan *connection string* pada variabel `engine` di setiap file dengan kredensial database lokal Anda (jangan unggah password Anda ke GitHub).
3. Jalankan skrip `.py` atau sel di `.ipynb` untuk melihat tabel hasil dan pop-up visualisasi.
