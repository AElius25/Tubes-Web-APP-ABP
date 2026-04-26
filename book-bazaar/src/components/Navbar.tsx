import { Link, useNavigate } from 'react-router-dom';
import { ShoppingCart, User, BookOpen, LogOut, Package } from 'lucide-react';
import { useAuth } from '@/lib/auth';
import { Button } from '@/components/ui/button';
import { useCart } from '@/hooks/useCart';
import { motion } from 'framer-motion';

export function Navbar() {
  const { user, role, signOut } = useAuth();
  const navigate = useNavigate();
  const { cartItemsCount } = useCart();

  const handleSignOut = async () => {
    await signOut();
    navigate('/');
  };

  return (
    <motion.nav 
      initial={{ y: -100 }}
      animate={{ y: 0 }}
      className="sticky top-0 z-50 bg-primary/95 backdrop-blur-sm border-b border-primary/20"
    >
      <div className="content-container">
        <div className="flex items-center justify-between h-16">
          {/* Logo */}
          <Link to="/" className="flex items-center gap-2 group">
            <BookOpen className="h-8 w-8 text-gold transition-transform group-hover:rotate-12" />
            <span className="font-serif text-2xl font-bold text-primary-foreground">
              Pustaka<span className="text-gold">Online</span>
            </span>
          </Link>

          {/* Navigation Links */}
          <div className="hidden md:flex items-center gap-6">
            <Link 
              to="/" 
              className="text-primary-foreground/80 hover:text-gold transition-colors font-medium"
            >
              Beranda
            </Link>
            <Link 
              to="/catalog" 
              className="text-primary-foreground/80 hover:text-gold transition-colors font-medium"
            >
              Katalog Buku
            </Link>
          </div>

          {/* Actions */}
          <div className="flex items-center gap-3">
            {user ? (
              <>
                {role === 'seller' && (
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => navigate('/seller')}
                    className="text-primary-foreground/80 hover:text-gold hover:bg-primary-foreground/10"
                  >
                    <Package className="h-5 w-5 mr-2" />
                    <span className="hidden sm:inline">Dashboard</span>
                  </Button>
                )}
                
                {role === 'buyer' && (
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => navigate('/cart')}
                    className="relative text-primary-foreground/80 hover:text-gold hover:bg-primary-foreground/10"
                  >
                    <ShoppingCart className="h-5 w-5" />
                    {cartItemsCount > 0 && (
                      <motion.span 
                        initial={{ scale: 0 }}
                        animate={{ scale: 1 }}
                        className="absolute -top-1 -right-1 bg-gold text-secondary-foreground text-xs rounded-full h-5 w-5 flex items-center justify-center font-bold"
                      >
                        {cartItemsCount}
                      </motion.span>
                    )}
                  </Button>
                )}

                <Button
                  variant="ghost"
                  size="sm"
                  onClick={handleSignOut}
                  className="text-primary-foreground/80 hover:text-gold hover:bg-primary-foreground/10"
                >
                  <LogOut className="h-5 w-5 mr-2" />
                  <span className="hidden sm:inline">Keluar</span>
                </Button>
              </>
            ) : (
              <Button
                onClick={() => navigate('/auth')}
                className="bg-gold text-secondary-foreground hover:bg-gold-dark font-semibold"
              >
                <User className="h-5 w-5 mr-2" />
                Masuk
              </Button>
            )}
          </div>
        </div>
      </div>
    </motion.nav>
  );
}
