import { Link, useNavigate } from 'react-router-dom';
import { ShoppingCart, User, BookOpen, LogOut, LayoutDashboard, ChevronDown } from 'lucide-react';
import { useAuth } from '@/lib/auth';
import { Button } from '@/components/ui/button';
import { useCart } from '@/hooks/useCart';
import { motion, AnimatePresence } from 'framer-motion';
import { useState, useRef, useEffect } from 'react';

export function Navbar() {
  const { user, role, signOut } = useAuth();
  const navigate = useNavigate();
  const { cartItemsCount } = useCart();
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);

  // Menutup menu jika klik di luar area dropdown
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(event.target as Node)) {
        setIsMenuOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleSignOut = async () => {
    await signOut();
    setIsMenuOpen(false);
    navigate('/');
  };

  return (
    <motion.nav 
      initial={{ y: -100 }}
      animate={{ y: 0 }}
      className="sticky top-0 z-[100] bg-[#2D336B]/95 backdrop-blur-md border-b border-white/10"
    >
      <div className="max-w-7xl mx-auto px-4">
        <div className="flex items-center justify-between h-20">
          
          {/* Logo */}
          <Link to="/" className="flex items-center gap-3 group">
            <div className="bg-[#FFF2F2] p-2 rounded-xl group-hover:rotate-12 transition-transform duration-300">
              <BookOpen className="h-6 w-6 text-[#2D336B]" />
            </div>
            <span 
              style={{ fontFamily: 'DashHorizon, sans-serif' }} 
              className="text-2xl md:text-3xl font-normal tracking-widest text-white italic leading-none"
            >
              PUSTAKA <span className="text-[#A9B5DF]">ONLINE</span>
            </span>
          </Link>

          {/* Navigation Links - Desktop */}
          <div className="hidden md:flex items-center gap-8">
            <Link 
              to="/" 
              className="text-white/80 hover:text-[#A9B5DF] transition-colors font-bold tracking-[0.2em] text-[10px] uppercase"
            >
              Beranda
            </Link>
            <Link 
              to="/catalog" 
              className="text-white/80 hover:text-[#A9B5DF] transition-colors font-bold tracking-[0.2em] text-[10px] uppercase"
            >
              Katalog Buku
            </Link>
          </div>

          {/* Actions Section */}
          <div className="flex items-center gap-4">
            {user ? (
              <div className="flex items-center gap-4 relative" ref={menuRef}>
                
                {/* Cart Icon (Hanya untuk Buyer) */}
                {role === 'buyer' && (
                  <Button
                    variant="ghost"
                    onClick={() => navigate('/cart')}
                    className="relative text-white/80 hover:text-[#A9B5DF] hover:bg-white/10 rounded-full h-10 w-10 p-0"
                  >
                    <ShoppingCart className="h-5 w-5" />
                    {cartItemsCount > 0 && (
                      <span className="absolute -top-1 -right-1 bg-[#A9B5DF] text-[#2D336B] text-[9px] rounded-full h-4 w-4 flex items-center justify-center font-black">
                        {cartItemsCount}
                      </span>
                    )}
                  </Button>
                )}

                {/* Profile Trigger */}
                <button 
                  onClick={() => setIsMenuOpen(!isMenuOpen)}
                  className="flex items-center gap-3 outline-none group border-l border-white/10 pl-4"
                >
                  <div className="text-right hidden sm:block">
                    <p className="text-[10px] font-black text-white tracking-widest uppercase leading-none">
                      {user?.user_metadata?.full_name || user?.email?.split('@')[0] || 'User'}
                    </p>
                    <p className="text-[8px] font-bold text-[#A9B5DF] tracking-widest uppercase italic">
                      {role === 'seller' ? 'Official Seller' : 'Member'}
                    </p>
                  </div>
                  <div className="w-10 h-10 rounded-full bg-[#A9B5DF] border-2 border-white/20 flex items-center justify-center transition-all group-hover:ring-4 group-hover:ring-[#A9B5DF]/20 shadow-lg overflow-hidden">
                    <User className="h-5 w-5 text-[#2D336B]" />
                  </div>
                  <ChevronDown className={`h-3 w-3 text-[#A9B5DF] transition-transform ${isMenuOpen ? 'rotate-180' : ''}`} />
                </button>

                {/* Dropdown Menu */}
                <AnimatePresence>
                  {isMenuOpen && (
                    <motion.div
                      initial={{ opacity: 0, y: 10, scale: 0.95 }}
                      animate={{ opacity: 1, y: 0, scale: 1 }}
                      exit={{ opacity: 0, y: 10, scale: 0.95 }}
                      className="absolute right-0 top-full mt-2 w-64 bg-white rounded-[1.5rem] shadow-2xl border border-[#A9B5DF]/20 overflow-hidden py-2"
                    >
                      <div className="px-4 py-3 border-b border-[#FFF2F2]">
                        <p style={{ fontFamily: 'DashHorizon, sans-serif' }} className="text-[#2D336B] text-[10px] italic tracking-[0.2em]">
                          MY <span className="text-[#A9B5DF]">ACCOUNT</span>
                        </p>
                        <p className="text-[8px] text-[#7886C7] font-bold truncate mt-1 italic">{user?.email}</p>
                      </div>

                      <div className="p-1">
                        {/* Hanya menampilkan Dashboard Seller jika role-nya seller */}
                        {role === 'seller' && (
                          <button 
                            onClick={() => { navigate('/seller'); setIsMenuOpen(false); }}
                            className="w-full flex items-center gap-3 px-3 py-2.5 text-[10px] font-black tracking-widest text-[#2D336B] hover:bg-[#FFF2F2] rounded-xl transition-colors uppercase"
                          >
                            <LayoutDashboard className="h-4 w-4 text-[#7886C7]" /> Dashboard Seller
                          </button>
                        )}
                      </div>

                      <div className="mt-1 pt-1 border-t border-[#FFF2F2] p-1">
                        <button 
                          onClick={handleSignOut}
                          className="w-full flex items-center gap-3 px-3 py-2.5 text-[10px] font-black tracking-widest text-red-500 hover:bg-red-50 rounded-xl transition-colors uppercase"
                        >
                          <LogOut className="h-4 w-4" /> Keluar
                        </button>
                      </div>
                    </motion.div>
                  )}
                </AnimatePresence>
              </div>
            ) : (
              <Button
                onClick={() => navigate('/auth')}
                className="bg-[#A9B5DF] text-[#2D336B] hover:bg-white font-black rounded-full px-8 shadow-lg transition-all hover:scale-105 uppercase tracking-[0.2em] text-[10px] h-10"
              >
                Masuk
              </Button>
            )}
          </div>
        </div>
      </div>
    </motion.nav>
  );
}