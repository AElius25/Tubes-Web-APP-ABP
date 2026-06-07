import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/transaction.dart';

class ReceiptScreen extends StatelessWidget {
  final Transaction transaction;
  const ReceiptScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    final dateFmt = DateFormat('dd MMMM yyyy, HH:mm', 'id');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Struk Pembayaran'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            icon: const Icon(Icons.home, color: Colors.white),
            label: const Text('Beranda', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [

          // ── Banner Sukses ──────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: Colors.green.shade50,
            child: Column(children: [
              Container(
                width: 64, height: 64,
                decoration: const BoxDecoration(
                  color: Colors.green, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 12),
              const Text('Pembayaran Berhasil!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                  color: Colors.green)),
              const SizedBox(height: 4),
              Text('Terima kasih telah berbelanja',
                style: TextStyle(color: Colors.green.shade700)),
            ]),
          ),

          // ── Struk ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Header
                  Center(child: Column(children: [
                    Text('BOOKISH', style: Theme.of(context).textTheme.displayMedium),
                    const Text('Toko Buku', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text('No: ${transaction.receiptNumber}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(dateFmt.format(transaction.createdAt),
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ])),
                  const Divider(height: 24),

                  // Items
                  ...transaction.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.bookTitle,
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('${item.quantity} x ${fmt.format(item.unitPrice)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(fmt.format(item.subtotal),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      ]),
                      if (item.discount > 0)
                        Text('Diskon ${item.discount.toStringAsFixed(0)}%',
                          style: const TextStyle(color: Colors.green, fontSize: 11)),
                    ]),
                  )),
                  const Divider(),

                  // Totals
                  _ReceiptRow(label: 'Subtotal', value: fmt.format(transaction.subtotal)),
                  if (transaction.discount > 0)
                    _ReceiptRow(label: 'Diskon',
                      value: '- ${fmt.format(transaction.discount)}',
                      valueColor: Colors.green),
                  if (transaction.tax > 0)
                    _ReceiptRow(label: 'Pajak', value: fmt.format(transaction.tax)),
                  const Divider(),
                  _ReceiptRow(label: 'TOTAL', value: fmt.format(transaction.total),
                    isBold: true),
                  const SizedBox(height: 8),
                  _ReceiptRow(
                    label: transaction.paymentMethod == PaymentMethod.cash
                        ? 'Tunai' : 'QRIS',
                    value: fmt.format(transaction.amountPaid)),
                  if (transaction.change > 0)
                    _ReceiptRow(label: 'Kembalian',
                      value: fmt.format(transaction.change),
                      valueColor: Colors.blue),
                  if (transaction.customerName != null) ...[
                    const Divider(),
                    _ReceiptRow(label: 'Pelanggan', value: transaction.customerName!),
                  ],
                  const Divider(height: 24),
                  const Center(child: Column(children: [
                    Text('Terima kasih sudah membeli di Bookish!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                    SizedBox(height: 4),
                    Text('Selamat membaca 📚',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ])),
                ]),
              ),
            ),
          ),

          // ── Tombol Aksi ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                // Cetak PDF — membuka dialog print system
                onPressed: () => _printReceipt(context),
                icon: const Icon(Icons.print_outlined),
                label: const Text('Cetak Struk'),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    Navigator.of(context).popUntil((r) => r.isFirst),
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Transaksi Baru'),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  /// Generate PDF struk & buka dialog cetak
  Future<void> _printReceipt(BuildContext context) async {
    final fmt = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    final dateFmt = DateFormat('dd MMMM yyyy, HH:mm', 'id');

    await Printing.layoutPdf(
      // format: 80mm thermal printer — lebar standar kasir
      format: const PdfPageFormat(80 * PdfPageFormat.mm, double.infinity,
          marginAll: 8 * PdfPageFormat.mm),
      onLayout: (PdfPageFormat format) async {
        final doc = pw.Document();
        doc.addPage(
          pw.Page(
            pageFormat: format,
            build: (pw.Context ctx) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Header
                pw.Text('BOOKISH',
                  style: pw.TextStyle(
                    fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Text('Toko Buku',
                  style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 4),
                pw.Text('No: ${transaction.receiptNumber}',
                  style: const pw.TextStyle(fontSize: 9)),
                pw.Text(dateFmt.format(transaction.createdAt),
                  style: const pw.TextStyle(fontSize: 9)),
                pw.Divider(),

                // Items
                ...transaction.items.map((item) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(item.bookTitle,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold,
                        fontSize: 10)),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('${item.quantity} x ${fmt.format(item.unitPrice)}',
                          style: const pw.TextStyle(fontSize: 9)),
                        pw.Text(fmt.format(item.subtotal),
                          style: const pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                    if (item.discount > 0)
                      pw.Text('Diskon ${item.discount.toStringAsFixed(0)}%',
                        style: const pw.TextStyle(fontSize: 8)),
                    pw.SizedBox(height: 4),
                  ],
                )),
                pw.Divider(),

                // Totals
                _pdfRow('Subtotal', fmt.format(transaction.subtotal)),
                if (transaction.discount > 0)
                  _pdfRow('Diskon', '- ${fmt.format(transaction.discount)}'),
                pw.Divider(),
                _pdfRow('TOTAL', fmt.format(transaction.total), bold: true),
                pw.SizedBox(height: 4),
                _pdfRow(
                  transaction.paymentMethod == PaymentMethod.cash
                      ? 'Tunai' : 'QRIS',
                  fmt.format(transaction.amountPaid)),
                if (transaction.change > 0)
                  _pdfRow('Kembalian', fmt.format(transaction.change)),
                if (transaction.customerName != null) ...[
                  pw.Divider(),
                  _pdfRow('Pelanggan', transaction.customerName!),
                ],
                pw.Divider(),
                pw.SizedBox(height: 8),
                pw.Text('Terima kasih sudah membeli di Bookish!',
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 9)),
                pw.Text('Selamat membaca :)',
                  style: const pw.TextStyle(fontSize: 9)),
              ],
            ),
          ),
        );
        return doc.save();
      },
    );
  }

  pw.Widget _pdfRow(String label, String value, {bool bold = false}) =>
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(value,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      );
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;
  const _ReceiptRow({required this.label, required this.value,
    this.isBold = false, this.valueColor});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(
        fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
        fontSize: isBold ? 14 : 13)),
      Text(value, style: TextStyle(
        fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
        fontSize: isBold ? 14 : 13, color: valueColor)),
    ]),
  );
}
