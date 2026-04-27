import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Plus, Edit, Trash2, Package, BookOpen, Eye, EyeOff, LayoutDashboard, TrendingUp, X } from 'lucide-react';
import { Navbar } from '@/components/Navbar';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { useAuth } from '@/lib/auth';
import { useSellerBooks, Book } from '@/hooks/useBooks';
import { motion, AnimatePresence } from 'framer-motion';

const categories = ['Novel', 'Komik', 'Akademik', 'Bisnis', 'Self-Help', 'Anak-anak', 'Agama', 'Hobi'];

interface BookFormData {
  title: string;
  author: string;
  description: string;
  price: string;
  stock: string;
  cover_image: string;
  category: string;
  isbn: string;
}

const initialFormData: BookFormData = {
  title: '', author: '', description: '', price: '', stock: '', cover_image: '', category: '', isbn: '',
};

export default function SellerDashboard() {
  const { user, role, loading: authLoading } = useAuth();
  const { books, loading, addBook, updateBook, deleteBook, toggleAvailability } = useSellerBooks();
  const navigate = useNavigate();

  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [editingBook, setEditingBook] = useState<Book | null>(null);
  const [formData, setFormData] = useState<BookFormData>(initialFormData);
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    if (!authLoading && !user) navigate('/auth');
    if (!authLoading && user && role !== 'seller') navigate('/catalog');
  }, [user, role, authLoading, navigate]);

  const handleOpenDialog = (book?: Book) => {
    if (book) {
      setEditingBook(book);
      setFormData({
        title: book.title,
        author: book.author,
        description: book.description || '',
        price: book.price.toString(),
        stock: book.stock.toString(),
        cover_image: book.cover_image || '',
        category: book.category || '',
        isbn: book.isbn || '',
      });
    } else {
      setEditingBook(null);
      setFormData(initialFormData);
    }
    setIsDialogOpen(true);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    const bookData = {
      ...formData,
      price: parseFloat(formData.price),
      stock: parseInt(formData.stock),
      is_available: editingBook ? editingBook.is_available : true,
    };

    if (editingBook) {
      await updateBook(editingBook.id, bookData);
    } else {
      await addBook(bookData);
    }
    setSubmitting(false);
    setIsDialogOpen(false);
  };

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('id-ID', {
      style: 'currency', currency: 'IDR', minimumFractionDigits: 0,
    }).format(price);
  };

  if (authLoading || loading) {
    return (
      <div className="min-h-screen bg-[#FFF2F2]">
        <Navbar />
        <div className="flex flex-col items-center justify-center py-20">
          <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-[#2D336B]"></div>
          <p className="mt-4 font-black tracking-widest text-[#2D336B] uppercase text-[10px]">Memuat Data Koleksi...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#FFF2F2]">
      <Navbar />

      <main className="max-w-7xl mx-auto px-4 py-10">
        {/* Header Section */}
        <div className="flex flex-col md:flex-row md:items-end justify-between gap-6 mb-12">
          <motion.div initial={{ opacity: 0, x: -20 }} animate={{ opacity: 1, x: 0 }}>
            <div className="flex items-center gap-3 mb-2">
              <div className="p-2 bg-[#2D336B] rounded-lg shadow-lg shadow-[#2D336B]/20">
                <LayoutDashboard className="h-5 w-5 text-[#A9B5DF]" />
              </div>
              <span className="text-[10px] font-black text-[#7886C7] tracking-[0.3em] uppercase italic">Seller Central</span>
            </div>
            <h1 style={{ fontFamily: 'DashHorizon, sans-serif' }} className="text-4xl md:text-5xl text-[#2D336B] italic leading-none uppercase">
              DASHBOARD <span className="text-[#A9B5DF]">PENJUAL</span>
            </h1>
          </motion.div>

          <Button
            onClick={() => handleOpenDialog()}
            className="bg-[#2D336B] hover:bg-[#7886C7] text-white font-black py-6 px-8 rounded-2xl shadow-xl transition-all hover:scale-105 active:scale-95"
          >
            <Plus className="h-5 w-5 mr-2" />
            <span className="tracking-[0.2em] uppercase text-[10px]">Tambah Koleksi</span>
          </Button>
        </div>

        {/* Analytics Stats */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-12">
          {[
            { label: 'Total Buku', val: books.length, icon: BookOpen, color: '#2D336B' },
            { label: 'Tersedia', val: books.filter(b => b.is_available).length, icon: Eye, color: '#7886C7' },
            { label: 'Stok Habis', val: books.filter(b => b.stock === 0).length, icon: Package, color: '#EF4444' },
            { label: 'Performa Toko', val: '100%', icon: TrendingUp, color: '#A9B5DF' }
          ].map((stat, i) => (
            <motion.div key={i} initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.1 }}
              className="bg-white p-6 rounded-[2rem] border border-[#A9B5DF]/20 shadow-sm hover:shadow-md transition-shadow"
            >
              <div className="flex justify-between items-start">
                <div>
                  <p className="text-[9px] font-black text-[#7886C7] tracking-widest uppercase mb-1">{stat.label}</p>
                  <p className="text-3xl font-black text-[#2D336B]">{stat.val}</p>
                </div>
                <div className="p-3 rounded-2xl bg-[#FFF2F2]" style={{ color: stat.color }}>
                  <stat.icon className="h-6 w-6" />
                </div>
              </div>
            </motion.div>
          ))}
        </div>

        {/* Books Catalog Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          <AnimatePresence mode="popLayout">
            {books.map((book, index) => (
              <motion.div
                key={book.id}
                layout
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.9 }}
                className={`group bg-white rounded-[2.5rem] overflow-hidden border border-[#A9B5DF]/20 shadow-sm hover:shadow-xl transition-all duration-500 ${!book.is_available ? 'grayscale-[0.8] opacity-60' : ''}`}
              >
                <div className="p-6">
                  <div className="flex gap-5">
                    <div className="w-28 h-40 rounded-2xl overflow-hidden bg-[#FFF2F2] flex-shrink-0 shadow-inner group-hover:rotate-2 transition-transform duration-500">
                      {book.cover_image ? (
                        <img src={book.cover_image} alt={book.title} className="w-full h-full object-cover" />
                      ) : (
                        <div className="w-full h-full flex items-center justify-center bg-[#A9B5DF]/10">
                          <BookOpen className="h-8 w-8 text-[#A9B5DF]" />
                        </div>
                      )}
                    </div>
                    <div className="flex-1 flex flex-col justify-between py-1">
                      <div>
                        <p className="text-[8px] font-black text-[#A9B5DF] tracking-[0.2em] uppercase mb-1">{book.category || 'General'}</p>
                        <h3 className="font-bold text-[#2D336B] leading-tight line-clamp-2 uppercase text-sm tracking-wide">{book.title}</h3>
                        <p className="text-[10px] font-bold text-[#7886C7] italic mt-1">{book.author}</p>
                      </div>
                      <div>
                        <p className="text-lg font-black text-[#2D336B]">{formatPrice(book.price)}</p>
                        <span className={`text-[8px] font-black px-2 py-0.5 rounded-full uppercase mt-2 inline-block ${book.stock > 0 ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>
                          Stok: {book.stock}
                        </span>
                      </div>
                    </div>
                  </div>
                </div>
                <div className="bg-[#2D336B]/5 px-6 py-4 flex gap-2">
                  <Button 
                    variant="ghost" 
                    size="sm" 
                    onClick={() => toggleAvailability(book.id, !book.is_available)} 
                    className="flex-1 h-10 rounded-xl text-[9px] font-black uppercase tracking-widest text-[#2D336B] hover:bg-[#2D336B] hover:text-white transition-all"
                  >
                    {book.is_available ? <><EyeOff className="h-3 w-3 mr-2" /> Sembunyi</> : <><Eye className="h-3 w-3 mr-2" /> Tampil</>}
                  </Button>
                  <Button variant="ghost" size="sm" onClick={() => handleOpenDialog(book)} className="h-10 w-10 rounded-xl hover:bg-[#A9B5DF]/20 text-[#7886C7]"><Edit className="h-3 w-3" /></Button>
                  <Button variant="ghost" size="sm" onClick={() => { if(confirm('Hapus koleksi buku ini?')) deleteBook(book.id) }} className="h-10 w-10 rounded-xl hover:bg-red-50 text-red-400"><Trash2 className="h-3 w-3" /></Button>
                </div>
              </motion.div>
            ))}
          </AnimatePresence>
        </div>
      </main>

      {/* Modern Dialog Form (Bebas Warna Kuning) */}
      <AnimatePresence>
        {isDialogOpen && (
          <div className="fixed inset-0 z-[150] flex items-center justify-center p-4 bg-[#2D336B]/60 backdrop-blur-md">
            <motion.div 
              initial={{ scale: 0.9, opacity: 0, y: 20 }} 
              animate={{ scale: 1, opacity: 1, y: 0 }} 
              exit={{ scale: 0.9, opacity: 0, y: 20 }}
              className="bg-white w-full max-w-2xl rounded-[3rem] shadow-2xl overflow-hidden border border-[#A9B5DF]/30"
            >
              <div className="p-8 md:p-10">
                <div className="flex justify-between items-center mb-8">
                  <div>
                    <h2 style={{ fontFamily: 'DashHorizon, sans-serif' }} className="text-3xl text-[#2D336B] italic leading-none uppercase">
                      {editingBook ? 'EDIT' : 'TAMBAH'} <span className="text-[#A9B5DF]">BUKU</span>
                    </h2>
                    <p className="text-[9px] font-bold text-[#7886C7] tracking-[0.3em] uppercase mt-2">Detail Informasi Koleksi</p>
                  </div>
                  <button 
                    onClick={() => setIsDialogOpen(false)} 
                    className="w-10 h-10 rounded-full bg-[#FFF2F2] flex items-center justify-center hover:bg-red-50 transition-colors"
                  >
                    <X className="h-4 w-4 text-[#2D336B]" />
                  </button>
                </div>

                <form onSubmit={handleSubmit} className="space-y-4">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="space-y-1">
                      <Label className="text-[10px] font-black uppercase tracking-widest ml-1 text-[#2D336B]">Judul</Label>
                      <Input 
                        value={formData.title} 
                        onChange={e => setFormData({...formData, title: e.target.value})} 
                        className="rounded-xl h-11 border-[#A9B5DF]/30 focus-visible:ring-[#2D336B]" 
                        required 
                      />
                    </div>
                    <div className="space-y-1">
                      <Label className="text-[10px] font-black uppercase tracking-widest ml-1 text-[#2D336B]">Penulis</Label>
                      <Input 
                        value={formData.author} 
                        onChange={e => setFormData({...formData, author: e.target.value})} 
                        className="rounded-xl h-11 border-[#A9B5DF]/30 focus-visible:ring-[#2D336B]" 
                        required 
                      />
                    </div>
                  </div>

                  <div className="space-y-1">
                    <Label className="text-[10px] font-black uppercase tracking-widest ml-1 text-[#2D336B]">Deskripsi</Label>
                    <Textarea 
                      value={formData.description} 
                      onChange={e => setFormData({...formData, description: e.target.value})} 
                      className="rounded-2xl min-h-[80px] border-[#A9B5DF]/30 focus-visible:ring-[#2D336B] resize-none" 
                    />
                  </div>
                  
                  <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                    <div className="space-y-1">
                      <Label className="text-[10px] font-black uppercase tracking-widest ml-1 text-[#2D336B]">Harga (Rp)</Label>
                      <Input 
                        type="number" 
                        value={formData.price} 
                        onChange={e => setFormData({...formData, price: e.target.value})} 
                        className="rounded-xl h-11 border-[#A9B5DF]/30 focus-visible:ring-[#2D336B]" 
                        required 
                      />
                    </div>
                    <div className="space-y-1">
                      <Label className="text-[10px] font-black uppercase tracking-widest ml-1 text-[#2D336B]">Stok</Label>
                      <Input 
                        type="number" 
                        value={formData.stock} 
                        onChange={e => setFormData({...formData, stock: e.target.value})} 
                        className="rounded-xl h-11 border-[#A9B5DF]/30 focus-visible:ring-[#2D336B]" 
                        required 
                      />
                    </div>
                    <div className="space-y-1 col-span-2 md:col-span-1">
                      <Label className="text-[10px] font-black uppercase tracking-widest ml-1 text-[#2D336B]">Kategori</Label>
                      <Select value={formData.category} onValueChange={(val) => setFormData({...formData, category: val})}>
                        <SelectTrigger className="rounded-xl h-11 border-[#A9B5DF]/30 bg-white text-[#2D336B] focus:ring-[#2D336B] focus:border-[#2D336B]">
                          <SelectValue placeholder="Pilih" />
                        </SelectTrigger>
                        <SelectContent className="z-[200] bg-white border-[#A9B5DF]/20 shadow-xl rounded-xl overflow-hidden">
                          {categories.map((c) => (
                            <SelectItem 
                              key={c} 
                              value={c} 
                              className="text-[10px] font-bold uppercase py-3 cursor-pointer focus:bg-[#2D336B] focus:text-white data-[state=selected]:bg-[#2D336B] data-[state=selected]:text-white transition-colors"
                            >
                              {c}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>
                  </div>

                  <div className="space-y-1">
                    <Label className="text-[10px] font-black uppercase tracking-widest ml-1 text-[#2D336B]">URL Cover Gambar</Label>
                    <Input 
                      value={formData.cover_image} 
                      onChange={e => setFormData({...formData, cover_image: e.target.value})} 
                      placeholder="https://images.unsplash.com/..." 
                      className="rounded-xl h-11 border-[#A9B5DF]/30 focus-visible:ring-[#2D336B]" 
                    />
                  </div>
                  
                  <div className="flex gap-4 pt-6">
                    <Button 
                      type="button" 
                      variant="ghost" 
                      onClick={() => setIsDialogOpen(false)} 
                      className="flex-1 h-14 rounded-2xl uppercase font-black text-[10px] tracking-widest text-[#7886C7] hover:bg-[#FFF2F2]"
                    >
                      Batal
                    </Button>
                    <Button 
                      type="submit" 
                      disabled={submitting} 
                      className="flex-[2] h-14 bg-[#2D336B] hover:bg-[#7886C7] text-white rounded-2xl uppercase font-black text-[10px] tracking-widest shadow-lg shadow-[#2D336B]/20 transition-all hover:scale-[1.02] active:scale-95"
                    >
                      {submitting ? 'Sedang Memproses...' : 'Simpan Koleksi'}
                    </Button>
                  </div>
                </form>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </div>
  );
}