import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { BookOpen, Mail, Lock, User, ArrowRight, Sparkles } from 'lucide-react';
import { useAuth } from '@/lib/auth';
import { motion, AnimatePresence } from 'framer-motion';
import { toast } from 'sonner';

export default function Auth() {
  const [mode, setMode] = useState<'login' | 'register'>('login');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [name, setName] = useState('');
  const [loading, setLoading] = useState(false);
  const { signIn, signUp, user } = useAuth();
  const navigate = useNavigate();

  useEffect(() => { if (user) navigate('/'); }, [user, navigate]);

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      if (mode === 'login') {
        const { error } = await signIn(email, password);
        if (error) toast.error('Email atau password salah');
      } else {
        if (name.trim().length < 2) { toast.error('Nama minimal 2 karakter'); setLoading(false); return; }
        if (password.length < 6) { toast.error('Password minimal 6 karakter'); setLoading(false); return; }
        const { error } = await signUp(email, password, name, 'seller');
        if (error) toast.error(error.message.includes('already') ? 'Email sudah terdaftar' : error.message);
        else toast.success('Akun berhasil dibuat!');
      }
    } catch { toast.error('Terjadi kesalahan'); }
    setLoading(false);
  };

  return (
    <div className="min-h-screen flex" style={{ background: 'var(--bg-deep)' }}>

      {/* Left Panel */}
      <motion.aside
        initial={{ x: -80, opacity: 0 }}
        animate={{ x: 0, opacity: 1 }}
        transition={{ duration: 0.8, ease: [0.22, 1, 0.36, 1] }}
        className="hidden lg:flex flex-col w-[460px] relative overflow-hidden"
        style={{ background: 'var(--bg-surface)', borderRight: '1px solid var(--border)' }}
      >
        <div className="absolute inset-0 opacity-[0.035]"
          style={{
            backgroundImage: 'linear-gradient(rgba(245,166,35,1) 1px, transparent 1px), linear-gradient(90deg, rgba(245,166,35,1) 1px, transparent 1px)',
            backgroundSize: '48px 48px',
          }}
        />
        <div className="absolute top-1/3 -left-40 w-[480px] h-[480px] rounded-full opacity-15 blur-[80px] pointer-events-none"
          style={{ background: 'var(--amber)' }}
        />

        <div className="relative z-10 flex flex-col h-full p-12">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl flex items-center justify-center"
              style={{ background: 'var(--amber-glow)', border: '1px solid var(--border-accent)' }}>
              <BookOpen className="h-5 w-5" style={{ color: 'var(--amber)' }} />
            </div>
            <span className="font-display text-xl italic" style={{ color: 'var(--text-primary)' }}>Pustaka Kasir</span>
          </div>

          <div className="mt-auto">
            <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full mb-6"
              style={{ background: 'var(--amber-subtle)', border: '1px solid var(--border-accent)' }}>
              <Sparkles className="h-3 w-3" style={{ color: 'var(--amber)' }} />
              <span className="text-[10px] font-bold tracking-widest uppercase" style={{ color: 'var(--amber)' }}>
                Point of Sale System
              </span>
            </div>
            <h1 className="font-display text-5xl leading-[1.15] mb-6" style={{ color: 'var(--text-primary)' }}>
              Kasir Toko Buku<br />
              <em style={{ color: 'var(--amber)' }}>Profesional</em>
            </h1>
            <p className="text-sm leading-relaxed max-w-[280px]" style={{ color: 'var(--text-secondary)' }}>
              Proses transaksi, kelola inventori, dan pantau penjualan harian dengan mudah.
            </p>
          </div>

          <div className="mt-12 space-y-2.5">
            {[
              { icon: '⚡', label: 'Transaksi kilat', sub: 'Checkout dalam hitungan detik' },
              { icon: '📦', label: 'Stok real-time', sub: 'Update otomatis setiap transaksi' },
              { icon: '🧾', label: 'Struk digital', sub: 'Riwayat transaksi tersimpan' },
            ].map((f, i) => (
              <motion.div key={i}
                initial={{ opacity: 0, x: -16 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: 0.6 + i * 0.12 }}
                className="flex items-center gap-3 px-4 py-3 rounded-xl"
                style={{ background: 'var(--bg-elevated)', border: '1px solid var(--border)' }}>
                <span className="text-base">{f.icon}</span>
                <div>
                  <p className="text-xs font-semibold" style={{ color: 'var(--text-primary)' }}>{f.label}</p>
                  <p className="text-[10px]" style={{ color: 'var(--text-muted)' }}>{f.sub}</p>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </motion.aside>

      {/* Right Panel */}
      <div className="flex-1 flex items-center justify-center p-8 relative">
        <div className="absolute inset-0 opacity-[0.02]"
          style={{
            backgroundImage: 'radial-gradient(circle, white 1px, transparent 1px)',
            backgroundSize: '28px 28px',
          }}
        />

        <motion.div
          initial={{ opacity: 0, y: 24 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.25 }}
          className="w-full max-w-[400px] relative z-10"
        >
          {/* Mobile Logo */}
          <div className="flex items-center gap-3 mb-10 lg:hidden">
            <BookOpen className="h-6 w-6" style={{ color: 'var(--amber)' }} />
            <span className="font-display text-2xl italic" style={{ color: 'var(--text-primary)' }}>Pustaka Kasir</span>
          </div>

          <div className="mb-8">
            <h2 className="text-3xl font-bold mb-1.5" style={{ color: 'var(--text-primary)' }}>
              {mode === 'login' ? 'Selamat Datang' : 'Buat Akun'}
            </h2>
            <p className="text-sm" style={{ color: 'var(--text-secondary)' }}>
              {mode === 'login' ? 'Masuk ke sistem kasir Anda' : 'Daftarkan akun kasir baru'}
            </p>
          </div>

          {/* Mode Toggle */}
          <div className="flex rounded-xl p-1 mb-8"
            style={{ background: 'var(--bg-surface)', border: '1px solid var(--border)' }}>
            {(['login', 'register'] as const).map((m) => (
              <button key={m} onClick={() => setMode(m)}
                className="flex-1 py-2.5 rounded-lg text-[11px] font-bold tracking-widest uppercase transition-all duration-200"
                style={mode === m
                  ? { background: 'var(--amber)', color: '#0D1120', boxShadow: '0 2px 10px rgba(245,166,35,0.35)' }
                  : { color: 'var(--text-muted)' }}>
                {m === 'login' ? 'Masuk' : 'Daftar'}
              </button>
            ))}
          </div>

          <AnimatePresence mode="wait">
            <motion.form key={mode}
              initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -8 }}
              transition={{ duration: 0.18 }}
              onSubmit={submit} className="space-y-4">

              {mode === 'register' && (
                <div>
                  <label className="block text-[10px] font-bold uppercase tracking-widest mb-2"
                    style={{ color: 'var(--text-muted)' }}>Nama Lengkap</label>
                  <div className="relative">
                    <User className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4" style={{ color: 'var(--text-ghost)' }} />
                    <input value={name} onChange={e => setName(e.target.value)}
                      placeholder="Nama kasir" className="input-pos w-full pl-11" />
                  </div>
                </div>
              )}

              <div>
                <label className="block text-[10px] font-bold uppercase tracking-widest mb-2"
                  style={{ color: 'var(--text-muted)' }}>Email</label>
                <div className="relative">
                  <Mail className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4" style={{ color: 'var(--text-ghost)' }} />
                  <input type="email" value={email} onChange={e => setEmail(e.target.value)}
                    placeholder="kasir@toko.com" className="input-pos w-full pl-11" required />
                </div>
              </div>

              <div>
                <label className="block text-[10px] font-bold uppercase tracking-widest mb-2"
                  style={{ color: 'var(--text-muted)' }}>Password</label>
                <div className="relative">
                  <Lock className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4" style={{ color: 'var(--text-ghost)' }} />
                  <input type="password" value={password} onChange={e => setPassword(e.target.value)}
                    placeholder="••••••••" className="input-pos w-full pl-11" required />
                </div>
              </div>

              <button type="submit" disabled={loading}
                className="btn-amber w-full h-12 flex items-center justify-center gap-2 mt-2"
                style={{ borderRadius: 12 }}>
                {loading
                  ? <div className="w-4 h-4 border-2 border-black/20 border-t-black rounded-full animate-spin" />
                  : <><span>{mode === 'login' ? 'Masuk ke Sistem' : 'Buat Akun'}</span><ArrowRight className="h-4 w-4" /></>
                }
              </button>
            </motion.form>
          </AnimatePresence>

          <p className="text-center mt-10 text-[10px] tracking-[0.2em]" style={{ color: 'var(--text-ghost)' }}>
            PUSTAKA KASIR © 2026
          </p>
        </motion.div>
      </div>
    </div>
  );
}