import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { BookOpen, Mail, Lock, User, Store, ShoppingBag } from 'lucide-react';
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
    <div className="min-h-screen bg-gradient-to-br from-primary via-primary to-navy-light flex items-center justify-center p-4">
      {/* Decorative Elements */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute -top-40 -right-40 w-96 h-96 bg-gold/10 rounded-full blur-3xl" />
        <div className="absolute -bottom-40 -left-40 w-96 h-96 bg-gold/10 rounded-full blur-3xl" />
      </div>

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="w-full max-w-md relative"
      >
        {/* Logo */}
        <div className="text-center mb-8">
          <a href="/" className="inline-flex items-center gap-2">
            <BookOpen className="h-10 w-10 text-gold" />
            <span className="font-serif text-3xl font-bold text-primary-foreground">
              Pustaka<span className="text-gold">Online</span>
            </span>
          </a>
        </div>

        {/* Auth Card */}
        <div className="bg-card rounded-2xl shadow-xl p-8">
          {/* Tab Switcher */}
          <div className="flex rounded-lg bg-muted p-1 mb-6">
            <button
              onClick={() => setIsLogin(true)}
              className={`flex-1 py-2.5 text-sm font-medium rounded-md transition-all ${
                isLogin
                  ? 'bg-card text-foreground shadow-sm'
                  : 'text-muted-foreground hover:text-foreground'
              }`}
            >
              Masuk
            </button>
            <button
              onClick={() => setIsLogin(false)}
              className={`flex-1 py-2.5 text-sm font-medium rounded-md transition-all ${
                !isLogin
                  ? 'bg-card text-foreground shadow-sm'
                  : 'text-muted-foreground hover:text-foreground'
              }`}
            >
              Daftar
            </button>
          </div>

          <AnimatePresence mode="wait">
            <motion.form
              key={isLogin ? 'login' : 'register'}
              initial={{ opacity: 0, x: isLogin ? -20 : 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: isLogin ? 20 : -20 }}
              transition={{ duration: 0.2 }}
              onSubmit={handleSubmit}
              className="space-y-5"
            >
              {!isLogin && (
                <>
                  <div className="space-y-2">
                    <Label htmlFor="fullName">Nama Lengkap</Label>
                    <div className="relative">
                      <User className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-muted-foreground" />
                      <Input
                        id="fullName"
                        type="text"
                        placeholder="Masukkan nama lengkap"
                        value={fullName}
                        onChange={(e) => setFullName(e.target.value)}
                        className="pl-10"
                      />
                    </div>
                    {errors.fullName && (
                      <p className="text-destructive text-sm">{errors.fullName}</p>
                    )}
                  </div>

                  {/* Role Selection */}
                  <div className="space-y-2">
                    <Label>Daftar Sebagai</Label>
                    <div className="grid grid-cols-2 gap-3">
                      <button
                        type="button"
                        onClick={() => setSelectedRole('buyer')}
                        className={`p-4 rounded-lg border-2 transition-all ${
                          selectedRole === 'buyer'
                            ? 'border-gold bg-gold/10'
                            : 'border-border hover:border-gold/50'
                        }`}
                      >
                        <ShoppingBag className={`h-6 w-6 mx-auto mb-2 ${
                          selectedRole === 'buyer' ? 'text-gold' : 'text-muted-foreground'
                        }`} />
                        <p className={`font-medium text-sm ${
                          selectedRole === 'buyer' ? 'text-foreground' : 'text-muted-foreground'
                        }`}>
                          Pembeli
                        </p>
                      </button>
                      <button
                        type="button"
                        onClick={() => setSelectedRole('seller')}
                        className={`p-4 rounded-lg border-2 transition-all ${
                          selectedRole === 'seller'
                            ? 'border-gold bg-gold/10'
                            : 'border-border hover:border-gold/50'
                        }`}
                      >
                        <Store className={`h-6 w-6 mx-auto mb-2 ${
                          selectedRole === 'seller' ? 'text-gold' : 'text-muted-foreground'
                        }`} />
                        <p className={`font-medium text-sm ${
                          selectedRole === 'seller' ? 'text-foreground' : 'text-muted-foreground'
                        }`}>
                          Penjual
                        </p>
                      </button>
                    </div>
                  </div>
                </>
              )}

              <div className="space-y-2">
                <Label htmlFor="email">Email</Label>
                <div className="relative">
                  <Mail className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-muted-foreground" />
                  <Input
                    id="email"
                    type="email"
                    placeholder="email@example.com"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className="pl-10"
                  />
                </div>
                {errors.email && (
                  <p className="text-destructive text-sm">{errors.email}</p>
                )}
              </div>

              <div className="space-y-2">
                <Label htmlFor="password">Password</Label>
                <div className="relative">
                  <Lock className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-muted-foreground" />
                  <Input
                    id="password"
                    type="password"
                    placeholder="••••••••"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    className="pl-10"
                  />
                </div>
                {errors.password && (
                  <p className="text-destructive text-sm">{errors.password}</p>
                )}
              </div>

              <Button
                type="submit"
                disabled={loading}
                className="w-full bg-gold text-secondary-foreground hover:bg-gold-dark font-semibold py-6"
              >
                {loading ? (
                  <span className="flex items-center gap-2">
                    <span className="h-4 w-4 border-2 border-secondary-foreground/30 border-t-secondary-foreground rounded-full animate-spin" />
                    {isLogin ? 'Masuk...' : 'Mendaftar...'}
                  </span>
                ) : (
                  isLogin ? 'Masuk' : 'Daftar Sekarang'
                )}
              </Button>
            </motion.form>
          </AnimatePresence>
        </div>

        {/* Back to Home */}
        <p className="text-center mt-6 text-primary-foreground/70">
          <a href="/" className="hover:text-gold transition-colors">
            ← Kembali ke Beranda
          </a>
        </p>
      </motion.div>
    </div>
  );
}
