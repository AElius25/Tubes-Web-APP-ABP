import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/cart_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/book_provider.dart';
import '../models/transaction.dart';
import 'receipt_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  final _cashController = TextEditingController();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  bool _processing = false;
  final fmt = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  double get _paidAmount {
    final val = double.tryParse(
        _cashController.text.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
    return val;
  }

  double get _changeAmount {
    final cart = context.read<CartProvider>();
    return (_paidAmount - cart.total).clamp(0, double.infinity);
  }

  bool get _canProcess {
    final cart = context.read<CartProvider>();
    if (_selectedMethod == PaymentMethod.cash) {
      return _paidAmount >= cart.total;
    }
    return true;
  }

  @override
  void dispose() {
    _cashController.dispose();
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Order Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Ringkasan Pesanan',
                  style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                ...cart.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(children: [
                    Expanded(child: Text('${item.book.title} x${item.quantity}',
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13))),
                    Text(fmt.format(item.subtotal),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  ]),
                )),
                const Divider(),
                _SummaryRow(label: 'Subtotal', value: fmt.format(cart.subtotal)),
                if (cart.discountAmount > 0)
                  _SummaryRow(
                    label: 'Diskon',
                    value: '- ${fmt.format(cart.discountAmount)}',
                    valueColor: Colors.green,
                  ),
                const Divider(),
                _SummaryRow(
                  label: 'TOTAL',
                  value: fmt.format(cart.total),
                  isBold: true,
                  valueColor: Theme.of(context).colorScheme.primary,
                ),
              ]),
            ),
          ),
          const SizedBox(height: 20),

          // Payment Method
          Text('Metode Pembayaran',
            style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(children: [
            _PaymentMethodCard(
              icon: Icons.payments_outlined,
              label: 'Tunai',
              method: PaymentMethod.cash,
              selected: _selectedMethod,
              onTap: () => setState(() => _selectedMethod = PaymentMethod.cash),
            ),
            const SizedBox(width: 8),
            _PaymentMethodCard(
              icon: Icons.qr_code,
              label: 'QRIS',
              method: PaymentMethod.qris,
              selected: _selectedMethod,
              onTap: () => setState(() {
                _selectedMethod = PaymentMethod.qris;
                _cashController.clear();
              }),
            ),
            const SizedBox(width: 8),
            _PaymentMethodCard(
              icon: Icons.account_balance,
              label: 'Transfer',
              method: PaymentMethod.transfer,
              selected: _selectedMethod,
              onTap: () => setState(() {
                _selectedMethod = PaymentMethod.transfer;
                _cashController.clear();
              }),
            ),
            const SizedBox(width: 8),
            _PaymentMethodCard(
              icon: Icons.credit_card,
              label: 'Debit',
              method: PaymentMethod.debit,
              selected: _selectedMethod,
              onTap: () => setState(() {
                _selectedMethod = PaymentMethod.debit;
                _cashController.clear();
              }),
            ),
          ]),
          const SizedBox(height: 20),

          // Cash input
          if (_selectedMethod == PaymentMethod.cash) ...[
            Text('Jumlah Bayar', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _cashController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                prefixText: 'Rp ',
                hintText: '0',
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            // Quick amount buttons
            Wrap(
              spacing: 8,
              children: [
                cart.total,
                _roundUp(cart.total, 50000),
                _roundUp(cart.total, 100000),
                200000,
              ].map((amount) => ActionChip(
                label: Text(fmt.format(amount),
                  style: const TextStyle(fontSize: 12)),
                onPressed: () {
                  _cashController.text = amount.toStringAsFixed(0);
                  setState(() {});
                },
              )).toList(),
            ),
            if (_paidAmount > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kembalian', style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.w600)),
                    Text(fmt.format(_changeAmount), style: const TextStyle(
                        color: Colors.green, fontWeight: FontWeight.w700,
                        fontSize: 18)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],

          // Customer name (optional)
          Text('Info Pelanggan (Opsional)',
            style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Nama pelanggan',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              hintText: 'Catatan (opsional)',
              prefixIcon: Icon(Icons.note_outlined),
            ),
          ),
          const SizedBox(height: 32),

          // Process button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _canProcess && !_processing ? _processPayment : null,
              icon: _processing
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.check_circle_outline),
              label: Text(_processing ? 'Memproses...' : 'Proses Pembayaran'),
            ),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  double _roundUp(double amount, double multiple) {
    return (amount / multiple).ceil() * multiple;
  }

  void _processPayment() async {
    setState(() => _processing = true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    final cart = context.read<CartProvider>();
    final txProvider = context.read<TransactionProvider>();
    final bookProvider = context.read<BookProvider>();

    final amountPaid = _selectedMethod == PaymentMethod.cash
        ? _paidAmount
        : cart.total;

    // Decrease stock
    for (final item in cart.items) {
      bookProvider.decreaseStock(item.book.id, item.quantity);
    }

    final transaction = txProvider.createTransaction(
      cartItems: cart.items.toList(),
      subtotal: cart.subtotal,
      discount: cart.discountAmount,
      tax: cart.tax,
      total: cart.total,
      amountPaid: amountPaid,
      paymentMethod: _selectedMethod,
      customerName: _nameController.text.isEmpty ? null : _nameController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    cart.clear();

    if (!mounted) return;
    setState(() => _processing = false);

    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => ReceiptScreen(transaction: transaction),
    ));
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;
  const _SummaryRow({required this.label, required this.value,
    this.isBold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.normal)),
        Text(value, style: TextStyle(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: valueColor)),
      ]),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final PaymentMethod method;
  final PaymentMethod selected;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.icon, required this.label, required this.method,
    required this.selected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = method == selected;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.primary.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(children: [
            Icon(icon,
              color: isSelected ? Colors.white
                  : Theme.of(context).colorScheme.primary,
              size: 20),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white
                  : Theme.of(context).colorScheme.primary,
            )),
          ]),
        ),
      ),
    );
  }
}
