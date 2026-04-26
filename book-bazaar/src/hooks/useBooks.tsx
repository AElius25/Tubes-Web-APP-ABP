import { useState, useEffect } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { useAuth } from '@/lib/auth';
import { toast } from 'sonner';

export interface Book {
  id: string;
  seller_id: string;
  title: string;
  author: string;
  description: string | null;
  price: number;
  stock: number;
  cover_image: string | null;
  category: string | null;
  isbn: string | null;
  is_available: boolean;
  created_at: string;
  updated_at: string;
}

export function useBooks() {
  const [books, setBooks] = useState<Book[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchBooks = async () => {
    setLoading(true);
    const { data, error } = await supabase
      .from('books')
      .select('*')
      .eq('is_available', true)
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Error fetching books:', error);
      toast.error('Gagal memuat buku');
    } else {
      setBooks(data || []);
    }
    setLoading(false);
  };

  useEffect(() => {
    fetchBooks();
  }, []);

  return { books, loading, refetch: fetchBooks };
}

export function useSellerBooks() {
  const { user } = useAuth();
  const [books, setBooks] = useState<Book[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchBooks = async () => {
    if (!user) {
      setBooks([]);
      setLoading(false);
      return;
    }

    setLoading(true);
    const { data, error } = await supabase
      .from('books')
      .select('*')
      .eq('seller_id', user.id)
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Error fetching seller books:', error);
      toast.error('Gagal memuat buku');
    } else {
      setBooks(data || []);
    }
    setLoading(false);
  };

  useEffect(() => {
    fetchBooks();
  }, [user]);

  const addBook = async (bookData: Omit<Book, 'id' | 'seller_id' | 'created_at' | 'updated_at'>) => {
    if (!user) return null;

    const { data, error } = await supabase
      .from('books')
      .insert({ ...bookData, seller_id: user.id })
      .select()
      .single();

    if (error) {
      console.error('Error adding book:', error);
      toast.error('Gagal menambahkan buku');
      return null;
    }

    toast.success('Buku berhasil ditambahkan');
    fetchBooks();
    return data;
  };

  const updateBook = async (id: string, bookData: Partial<Book>) => {
    const { error } = await supabase
      .from('books')
      .update(bookData)
      .eq('id', id);

    if (error) {
      console.error('Error updating book:', error);
      toast.error('Gagal mengupdate buku');
      return false;
    }

    toast.success('Buku berhasil diupdate');
    fetchBooks();
    return true;
  };

  const deleteBook = async (id: string) => {
    const { error } = await supabase
      .from('books')
      .delete()
      .eq('id', id);

    if (error) {
      console.error('Error deleting book:', error);
      toast.error('Gagal menghapus buku');
      return false;
    }

    toast.success('Buku berhasil dihapus');
    fetchBooks();
    return true;
  };

  const toggleAvailability = async (id: string, isAvailable: boolean) => {
    return updateBook(id, { is_available: isAvailable });
  };

  return { books, loading, addBook, updateBook, deleteBook, toggleAvailability, refetch: fetchBooks };
}
