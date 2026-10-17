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
  Widget build(BuildContext context) {
    final canManage = store.hasPermission(SimpelPermission.productAksi);

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Kelola Produk & Menu'),
          actions: [
            if (canManage)
              IconButton(
                icon: const Icon(Icons.add_rounded),
                onPressed: () => _openForm(context),
              ),
          ],
        ),
        body: AdminBackdrop(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              HeaderCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Daftar Menu & Produk',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${store.menu.length} Menu Terdaftar',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (canManage)
                      FilledButton.icon(
                        onPressed: () => _openForm(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(40, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Tambah Menu'),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
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
                            '${product.category} • ${rupiah(product.price)} • Stok: ${product.stock}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          trailing: canManage
                              ? PopupMenuButton<String>(
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
                                )
                              : const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Lihat Saja', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
  late List<MenuVariant> _variants;

  final List<String> _suggestedCategories = [
    'Makanan',
    'Minuman',
    'Dim Sum',
    'Cemilan',
    'Paket',
  ];

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
    _variants = p != null
        ? List<MenuVariant>.from(p.variants)
        : [
            const MenuVariant(label: 'Original'),
            const MenuVariant(label: 'Pedas'),
          ];
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

  void _addVariantDialog([int? editIndex]) {
    final isEditing = editIndex != null;
    final initialLabel = isEditing ? _variants[editIndex].label : '';
    final initialPrice = isEditing && _variants[editIndex].extraPrice > 0
        ? '${_variants[editIndex].extraPrice}'
        : '0';

    final labelCtrl = TextEditingController(text: initialLabel);
    final priceCtrl = TextEditingController(text: initialPrice);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Ubah Varian' : 'Tambah Varian Baru'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: labelCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nama Varian',
                  hintText: 'Misal: Pedas Level 2, Dingin, Jumbo',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Nama varian wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Tambahan Harga (Opsional)',
                  prefixText: 'Rp ',
                  hintText: '0 jika tanpa biaya tambahan',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  if (int.tryParse(v.trim()) == null) {
                    return 'Harus berupa angka';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final label = labelCtrl.text.trim();
              final extra = int.tryParse(priceCtrl.text.trim()) ?? 0;
              setState(() {
                if (isEditing) {
                  _variants[editIndex] = MenuVariant(
                    label: label,
                    extraPrice: extra,
                  );
                } else {
                  _variants.add(
                    MenuVariant(label: label, extraPrice: extra),
                  );
                }
              });
              Navigator.of(ctx).pop();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
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
        variants: _variants.isEmpty
            ? const [MenuVariant(label: 'Original')]
            : _variants,
      );
    } else {
      widget.store.updateProduct(
        widget.product!,
        name: name,
        category: category,
        price: price,
        imagePath: _imagePath,
        description: desc,
        variants: _variants.isEmpty
            ? const [MenuVariant(label: 'Original')]
            : _variants,
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
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  const SizedBox(height: 14),

                  // Kategori dengan Saran Chip Cepat + Input Kustom
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _categoryController,
                        decoration: InputDecoration(
                          labelText: 'Kategori',
                          hintText: 'Ketik kategori baru atau pilih di bawah',
                          suffixIcon: _categoryController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    setState(() => _categoryController.clear());
                                  },
                                )
                              : null,
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Kategori wajib diisi'
                            : null,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            const Text(
                              'Pilihan: ',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            ..._suggestedCategories.map((cat) {
                              final isSelected =
                                  _categoryController.text.trim().toLowerCase() ==
                                      cat.toLowerCase();
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ChoiceChip(
                                  label: Text(cat),
                                  labelStyle: TextStyle(
                                    fontSize: 11.5,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                  selected: isSelected,
                                  selectedColor: AppColors.primary,
                                  onSelected: (_) {
                                    setState(() {
                                      _categoryController.text = cat;
                                    });
                                  },
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Harga Jual Dasar',
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
                  const SizedBox(height: 20),

                  // Manajemen Varian Dinamis
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pilihan Varian',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '${_variants.length} varian terpasang',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            FilledButton.tonalIcon(
                              onPressed: () => _addVariantDialog(),
                              style: FilledButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                              ),
                              icon: const Icon(Icons.add_rounded, size: 16),
                              label: const Text('Tambah Varian'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (_variants.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                'Belum ada varian. Produk akan menggunakan varian standar.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          )
                        else
                          ...List.generate(_variants.length, (idx) {
                            final v = _variants[idx];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.border.withValues(alpha: 0.7),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          v.label,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          v.extraPrice > 0
                                              ? '+${rupiah(v.extraPrice)}'
                                              : 'Tanpa biaya tambahan',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: v.extraPrice > 0
                                                ? AppColors.primary
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                      color: AppColors.textSecondary,
                                    ),
                                    onPressed: () => _addVariantDialog(idx),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18,
                                      color: AppColors.danger,
                                    ),
                                    onPressed: () {
                                      setState(() => _variants.removeAt(idx));
                                    },
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
    );
  }
}
