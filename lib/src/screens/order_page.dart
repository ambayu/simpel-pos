import 'package:flutter/material.dart';

import '../models.dart';
import '../pos_store.dart';
import '../services/receipt_printer.dart';
import '../theme/app_theme.dart';
import '../widgets/food_image.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key, required this.store});

  final PosStore store;

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String selectedCategory = 'Semua';
  String searchQuery = '';

  void _openDetail(MenuItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductDetailSheet(item: item, store: widget.store),
    );
  }

  void _openCart() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => _CartPage(store: widget.store)));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final categories = widget.store.categories;
        if (!categories.contains(selectedCategory)) {
          selectedCategory = 'Semua';
        }

        final filtered = widget.store.menu.where((item) {
          if (selectedCategory != 'Semua' &&
              item.category != selectedCategory) {
            return false;
          }
          if (searchQuery.isNotEmpty) {
            final q = searchQuery.toLowerCase();
            final matchName = item.name.toLowerCase().contains(q);
            final matchCat = item.category.toLowerCase().contains(q);
            if (!matchName && !matchCat) return false;
          }
          return true;
        }).toList();

        final title = widget.store.activeOrder ?? 'Menu';

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: Text(title),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.danger,
                ),
                tooltip: 'Kosongkan Keranjang',
                onPressed: widget.store.cart.isEmpty
                    ? null
                    : () => widget.store.clearCart(),
              ),
            ],
          ),
          body: AdminBackdrop(
            child: Column(
              children: [
                // Search input
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari menu makanan atau minuman...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () => setState(() => searchQuery = ''),
                            )
                          : const Icon(Icons.qr_code_scanner_rounded),
                    ),
                    onChanged: (v) => setState(() => searchQuery = v),
                  ),
                ),

                // Category chips
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final selected = cat == selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: selected,
                          onSelected: (_) =>
                              setState(() => selectedCategory = cat),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // Product grid
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 900
                          ? 4
                          : constraints.maxWidth >= 600
                          ? 3
                          : 2;

                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                        itemCount: filtered.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          mainAxisExtent: 220,
                        ),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return _MenuGridCard(
                            item: item,
                            onTap: () => _openDetail(item),
                            onFavorite: () =>
                                widget.store.toggleFavorite(item.id),
                            onQuickAdd: () => widget.store.add(item),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          bottomSheet: widget.store.cart.isEmpty
              ? null
              : Container(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    10,
                    16,
                    12 + MediaQuery.paddingOf(context).bottom,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _openCart,
                      icon: const Icon(Icons.shopping_bag_rounded),
                      label: Text(
                        'Pesanan Saya (${widget.store.cartCount}) - ${rupiah(widget.store.total)}',
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _MenuGridCard extends StatelessWidget {
  const _MenuGridCard({
    required this.item,
    required this.onTap,
    required this.onFavorite,
    required this.onQuickAdd,
  });

  final MenuItem item;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onQuickAdd;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    FoodImage(
                      assetPath: item.assetPath,
                      filePath: item.imagePath,
                      fallbackIcon: item.icon,
                      fallbackColor: item.color,
                      borderRadius: 15,
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: onFavorite,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.favorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 16,
                            color: item.favorite
                                ? AppColors.primary
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              rupiah(item.price),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: onQuickAdd,
                            borderRadius: BorderRadius.circular(99),
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: const BoxDecoration(
                                color: AppColors.primarySoft,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Screen 6: Detail Produk
class _ProductDetailSheet extends StatefulWidget {
  const _ProductDetailSheet({required this.item, required this.store});

  final MenuItem item;
  final PosStore store;

  @override
  State<_ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<_ProductDetailSheet> {
  int quantity = 1;
  String selectedVariant = 'Original';
  int extraPrice = 0;
  final noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.item.variants.isNotEmpty) {
      selectedVariant = widget.item.variants.first.label;
      extraPrice = widget.item.variants.first.extraPrice;
    }
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  void _submit() {
    widget.store.addItem(
      widget.item,
      variantLabel: selectedVariant,
      variantExtraPrice: extraPrice,
      quantity: quantity,
      note: noteController.text.trim(),
    );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.item.name} ($quantity) ditambahkan ke pesanan'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final unitPrice = item.price + extraPrice;
    final total = unitPrice * quantity;

    return Container(
      height: MediaQuery.sizeOf(context).height * .88,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Hero image with top bar controls
          SizedBox(
            height: 220,
            child: Stack(
              fit: StackFit.expand,
              children: [
                FoodImage(
                  assetPath: item.assetPath,
                  filePath: item.imagePath,
                  fallbackIcon: item.icon,
                  fallbackColor: item.color,
                  borderRadius: 0,
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: .45),
                    foregroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: .45),
                    foregroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(
                        item.favorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: item.favorite ? AppColors.primary : Colors.white,
                      ),
                      onPressed: () => widget.store.toggleFavorite(item.id),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body controls
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            rupiah(unitPrice),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Variants
                if (item.variants.isNotEmpty) ...[
                  const Text(
                    'Pilih Varian',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: item.variants.map((variant) {
                      final selected = variant.label == selectedVariant;
                      final label = variant.extraPrice > 0
                          ? '${variant.label} (+${rupiah(variant.extraPrice)})'
                          : variant.label;
                      return ChoiceChip(
                        label: Text(label),
                        selected: selected,
                        onSelected: (_) {
                          setState(() {
                            selectedVariant = variant.label;
                            extraPrice = variant.extraPrice;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Quantity
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Jumlah',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    _QtyButton(
                      icon: Icons.remove_rounded,
                      onTap: quantity <= 1
                          ? null
                          : () => setState(() => quantity--),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '$quantity',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    _QtyButton(
                      icon: Icons.add_rounded,
                      onTap: () => setState(() => quantity++),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Catatan khusus
                const Text(
                  'Catatan Khusus',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: kurang pedas, tanpa bawang...',
                  ),
                ),
              ],
            ),
          ),

          // Bottom CTA
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              10,
              16,
              12 + MediaQuery.paddingOf(context).bottom,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: widget.store.hasPermission(SimpelPermission.orderAksi)
                  ? FilledButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: Text('Tambah ke Pesanan • ${rupiah(total)}'),
                    )
                  : FilledButton.tonal(
                      onPressed: null,
                      child: const Text('Hanya Lihat (Read-Only)'),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: onTap == null ? AppColors.surfaceMuted : AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap == null ? AppColors.textMuted : Colors.white,
        ),
      ),
    );
  }
}

/// Screen 7: Cart / Pesanan Saya
class _CartPage extends StatelessWidget {
  const _CartPage({required this.store});

  final PosStore store;

  void _nextToPayment(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => _PaymentPage(store: store)));
  }

  void _showDiscountDialog(BuildContext context) {
    final controller = TextEditingController(
      text: store.discount > 0 ? '${store.discount}' : '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Atur Diskon Pesanan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subtotal saat ini: ${rupiah(store.subtotal)}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nominal Diskon (Rp)',
                prefixText: 'Rp ',
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children:
                  [
                    (label: '10%', value: (store.subtotal * .1).round()),
                    (label: '20%', value: (store.subtotal * .2).round()),
                    (label: '50%', value: (store.subtotal * .5).round()),
                    (label: '100% (Gratis)', value: store.subtotal),
                    (label: 'Rp 5.000', value: 5000),
                    (label: 'Rp 10.000', value: 10000),
                    (label: 'Rp 20.000', value: 20000),
                  ].where((d) => d.value <= store.subtotal && d.value > 0).map((
                    preset,
                  ) {
                    return ActionChip(
                      avatar: preset.label.contains('100%')
                          ? const Icon(
                              Icons.celebration_rounded,
                              size: 14,
                              color: AppColors.primary,
                            )
                          : null,
                      label: Text(
                        '${preset.label} (${rupiah(preset.value)})',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: preset.label.contains('100%')
                              ? FontWeight.w900
                              : FontWeight.normal,
                          color: preset.label.contains('100%')
                              ? AppColors.primary
                              : null,
                        ),
                      ),
                      onPressed: () => controller.text = '${preset.value}',
                    );
                  }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              store.setDiscount(0);
              Navigator.pop(ctx);
            },
            child: const Text(
              'Hapus Diskon',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
          FilledButton(
            onPressed: () {
              final val =
                  int.tryParse(
                    controller.text.replaceAll(RegExp(r'[^0-9]'), ''),
                  ) ??
                  0;
              store.setDiscount(val);
              Navigator.pop(ctx);
            },
            child: const Text('Terapkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Pesanan Saya'),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.danger,
              ),
              onPressed: store.cart.isEmpty ? null : () => store.clearCart(),
            ),
          ],
        ),
        body: AdminBackdrop(
          child: Column(
            children: [
              Expanded(
                child: store.cart.isEmpty
                    ? const Center(
                        child: Text(
                          'Keranjang masih kosong',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: store.cart.entries.map((entry) {
                          final line = entry.value;
                          return _CartItemTile(
                            line: line,
                            onIncrement: () => store.incrementLine(entry.key),
                            onDecrement: () => store.decrementLine(entry.key),
                          );
                        }).toList(),
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Column(
                  children: [
                    _SummaryRow(
                      label: 'Subtotal',
                      value: rupiah(store.subtotal),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () => _showDiscountDialog(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Diskon',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: store.discount > 0
                                        ? AppColors.danger
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySoft,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.edit_rounded,
                                        size: 11,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(width: 2),
                                      Text(
                                        'Ubah',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              store.discount > 0
                                  ? '- ${rupiah(store.discount)}'
                                  : 'Rp 0',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: store.discount > 0
                                    ? AppColors.danger
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _SummaryRow(label: 'Pajak (10%)', value: rupiah(store.tax)),
                    const Divider(),
                    _SummaryRow(
                      label: 'Total',
                      value: rupiah(store.total),
                      isBold: true,
                      isPrimary: true,
                    ),
                    const SizedBox(height: 14),
                    if (store.activeOrder?.startsWith('Meja ') == true)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: (store.cart.isEmpty || !store.hasPermission(SimpelPermission.orderAksi))
                                  ? null
                                  : () {
                                      store.savePendingOrder();
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                    },
                              child: const Text('Simpan Meja'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: FilledButton.icon(
                              onPressed: (store.cart.isEmpty || !store.hasPermission(SimpelPermission.orderAksi))
                                  ? null
                                  : () => _nextToPayment(context),
                              iconAlignment: IconAlignment.end,
                              icon: const Icon(Icons.chevron_right_rounded),
                              label: const Text('Lanjut Pembayaran'),
                            ),
                          ),
                        ],
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: (store.cart.isEmpty || !store.hasPermission(SimpelPermission.orderAksi))
                              ? null
                              : () => _nextToPayment(context),
                          iconAlignment: IconAlignment.end,
                          icon: const Icon(Icons.chevron_right_rounded),
                          label: const Text('Lanjut Pembayaran'),
                        ),
                      ),
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

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.line,
    required this.onIncrement,
    required this.onDecrement,
  });

  final CartLine line;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 58,
            height: 58,
            child: FoodImage(
              assetPath: line.item.assetPath,
              filePath: line.item.imagePath,
              fallbackIcon: line.item.icon,
              fallbackColor: line.item.color,
              borderRadius: 10,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  rupiah(line.unitPrice),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (line.note.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    line.note,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.accentGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Row(
            children: [
              _MiniButton(icon: Icons.remove_rounded, onTap: onDecrement),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '${line.quantity}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _MiniButton(icon: Icons.add_rounded, onTap: onIncrement),
            ],
          ),
          const SizedBox(width: 10),
          Text(
            rupiah(line.total),
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  const _MiniButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 15, color: AppColors.textPrimary),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.isPrimary = false,
    this.isDanger = false,
  });

  final String label;
  final String value;
  final bool isBold;
  final bool isPrimary;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final color = isDanger
        ? AppColors.danger
        : isPrimary
        ? AppColors.primary
        : AppColors.textPrimary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 17 : 13,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Screen 8: Pembayaran
class _PaymentPage extends StatefulWidget {
  const _PaymentPage({required this.store});

  final PosStore store;

  @override
  State<_PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<_PaymentPage> {
  String selectedMethod = 'Tunai';
  late TextEditingController payController;

  static const methods = <(String, IconData)>[
    ('Tunai', Icons.payments_rounded),
    ('QRIS', Icons.qr_code_2_rounded),
    ('Kartu', Icons.credit_card_rounded),
    ('E-Wallet', Icons.account_balance_wallet_rounded),
    ('Transfer', Icons.account_balance_rounded),
  ];

  @override
  void initState() {
    super.initState();
    payController = TextEditingController(text: '${widget.store.total}');
  }

  @override
  void dispose() {
    payController.dispose();
    super.dispose();
  }

  int get paidAmount =>
      int.tryParse(payController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
      widget.store.total;

  int get change => (paidAmount - widget.store.total).clamp(0, paidAmount);

  Future<void> _process() async {
    final transaction = widget.store.completeOrder(
      selectedMethod,
      paidAmount: paidAmount,
    );
    if (transaction == null) return;

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            _SuccessPage(transaction: transaction, store: widget.store),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.store.total;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Pembayaran')),
      body: AdminBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Total banner in red
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    rupiah(total),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Pilih Metode Pembayaran',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            // Payment method grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.3,
              children: methods.map((m) {
                final selected = m.$1 == selectedMethod;
                return Material(
                  color: selected ? AppColors.primarySoft : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => setState(() => selectedMethod = m.$1),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.border,
                          width: selected ? 1.6 : 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            m.$2,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            m.$1,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),

            const Text(
              'Jumlah Bayar',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: payController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                prefixText: 'Rp ',
                prefixStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),

            // Quick presets
            Wrap(
              spacing: 8,
              children: {total, if (total <= 150000) 150000, 200000, 500000}
                  .map((amt) {
                    return ActionChip(
                      label: Text(rupiah(amt)),
                      onPressed: () {
                        setState(() {
                          payController.text = '$amt';
                        });
                      },
                    );
                  })
                  .toList(),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.statusFreeBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.statusFreeBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kembalian',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.statusFreeText,
                    ),
                  ),
                  Text(
                    rupiah(change),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.statusFreeText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: paidAmount < total ? null : _process,
                icon: const Icon(Icons.lock_outline_rounded),
                label: const Text('Proses Pembayaran'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Screen 9: Transaksi Berhasil!
class _SuccessPage extends StatelessWidget {
  const _SuccessPage({required this.transaction, required this.store});

  final SaleRecord transaction;
  final PosStore store;

  Future<void> _print(BuildContext context) async {
    try {
      await ReceiptPrinter.printReceipt(transaction);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mencetak struk: $e')));
      }
    }
  }

  void _finish(BuildContext context) {
    // Pop _SuccessPage dan _CartPage, kembali ke OrderPage (tab Pesanan)
    // tanpa menyentuh ShellPage sehingga tab aktif tidak berubah ke Beranda.
    int count = 0;
    Navigator.of(context).popUntil((_) => count++ >= 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: AdminBackdrop(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Transaksi Berhasil!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Terima kasih atas pembelian Anda',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Struk Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                AppAssets.logo,
                                width: 32,
                                height: 32,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.ramen_dining_rounded,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppBrand.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    AppBrand.tagline,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 24),

                          _ReceiptMetaRow(
                            label: 'No. Struk',
                            value: transaction.id,
                          ),
                          _ReceiptMetaRow(
                            label: 'Tanggal',
                            value:
                                '${transaction.createdAt.day}/${transaction.createdAt.month}/${transaction.createdAt.year} '
                                '${transaction.createdAt.hour.toString().padLeft(2, '0')}:'
                                '${transaction.createdAt.minute.toString().padLeft(2, '0')}',
                          ),
                          _ReceiptMetaRow(
                            label: 'Kasir',
                            value: transaction.cashier,
                          ),
                          _ReceiptMetaRow(
                            label: 'Metode',
                            value: transaction.paymentMethod,
                          ),
                          const Divider(height: 20),

                          ...transaction.items.map(
                            (it) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      it.productName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  Text(
                                    '${it.quantity} x ${rupiah(it.unitPrice)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    rupiah(it.total),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(height: 20),

                          _SummaryRow(
                            label: 'Subtotal',
                            value: rupiah(transaction.subtotal),
                          ),
                          if (transaction.discount > 0)
                            _SummaryRow(
                              label: 'Diskon',
                              value: '- ${rupiah(transaction.discount)}',
                              isDanger: true,
                            ),
                          _SummaryRow(
                            label: 'Pajak (10%)',
                            value: rupiah(transaction.tax),
                          ),
                          const SizedBox(height: 6),
                          _SummaryRow(
                            label: 'Total',
                            value: rupiah(transaction.total),
                            isBold: true,
                            isPrimary: true,
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Terima Kasih\n- Sampai Jumpa Lagi -',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _print(context),
                            icon: const Icon(Icons.print_rounded),
                            label: const Text('Cetak Struk'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _finish(context),
                            icon: const Icon(Icons.check_circle_rounded),
                            label: const Text('Selesai'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReceiptMetaRow extends StatelessWidget {
  const _ReceiptMetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 11)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
