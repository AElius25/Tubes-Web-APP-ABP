import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final fmt = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    final transactions = txProvider.transactions
        .where((t) => t.status != TransactionStatus.voided || true)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: transactions.isEmpty
          ? const Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined, size: 56, color: Colors.grey),
                SizedBox(height: 16),
                Text('Belum ada transaksi', style: TextStyle(color: Colors.grey)),
              ],
            ))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: transactions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (ctx, i) {
                final tx = transactions[i];
                return _TransactionTile(tx: tx, fmt: fmt);
              },
            ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction tx;
  final NumberFormat fmt;
  const _TransactionTile({required this.tx, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy, HH:mm', 'id');
    final isVoided = tx.status == TransactionStatus.voided;

    return Card(
      child: InkWell(
        onTap: () => _showDetail(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isVoided
                    ? Colors.red.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isVoided ? Icons.cancel_outlined : Icons.check_circle_outline,
                color: isVoided ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(tx.receiptNumber,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 13,
                      decoration: isVoided ? TextDecoration.lineThrough : null,
                    )),
                  Text(fmt.format(tx.total),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isVoided ? Colors.grey
                          : Theme.of(context).colorScheme.primary,
                      decoration: isVoided ? TextDecoration.lineThrough : null,
                    )),
                ]),
                const SizedBox(height: 3),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('${tx.totalItems} item · ${_methodLabel(tx.paymentMethod)}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  Text(dateFmt.format(tx.createdAt),
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ]),
                if (tx.customerName != null)
                  Text(tx.customerName!,
                    style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  String _methodLabel(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.cash: return 'Tunai';
      case PaymentMethod.qris: return 'QRIS';
      case PaymentMethod.transfer: return 'Transfer';
      case PaymentMethod.debit: return 'Debit';
    }
  }

  void _showDetail(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    final dateFmt = DateFormat('dd MMMM yyyy, HH:mm', 'id');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, scroll) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Detail Transaksi',
              style: Theme.of(context).textTheme.titleLarge),
            Expanded(
              child: SingleChildScrollView(
                controller: scroll,
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _DetailRow(label: 'No. Transaksi', value: tx.receiptNumber),
                  _DetailRow(label: 'Tanggal', value: dateFmt.format(tx.createdAt)),
                  _DetailRow(label: 'Metode', value: _methodLabel(tx.paymentMethod)),
                  if (tx.customerName != null)
                    _DetailRow(label: 'Pelanggan', value: tx.customerName!),
                  const Divider(height: 24),
                  Text('Item', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...tx.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(children: [
                      Expanded(child: Text('${item.bookTitle}\n${item.quantity} x ${fmt.format(item.unitPrice)}',
                        style: const TextStyle(fontSize: 13))),
                      Text(fmt.format(item.subtotal),
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    ]),
                  )),
                  const Divider(height: 24),
                  _DetailRow(label: 'Subtotal', value: fmt.format(tx.subtotal)),
                  if (tx.discount > 0)
                    _DetailRow(label: 'Diskon', value: '- ${fmt.format(tx.discount)}',
                      valueColor: Colors.green),
                  _DetailRow(label: 'Total', value: fmt.format(tx.total), isBold: true),
                  _DetailRow(label: 'Dibayar', value: fmt.format(tx.amountPaid)),
                  if (tx.change > 0)
                    _DetailRow(label: 'Kembalian', value: fmt.format(tx.change),
                      valueColor: Colors.blue),
                ]),
              ),
            ),
            if (tx.status != TransactionStatus.voided)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red)),
                    onPressed: () {
                      context.read<TransactionProvider>().voidTransaction(tx.id);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Batalkan Transaksi'),
                  ),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;
  const _DetailRow({required this.label, required this.value,
    this.isBold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(value, style: TextStyle(
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          color: valueColor, fontSize: isBold ? 15 : 13)),
      ]),
    );
  }
}
