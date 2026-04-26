import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Plus, Edit, Trash2, Package, BookOpen, Eye, EyeOff } from 'lucide-react';
import { Navbar } from '@/components/Navbar';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { useAuth } from '@/lib/auth';
import { useSellerBooks, Book } from '@/hooks/useBooks';
import { motion, AnimatePresence } from 'framer-motion';
import { toast } from 'sonner';

const categories = [
  'Novel',
  'Komik',
  'Akademik',
  'Bisnis',
  'Self-Help',
  'Anak-anak',
  'Agama',
  'Hobi',
];

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
  title: '',
  author: '',
  description: '',
  price: '',
  stock: '',
  cover_image: '',
  category: '',
  isbn: '',
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
    if (!authLoading && !user) {
      navigate('/auth');
    }
    if (!authLoading && user && role !== 'seller') {
      navigate('/catalog');
    }
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

  const handleCloseDialog = () => {
    setIsDialogOpen(false);
    setEditingBook(null);
    setFormData(initialFormData);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);

    const bookData = {
      title: formData.title,
      author: formData.author,
      description: formData.description || null,
      price: parseFloat(formData.price),
      stock: parseInt(formData.stock),
      cover_image: formData.cover_image || null,
      category: formData.category || null,
      isbn: formData.isbn || null,
      is_available: true,
    };

    if (editingBook) {
      await updateBook(editingBook.id, bookData);
    } else {
      await addBook(bookData);
    }

    setSubmitting(false);
    handleCloseDialog();
  };

  const handleDelete = async (id: string) => {
    if (window.confirm('Apakah Anda yakin ingin menghapus buku ini?')) {
      await deleteBook(id);
    }
  };

  const handleToggleAvailability = async (book: Book) => {
    await toggleAvailability(book.id, !book.is_available);
  };

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
            <div className="h-12 bg-muted rounded w-1/3" />
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {[...Array(6)].map((_, i) => (
                <div key={i} className="h-48 bg-muted rounded-lg" />
              ))}
            </div>
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
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-8">
          <div>
            <h1 className="font-serif text-3xl font-bold text-foreground">
              Dashboard <span className="text-gold">Penjual</span>
            </h1>
            <p className="text-muted-foreground mt-1">
              Kelola buku dagangan Anda
            </p>
          </div>

          <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
            <DialogTrigger asChild>
              <Button
                onClick={() => handleOpenDialog()}
                className="bg-gold text-secondary-foreground hover:bg-gold-dark"
              >
                <Plus className="h-5 w-5 mr-2" />
                Tambah Buku
              </Button>
            </DialogTrigger>
            <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
              <DialogHeader>
                <DialogTitle className="font-serif text-2xl">
                  {editingBook ? 'Edit Buku' : 'Tambah Buku Baru'}
                </DialogTitle>
              </DialogHeader>

              <form onSubmit={handleSubmit} className="space-y-4 mt-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="title">Judul Buku *</Label>
                    <Input
                      id="title"
                      value={formData.title}
                      onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                      required
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="author">Penulis *</Label>
                    <Input
                      id="author"
                      value={formData.author}
                      onChange={(e) => setFormData({ ...formData, author: e.target.value })}
                      required
                    />
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="description">Deskripsi</Label>
                  <Textarea
                    id="description"
                    value={formData.description}
                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                    rows={3}
                  />
                </div>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="price">Harga (Rp) *</Label>
                    <Input
                      id="price"
                      type="number"
                      min="0"
                      value={formData.price}
                      onChange={(e) => setFormData({ ...formData, price: e.target.value })}
                      required
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="stock">Stok *</Label>
                    <Input
                      id="stock"
                      type="number"
                      min="0"
                      value={formData.stock}
                      onChange={(e) => setFormData({ ...formData, stock: e.target.value })}
                      required
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="category">Kategori</Label>
                    <Select
                      value={formData.category}
                      onValueChange={(value) => setFormData({ ...formData, category: value })}
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Pilih kategori" />
                      </SelectTrigger>
                      <SelectContent>
                        {categories.map((cat) => (
                          <SelectItem key={cat} value={cat}>
                            {cat}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="cover_image">URL Gambar Cover</Label>
                    <Input
                      id="cover_image"
                      type="url"
                      placeholder="https://..."
                      value={formData.cover_image}
                      onChange={(e) => setFormData({ ...formData, cover_image: e.target.value })}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="isbn">ISBN</Label>
                    <Input
                      id="isbn"
                      value={formData.isbn}
                      onChange={(e) => setFormData({ ...formData, isbn: e.target.value })}
                    />
                  </div>
                </div>

                <div className="flex gap-3 pt-4">
                  <Button
                    type="button"
                    variant="outline"
                    onClick={handleCloseDialog}
                    className="flex-1"
                  >
                    Batal
                  </Button>
                  <Button
                    type="submit"
                    disabled={submitting}
                    className="flex-1 bg-gold text-secondary-foreground hover:bg-gold-dark"
                  >
                    {submitting ? 'Menyimpan...' : editingBook ? 'Update Buku' : 'Tambah Buku'}
                  </Button>
                </div>
              </form>
            </DialogContent>
          </Dialog>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
          <div className="bg-card rounded-xl p-4 shadow-sm">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-gold/10 rounded-lg flex items-center justify-center">
                <BookOpen className="h-5 w-5 text-gold" />
              </div>
              <div>
                <p className="text-2xl font-bold text-foreground">{books.length}</p>
                <p className="text-sm text-muted-foreground">Total Buku</p>
              </div>
            </div>
          </div>
          <div className="bg-card rounded-xl p-4 shadow-sm">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
                <Eye className="h-5 w-5 text-green-600" />
              </div>
              <div>
                <p className="text-2xl font-bold text-foreground">
                  {books.filter((b) => b.is_available).length}
                </p>
                <p className="text-sm text-muted-foreground">Tersedia</p>
              </div>
            </div>
          </div>
          <div className="bg-card rounded-xl p-4 shadow-sm">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-red-100 rounded-lg flex items-center justify-center">
                <EyeOff className="h-5 w-5 text-red-600" />
              </div>
              <div>
                <p className="text-2xl font-bold text-foreground">
                  {books.filter((b) => !b.is_available).length}
                </p>
                <p className="text-sm text-muted-foreground">Tidak Tersedia</p>
              </div>
            </div>
          </div>
          <div className="bg-card rounded-xl p-4 shadow-sm">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-orange-100 rounded-lg flex items-center justify-center">
                <Package className="h-5 w-5 text-orange-600" />
              </div>
              <div>
                <p className="text-2xl font-bold text-foreground">
                  {books.filter((b) => b.stock === 0).length}
                </p>
                <p className="text-sm text-muted-foreground">Stok Habis</p>
              </div>
            </div>
          </div>
        </div>

        {/* Books Grid */}
        {books.length === 0 ? (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-center py-20 bg-muted/30 rounded-2xl"
          >
            <Package className="h-20 w-20 text-muted-foreground mx-auto mb-4" />
            <h3 className="font-serif text-2xl font-semibold text-foreground mb-2">
              Belum Ada Buku
            </h3>
            <p className="text-muted-foreground mb-6">
              Mulai tambahkan buku untuk dijual
            </p>
            <Button
              onClick={() => handleOpenDialog()}
              className="bg-gold text-secondary-foreground hover:bg-gold-dark"
            >
              <Plus className="h-5 w-5 mr-2" />
              Tambah Buku Pertama
            </Button>
          </motion.div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <AnimatePresence>
              {books.map((book, index) => (
                <motion.div
                  key={book.id}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, scale: 0.9 }}
                  transition={{ delay: index * 0.05 }}
                  className={`bg-card rounded-xl overflow-hidden shadow-sm ${
                    !book.is_available ? 'opacity-60' : ''
                  }`}
                >
                  <div className="flex gap-4 p-4">
                    {/* Cover */}
                    <div className="w-24 h-32 rounded-lg overflow-hidden bg-muted flex-shrink-0">
                      {book.cover_image ? (
                        <img
                          src={book.cover_image}
                          alt={book.title}
                          className="w-full h-full object-cover"
                        />
                      ) : (
                        <div className="w-full h-full flex items-center justify-center">
                          <span className="text-3xl">📚</span>
                        </div>
                      )}
                    </div>

                    {/* Info */}
                    <div className="flex-1 min-w-0">
                      <h3 className="font-serif font-semibold text-foreground line-clamp-2">
                        {book.title}
                      </h3>
                      <p className="text-muted-foreground text-sm mt-1">{book.author}</p>
                      <p className="font-bold text-gold mt-2">{formatPrice(book.price)}</p>
                      <div className="flex gap-2 mt-2">
                        {book.stock === 0 ? (
                          <span className="badge-out-of-stock">Stok Habis</span>
                        ) : (
                          <span className="badge-in-stock">Stok: {book.stock}</span>
                        )}
                        {!book.is_available && (
                          <span className="badge-stock bg-gray-100 text-gray-800">
                            Tidak Ditampilkan
                          </span>
                        )}
                      </div>
                    </div>
                  </div>

                  {/* Actions */}
                  <div className="border-t border-border p-3 flex gap-2">
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => handleToggleAvailability(book)}
                      className="flex-1"
                    >
                      {book.is_available ? (
                        <>
                          <EyeOff className="h-4 w-4 mr-1" />
                          Sembunyikan
                        </>
                      ) : (
                        <>
                          <Eye className="h-4 w-4 mr-1" />
                          Tampilkan
                        </>
                      )}
                    </Button>
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => handleOpenDialog(book)}
                    >
                      <Edit className="h-4 w-4" />
                    </Button>
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => handleDelete(book.id)}
                      className="text-destructive hover:text-destructive"
                    >
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  </div>
                </motion.div>
              ))}
            </AnimatePresence>
          </div>
        )}
      </div>
    </div>
  );
}
