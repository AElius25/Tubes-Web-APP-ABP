import { Link } from 'react-router-dom';
import { ArrowRight, BookOpen, Truck, Shield, Award } from 'lucide-react';
import { Navbar } from '@/components/Navbar';
import { Button } from '@/components/ui/button';
import { BookCard } from '@/components/BookCard';
import { useBooks } from '@/hooks/useBooks';
import { motion } from 'framer-motion';

const features = [
  {
    icon: BookOpen,
    title: 'Koleksi Lengkap',
    description: 'Ribuan judul buku dari berbagai genre dan penulis terkenal',
  },
  {
    icon: Truck,
    title: 'Pengiriman Cepat',
    description: 'Pengiriman ke seluruh Indonesia dengan aman dan cepat',
  },
  {
    icon: Shield,
    title: 'Transaksi Aman',
    description: 'Pembayaran terjamin aman dengan berbagai metode',
  },
  {
    icon: Award,
    title: 'Kualitas Terbaik',
    description: 'Semua buku original dengan kondisi terbaik',
  },
];

export default function Index() {
  const { books, loading } = useBooks();
  const featuredBooks = books.slice(0, 4);

  return (
    <div className="page-container">
      <Navbar />

      {/* Hero Section */}
      <section className="relative overflow-hidden bg-gradient-to-br from-primary via-primary to-navy-light py-20 lg:py-32">
        {/* Decorative Elements */}
        <div className="absolute inset-0 overflow-hidden">
          <div className="absolute -top-40 -right-40 w-80 h-80 bg-gold/10 rounded-full blur-3xl" />
          <div className="absolute -bottom-40 -left-40 w-80 h-80 bg-gold/10 rounded-full blur-3xl" />
        </div>

        <div className="content-container relative">
          <div className="max-w-3xl">
            <motion.h1 
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6 }}
              className="font-serif text-4xl md:text-5xl lg:text-6xl font-bold text-primary-foreground leading-tight"
            >
              Temukan Buku Impianmu di{' '}
              <span className="text-gradient-gold">Pustaka Online</span>
            </motion.h1>
            
            <motion.p 
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.2 }}
              className="mt-6 text-lg md:text-xl text-primary-foreground/80 leading-relaxed"
            >
              Jelajahi ribuan koleksi buku berkualitas dari penjual terpercaya. 
              Mulai dari novel, komik, buku akademik, hingga buku langka yang susah ditemukan.
            </motion.p>

            <motion.div 
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.4 }}
              className="mt-8 flex flex-wrap gap-4"
            >
              <Link to="/catalog">
                <Button size="lg" className="bg-gold text-secondary-foreground hover:bg-gold-dark font-semibold text-lg px-8">
                  Jelajahi Katalog
                  <ArrowRight className="ml-2 h-5 w-5" />
                </Button>
              </Link>
              <Link to="/auth">
                <Button 
                  size="lg" 
                  variant="outline" 
                  className="border-2 border-primary-foreground/30 text-primary-foreground hover:bg-primary-foreground/10 font-semibold text-lg px-8"
                >
                  Mulai Berjualan
                </Button>
              </Link>
            </motion.div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-16 bg-cream">
        <div className="content-container">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {features.map((feature, index) => (
              <motion.div
                key={feature.title}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.1, duration: 0.4 }}
                viewport={{ once: true }}
                className="bg-card p-6 rounded-xl shadow-md hover:shadow-lg transition-shadow"
              >
                <div className="w-12 h-12 bg-gold/10 rounded-lg flex items-center justify-center mb-4">
                  <feature.icon className="h-6 w-6 text-gold" />
                </div>
                <h3 className="font-serif text-lg font-semibold text-foreground mb-2">
                  {feature.title}
                </h3>
                <p className="text-muted-foreground text-sm">
                  {feature.description}
                </p>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Featured Books Section */}
      <section className="py-16 lg:py-24">
        <div className="content-container">
          <div className="flex items-center justify-between mb-10">
            <div>
              <h2 className="font-serif text-3xl md:text-4xl font-bold text-foreground">
                Buku <span className="text-gold">Terbaru</span>
              </h2>
              <p className="mt-2 text-muted-foreground">
                Koleksi buku terbaru dari penjual kami
              </p>
            </div>
            <Link to="/catalog">
              <Button variant="outline" className="hidden sm:flex">
                Lihat Semua
                <ArrowRight className="ml-2 h-4 w-4" />
              </Button>
            </Link>
          </div>

          {loading ? (
            <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
              {[...Array(4)].map((_, i) => (
                <div key={i} className="animate-pulse">
                  <div className="aspect-[3/4] bg-muted rounded-lg" />
                  <div className="mt-4 h-4 bg-muted rounded w-3/4" />
                  <div className="mt-2 h-3 bg-muted rounded w-1/2" />
                </div>
              ))}
            </div>
          ) : featuredBooks.length > 0 ? (
            <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
              {featuredBooks.map((book, index) => (
                <BookCard key={book.id} book={book} index={index} />
              ))}
            </div>
          ) : (
            <div className="text-center py-16 bg-muted/50 rounded-2xl">
              <BookOpen className="h-16 w-16 text-muted-foreground mx-auto mb-4" />
              <h3 className="font-serif text-xl font-semibold text-foreground mb-2">
                Belum Ada Buku
              </h3>
              <p className="text-muted-foreground mb-6">
                Jadilah penjual pertama dan mulai jual buku Anda!
              </p>
              <Link to="/auth">
                <Button className="bg-gold text-secondary-foreground hover:bg-gold-dark">
                  Mulai Berjualan
                </Button>
              </Link>
            </div>
          )}

          <div className="mt-8 text-center sm:hidden">
            <Link to="/catalog">
              <Button variant="outline">
                Lihat Semua Buku
                <ArrowRight className="ml-2 h-4 w-4" />
              </Button>
            </Link>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-16 bg-primary">
        <div className="content-container text-center">
          <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            whileInView={{ opacity: 1, scale: 1 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5 }}
          >
            <h2 className="font-serif text-3xl md:text-4xl font-bold text-primary-foreground mb-4">
              Punya Buku untuk Dijual?
            </h2>
            <p className="text-primary-foreground/80 text-lg mb-8 max-w-2xl mx-auto">
              Bergabunglah sebagai penjual dan jangkau ribuan pembeli buku di seluruh Indonesia.
              Gratis mendaftar, mulai jual sekarang!
            </p>
            <Link to="/auth">
              <Button size="lg" className="bg-gold text-secondary-foreground hover:bg-gold-dark font-semibold text-lg px-10">
                Daftar Sebagai Penjual
              </Button>
            </Link>
          </motion.div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-foreground py-12">
        <div className="content-container">
          <div className="flex flex-col md:flex-row items-center justify-between gap-6">
            <div className="flex items-center gap-2">
              <BookOpen className="h-8 w-8 text-gold" />
              <span className="font-serif text-2xl font-bold text-background">
                Pustaka<span className="text-gold">Online</span>
              </span>
            </div>
            <p className="text-background/60 text-sm">
              © 2024 PustakaOnline. Semua hak dilindungi.
            </p>
          </div>
        </div>
      </footer>
    </div>
  );
}
