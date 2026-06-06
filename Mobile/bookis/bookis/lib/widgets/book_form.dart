import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/book.dart';

class BookForm extends StatefulWidget {
  final Book? book;
  final Function(Book) onSave;

  const BookForm({super.key, this.book, required this.onSave});

  @override
  State<BookForm> createState() => _BookFormState();
}

class _BookFormState extends State<BookForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _authorCtrl;
  late final TextEditingController _isbnCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _publisherCtrl;
  late final TextEditingController _yearCtrl;
  String _category = 'Fiksi';

  static const _categories = [
    'Fiksi', 'Fiksi Sejarah', 'Pengembangan Diri',
    'Sejarah', 'Keuangan', 'Bisnis', 'Sains', 'Agama', 'Anak-Anak', 'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    final b = widget.book;
    _titleCtrl = TextEditingController(text: b?.title ?? '');
    _authorCtrl = TextEditingController(text: b?.author ?? '');
    _isbnCtrl = TextEditingController(text: b?.isbn ?? '');
    _priceCtrl = TextEditingController(text: b?.price.toStringAsFixed(0) ?? '');
    _stockCtrl = TextEditingController(text: b?.stock.toString() ?? '');
    _publisherCtrl = TextEditingController(text: b?.publisher ?? '');
    _yearCtrl = TextEditingController(
        text: b?.year.toString() ?? DateTime.now().year.toString());
    _category = b?.category ?? 'Fiksi';
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _authorCtrl.dispose(); _isbnCtrl.dispose();
    _priceCtrl.dispose(); _stockCtrl.dispose(); _publisherCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.book != null;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 8),
        Container(width: 40, height: 4,
          decoration: BoxDecoration(color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2))),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(isEdit ? 'Edit Buku' : 'Tambah Buku',
            style: Theme.of(context).textTheme.titleLarge),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: _formKey,
              child: Column(children: [
                _Field(controller: _titleCtrl, label: 'Judul Buku *',
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                const SizedBox(height: 10),
                _Field(controller: _authorCtrl, label: 'Pengarang *',
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                const SizedBox(height: 10),
                _Field(controller: _isbnCtrl, label: 'ISBN',
                  keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _Field(
                    controller: _priceCtrl,
                    label: 'Harga (Rp) *',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _Field(
                    controller: _stockCtrl,
                    label: 'Stok *',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  )),
                ]),
                const SizedBox(height: 10),
                // Category dropdown
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  items: _categories.map((c) =>
                    DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _Field(
                    controller: _publisherCtrl, label: 'Penerbit')),
                  const SizedBox(width: 10),
                  Expanded(child: _Field(
                    controller: _yearCtrl, label: 'Tahun',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4)],
                  )),
                ]),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      child: Text(isEdit ? 'Simpan' : 'Tambahkan'),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final book = Book(
      id: widget.book?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      author: _authorCtrl.text.trim(),
      isbn: _isbnCtrl.text.trim(),
      category: _category,
      price: double.parse(_priceCtrl.text),
      stock: int.parse(_stockCtrl.text),
      publisher: _publisherCtrl.text.trim(),
      year: int.tryParse(_yearCtrl.text) ?? DateTime.now().year,
    );
    widget.onSave(book);
    Navigator.pop(context);
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(labelText: label),
    );
  }
}
