import { User, Mail, ShieldCheck, LogOut, BookOpen, Settings, Zap } from 'lucide-react';
import { Navbar } from '@/components/Navbar';
import { Button } from '@/components/ui/button';
import { useAuth } from '@/lib/auth';
import { motion } from 'framer-motion';

export default function Profile() {
  const { user, role, logout } = useAuth();

  return (
    <div className="min-h-screen bg-[#FFF2F2]/30" style={{ fontFamily: 'Trench, sans-serif' }}>
      <Navbar />

      <div className="max-w-4xl mx-auto px-4 py-16">
        <h1 style={{ fontFamily: 'DashHorizon, sans-serif' }} className="text-4xl text-[#2D336B] mb-12 italic tracking-widest text-center">
          USER <span className="text-[#A9B5DF]">PROFILE</span>
        </h1>

        <div className="grid md:grid-cols-3 gap-8">
          {/* Avatar & Tech Badge */}
          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="md:col-span-1 bg-[#2D336B] rounded-[3rem] p-8 text-white text-center shadow-2xl border border-white/5"
          >
            <div className="w-32 h-32 bg-[#A9B5DF] rounded-full mx-auto mb-6 flex items-center justify-center border-4 border-white/10 overflow-hidden relative">
              <User className="h-16 w-16 text-[#2D336B]" />
              <div className="absolute bottom-0 right-0 p-2 bg-[#FFF2F2] rounded-full shadow-lg">
                <Zap className="h-4 w-4 text-[#2D336B]" />
              </div>
            </div>
            <h2 style={{ fontFamily: 'DashHorizon, sans-serif' }} className="text-xl italic tracking-wider mb-1">
              {user?.name || 'ALDEN AUDY AKBAR'}
            </h2>
            <p className="text-[#A9B5DF] text-[10px] font-bold tracking-[0.2em] uppercase mb-6">
              {role === 'seller' ? 'Official Seller' : 'Student & AI Enthusiast'}
            </p>
            
            <Button 
              variant="outline" 
              className="w-full rounded-full border-white/20 text-white hover:bg-white hover:text-[#2D336B] text-[10px] font-black tracking-widest uppercase h-10"
            >
              Ubah Foto
            </Button>
          </motion.div>

          {/* Account Details */}
          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="md:col-span-2 space-y-6"
          >
            <div className="bg-white rounded-[2.5rem] p-8 shadow-sm border border-[#A9B5DF]/20">
              <h3 style={{ fontFamily: 'DashHorizon, sans-serif' }} className="text-[#2D336B] text-lg italic mb-8 tracking-widest">
                DETAIL <span className="text-[#A9B5DF]">AKUN</span>
              </h3>
              
              <div className="space-y-6">
                <div className="flex items-center gap-4 p-4 bg-[#FFF2F2] rounded-2xl border border-[#A9B5DF]/10">
                  <div className="p-3 bg-white rounded-xl shadow-sm flex-shrink-0">
                    <Mail className="h-5 w-5 text-[#7886C7]" />
                  </div>
                  <div className="min-w-0">
                    <p className="text-[#7886C7] text-[8px] font-black tracking-widest uppercase">Alamat Email</p>
                    <p className="text-[#2D336B] font-bold text-sm truncate">{user?.email || 'alden@student.telkomuniversity.ac.id'}</p>
                  </div>
                </div>

                <div className="flex items-center gap-4 p-4 bg-[#FFF2F2] rounded-2xl border border-[#A9B5DF]/10">
                  <div className="p-3 bg-white rounded-xl shadow-sm flex-shrink-0">
                    <ShieldCheck className="h-5 w-5 text-[#7886C7]" />
                  </div>
                  <div>
                    <p className="text-[#7886C7] text-[8px] font-black tracking-widest uppercase">Status</p>
                    <p className="text-[#2D336B] font-bold text-sm">Verified Informatics Student</p>
                  </div>
                </div>

                <div className="flex items-center gap-4 p-4 bg-[#FFF2F2] rounded-2xl border border-[#A9B5DF]/10">
                  <div className="p-3 bg-white rounded-xl shadow-sm flex-shrink-0">
                    <BookOpen className="h-5 w-5 text-[#7886C7]" />
                  </div>
                  <div>
                    <p className="text-[#7886C7] text-[8px] font-black tracking-widest uppercase">Akademik</p>
                    <p className="text-[#2D336B] font-bold text-sm italic">AI Research Project Active</p>
                  </div>
                </div>
              </div>
            </div>

            {/* Buttons */}
            <div className="flex flex-col sm:flex-row gap-4">
              <Button className="flex-1 bg-[#A9B5DF] hover:bg-white text-[#2D336B] rounded-full h-14 font-black tracking-[0.2em] text-[10px] shadow-lg transition-all border-2 border-transparent hover:border-[#A9B5DF]">
                <Settings className="h-4 w-4 mr-2" /> PENGATURAN
              </Button>
              <Button 
                onClick={logout}
                className="flex-1 bg-[#2D336B] hover:bg-red-500 text-white rounded-full h-14 font-black tracking-[0.2em] text-[10px] shadow-lg transition-all"
              >
                <LogOut className="h-4 w-4 mr-2" /> KELUAR
              </Button>
            </div>
          </motion.div>
        </div>
      </div>
    </div>
  );
}