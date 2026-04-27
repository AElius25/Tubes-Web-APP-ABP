import { Trash2, Plus, Minus, ShoppingBag, ArrowLeft } from 'lucide-react';
import { Link, useNavigate } from 'react-router-dom';
import { Navbar } from '@/components/Navbar';
import { Button } from '@/components/ui/button';
import { useCart } from '@/hooks/useCart';
import { useAuth } from '@/lib/auth';
import { motion, AnimatePresence } from 'framer-motion';
import { useEffect } from 'react';

export default function Cart() {
  const { user, role, loading: authLoading } = useAuth();
  const { cartItems, loading, updateQuantity, removeFromCart, cartTotal } = useCart();
  const navigate = useNavigate();

  useEffect(() => {
    if (!authLoading && !user) {
      navigate('/auth');
    }
    if (!authLoading && user && role === 'seller') {
      navigate('/seller');
    }
  }, [user, role, authLoading, navigate]);

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('id-ID', {
      style: 'currency',
      currency: 'IDR',
      minimumFractionDigits: 0,
    }).format(price);
  };

  if (authLoading || loading) {
    return (
      <div className="min-h-screen bg-[#FFF2F2]/30">
        <Navbar />
        <div className="max-w-7xl mx-auto px-4 py-20">
          <div className="animate-pulse space-y-6">
            <div className="h-10 w-64 bg-[#A9B5DF]/20 rounded-full" />
            <div className="grid lg:grid-cols-3 gap-8">
              <div className="lg:col-span-2 space-y-4">
                {[...Array(3)].map((_, i) => (
                  <div key={i} className="h-32 bg-white rounded-[2rem] shadow-sm border border-[#A9B5DF]/10" />
                ))}
              </div>
              <div className="h-64 bg-[#2D336B]/10 rounded-[2.5rem]" />
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#FFF2F2]/30" style={{ fontFamily: 'Trench, sans-serif' }}>
      <Navbar />

      <div className="max-w-7xl mx-auto px-4 py-10">
        {/* Header Navigation */}
        <div className="flex items-center gap-4 mb-8">
          <Link to="/catalog" className="group flex items-center gap-2 text-[#7886C7] hover:text-[#2D336B] transition-colors font-bold tracking-widest text-[10px] uppercase">
            <ArrowLeft className="h-4 w-4 transition-transform group-hover:-translate-x-1" />
            Lanjut Belanja
          </Link>
        </div>

        <h1 style={{ fontFamily: 'DashHorizon, sans-serif' }} className="text-4xl text-[#2D336B] mb-12 italic tracking-widest">
          KERANJANG <span className="text-[#A9B5DF]">BELANJA</span>
        </h1>

        {cartItems.length === 0 ? (
          <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            className="text-center py-24 bg-white rounded-[3rem] shadow-xl border border-[#A9B5DF]/20"
          >
            <div className="w-24 h-24 bg-[#FFF2F2] rounded-full flex items-center justify-center mx-auto mb-6">
              <ShoppingBag className="h-10 w-10 text-[#7886C7]" />
            </div>
            <h3 style={{ fontFamily: 'DashHorizon, sans-serif' }} className="text-2xl text-[#2D336B] mb-4 italic">
              KERANJANG KOSONG
            </h3>
            <p className="text-[#7886C7] font-bold tracking-wider text-xs mb-8 uppercase">
              Anda belum menambahkan buku apapun
            </p>
            <Link to="/catalog">
              <Button className="bg-[#2D336B] hover:bg-[#1A1F4D] text-white rounded-full px-10 h-12 font-black tracking-[0.2em] text-[10px]">
                JELAJAHI KATALOG
              </Button>
            </Link>
          </motion.div>
        ) : (
          <div className="grid lg:grid-cols-3 gap-8">
            {/* List Item Section */}
            <div className="lg:col-span-2 space-y-4">
              <AnimatePresence mode="popLayout">
                {cartItems.map((item) => (
                  <motion.div
                    key={item.id}
                    layout
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    exit={{ opacity: 0, x: 50 }}
                    className="bg-white rounded-[2.5rem] p-6 shadow-sm border border-[#A9B5DF]/20 flex flex-col md:flex-row gap-6 items-center"
                  >
                    {/* Book Cover */}
                    <div className="w-24 h-32 rounded-2xl overflow-hidden bg-[#FFF2F2] flex-shrink-0 shadow-inner">
                      {item.book?.cover_image ? (
                        <img src={item.book.cover_image} alt={item.book.title} className="w-full h-full object-cover" />
                      ) : (
                        <div className="w-full h-full flex items-center justify-center text-2xl opacity-50">📚</div>
                      )}
                    </div>

                    {/* Book Info */}
                    <div className="flex-1 min-w-0 text-center md:text-left">
                      <h3 style={{ fontFamily: 'DashHorizon, sans-serif' }} className="text-[#2D336B] text-lg italic line-clamp-1">
                        {item.book?.title}
                      </h3>
                      <p className="text-[#7886C7] text-[10px] font-bold tracking-widest uppercase mb-4">
                        {item.book?.author}
                      </p>
                      
                      <div className="flex items-center justify-center md:justify-start gap-4">
                        <div className="flex items-center bg-[#FFF2F2] rounded-full p-1 border border-[#A9B5DF]/10">
                          <button 
                            onClick={() => updateQuantity(item.id, Math.max(1, item.quantity - 1))}
                            className="w-8 h-8 flex items-center justify-center text-[#2D336B] hover:bg-white rounded-full transition-colors"
                          >
                            <Minus className="h-3 w-3" />
                          </button>
                          <span className="w-8 text-center font-black text-[#2D336B] text-sm">{item.quantity}</span>
                          <button 
                            onClick={() => updateQuantity(item.id, item.quantity + 1)}
                            disabled={item.quantity >= (item.book?.stock || 0)}
                            className="w-8 h-8 flex items-center justify-center text-[#2D336B] hover:bg-white rounded-full transition-colors disabled:opacity-30"
                          >
                            <Plus className="h-3 w-3" />
                          </button>
                        </div>
                        
                        <button 
                          onClick={() => removeFromCart(item.id)}
                          className="p-2 text-red-400 hover:text-red-600 transition-colors"
                        >
                          <Trash2 className="h-5 w-5" />
                        </button>
                      </div>
                    </div>

                    {/* Subtotal Item */}
                    <div className="text-center md:text-right flex-shrink-0">
                      <p className="text-[#7886C7] text-[9px] font-bold tracking-widest mb-1 uppercase">Subtotal</p>
                      <p className="text-[#2D336B] font-black text-xl tracking-tighter">
                        {formatPrice((item.book?.price || 0) * item.quantity)}
                      </p>
                    </div>
                  </motion.div>
                ))}
              </AnimatePresence>
            </div>

            {/* Order Summary */}
            <div className="lg:col-span-1">
              <div className="bg-[#2D336B] rounded-[2.5rem] p-8 shadow-2xl text-white sticky top-32 border border-white/5">
                <h2 style={{ fontFamily: 'DashHorizon, sans-serif' }} className="text-xl italic tracking-widest mb-8 flex items-center gap-3">
                  <ShoppingBag className="h-5 w-5 text-[#A9B5DF]" />
                  RINGKASAN <span className="text-[#A9B5DF]">PESANAN</span>
                </h2>

                <div className="space-y-4 mb-8">
                  <div className="flex justify-between text-[#A9B5DF] text-[10px] font-bold tracking-[0.2em] uppercase">
                    <span>Subtotal ({cartItems.reduce((sum, item) => sum + item.quantity, 0)} item)</span>
                    <span className="text-white">{formatPrice(cartTotal)}</span>
                  </div>
                  <div className="flex justify-between text-[#A9B5DF] text-[10px] font-bold tracking-[0.2em] uppercase">
                    <span>Ongkos Kirim</span>
                    <span className="text-green-400">GRATIS</span>
                  </div>
                  <div className="h-[1px] bg-white/10 my-4" />
                  <div className="flex justify-between items-end">
                    <span className="text-[#A9B5DF] text-[10px] font-bold tracking-[0.2em] uppercase">Total Tagihan</span>
                    <span className="text-2xl font-black tracking-tighter text-white">
                      {formatPrice(cartTotal)}
                    </span>
                  </div>
                </div>

                <Button className="w-full bg-[#A9B5DF] hover:bg-white text-[#2D336B] rounded-full h-14 font-black tracking-[0.3em] text-[10px] shadow-xl transition-all active:scale-[0.98]">
                  CHECKOUT SEKARANG
                </Button>
                
                <p className="text-center mt-6 text-[8px] text-white/30 font-bold tracking-[0.2em] leading-relaxed uppercase">
                  Syarat & Ketentuan Berlaku
                </p>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}