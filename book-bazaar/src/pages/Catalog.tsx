import { useState, useMemo } from 'react';
import { Search, BookOpen, ShoppingCart, Plus, Minus, Trash2 } from 'lucide-react';
import { useBooks } from '@/hooks/useBooks';
import { useCart } from '@/hooks/useCart';

const categories = [
  'Semua',
  'Novel',
  'Komik',
  'Akademik',
  'Bisnis',
  'Self-Help',
  'Anak-anak',
  'Agama',
  'Hobi',
];

export default function Catalog() {
  const { books, loading } = useBooks();
  const { 
    cartItems, 
    addToCart, 
    updateQuantity, 
    removeFromCart, 
    clearCart, 
    cartTotal 
  } = useCart();

  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('Semua');

  // Logika Filter
  const filteredBooks = useMemo(() => {
    return books.filter((book) => {
      const matchesSearch =
        book.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
        book.author.toLowerCase().includes(searchQuery.toLowerCase());
      const matchesCategory =
        selectedCategory === 'Semua' || book.category === selectedCategory;
      return matchesSearch && matchesCategory;
    });
  }, [books, searchQuery, selectedCategory]);

  // Format Rupiah
  const formatRupiah = (number: number) => {
    return new Intl.NumberFormat('id-ID', {
      style: 'currency',
      currency: 'IDR',
      minimumFractionDigits: 0
    }).format(number);
  };

  return (
    <div className="min-h-screen bg-slate-50 p-4 font-sans flex flex-col lg:flex-row gap-4">
      
      {/* ========================================= */}
      {/* BAGIAN KIRI: KATALOG BUKU & PENCARIAN     */}
      {/* ========================================= */}
      <div className="flex-1 flex flex-col h-[calc(100vh-2rem)]">
        
        {/* Header & Search */}
        <div className="bg-white p-5 rounded-2xl shadow-sm border border-slate-100 mb-4 shrink-0">
          <h1 className="text-xl font-bold text-slate-800 mb-4">Sistem Kasir Toko Buku</h1>
          
          <div className="relative mb-4">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 h-5 w-5 text-slate-400" />
            <input
              type="text"
              placeholder="Cari judul buku atau penulis..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-12 pr-4 py-3 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all"
            />
          </div>
          
          {/* Category Filter */}
          <div className="flex gap-2 overflow-x-auto pb-2 no-scrollbar">
            {categories.map((category) => (
              <button
                key={category}
                onClick={() => setSelectedCategory(category)}
                className={`px-4 py-2 rounded-lg text-sm font-medium whitespace-nowrap transition-all ${
                  selectedCategory === category
                    ? 'bg-blue-600 text-white shadow-md'
                    : 'bg-slate-50 text-slate-600 border border-slate-200 hover:bg-slate-100'
                }`}
              >
                {category}
              </button>
            ))}
          </div>
        </div>

        {/* Grid Buku */}
        <div className="bg-white p-5 rounded-2xl shadow-sm border border-slate-100 flex-1 overflow-y-auto">
          {loading ? (
            <div className="flex items-center justify-center h-full">
              <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
            </div>
          ) : filteredBooks.length > 0 ? (
            <div className="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-4">
              {filteredBooks.map((book) => (
                <div 
                  key={book.id}
                  onClick={() => addToCart(book.id)}
                  className="group flex flex-col bg-white border border-slate-100 rounded-xl overflow-hidden hover:shadow-lg transition-all cursor-pointer hover:border-blue-200"
                >
                  <div className="h-40 bg-slate-100 flex items-center justify-center p-4 relative overflow-hidden">
                    {book.cover_image ? (
                      <img 
                        src={book.cover_image} 
                        alt={book.title} 
                        className="h-full object-contain group-hover:scale-105 transition-transform" 
                      />
                    ) : (
                      <BookOpen className="h-12 w-12 text-slate-300" />
                    )}
                  </div>
                  <div className="p-3 flex flex-col flex-1">
                    <h3 className="text-sm font-semibold text-slate-800 line-clamp-2 mb-1">
                      {book.title}
                    </h3>
                    <p className="text-xs text-slate-500 mb-3 line-clamp-1">{book.author}</p>
                    <div className="mt-auto flex items-center justify-between">
                      <span className="text-blue-600 font-bold text-sm">
                        {formatRupiah(book.price)}
                      </span>
                      <span className="text-[10px] font-medium px-2 py-1 bg-slate-100 text-slate-600 rounded-md">
                        Stok: {book.stock}
                      </span>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="flex flex-col items-center justify-center h-full text-slate-400">
              <BookOpen className="h-16 w-16 mb-4 opacity-20" />
              <p className="text-sm font-medium">Tidak ada buku yang ditemukan</p>
            </div>
          )}
        </div>
      </div>

      {/* ========================================= */}
      {/* BAGIAN KANAN: KERANJANG / STRUK KASIR     */}
      {/* ========================================= */}
      <div className="w-full lg:w-[400px] h-[calc(100vh-2rem)] shrink-0 flex flex-col bg-white rounded-2xl shadow-lg border border-slate-100 overflow-hidden">
        
        {/* Cart Header */}
        <div className="p-5 bg-white border-b border-slate-100 flex items-center justify-between shrink-0">
          <div className="flex items-center gap-2">
            <ShoppingCart className="h-5 w-5 text-blue-600" />
            <h2 className="font-bold text-slate-800">Pesanan Saat Ini</h2>
          </div>
          {cartItems.length > 0 && (
            <button 
              onClick={clearCart}
              className="text-xs font-semibold text-red-500 hover:text-red-600 hover:bg-red-50 px-2 py-1 rounded transition-colors"
            >
              Kosongkan
            </button>
          )}
        </div>

        {/* Cart Items List */}
        <div className="flex-1 overflow-y-auto bg-slate-50/50 p-4 space-y-3">
          {cartItems.length === 0 ? (
            <div className="h-full flex flex-col items-center justify-center text-slate-400">
              <ShoppingCart className="h-12 w-12 mb-3 opacity-20" />
              <p className="text-sm text-center">Keranjang kosong.<br/>Klik buku untuk menambahkan.</p>
            </div>
          ) : (
            cartItems.map((item) => (
              <div key={item.id} className="bg-white p-3 rounded-xl shadow-sm border border-slate-100">
                <div className="flex justify-between mb-2">
                  <h4 className="text-sm font-semibold text-slate-800 line-clamp-2 pr-4">
                    {item.book?.title}
                  </h4>
                  <span className="text-sm font-bold text-blue-600 shrink-0">
                    {formatRupiah((item.book?.price || 0) * item.quantity)}
                  </span>
                </div>
                
                <div className="flex items-center justify-between mt-2">
                  <span className="text-xs text-slate-500">
                    {formatRupiah(item.book?.price || 0)} / item
                  </span>
                  
                  {/* Quantity Controls */}
                  <div className="flex items-center gap-3 bg-slate-50 rounded-lg p-1 border border-slate-100">
                    <button 
                      onClick={() => updateQuantity(item.id, item.quantity - 1)}
                      className="p-1 hover:bg-white rounded shadow-sm transition-colors"
                    >
                      {item.quantity <= 1 ? (
                        <Trash2 className="h-4 w-4 text-red-500" />
                      ) : (
                        <Minus className="h-4 w-4 text-slate-600" />
                      )}
                    </button>
                    <span className="text-sm font-bold text-slate-800 w-4 text-center">
                      {item.quantity}
                    </span>
                    <button 
                      onClick={() => updateQuantity(item.id, item.quantity + 1)}
                      className="p-1 hover:bg-white rounded shadow-sm transition-colors"
                    >
                      <Plus className="h-4 w-4 text-slate-600" />
                    </button>
                  </div>
                </div>
              </div>
            ))
          )}
        </div>

        {/* Checkout Footer */}
        <div className="p-5 bg-white border-t border-slate-100 shrink-0">
          <div className="flex items-center justify-between mb-4">
            <span className="text-slate-500 font-medium">Total Tagihan</span>
            <span className="text-2xl font-bold text-blue-600">
              {formatRupiah(cartTotal)}
            </span>
          </div>
          <button 
            disabled={cartItems.length === 0}
            onClick={() => alert('Sistem Pembayaran / Struk Kasir akan diproses di sini.')}
            className="w-full bg-blue-600 hover:bg-blue-700 disabled:bg-slate-300 disabled:cursor-not-allowed text-white font-bold py-3 rounded-xl shadow-lg shadow-blue-600/20 transition-all active:scale-[0.98]"
          >
            Bayar Sekarang
          </button>
        </div>
      </div>

    </div>
  );
}