import { useState, useMemo } from 'react';
import { Search, BookOpen } from 'lucide-react';
import { Navbar } from '@/components/Navbar';
import { BookCard } from '@/components/BookCard';
import { useBooks } from '@/hooks/useBooks';
import { Input } from '@/components/ui/input';
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
    <div className="min-h-screen bg-[#FFF2F2]" style={{ fontFamily: 'Trench, sans-serif' }}>
      <Navbar />

      {/* Header - Konsisten dengan tema Blue-Dark */}
      <section className="bg-[#2D336B] pt-32 pb-20 relative overflow-hidden">
        <div className="absolute top-0 right-0 w-64 h-64 bg-[#A9B5DF]/10 rounded-full -mr-32 -mt-32 blur-3xl" />
        <div className="content-container relative z-10 text-center">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
          >
            <h1 
              style={{ fontFamily: 'DashHorizon, sans-serif' }}
              className="text-5xl md:text-6xl text-white italic tracking-widest mb-4"
            >
              EXPLORE <span className="text-[#A9B5DF]">CATALOG</span>
            </h1>
            <p className="text-white/60 max-w-xl mx-auto uppercase tracking-[0.3em] text-xs">
              Temukan koleksi literatur original dengan kualitas terbaik
            </p>
          </motion.div>
        </div>
      </section>

      {/* Search & Filter - Sticky Navigation */}
      <section className="sticky top-20 z-40 bg-[#FFF2F2]/80 backdrop-blur-md border-b border-[#2D336B]/5 py-6 shadow-sm">
        <div className="content-container">
          <div className="flex flex-col lg:flex-row gap-6 items-center">
            
            {/* Search Input - Fixed Caps & Color Issues */}
            <div className="relative w-full lg:w-1/3">
              <Search className="absolute left-4 top-1/2 -translate-y-1/2 h-4 w-4 text-[#7886C7]" />
              <Input
                type="text"
                placeholder="Cari judul atau penulis..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-12 bg-white border-[#A9B5DF]/30 focus:border-[#2D336B] focus-visible:ring-[#2D336B] focus-visible:ring-offset-0 rounded-full h-12 tracking-widest text-sm text-[#2D336B]"
              />
            </div>

            {/* Category Filter */}
            <div className="flex gap-3 overflow-x-auto w-full pb-2 no-scrollbar">
              {categories.map((category) => (
                <button
                  key={category}
                  onClick={() => setSelectedCategory(category)}
                  className={`px-6 py-2 rounded-full text-[10px] font-bold tracking-[0.2em] uppercase transition-all whitespace-nowrap border ${
                    selectedCategory === category
                      ? 'bg-[#2D336B] text-white border-[#2D336B] shadow-lg'
                      : 'bg-white text-[#2D336B] border-[#A9B5DF]/30 hover:border-[#2D336B]'
                  }`}
                >
                  {category}
                </button>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Books Grid */}
      <section className="py-12">
        <div className="content-container">
          {loading ? (
            <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-8">
              {[...Array(10)].map((_, i) => (
                <div key={i} className="animate-pulse">
                  <div className="aspect-[3/4] bg-[#A9B5DF]/20 rounded-2xl" />
                  <div className="mt-4 h-3 bg-[#A9B5DF]/20 rounded w-3/4" />
                </div>
              ))}
            </div>
          ) : filteredBooks.length > 0 ? (
            <>
              <div className="flex justify-between items-center mb-8">
                <p className="text-[#7886C7] text-xs font-bold tracking-[0.2em] uppercase">
                  Menampilkan {filteredBooks.length} Buku
                </p>
                <div className="h-[1px] flex-1 bg-[#2D336B]/5 ml-6" />
              </div>
              
              <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-8">
                {filteredBooks.map((book, index) => (
                  <motion.div
                    key={book.id}
                    initial={{ opacity: 0, y: 20 }}
                    whileInView={{ opacity: 1, y: 0 }}
                    viewport={{ once: true }}
                    transition={{ delay: (index % 5) * 0.1 }}
                  >
                    <BookCard book={book} index={index} />
                  </motion.div>
                ))}
              </div>
            </>
          ) : (
            <div className="text-center py-32 bg-white rounded-[3rem] border border-[#A9B5DF]/20 shadow-sm">
              <BookOpen className="h-16 w-16 text-[#A9B5DF] mx-auto mb-6 opacity-30" />
              <h3 
                style={{ fontFamily: 'DashHorizon, sans-serif' }}
                className="text-2xl text-[#2D336B] italic tracking-widest mb-2"
              >
                NOT <span className="text-[#A9B5DF]">FOUND</span>
              </h3>
              <p className="text-[#7886C7] text-sm uppercase tracking-widest">
                Coba gunakan kata kunci lain atau pilih kategori berbeda
              </p>
            </div>
          )}
        </div>
      </section>

      {/* Footer Minimalist */}
      <footer className="bg-[#2D336B] py-16 text-center">
        <div className="content-container">
          <span 
            style={{ fontFamily: 'DashHorizon, sans-serif' }} 
            className="text-2xl text-white italic tracking-widest"
          >
            PUSTAKA <span className="text-[#A9B5DF]">ONLINE</span>
          </span>
          <p className="mt-4 text-white/30 text-[10px] tracking-[0.4em] uppercase">
            © 2026 Crafted for Excellence
          </p>
        </div>
      </footer>
    </div>
  );
}