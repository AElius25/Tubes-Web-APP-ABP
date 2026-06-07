-- ============================================================
-- BOOKISH POS — Supabase PostgreSQL Schema
-- Jalankan file ini di Supabase > SQL Editor
-- ============================================================

-- ── Tabel Buku ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS books (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title       TEXT NOT NULL,
  author      TEXT NOT NULL,
  isbn        TEXT DEFAULT '',
  category    TEXT NOT NULL,
  price       NUMERIC(12,2) NOT NULL,
  stock       INTEGER NOT NULL DEFAULT 0,
  cover_path  TEXT,         -- path file lokal (image_picker)
  cover_url   TEXT,         -- URL jaringan (opsional)
  publisher   TEXT DEFAULT '',
  year        INTEGER DEFAULT 2024,
  created_at  TIMESTAMPTZ DEFAULT now(),
  updated_at  TIMESTAMPTZ DEFAULT now()
);

-- ── Tabel Transaksi ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS transactions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  receipt_number  TEXT NOT NULL UNIQUE,
  subtotal        NUMERIC(12,2) NOT NULL DEFAULT 0,
  discount        NUMERIC(12,2) NOT NULL DEFAULT 0,
  tax             NUMERIC(12,2) NOT NULL DEFAULT 0,
  total           NUMERIC(12,2) NOT NULL DEFAULT 0,
  amount_paid     NUMERIC(12,2) NOT NULL DEFAULT 0,
  change          NUMERIC(12,2) NOT NULL DEFAULT 0,
  payment_method  TEXT NOT NULL DEFAULT 'cash',  -- 'cash' | 'qris'
  status          TEXT NOT NULL DEFAULT 'completed', -- 'completed' | 'voided'
  customer_name   TEXT,
  notes           TEXT,
  cashier_name    TEXT DEFAULT 'Kasir',
  created_at      TIMESTAMPTZ DEFAULT now()
);

-- ── Tabel Item Transaksi ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS transaction_items (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_id  UUID NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
  book_id         UUID NOT NULL REFERENCES books(id),
  book_title      TEXT NOT NULL,
  book_author     TEXT NOT NULL,
  unit_price      NUMERIC(12,2) NOT NULL,
  quantity        INTEGER NOT NULL DEFAULT 1,
  discount        NUMERIC(5,2) NOT NULL DEFAULT 0,
  created_at      TIMESTAMPTZ DEFAULT now()
);

-- ── Stored Procedure: kurangi stok atomik ────────────────────
CREATE OR REPLACE FUNCTION decrease_book_stock(book_id UUID, qty INTEGER)
RETURNS VOID AS $$
BEGIN
  UPDATE books
  SET stock = stock - qty,
      updated_at = now()
  WHERE id = book_id AND stock >= qty;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Stok tidak cukup untuk buku %', book_id;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ── Auto-update updated_at saat buku diedit ──────────────────
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER books_updated_at
  BEFORE UPDATE ON books
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ── Row Level Security (RLS) — aktifkan untuk keamanan ───────
ALTER TABLE books ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE transaction_items ENABLE ROW LEVEL SECURITY;

-- Policy: izinkan semua operasi (sesuaikan setelah tambah auth)
CREATE POLICY "allow_all_books" ON books FOR ALL USING (true);
CREATE POLICY "allow_all_transactions" ON transactions FOR ALL USING (true);
CREATE POLICY "allow_all_items" ON transaction_items FOR ALL USING (true);

-- ── Index untuk performa ──────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_transactions_created ON transactions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_items_transaction ON transaction_items(transaction_id);
CREATE INDEX IF NOT EXISTS idx_books_category ON books(category);
CREATE INDEX IF NOT EXISTS idx_books_title ON books(title);
