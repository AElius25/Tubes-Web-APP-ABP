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
    title: 'KOLEKSI LENGKAP',
    description: 'Ribuan judul buku dari berbagai genre dan penulis terkenal',
  },
  {
    icon: Truck,
    title: 'PENGIRIMAN CEPAT',
    description: 'Pengiriman ke seluruh Indonesia dengan aman dan cepat',
  },
  {
    icon: Shield,
    title: 'TRANSAKSI AMAN',
    description: 'Pembayaran terjamin aman dengan berbagai metode',
  },
  {
    icon: Award,
    title: 'KUALITAS TERBAIK',
    description: 'Semua buku original dengan kondisi terbaik',
  },
];

export default function Index() {
  const { books } = useBooks();
  const featuredBooks = books.slice(0, 4);

  return (
    <div className="page-container bg-[#FFF2F2] min-h-screen" style={{ fontFamily: 'Trench, sans-serif' }}>
      <Navbar />

      {/* Hero Section */}
      <section className="relative min-h-[90vh] flex items-center overflow-hidden bg-[#FFF2F2]">
        <div 
          className="absolute inset-0 bg-[#2D336B]" 
          style={{ clipPath: 'polygon(0 0, 100% 0, 100% 75%, 0 100%)' }}
        />

        <div className="content-container relative z-10 py-16 lg:py-24">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
            
            <div className="flex flex-col items-start text-left order-2 lg:order-1">
              <motion.div initial={{ opacity: 0, x: -30 }} animate={{ opacity: 1, x: 0 }}>
                <span className="inline-block px-4 py-1.5 mb-6 rounded-full bg-[#A9B5DF]/20 border border-[#A9B5DF]/30 text-[#A9B5DF] text-sm font-bold tracking-[0.3em]">
                  PUSTAKA ONLINE SPECIAL
                </span>
                
                <h1 
                  style={{ fontFamily: 'DashHorizon, sans-serif' }}
                  className="text-6xl md:text-7xl lg:text-8xl text-white leading-tight italic tracking-tighter"
                >
                  ADVENTURE <br /> 
                  <span className="text-[#A9B5DF]">AWAITS</span>
                </h1>
                
                <p className="mt-8 text-xl md:text-2xl text-white/80 leading-relaxed max-w-xl tracking-wider">
                  Terbanglah ke bintang-bintang bersama "Project Hail Mary" karya Andy Weir. 
                  Dapatkan koleksi original dengan kualitas terbaik hanya di platform kami.
                </p>

                <div className="mt-12 flex flex-wrap gap-10 items-center">
                  
                  {/* VENOM BUTTON 1: BELI SEKARANG */}
                  <div className="relative group" style={{ isolation: 'isolate' }}>
                    <div 
                      className="absolute inset-[-40px] pointer-events-none transition-opacity duration-300 opacity-0 group-hover:opacity-100"
                      style={{ filter: 'url(#venom-hero)' }}
                    >
                      <div className="absolute inset-[40px] bg-white rounded-full" />
                      {[...Array(3)].map((_, i) => (
                        <motion.div
                          key={i}
                          className="absolute top-1/2 left-1/2 w-8 h-8 bg-white rounded-full"
                          animate={{
                            x: [0, (i === 0 ? 75 : i === 1 ? -75 : 45), 0],
                            y: [0, (i === 0 ? -45 : i === 1 ? 45 : 65), 0],
                            scale: [1, 0.6, 1],
                          }}
                          transition={{ duration: 2.5, repeat: Infinity, delay: i * 0.5 }}
                        />
                      ))}
                    </div>
                    <Link to="/catalog" className="relative z-10">
                      <Button size="lg" className="bg-white text-[#2D336B] hover:bg-white border-none font-bold text-xl px-12 h-16 rounded-full shadow-2xl transition-transform active:scale-95">
                        BELI SEKARANG
                      </Button>
                    </Link>
                  </div>

                  {/* VENOM BUTTON 2: MULAI JUAL */}
                  <div className="relative group" style={{ isolation: 'isolate' }}>
                    <div 
                      className="absolute inset-[-40px] pointer-events-none transition-opacity duration-300 opacity-0 group-hover:opacity-100"
                      style={{ filter: 'url(#venom-hero)' }}
                    >
                      <div className="absolute inset-[40px] bg-[#A9B5DF] rounded-full" />
                      {[...Array(3)].map((_, i) => (
                        <motion.div
                          key={i}
                          className="absolute top-1/2 left-1/2 w-8 h-8 bg-[#A9B5DF] rounded-full"
                          animate={{
                            x: [0, (i === 0 ? -65 : 65), 0],
                            y: [0, (i === 0 ? 55 : -55), 0],
                          }}
                          transition={{ duration: 3, repeat: Infinity, delay: i * 0.7 }}
                        />
                      ))}
                    </div>
                    <Link to="/auth" className="relative z-10">
                      <Button size="lg" className="bg-[#A9B5DF] text-[#2D336B] hover:bg-[#A9B5DF] border-none font-bold text-xl px-10 h-16 rounded-full shadow-xl transition-transform active:scale-95">
                        MULAI JUAL
                      </Button>
                    </Link>
                  </div>

                </div>
              </motion.div>
            </div>

            {/* Gambar Buku & Badge */}
            <motion.div initial={{ opacity: 0, scale: 0.9 }} animate={{ opacity: 1, scale: 1 }} className="relative flex justify-center lg:justify-end order-1 lg:order-2">
              <div className="relative group">
                <img 
                  src="https://m.media-amazon.com/images/I/91Gws4BuelL._SL1500_.jpg" 
                  className="rounded-lg shadow-2xl rotate-2 group-hover:rotate-0 transition-all duration-700 max-h-[550px] border-4 border-white/10" 
                  alt="Project Hail Mary"
                />
                <div className="absolute -bottom-6 -left-6 bg-white p-5 rounded-2xl shadow-2xl border border-[#A9B5DF]/20 flex items-center gap-4 z-20">
                  <div className="w-12 h-12 bg-[#2D336B] rounded-xl flex items-center justify-center text-[#A9B5DF]">
                     <Award size={28} />
                  </div>
                  <div>
                      <p className="text-[10px] text-[#7886C7] font-black tracking-widest uppercase">INTERNATIONAL</p>
                      <p className="text-xl font-normal text-[#2D336B]">BEST SELLER</p>
                  </div>
                </div>
              </div>
            </motion.div>
          </div>
        </div>
      </section>

      {/* Keunggulan Section */}
      <section className="py-20 bg-[#FFF2F2]">
        <div className="content-container grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
          {features.map((feature, index) => (
            <div key={index} className="bg-white p-8 rounded-3xl border border-[#A9B5DF]/20 shadow-sm hover:shadow-md transition-shadow">
              <feature.icon className="h-8 w-8 text-[#7886C7] mb-4" />
              <h3 className="text-xl font-bold text-[#2D336B] mb-2 tracking-widest uppercase">{feature.title}</h3>
              <p className="text-[#2D336B]/60 text-sm leading-relaxed">{feature.description}</p>
            </div>
          ))}
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-[#2D336B] py-16 text-center">
        <div className="content-container border-t border-white/10 pt-10">
          <span style={{ fontFamily: 'DashHorizon, sans-serif' }} className="text-3xl text-white italic tracking-widest">
            PUSTAKA <span className="text-[#A9B5DF]">ONLINE</span>
          </span>
          <p className="mt-4 text-white/40 text-sm tracking-[0.3em]">© 2026 PUSTAKAONLINE.</p>
        </div>
      </footer>

      {/* SVG FILTER HERO */}
      <svg width="0" height="0" className="absolute invisible pointer-events-none">
        <defs>
          <filter id="venom-hero">
            <feGaussianBlur in="SourceGraphic" stdDeviation="10" result="blur" />
            <feColorMatrix 
              in="blur" 
              mode="matrix" 
              values="1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  0 0 0 20 -10" 
              result="goo" 
            />
            <feComposite in="SourceGraphic" in2="goo" operator="atop" />
          </filter>
        </defs>
      </svg>
    </div>
  );
}