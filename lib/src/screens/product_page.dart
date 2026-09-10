import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models.dart';
import '../pos_store.dart';
import '../theme/app_theme.dart';
import '../widgets/food_image.dart';

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
    builder: (context, _) => Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Kelola Produk & Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _openForm(context),
          ),
        ],
      ),
      body: AdminBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              '${store.menu.length} Menu Terdaftar',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            ...store.menu.map((product) {
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: SizedBox(
                    width: 54,
                    height: 54,
                    child: FoodImage(
                      assetPath: product.assetPath,
                      filePath: product.imagePath,
                      fallbackIcon: product.icon,
                      fallbackColor: product.color,
                      borderRadius: 10,
                    ),
                  ),
                  title: Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(
                    '${product.category} • ${rupiah(product.price)}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') _openForm(context, product);
                      if (v == 'delete') store.deleteProduct(product.id);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Ubah')),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Hapus',
                          style: TextStyle(color: AppColors.danger),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
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
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _categoryController = TextEditingController(text: p?.category ?? 'Makanan');
    _priceController = TextEditingController(
      text: p == null ? '' : '${p.price}',
    );
    _descController = TextEditingController(text: p?.description ?? '');
    _imagePath = p?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _imagePath = file.path);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameController.text.trim();
    final category = _categoryController.text.trim();
    final price = int.parse(_priceController.text.trim());
    final desc = _descController.text.trim();

    if (widget.product == null) {
      widget.store.addProduct(
        name: name,
        category: category,
        price: price,
        imagePath: _imagePath,
        description: desc,
      );
    } else {
      widget.store.updateProduct(
        widget.product!,
        name: name,
        category: category,
        price: price,
        imagePath: _imagePath,
        description: desc,
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(isEdit ? 'Ubah Produk' : 'Tambah Produk Baru'),
      ),
      body: AdminBackdrop(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: _imagePath != null
                            ? FoodImage(
                                filePath: _imagePath,
                                fallbackIcon: Icons.restaurant,
                                fallbackColor: AppColors.primary,
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_outlined,
                                    color: AppColors.textMuted,
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Pilih Foto',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nama Menu'),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Nama wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Kategori wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Harga Jual',
                      prefixText: 'Rp ',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Harga wajib diisi';
                      }
                      if (int.tryParse(v.trim()) == null) {
                        return 'Harga harus angka';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi Singkat',
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save_rounded),
                      label: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Menu'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
