import { useState, useMemo } from 'react';
import { Search, Filter, BookOpen } from 'lucide-react';
import { Navbar } from '@/components/Navbar';
import { BookCard } from '@/components/BookCard';
import { useBooks } from '@/hooks/useBooks';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { motion } from 'framer-motion';

const categories = [
  'Semua',
  'Novel',
  'Komik',
  'Akademik',
  'Bisnis',
  'Self-Help',
  'Anak-anak',
  'Agama',
  'Hobi',
];

export default function Catalog() {
  const { books, loading } = useBooks();
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('Semua');

  const filteredBooks = useMemo(() => {
    return books.filter((book) => {
      const matchesSearch =
        book.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
        book.author.toLowerCase().includes(searchQuery.toLowerCase());
      const matchesCategory =
        selectedCategory === 'Semua' || book.category === selectedCategory;
      return matchesSearch && matchesCategory;
    });
  }, [books, searchQuery, selectedCategory]);

  return (
    <div className="page-container">
      <Navbar />

      {/* Header */}
      <section className="bg-primary py-12">
        <div className="content-container">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-center"
          >
            <h1 className="font-serif text-3xl md:text-4xl font-bold text-primary-foreground mb-4">
              Katalog <span className="text-gold">Buku</span>
            </h1>
            <p className="text-primary-foreground/70 max-w-xl mx-auto">
              Temukan buku favoritmu dari koleksi lengkap kami
            </p>
          </motion.div>
        </div>
      </section>

      {/* Search & Filter */}
      <section className="py-6 border-b border-border bg-card sticky top-16 z-40">
        <div className="content-container">
          <div className="flex flex-col md:flex-row gap-4">
            {/* Search Input */}
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-muted-foreground" />
              <Input
                type="text"
                placeholder="Cari judul atau penulis..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-10"
              />
            </div>

            {/* Category Filter */}
            <div className="flex gap-2 overflow-x-auto pb-2 md:pb-0">
              {categories.map((category) => (
                <Button
                  key={category}
                  variant={selectedCategory === category ? 'default' : 'outline'}
                  size="sm"
                  onClick={() => setSelectedCategory(category)}
                  className={`whitespace-nowrap ${
                    selectedCategory === category
                      ? 'bg-gold text-secondary-foreground hover:bg-gold-dark'
                      : ''
                  }`}
                >
                  {category}
                </Button>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Books Grid */}
      <section className="py-10">
        <div className="content-container">
          {loading ? (
            <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-6">
              {[...Array(10)].map((_, i) => (
                <div key={i} className="animate-pulse">
                  <div className="aspect-[3/4] bg-muted rounded-lg" />
                  <div className="mt-4 h-4 bg-muted rounded w-3/4" />
                  <div className="mt-2 h-3 bg-muted rounded w-1/2" />
                </div>
              ))}
            </div>
          ) : filteredBooks.length > 0 ? (
            <>
              <p className="text-muted-foreground mb-6">
                Menampilkan {filteredBooks.length} buku
              </p>
              <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-6">
                {filteredBooks.map((book, index) => (
                  <BookCard key={book.id} book={book} index={index} />
                ))}
              </div>
            </>
          ) : (
            <div className="text-center py-20">
              <BookOpen className="h-16 w-16 text-muted-foreground mx-auto mb-4" />
              <h3 className="font-serif text-xl font-semibold text-foreground mb-2">
                Buku Tidak Ditemukan
              </h3>
              <p className="text-muted-foreground">
                Coba gunakan kata kunci lain atau pilih kategori berbeda
              </p>
            </div>
          )}
        </div>
      </section>
    </div>
  );
}
