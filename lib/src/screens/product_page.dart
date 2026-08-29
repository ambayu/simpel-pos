import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models.dart';
import '../pos_store.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key, required this.store});
  final PosStore store;

  void _openForm(BuildContext context, [MenuItem? product]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductFormPage(store: store, product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (context, _) => ListView(
      padding: const EdgeInsets.all(12),
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final title = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Produk',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${store.menu.length} menu tersedia dan dapat diubah sendiri',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            );
            final button = FilledButton.icon(
              onPressed: () => _openForm(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah Produk'),
            );

            if (constraints.maxWidth < 520) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [title, const SizedBox(height: 10), button],
              );
            }

            return Row(
              children: [
                Expanded(child: title),
                button,
              ],
            );
          },
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final count = constraints.maxWidth >= 950
                ? 4
                : constraints.maxWidth >= 650
                ? 3
                : constraints.maxWidth >= 360
                ? 2
                : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: store.menu.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: count,
                mainAxisExtent: constraints.maxWidth < 360 ? 138 : 172,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final product = store.menu[index];
                final hasImage =
                    product.imagePath != null &&
                    File(product.imagePath!).existsSync();

                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (hasImage && !kIsWeb)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(product.imagePath!),
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      CircleAvatar(
                                        backgroundColor: product.color
                                            .withValues(alpha: .15),
                                        child: Icon(
                                          product.icon,
                                          color: product.color,
                                        ),
                                      ),
                                ),
                              )
                            else
                              CircleAvatar(
                                backgroundColor: product.color.withValues(
                                  alpha: .15,
                                ),
                                child: Icon(product.icon, color: product.color),
                              ),
                            const Spacer(),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _openForm(context, product);
                                }
                                if (value == 'delete') {
                                  store.deleteProduct(product.id);
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit produk'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Hapus produk'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          product.category,
                          style: const TextStyle(
                            color: Colors.black45,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          rupiah(product.price),
                          style: const TextStyle(
                            color: Color(0xFF316B58),
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    ),
  );
}

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key, required this.store, this.product});
  final PosStore store;
  final MenuItem? product;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController name;
  late final TextEditingController category;
  late final TextEditingController price;
  final ImagePicker _picker = ImagePicker();
  String? selectedImagePath;
  bool isImageRemoved = false;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.product?.name ?? '');
    category = TextEditingController(
      text: widget.product?.category ?? 'Makanan',
    );
    price = TextEditingController(
      text: widget.product == null ? '' : '${widget.product!.price}',
    );
    selectedImagePath = widget.product?.imagePath;
  }

  @override
  void dispose() {
    name.dispose();
    category.dispose();
    price.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          selectedImagePath = pickedFile.path;
          isImageRemoved = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memilih foto: $e')));
    }
  }

  void _removeImage() {
    setState(() {
      selectedImagePath = null;
      isImageRemoved = true;
    });
  }

  void save() {
    if (!formKey.currentState!.validate()) return;
    final value = int.tryParse(price.text.trim()) ?? 0;
    if (widget.product == null) {
      widget.store.addProduct(
        name: name.text,
        category: category.text,
        price: value,
        imagePath: selectedImagePath,
      );
    } else {
      widget.store.updateProduct(
        widget.product!,
        name: name.text,
        category: category.text,
        price: value,
        imagePath: selectedImagePath,
        clearImagePath: isImageRemoved,
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.product == null ? 'Tambah Produk' : 'Edit Produk'),
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: formKey,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final form = Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Foto Makanan / Minuman',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Image Upload Area & Preview
                        Center(
                          child: Container(
                            width: double.infinity,
                            height: 180,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F2EE),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE5DDD5),
                                width: 1.2,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child:
                                selectedImagePath != null &&
                                    File(selectedImagePath!).existsSync()
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.file(
                                        File(selectedImagePath!),
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.black54,
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline_rounded,
                                              color: Colors.white,
                                            ),
                                            tooltip: 'Hapus foto',
                                            onPressed: _removeImage,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.add_a_photo_outlined,
                                        size: 48,
                                        color: Color(0xFF9E7051),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Belum ada foto makanan',
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Format JPG atau PNG',
                                        style: TextStyle(
                                          color: Colors.black38,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Action Buttons: Pilih Foto
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _pickImage(ImageSource.gallery),
                                icon: const Icon(Icons.photo_library_rounded),
                                label: const Text('Pilih dari Galeri'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _pickImage(ImageSource.camera),
                                icon: const Icon(Icons.camera_alt_rounded),
                                label: const Text('Ambil Kamera'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),

                        // Input fields
                        TextFormField(
                          controller: name,
                          decoration: const InputDecoration(
                            labelText: 'Nama produk',
                            prefixIcon: Icon(Icons.restaurant_menu_rounded),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Nama produk wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: category,
                          decoration: const InputDecoration(
                            labelText: 'Kategori',
                            prefixIcon: Icon(Icons.category_rounded),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Kategori wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: price,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Harga jual',
                            prefixIcon: Icon(Icons.payments_rounded),
                            prefixText: 'Rp ',
                          ),
                          validator: (value) =>
                              int.tryParse(value ?? '') == null ||
                                  int.parse(value!) <= 0
                              ? 'Masukkan harga yang valid'
                              : null,
                        ),
                      ],
                    ),
                  ),
                );

                final actions = Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Simpan Produk',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 7),
                        const Text(
                          'Produk beserta foto langsung muncul di katalog kasir setelah disimpan.',
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 14),
                        FilledButton.icon(
                          onPressed: save,
                          icon: const Icon(Icons.save_rounded),
                          label: const Text('Simpan Produk'),
                        ),
                        const SizedBox(height: 6),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Batal'),
                        ),
                      ],
                    ),
                  ),
                );

                return constraints.maxWidth >= 700
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: form),
                          const SizedBox(width: 16),
                          SizedBox(width: 280, child: actions),
                        ],
                      )
                    : ListView(
                        children: [form, const SizedBox(height: 12), actions],
                      );
              },
            ),
          ),
        ),
      ),
    ),
  );
}
