-- Membuat Schema
CREATE SCHEMA IF NOT EXISTS toko_buku;
SET search_path TO toko_buku;

-- Membuat Tabel Buku
CREATE TABLE buku (
    id_buku SERIAL PRIMARY KEY,
    judul VARCHAR(255),
    kategori VARCHAR(50),
    harga INTEGER
);

-- Membuat Tabel Pelanggan
CREATE TABLE pelanggan (
    id_pelanggan SERIAL PRIMARY KEY,
    nama VARCHAR(50),
    kota VARCHAR(50)
);

-- Membuat Tabel Pesanan
CREATE TABLE pesanan (
    id_pesanan SERIAL PRIMARY KEY,
    id_pelanggan INTEGER,
    id_buku INTEGER,
    tanggal_pesanan DATE,
    jumlah_beli INTEGER,
    FOREIGN KEY (id_pelanggan) REFERENCES pelanggan(id_pelanggan) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_buku) REFERENCES buku(id_buku) ON UPDATE CASCADE ON DELETE CASCADE
);

-- ==========================================
-- MENGISI DATA DUMMY (SEED DATA)
-- ==========================================

-- Mengisi Data Buku
INSERT INTO buku (judul, kategori, harga) VALUES
('Algoritma dan Struktur Data', 'Teknologi', 150000),
('Shogun', 'Fiksi', 120000),
('Seni Bersikap Bodo Amat', 'Pengembangan Diri', 95000),
('Atomic Habits', 'Pengembangan Diri', 105000),
('Data Science for Business', 'Teknologi', 180000),
('Bumi Manusia', 'Fiksi', 110000);

-- Mengisi Data Pelanggan
INSERT INTO pelanggan (nama, kota) VALUES
('Budi', 'Jakarta'),
('Deden', 'Bandung'),
('Sayyid Nabeel', 'Surabaya'),
('Asep', 'Bogor'),
('Siti Aminah', 'Yogyakarta'),
('Chika', 'Semarang');

-- Mengisi Data Pesanan (Transaksi)
INSERT INTO pesanan (id_pelanggan, id_buku, tanggal_pesanan, jumlah_beli) VALUES
(1, 1, '2026-03-08', 2), -- Budi beli 2 buku Algoritma
(1, 5, '2026-03-12', 1), -- Budi beli 1 buku Data Science
(2, 3, '2026-03-14', 2), -- Deden beli 2 buku Seni Bersikap Bodo Amat
(3, 1, '2026-03-20', 1), -- Sayyid Nabeel beli 1 buku Algoritma
(3, 2, '2026-03-20', 1), -- Sayyid Nabeel beli 1 buku Shogun
(4, 2, '2026-03-08', 2), -- Asep beli 2 buku Shogun
(5, 4, '2026-03-19', 3), -- Siti beli 3 buku Atomic Habits
(6, 6, '2026-03-12', 1), -- Chika beli 1 buku Bumi Manusia
(1, 4, '2026-03-12', 1), -- Budi beli 1 buku Atomic Habits
(2, 2, '2026-03-14', 1); -- Deden beli 1 buku Shogun