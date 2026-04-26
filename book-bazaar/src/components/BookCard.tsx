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
      className="book-card group"
    >
      {/* Cover Image */}
      <div className="relative aspect-[3/4] overflow-hidden bg-muted">
        {book.cover_image ? (
          <img
            src={book.cover_image}
            alt={book.title}
            className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105"
          />
        ) : (
          <div className="w-full h-full flex items-center justify-center bg-gradient-to-br from-navy/10 to-gold/10">
            <span className="font-serif text-4xl text-navy/30">📚</span>
          </div>
        )}
        
        {/* Stock Badge */}
        <div className="absolute top-3 right-3">
          {isOutOfStock ? (
            <span className="badge-out-of-stock">Habis</span>
          ) : (
            <span className="badge-in-stock">Stok: {book.stock}</span>
          )}
        </div>

        {/* Category */}
        {book.category && (
          <div className="absolute top-3 left-3">
            <span className="bg-gold/90 text-secondary-foreground text-xs px-2 py-1 rounded-full font-medium">
              {book.category}
            </span>
          </div>
        )}

        {/* Quick Actions Overlay */}
        <div className="absolute inset-0 bg-gradient-to-t from-navy/80 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex items-end justify-center pb-4">
          <div className="flex gap-2">
            <Button
              size="sm"
              variant="secondary"
              onClick={() => navigate(`/book/${book.id}`)}
              className="bg-primary-foreground text-primary hover:bg-primary-foreground/90"
            >
              <Eye className="h-4 w-4 mr-1" />
              Detail
            </Button>
            {!isOutOfStock && (
              <Button
                size="sm"
                onClick={handleAddToCart}
                className="bg-gold text-secondary-foreground hover:bg-gold-dark"
              >
                <ShoppingCart className="h-4 w-4 mr-1" />
                Beli
              </Button>
            )}
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="p-4 space-y-2">
        <h3 className="font-serif text-lg font-semibold text-foreground line-clamp-2 leading-tight">
          {book.title}
        </h3>
        <p className="text-muted-foreground text-sm">{book.author}</p>
        <p className="font-bold text-lg text-gold">{formatPrice(book.price)}</p>
      </div>
    </motion.div>
  );
}
