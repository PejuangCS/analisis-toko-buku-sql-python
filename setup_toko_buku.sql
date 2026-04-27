-- 1. Membuat Schema
CREATE SCHEMA IF NOT EXISTS toko_buku;
SET search_path TO toko_buku;

-- ==========================================
-- TABEL INDUK (TIDAK PUNYA FOREIGN KEY)
-- ==========================================

CREATE TABLE penerbit (
    id_penerbit SERIAL PRIMARY KEY,
    nama_penerbit VARCHAR(100),
    kota_penerbit VARCHAR(50)
);

CREATE TABLE penulis (
    id_penulis SERIAL PRIMARY KEY,
    nama_penulis VARCHAR(100),
    negara_asal VARCHAR(50)
);

CREATE TABLE promo (
    id_promo SERIAL PRIMARY KEY,
    kode_promo VARCHAR(20) UNIQUE,
    diskon_persen INTEGER CHECK (diskon_persen >= 0 AND diskon_persen <= 100),
    tanggal_mulai DATE,
    tanggal_selesai DATE CHECK (tanggal_selesai >= tanggal_mulai)
);

-- Penambahan: email dan tanggal_daftar
CREATE TABLE pelanggan (
    id_pelanggan SERIAL PRIMARY KEY,
    nama VARCHAR(50),
    email VARCHAR(100) UNIQUE, 
    kota_asal VARCHAR(50),
    tanggal_daftar DATE
);

-- ==========================================
-- TABEL TRANSAKSI & RELASI (PUNYA FOREIGN KEY)
-- ==========================================

-- Penambahan: id_penerbit
CREATE TABLE buku (
    id_buku SERIAL PRIMARY KEY,
    id_penerbit INTEGER NOT NULL,
    id_penulis INTEGER NOT NULL,
    judul VARCHAR(255),
    kategori VARCHAR(50),
    harga INTEGER CHECK (harga > 0),
    FOREIGN KEY (id_penerbit) REFERENCES penerbit(id_penerbit) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (id_penulis) REFERENCES penulis(id_penulis) ON UPDATE CASCADE ON DELETE RESTRICT
);


-- Penambahan: id_promo
CREATE TABLE pesanan (
    id_pesanan SERIAL PRIMARY KEY,
    id_pelanggan INTEGER NOT NULL,
    id_buku INTEGER NOT NULL,
    id_promo INTEGER,
    tanggal_pesanan DATE,
    jumlah_beli INTEGER CHECK (jumlah_beli > 0),
    FOREIGN KEY (id_pelanggan) REFERENCES pelanggan(id_pelanggan) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_buku) REFERENCES buku(id_buku) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_promo) REFERENCES promo(id_promo) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE pembayaran (
    id_pembayaran SERIAL PRIMARY KEY,
    id_pesanan INTEGER NOT NULL,
    metode_bayar VARCHAR(50), -- Contoh: 'Transfer Bank', 'E-Wallet', 'Kartu Kredit'
    status_bayar VARCHAR(20), -- Contoh: 'Lunas', 'Pending', 'Gagal'
    tanggal_bayar TIMESTAMP,
    FOREIGN KEY (id_pesanan) REFERENCES pesanan(id_pesanan) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE ulasan (
    id_ulasan SERIAL PRIMARY KEY,
    id_pelanggan INTEGER NOT NULL,
    id_buku INTEGER NOT NULL,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    teks_ulasan TEXT,
    tanggal_ulasan DATE,
    FOREIGN KEY (id_pelanggan) REFERENCES pelanggan(id_pelanggan) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_buku) REFERENCES buku(id_buku) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE stok_inventaris (
    id_stok SERIAL PRIMARY KEY,
    id_buku INTEGER NOT NULL,
    jenis_pergerakan VARCHAR(10) CHECK (jenis_pergerakan IN ('MASUK', 'KELUAR')),
    jumlah INTEGER CHECK (jumlah > 0),
    tanggal_pergerakan TIMESTAMP,
    FOREIGN KEY (id_buku) REFERENCES buku(id_buku) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE OR REPLACE FUNCTION catat_stok_keluar_lunas()
RETURNS TRIGGER AS $$
DECLARE
    v_id_buku INTEGER;
    v_jumlah_beli INTEGER;
BEGIN
    -- Cek apakah ini transaksi baru yang langsung 'Lunas', 
    -- ATAU transaksi lama yang statusnya di-update menjadi 'Lunas'
    IF (TG_OP = 'INSERT' AND NEW.status_bayar = 'Lunas') OR 
       (TG_OP = 'UPDATE' AND NEW.status_bayar = 'Lunas' AND OLD.status_bayar IS DISTINCT FROM 'Lunas') THEN
        
        -- Ambil data id_buku dan jumlah_beli dari tabel pesanan yang terkait
        SELECT id_buku, jumlah_beli INTO v_id_buku, v_jumlah_beli
        FROM pesanan
        WHERE id_pesanan = NEW.id_pesanan;

        -- Masukkan riwayat pergerakan stok secara otomatis
        INSERT INTO stok_inventaris (id_buku, jenis_pergerakan, jumlah, tanggal_pergerakan)
        VALUES (v_id_buku, 'KELUAR', v_jumlah_beli, CURRENT_TIMESTAMP);
        
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_setelah_pembayaran_lunas
AFTER INSERT OR UPDATE ON pembayaran
FOR EACH ROW
EXECUTE FUNCTION catat_stok_keluar_lunas();

CREATE OR REPLACE FUNCTION cek_ketersediaan_stok()
RETURNS TRIGGER AS $$
DECLARE
    v_stok_masuk INTEGER;
    v_stok_keluar INTEGER;
    v_stok_akhir INTEGER;
BEGIN
    -- 1. Hitung total stok MASUK untuk buku ini
    SELECT COALESCE(SUM(jumlah), 0) INTO v_stok_masuk
    FROM stok_inventaris
    WHERE id_buku = NEW.id_buku AND jenis_pergerakan = 'MASUK';

    -- 2. Hitung total stok KELUAR untuk buku ini
    SELECT COALESCE(SUM(jumlah), 0) INTO v_stok_keluar
    FROM stok_inventaris
    WHERE id_buku = NEW.id_buku AND jenis_pergerakan = 'KELUAR';

    -- 3. Hitung sisa stok riil di gudang
    v_stok_akhir := v_stok_masuk - v_stok_keluar;

    -- 4. Logika Validasi: Blokir jika pesanan melebihi stok!
    IF NEW.jumlah_beli > v_stok_akhir THEN
        RAISE EXCEPTION 'TRANSAKSI DITOLAK: Stok tidak mencukupi! Sisa stok untuk buku ID % saat ini hanya % eksemplar.', NEW.id_buku, v_stok_akhir;
    END IF;

    -- Jika stok cukup, biarkan pesanan masuk ke database
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sebelum_pesanan
BEFORE INSERT ON pesanan
FOR EACH ROW
EXECUTE FUNCTION cek_ketersediaan_stok();


INSERT INTO penerbit (nama_penerbit, kota_penerbit) VALUES 
('Gramedia Pustaka Utama', 'Jakarta'),
('Bentang Pustaka', 'Yogyakarta'),
('Penguin Random House', 'New York');

INSERT INTO penulis (nama_penulis, negara_asal) VALUES 
('Pramoedya Ananta Toer', 'Indonesia'),
('James Clear', 'Amerika Serikat'),
('Andrea Hirata', 'Indonesia'),
('Mark Manson', 'Amerika Serikat'),
('Zhu Yi', 'Tiongkok');

INSERT INTO promo (kode_promo, diskon_persen, tanggal_mulai, tanggal_selesai) VALUES 
('MARETDISKON', 15, '2026-03-01', '2026-03-31'),
('KILAT50', 50, '2026-04-01', '2026-04-05');

INSERT INTO pelanggan (nama, email, kota_asal, tanggal_daftar) VALUES 
('Budi', 'budi@email.com', 'Jakarta', '2026-01-15'),
('Deden', 'deden@email.com', 'Bandung', '2026-02-10'),
('Rasyid', 'rasyid@email.com', 'Surabaya', '2026-03-05'),
('Acep', 'acep@email.com', 'Bogor', '2026-03-12'),
('Andi', 'andi@email.com', 'Yogyakarta', '2026-03-15');

-- 5. Insert Buku
INSERT INTO buku (id_penerbit, id_penulis, judul, kategori, harga) VALUES 
(2, 3, 'Laskar Pelangi', 'Fiksi', 85000),             -- id_buku: 1
(1, 1, 'Bumi Manusia', 'Fiksi', 110000),             -- id_buku: 2
(3, 2, 'Atomic Habits', 'Pengembangan Diri', 105000),-- id_buku: 3
(3, 4, 'Seni Bersikap Bodo Amat', 'Pengembangan Diri', 95000), -- id_buku: 4
(1, 5, 'The First Frost', 'Slice of Life', 110000); -- id_buku: 5

-- 6. Insert Stok Inventaris
INSERT INTO stok_inventaris (id_buku, jenis_pergerakan, jumlah, tanggal_pergerakan) VALUES 
(1, 'MASUK', 100, '2026-02-01 08:00:00'), -- Laskar Pelangi masuk 100 eksemplar
(2, 'MASUK', 50, '2026-02-01 08:00:00'), -- Bumi Manusia masuk 50 eksemplar
(3, 'MASUK', 200, '2026-02-01 08:00:00'), -- Atomic Habits masuk 200 eksemplar
(4, 'MASUK', 150, '2026-02-01 08:00:00'), -- Seni Bodo Amat masuk 150 eksemplar
(5, 'MASUK', 100, '2026-02-01 08:00:00'), -- The First Frost masuk 100 eksemplar
(3, 'KELUAR', 5, '2026-03-20 09:00:00'); -- Stok berkurang karena rusak di gudang

-- 7. Insert Pesanan
INSERT INTO pesanan (id_pelanggan, id_buku, id_promo, tanggal_pesanan, jumlah_beli) VALUES 
(1, 3, 1, '2026-03-15', 2), -- Budi beli Atomic Habits pakai promo
(2, 1, NULL, '2026-03-18', 1), -- Deden beli Laskar Pelangi
(3, 4, NULL, '2026-03-20', 1), -- Rasyid beli Bodo Amat
(4, 2, NULL, '2026-03-25', 1), -- Acep beli Bumi Manusia
(5, 5, NULL, '2026-03-28', 1); -- Andi beli The First Frost

-- 8. Insert Pembayaran
INSERT INTO pembayaran (id_pesanan, metode_bayar, status_bayar, tanggal_bayar) VALUES 
(1, 'Kartu Kredit', 'Lunas', '2026-03-15 10:30:00'), -- Budi bayar langsung
(2, 'Transfer Bank', 'Lunas', '2026-03-18 14:00:00'), -- Deden bayar langsung
(3, 'E-Wallet', 'Lunas', '2026-03-20 11:00:00'), -- Rasyid bayar langsung
(4, 'Transfer Bank', 'Lunas', '2026-03-25 09:15:00'), -- Acep bayar langsung
(5, 'Kartu Kredit', 'Lunas', '2026-03-28 16:00:00'); -- Andi bayar langsung

-- 9. Insert Ulasan
INSERT INTO ulasan (id_pelanggan, id_buku, rating, teks_ulasan, tanggal_ulasan) VALUES 
(1, 3, 5, 'Buku yang sangat mengubah hidup!', '2026-03-20'), -- Budi ulas Atomic Habits
(2, 1, 4, 'Bagus, tapi kertasnya agak tipis.', '2026-03-25'), -- Deden ulas Laskar Pelangi
(4, 2, 5, 'Karya sastra terbaik.', '2026-04-02'), -- Acep ulas Bumi Manusia
(5, 5, 4, 'Cerita yang menyentuh hati.', '2026-04-05'); -- Andi ulas The First Frost
