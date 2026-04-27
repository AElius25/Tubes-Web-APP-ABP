import { ShoppingCart, Eye } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Book } from '@/hooks/useBooks';
import { useCart } from '@/hooks/useCart';
import { useAuth } from '@/lib/auth';
import { useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import { toast } from 'sonner';

interface BookCardProps {
  book: Book;
  index?: number;
}

export function BookCard({ book, index = 0 }: BookCardProps) {
  const { user, role } = useAuth();
  const { addToCart } = useCart();
  const navigate = useNavigate();

  const handleAddToCart = async () => {
    if (!user) {
      toast.error('Silakan login terlebih dahulu');
      navigate('/auth');
      return;
    }
    
    if (role === 'seller') {
      toast.error('Penjual tidak dapat menambahkan ke keranjang');
      return;
    }

    await addToCart(book.id);
    toast.success('Buku ditambahkan ke keranjang');
  };

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('id-ID', {
      style: 'currency',
      currency: 'IDR',
      minimumFractionDigits: 0,
    }).format(price);
  };

  const isOutOfStock = book.stock <= 0;

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: index * 0.1, duration: 0.4 }}
      className="group bg-white rounded-[2rem] overflow-hidden shadow-sm hover:shadow-2xl transition-all duration-500 border border-[#A9B5DF]/20"
      style={{ fontFamily: 'Trench, sans-serif' }}
    >
      {/* Cover Image Container */}
      <div className="relative aspect-[3/4] overflow-hidden bg-[#FFF2F2]">
        {book.cover_image ? (
          <img
            src={book.cover_image}
            alt={book.title}
            className="w-full h-full object-cover transition-transform duration-700 group-hover:scale-110"
          />
        ) : (
          <div className="w-full h-full flex items-center justify-center bg-[#2D336B]/5">
            <span className="text-4xl opacity-20">📚</span>
          </div>
        )}
        
        {/* Badges Layout */}
        <div className="absolute top-4 left-4 right-4 flex justify-between items-start z-10">
          {book.category && (
            <span className="bg-[#2D336B] text-white text-[9px] font-black px-3 py-1.5 rounded-full tracking-[0.2em] uppercase shadow-lg">
              {book.category}
            </span>
          )}
          <span className={`${isOutOfStock ? 'bg-red-500 text-white' : 'bg-[#FFF2F2]/90 text-[#7886C7] border border-[#A9B5DF]/30'} backdrop-blur-md text-[9px] font-bold px-3 py-1.5 rounded-full tracking-widest`}>
            {isOutOfStock ? 'HABIS' : `STOK: ${book.stock}`}
          </span>
        </div>

        {/* Quick Actions Overlay - SEKARANG LEBIH SELARAS */}
        <div className="absolute inset-0 bg-[#2D336B]/40 opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex items-center justify-center backdrop-blur-[2px]">
          <div className="flex gap-2 px-4 w-full justify-center">
            <Button
              size="sm"
              onClick={() => navigate(`/book/${book.id}`)}
              className="flex-1 max-w-[100px] bg-white text-[#2D336B] hover:bg-[#FFF2F2] rounded-full h-9 font-bold tracking-widest text-[10px] border-none shadow-xl transition-transform active:scale-95"
            >
              <Eye className="h-3.5 w-3.5 mr-1.5" />
              DETAIL
            </Button>
            
            {!isOutOfStock && (
              <Button
                size="sm"
                onClick={handleAddToCart}
                className="flex-1 max-w-[100px] bg-[#A9B5DF] text-[#2D336B] hover:bg-white rounded-full h-9 font-bold tracking-widest text-[10px] border-none shadow-xl transition-transform active:scale-95"
              >
                <ShoppingCart className="h-3.5 w-3.5 mr-1.5" />
                BELI
              </Button>
            )}
          </div>
        </div>
      </div>

      {/* Content Area */}
      <div className="p-6">
        <h3 
          style={{ fontFamily: 'DashHorizon, sans-serif' }}
          className="text-lg text-[#2D336B] line-clamp-1 italic tracking-wider mb-1"
        >
          {book.title}
        </h3>
        <p className="text-[#7886C7] text-[10px] font-bold tracking-[0.2em] uppercase mb-4 opacity-80">
          {book.author}
        </p>
        
        <div className="flex items-center justify-between pt-4 border-t border-[#FFF2F2]">
          <span className="text-[#2D336B] font-black text-xl tracking-tighter">
            {formatPrice(book.price)}
          </span>
          {/* Decorative Dot */}
          <div className="w-8 h-8 rounded-full bg-[#FFF2F2] flex items-center justify-center">
             <div className="w-2 h-2 rounded-full bg-[#A9B5DF] animate-pulse" />
          </div>
        </div>
      </div>
    </motion.div>
  );
}