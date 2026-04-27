import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { BookOpen, Mail, Lock, User, Store, ShoppingBag, ArrowLeft } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { useAuth } from '@/lib/auth';
import { motion, AnimatePresence } from 'framer-motion';
import { toast } from 'sonner';
import { z } from 'zod';

const signUpSchema = z.object({
  email: z.string().email('Email tidak valid'),
  password: z.string().min(6, 'Password minimal 6 karakter'),
  fullName: z.string().min(2, 'Nama minimal 2 karakter'),
});

const signInSchema = z.object({
  email: z.string().email('Email tidak valid'),
  password: z.string().min(1, 'Password tidak boleh kosong'),
});

type AppRole = 'seller' | 'buyer';

export default function Auth() {
  const [isLogin, setIsLogin] = useState(true);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [fullName, setFullName] = useState('');
  const [selectedRole, setSelectedRole] = useState<AppRole>('buyer');
  const [loading, setLoading] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});

  const { signIn, signUp, user, role } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    if (user && role) {
      if (role === 'seller') {
        navigate('/seller');
      } else {
        navigate('/catalog');
      }
    }
  }, [user, role, navigate]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErrors({});
    setLoading(true);

    try {
      if (isLogin) {
        const result = signInSchema.safeParse({ email, password });
        if (!result.success) {
          const fieldErrors: Record<string, string> = {};
          result.error.errors.forEach((err) => {
            if (err.path[0]) {
              fieldErrors[err.path[0] as string] = err.message;
            }
          });
          setErrors(fieldErrors);
          setLoading(false);
          return;
        }

        const { error } = await signIn(email, password);
        if (error) {
          if (error.message.includes('Invalid login')) {
            toast.error('Email atau password salah');
          } else {
            toast.error(error.message);
          }
        }
      } else {
        const result = signUpSchema.safeParse({ email, password, fullName });
        if (!result.success) {
          const fieldErrors: Record<string, string> = {};
          result.error.errors.forEach((err) => {
            if (err.path[0]) {
              fieldErrors[err.path[0] as string] = err.message;
            }
          });
          setErrors(fieldErrors);
          setLoading(false);
          return;
        }

        const { error } = await signUp(email, password, fullName, selectedRole);
        if (error) {
          if (error.message.includes('already registered')) {
            toast.error('Email sudah terdaftar. Silakan login.');
          } else {
            toast.error(error.message);
          }
        } else {
          toast.success('Pendaftaran berhasil!');
        }
      }
    } catch (error) {
      toast.error('Terjadi kesalahan. Silakan coba lagi.');
    }

    setLoading(false);
  };

  return (
    <div className="min-h-screen bg-[#2D336B] flex flex-col items-center justify-center p-4 relative overflow-hidden" 
         style={{ fontFamily: 'Trench, sans-serif' }}>
      
      {/* Decorative Blur Elements */}
      <div className="absolute top-0 left-0 w-96 h-96 bg-[#A9B5DF]/10 rounded-full -ml-48 -mt-48 blur-3xl" />
      <div className="absolute bottom-0 right-0 w-96 h-96 bg-[#FFF2F2]/5 rounded-full -mr-48 -mb-48 blur-3xl" />

      {/* Logo Section */}
      <motion.div 
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="mb-8 text-center z-10"
      >
        <a href="/" className="inline-flex items-center gap-3">
          <BookOpen className="h-10 w-10 text-[#A9B5DF]" />
          <h1 style={{ fontFamily: 'DashHorizon, sans-serif' }} className="text-4xl text-white italic tracking-widest">
            PUSTAKA <span className="text-[#A9B5DF]">ONLINE</span>
          </h1>
        </a>
      </motion.div>

      {/* Auth Card */}
      <motion.div
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        className="w-full max-w-md bg-white rounded-[2.5rem] shadow-2xl p-8 z-10 border border-[#A9B5DF]/20"
      >
        {/* Tab Switcher */}
        <div className="flex bg-[#FFF2F2] p-1.5 rounded-full mb-8">
          <button
            onClick={() => setIsLogin(true)}
            className={`flex-1 py-3 rounded-full text-[10px] font-black tracking-[0.2em] transition-all ${
              isLogin ? 'bg-[#2D336B] text-white shadow-lg' : 'text-[#7886C7]'
            }`}
          >
            MASUK
          </button>
          <button
            onClick={() => setIsLogin(false)}
            className={`flex-1 py-3 rounded-full text-[10px] font-black tracking-[0.2em] transition-all ${
              !isLogin ? 'bg-[#2D336B] text-white shadow-lg' : 'text-[#7886C7]'
            }`}
          >
            DAFTAR
          </button>
        </div>

        <AnimatePresence mode="wait">
          <motion.form
            key={isLogin ? 'login' : 'register'}
            initial={{ opacity: 0, x: isLogin ? -10 : 10 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: isLogin ? 10 : -10 }}
            transition={{ duration: 0.2 }}
            onSubmit={handleSubmit}
            className="space-y-5"
          >
            {!isLogin && (
              <>
                <div className="space-y-2">
                  <Label className="text-[10px] font-bold text-[#7886C7] tracking-[0.2em] ml-4 uppercase">Nama Lengkap</Label>
                  <div className="relative">
                    <User className="absolute left-4 top-1/2 -translate-y-1/2 h-4 w-4 text-[#A9B5DF]" />
                    <Input
                      type="text"
                      placeholder="Masukkan nama lengkap"
                      value={fullName}
                      onChange={(e) => setFullName(e.target.value)}
                      className="pl-12 bg-[#FFF2F2]/50 border-[#A9B5DF]/30 focus:border-[#2D336B] focus-visible:ring-[#2D336B] focus-visible:ring-offset-0 rounded-full h-12 text-[#2D336B] tracking-widest text-sm"
                    />
                  </div>
                  {errors.fullName && <p className="text-red-500 text-[10px] ml-4 font-bold">{errors.fullName}</p>}
                </div>

                {/* Role Selection - Blue Style */}
                <div className="space-y-2">
                  <Label className="text-[10px] font-bold text-[#7886C7] tracking-[0.2em] ml-4 uppercase">Daftar Sebagai</Label>
                  <div className="grid grid-cols-2 gap-3">
                    <button
                      type="button"
                      onClick={() => setSelectedRole('buyer')}
                      className={`p-4 rounded-2xl border-2 transition-all flex flex-col items-center gap-2 ${
                        selectedRole === 'buyer'
                          ? 'border-[#2D336B] bg-[#2D336B]/5'
                          : 'border-[#FFF2F2] hover:border-[#A9B5DF]/50'
                      }`}
                    >
                      <ShoppingBag className={`h-5 w-5 ${selectedRole === 'buyer' ? 'text-[#2D336B]' : 'text-[#A9B5DF]'}`} />
                      <span className={`text-[10px] font-black tracking-widest ${selectedRole === 'buyer' ? 'text-[#2D336B]' : 'text-[#7886C7]'}`}>PEMBELI</span>
                    </button>
                    <button
                      type="button"
                      onClick={() => setSelectedRole('seller')}
                      className={`p-4 rounded-2xl border-2 transition-all flex flex-col items-center gap-2 ${
                        selectedRole === 'seller'
                          ? 'border-[#2D336B] bg-[#2D336B]/5'
                          : 'border-[#FFF2F2] hover:border-[#A9B5DF]/50'
                      }`}
                    >
                      <Store className={`h-5 w-5 ${selectedRole === 'seller' ? 'text-[#2D336B]' : 'text-[#A9B5DF]'}`} />
                      <span className={`text-[10px] font-black tracking-widest ${selectedRole === 'seller' ? 'text-[#2D336B]' : 'text-[#7886C7]'}`}>PENJUAL</span>
                    </button>
                  </div>
                </div>
              </>
            )}

            <div className="space-y-2">
              <Label className="text-[10px] font-bold text-[#7886C7] tracking-[0.2em] ml-4 uppercase">Email Address</Label>
              <div className="relative">
                <Mail className="absolute left-4 top-1/2 -translate-y-1/2 h-4 w-4 text-[#A9B5DF]" />
                <Input
                  type="email"
                  placeholder="email@example.com"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="pl-12 bg-[#FFF2F2]/50 border-[#A9B5DF]/30 focus:border-[#2D336B] focus-visible:ring-[#2D336B] focus-visible:ring-offset-0 rounded-full h-12 text-[#2D336B] tracking-widest text-sm"
                />
              </div>
              {errors.email && <p className="text-red-500 text-[10px] ml-4 font-bold">{errors.email}</p>}
            </div>

            <div className="space-y-2">
              <Label className="text-[10px] font-bold text-[#7886C7] tracking-[0.2em] ml-4 uppercase">Password</Label>
              <div className="relative">
                <Lock className="absolute left-4 top-1/2 -translate-y-1/2 h-4 w-4 text-[#A9B5DF]" />
                <Input
                  type="password"
                  placeholder="••••••••"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="pl-12 bg-[#FFF2F2]/50 border-[#A9B5DF]/30 focus:border-[#2D336B] focus-visible:ring-[#2D336B] focus-visible:ring-offset-0 rounded-full h-12 text-[#2D336B] tracking-widest text-sm"
                />
              </div>
              {errors.password && <p className="text-red-500 text-[10px] ml-4 font-bold">{errors.password}</p>}
            </div>

            <Button
              type="submit"
              disabled={loading}
              className="w-full bg-[#2D336B] hover:bg-[#1A1F4D] text-white rounded-full h-14 font-black tracking-[0.3em] text-xs shadow-xl transition-all active:scale-[0.98] mt-4"
            >
              {loading ? (
                <div className="flex items-center gap-2">
                  <div className="h-4 w-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                  <span>PROSES...</span>
                </div>
              ) : (
                isLogin ? 'MASUK SEKARANG' : 'BUAT AKUN'
              )}
            </Button>
          </motion.form>
        </AnimatePresence>

        <a 
          href="/" 
          className="mt-8 flex items-center justify-center gap-2 text-[#7886C7] hover:text-[#2D336B] transition-colors text-[10px] font-bold tracking-widest uppercase"
        >
          <ArrowLeft className="h-3 w-3" />
          Kembali ke Beranda
        </a>
      </motion.div>
    </div>
  );
}