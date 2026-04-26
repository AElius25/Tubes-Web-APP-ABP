import { useState, useEffect } from 'react';
import { supabase } from '@/integrations/supabase/client';
import { useAuth } from '@/lib/auth';
import { toast } from 'sonner';

interface CartItem {
  id: string;
  book_id: string;
  quantity: number;
  book: {
    id: string;
    title: string;
    author: string;
    price: number;
    cover_image: string | null;
    stock: number;
  };
}

export function useCart() {
  const { user } = useAuth();
  const [cartItems, setCartItems] = useState<CartItem[]>([]);
  const [loading, setLoading] = useState(false);

  const fetchCart = async () => {
    if (!user) {
      setCartItems([]);
      return;
    }

    setLoading(true);
    const { data, error } = await supabase
      .from('cart_items')
      .select(`
        id,
        book_id,
        quantity,
        books (
          id,
          title,
          author,
          price,
          cover_image,
          stock
        )
      `)
      .eq('user_id', user.id);

    if (error) {
      console.error('Error fetching cart:', error);
    } else {
      const transformedData = data?.map(item => ({
        ...item,
        book: item.books as unknown as CartItem['book']
      })) || [];
      setCartItems(transformedData);
    }
    setLoading(false);
  };

  useEffect(() => {
    fetchCart();
  }, [user]);

  const addToCart = async (bookId: string) => {
    if (!user) {
      toast.error('Silakan login terlebih dahulu untuk menambahkan ke keranjang');
      return false;
    }

    const existingItem = cartItems.find(item => item.book_id === bookId);

    if (existingItem) {
      const { error } = await supabase
        .from('cart_items')
        .update({ quantity: existingItem.quantity + 1 })
        .eq('id', existingItem.id);

      if (error) {
        toast.error('Gagal menambahkan ke keranjang');
        return false;
      }
    } else {
      const { error } = await supabase
        .from('cart_items')
        .insert({ user_id: user.id, book_id: bookId, quantity: 1 });

      if (error) {
        toast.error('Gagal menambahkan ke keranjang');
        return false;
      }
    }

    toast.success('Buku ditambahkan ke keranjang');
    fetchCart();
    return true;
  };

  const updateQuantity = async (cartItemId: string, quantity: number) => {
    if (quantity <= 0) {
      return removeFromCart(cartItemId);
    }

    const { error } = await supabase
      .from('cart_items')
      .update({ quantity })
      .eq('id', cartItemId);

    if (error) {
      toast.error('Gagal mengupdate keranjang');
      return false;
    }

    fetchCart();
    return true;
  };

  const removeFromCart = async (cartItemId: string) => {
    const { error } = await supabase
      .from('cart_items')
      .delete()
      .eq('id', cartItemId);

    if (error) {
      toast.error('Gagal menghapus dari keranjang');
      return false;
    }

    toast.success('Buku dihapus dari keranjang');
    fetchCart();
    return true;
  };

  const clearCart = async () => {
    if (!user) return;

    const { error } = await supabase
      .from('cart_items')
      .delete()
      .eq('user_id', user.id);

    if (error) {
      toast.error('Gagal mengosongkan keranjang');
      return false;
    }

    setCartItems([]);
    return true;
  };

  const cartItemsCount = cartItems.reduce((sum, item) => sum + item.quantity, 0);
  const cartTotal = cartItems.reduce((sum, item) => sum + (item.book?.price || 0) * item.quantity, 0);

  return {
    cartItems,
    loading,
    addToCart,
    updateQuantity,
    removeFromCart,
    clearCart,
    cartItemsCount,
    cartTotal,
    refetch: fetchCart,
  };
}
