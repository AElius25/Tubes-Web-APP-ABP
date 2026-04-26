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
      <div className="page-container">
        <Navbar />
        <div className="content-container py-20">
          <div className="animate-pulse space-y-4">
            {[...Array(3)].map((_, i) => (
              <div key={i} className="h-32 bg-muted rounded-lg" />
            ))}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="page-container">
      <Navbar />

      <div className="content-container py-10">
        {/* Header */}
        <div className="flex items-center gap-4 mb-8">
          <Link to="/catalog">
            <Button variant="ghost" size="sm">
              <ArrowLeft className="h-4 w-4 mr-2" />
              Lanjut Belanja
            </Button>
          </Link>
        </div>

        <h1 className="font-serif text-3xl font-bold text-foreground mb-8">
          Keranjang <span className="text-gold">Belanja</span>
        </h1>

        {cartItems.length === 0 ? (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-center py-20 bg-muted/30 rounded-2xl"
          >
            <ShoppingBag className="h-20 w-20 text-muted-foreground mx-auto mb-4" />
            <h3 className="font-serif text-2xl font-semibold text-foreground mb-2">
              Keranjang Kosong
            </h3>
            <p className="text-muted-foreground mb-6">
              Anda belum menambahkan buku apapun ke keranjang
            </p>
            <Link to="/catalog">
              <Button className="bg-gold text-secondary-foreground hover:bg-gold-dark">
                Jelajahi Katalog
              </Button>
            </Link>
          </motion.div>
        ) : (
          <div className="grid lg:grid-cols-3 gap-8">
            {/* Cart Items */}
            <div className="lg:col-span-2 space-y-4">
              <AnimatePresence>
                {cartItems.map((item) => (
                  <motion.div
                    key={item.id}
                    layout
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, x: -100 }}
                    className="bg-card rounded-xl p-4 flex gap-4 shadow-sm"
                  >
                    {/* Book Cover */}
                    <div className="w-24 h-32 rounded-lg overflow-hidden bg-muted flex-shrink-0">
                      {item.book?.cover_image ? (
                        <img
                          src={item.book.cover_image}
                          alt={item.book.title}
                          className="w-full h-full object-cover"
                        />
                      ) : (
                        <div className="w-full h-full flex items-center justify-center">
                          <span className="text-3xl">📚</span>
                        </div>
                      )}
                    </div>

                    {/* Book Info */}
                    <div className="flex-1 min-w-0">
                      <h3 className="font-serif font-semibold text-foreground line-clamp-2">
                        {item.book?.title}
                      </h3>
                      <p className="text-muted-foreground text-sm mt-1">
                        {item.book?.author}
                      </p>
                      <p className="font-bold text-gold mt-2">
                        {formatPrice(item.book?.price || 0)}
                      </p>

                      {/* Quantity Controls */}
                      <div className="flex items-center gap-3 mt-3">
                        <div className="flex items-center border border-border rounded-lg">
                          <button
                            onClick={() => updateQuantity(item.id, item.quantity - 1)}
                            className="p-2 hover:bg-muted transition-colors"
                          >
                            <Minus className="h-4 w-4" />
                          </button>
                          <span className="px-4 font-medium">{item.quantity}</span>
                          <button
                            onClick={() => updateQuantity(item.id, item.quantity + 1)}
                            disabled={item.quantity >= (item.book?.stock || 0)}
                            className="p-2 hover:bg-muted transition-colors disabled:opacity-50"
                          >
                            <Plus className="h-4 w-4" />
                          </button>
                        </div>

                        <button
                          onClick={() => removeFromCart(item.id)}
                          className="p-2 text-destructive hover:bg-destructive/10 rounded-lg transition-colors"
                        >
                          <Trash2 className="h-5 w-5" />
                        </button>
                      </div>
                    </div>

                    {/* Subtotal */}
                    <div className="text-right">
                      <p className="text-sm text-muted-foreground">Subtotal</p>
                      <p className="font-bold text-lg">
                        {formatPrice((item.book?.price || 0) * item.quantity)}
                      </p>
                    </div>
                  </motion.div>
                ))}
              </AnimatePresence>
            </div>

            {/* Order Summary */}
            <div className="lg:col-span-1">
              <div className="bg-card rounded-xl p-6 shadow-sm sticky top-32">
                <h3 className="font-serif text-xl font-semibold text-foreground mb-4">
                  Ringkasan Pesanan
                </h3>

                <div className="space-y-3 border-b border-border pb-4 mb-4">
                  <div className="flex justify-between text-muted-foreground">
                    <span>Subtotal ({cartItems.reduce((sum, item) => sum + item.quantity, 0)} item)</span>
                    <span>{formatPrice(cartTotal)}</span>
                  </div>
                  <div className="flex justify-between text-muted-foreground">
                    <span>Ongkos Kirim</span>
                    <span className="text-green-600">Gratis</span>
                  </div>
                </div>

                <div className="flex justify-between font-bold text-lg mb-6">
                  <span>Total</span>
                  <span className="text-gold">{formatPrice(cartTotal)}</span>
                </div>

                <Button className="w-full bg-gold text-secondary-foreground hover:bg-gold-dark font-semibold py-6">
                  Checkout Sekarang
                </Button>

                <p className="text-xs text-muted-foreground text-center mt-4">
                  Dengan melanjutkan, Anda menyetujui syarat dan ketentuan kami
                </p>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
