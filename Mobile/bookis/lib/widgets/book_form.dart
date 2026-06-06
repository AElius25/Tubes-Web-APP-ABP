import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
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

  // Gambar: bisa dari file baru (XFile) atau path lama
  XFile? _pickedImage;
  String? _existingCoverPath;

  static const _categories = [
    'Fiksi', 'Sosial', 'Produktivitas',
    'Sejarah', 'Keuangan', 'Bisnis', 'Sains', 'Agama', 'Anak-Anak', 'Lainnya',
  ];

  final _picker = ImagePicker();

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
    _existingCoverPath = b?.coverPath;
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _authorCtrl.dispose(); _isbnCtrl.dispose();
    _priceCtrl.dispose(); _stockCtrl.dispose(); _publisherCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  // ── Pilih gambar: tampilkan sheet Kamera / Galeri ──
  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Text('Pilih Sumber Gambar',
            style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.photo_camera,
                  color: Theme.of(context).colorScheme.primary),
            ),
            title: const Text('Kamera'),
            subtitle: const Text('Foto langsung dari kamera'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.photo_library, color: Color(0xFF1565C0)),
            ),
            title: const Text('Galeri'),
            subtitle: const Text('Pilih dari galeri foto'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          if (_hasCover) ...[
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.delete_outline, color: Colors.red.shade400),
              ),
              title: const Text('Hapus Foto',
                style: TextStyle(color: Colors.red)),
              onTap: () {
                setState(() {
                  _pickedImage = null;
                  _existingCoverPath = null;
                });
                Navigator.pop(context);
              },
            ),
          ],
          const SizedBox(height: 8),
        ]),
      ),
    );

    if (source == null) return;

    try {
      final img = await _picker.pickImage(
        source: source,
        imageQuality: 85,   // kompres sedikit agar tidak terlalu besar
        maxWidth: 800,
      );
      if (img != null) {
        setState(() => _pickedImage = img);
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak bisa akses ${source == ImageSource.camera ? "kamera" : "galeri"}: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool get _hasCover =>
      _pickedImage != null ||
      (_existingCoverPath != null && _existingCoverPath!.isNotEmpty);

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
        Container(
          width: 40, height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
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

                // ── FOTO COVER ──────────────────────────────────
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _hasCover
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                            : Colors.grey.shade300,
                        width: _hasCover ? 2 : 1,
                        style: _hasCover ? BorderStyle.solid : BorderStyle.solid,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildCoverPreview(),
                  ),
                ),
                const SizedBox(height: 6),
                // Label kecil di bawah preview
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.touch_app, size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      _hasCover ? 'Ketuk untuk ganti/hapus foto' : 'Ketuk untuk pilih foto cover',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
                // ────────────────────────────────────────────────

                const SizedBox(height: 14),
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
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
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

  // Preview cover di dalam form
  Widget _buildCoverPreview() {
    // Gambar baru yang baru dipilih
    if (_pickedImage != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(_pickedImage!.path), fit: BoxFit.cover),
          // Badge "Foto baru"
          Positioned(
            top: 8, right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Foto baru',
                style: TextStyle(color: Colors.white, fontSize: 10,
                    fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      );
    }

    // Gambar lama dari path lokal (edit buku)
    if (_existingCoverPath != null && _existingCoverPath!.isNotEmpty) {
      final file = File(_existingCoverPath!);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }

    // Placeholder (belum ada gambar)
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined,
          size: 40,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
        ),
        const SizedBox(height: 8),
        Text(
          'Tambah Foto Cover',
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Kamera atau Galeri',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
        ),
      ],
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    // Tentukan path cover yang akan disimpan
    final String? finalCoverPath = _pickedImage?.path ?? _existingCoverPath;

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
      coverPath: finalCoverPath,
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
