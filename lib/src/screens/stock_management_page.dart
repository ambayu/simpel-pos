import 'package:flutter/material.dart';

import '../models.dart';
import '../pos_store.dart';
import '../theme/app_theme.dart';
import '../widgets/food_image.dart';

class StockManagementPage extends StatefulWidget {
  const StockManagementPage({super.key, required this.store});

  final PosStore store;

  @override
  State<StockManagementPage> createState() => _StockManagementPageState();
}

class _StockManagementPageState extends State<StockManagementPage> {
  String searchQuery = '';
  String filterStatus = 'Semua';

  Future<void> _adjustStockDelta(MenuItem item, bool isAdd) async {
    final qtyController = TextEditingController(text: '10');
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<int>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isAdd ? 'Tambah Stok Masuk' : 'Kurangi Stok Barang'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text('Stok saat ini: ${item.stock} unit'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: isAdd ? 'Jumlah Masuk' : 'Jumlah Keluar',
                      prefixIcon: Icon(isAdd ? Icons.add_circle_outline : Icons.remove_circle_outline),
                      suffixText: 'unit',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (val) {
                      final n = int.tryParse(val ?? '');
                      if (n == null || n <= 0) return 'Masukkan jumlah > 0';
                      if (!isAdd && n > item.stock) return 'Melebihi stok yang ada (${item.stock})';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            FilledButton.icon(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final qty = int.tryParse(qtyController.text) ?? 0;
                Navigator.pop(ctx, qty);
              },
              icon: Icon(isAdd ? Icons.add_rounded : Icons.remove_rounded),
              label: Text(isAdd ? 'Tambah' : 'Kurangi'),
            ),
          ],
        );
      },
    );

    if (result == null || !mounted) return;

    final delta = isAdd ? result : -result;
    widget.store.addStock(item.id, delta);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAdd
              ? 'Berhasil menambah $result unit ke ${item.name}'
              : 'Berhasil mengurangi $result unit dari ${item.name}',
        ),
      ),
    );
  }

  Future<void> _opnameStock(MenuItem item) async {
    final qtyController = TextEditingController(text: item.stock.toString());
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<int>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Koreksi Fisik (Stock Opname)'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text('Stok tercatat sistem: ${item.stock} unit'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Jumlah Fisik Sebenarnya',
                      prefixIcon: const Icon(Icons.inventory_2_outlined),
                      suffixText: 'unit',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (val) {
                      final n = int.tryParse(val ?? '');
                      if (n == null || n < 0) return 'Masukkan angka valid (>= 0)';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            FilledButton.icon(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final qty = int.tryParse(qtyController.text) ?? 0;
                Navigator.pop(ctx, qty);
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text('Simpan Opname'),
            ),
          ],
        );
      },
    );

    if (result == null || !mounted) return;

    widget.store.adjustStock(item.id, result);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Stok fisik ${item.name} diperbarui menjadi $result unit.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canManageStock = widget.store.hasPermission(SimpelPermission.stockAksi);
    final allItems = widget.store.menu;

    final lowStockCount = allItems.where((i) => i.stock > 0 && i.stock <= 10).length;
    final outOfStockCount = allItems.where((i) => i.stock <= 0).length;
    final totalUnits = allItems.fold<int>(0, (sum, i) => sum + i.stock);

    final filtered = allItems.where((item) {
      final q = searchQuery.trim().toLowerCase();
      if (q.isNotEmpty &&
          !item.name.toLowerCase().contains(q) &&
          !item.category.toLowerCase().contains(q)) {
        return false;
      }
      if (filterStatus == 'Menipis' && (item.stock <= 0 || item.stock > 10)) return false;
      if (filterStatus == 'Habis' && item.stock > 0) return false;
      if (filterStatus == 'Aman' && item.stock <= 10) return false;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Penyimpanan Stok Barang'),
      ),
      body: AdminBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // KPI Bar
            Row(
              children: [
                Expanded(
                  child: _KpiBox(
                    label: 'Total Barang',
                    value: '${allItems.length} ($totalUnits unit)',
                    color: AppColors.primary,
                    icon: Icons.inventory_2_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _KpiBox(
                    label: 'Stok Menipis',
                    value: '$lowStockCount item',
                    color: Colors.orange,
                    icon: Icons.warning_amber_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _KpiBox(
                    label: 'Stok Habis',
                    value: '$outOfStockCount item',
                    color: AppColors.danger,
                    icon: Icons.error_outline_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Search & Chips
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari nama produk atau kategori...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                fillColor: Colors.white,
                filled: true,
              ),
              onChanged: (val) => setState(() => searchQuery = val),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Semua', 'Aman', 'Menipis', 'Habis'].map((status) {
                  final isSelected = filterStatus == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => filterStatus = status);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Item List
            if (filtered.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text('Tidak ada produk sesuai filter stok.'),
                  ),
                ),
              )
            else
              ...filtered.map((item) {
                Color badgeColor = Colors.green;
                String badgeText = 'Aman';
                if (item.stock <= 0) {
                  badgeColor = AppColors.danger;
                  badgeText = 'Habis';
                } else if (item.stock <= 10) {
                  badgeColor = Colors.orange;
                  badgeText = 'Menipis';
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: FoodImage(
                              filePath: item.imagePath,
                              assetPath: item.assetPath,
                              fallbackIcon: item.icon,
                              fallbackColor: item.color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${item.category} • ${rupiah(item.price)}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: badgeColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '$badgeText: ${item.stock} unit',
                                  style: TextStyle(
                                    color: badgeColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (canManageStock) ...[
                          IconButton(
                            tooltip: 'Kurangi Stok (-)',
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.danger),
                            onPressed: item.stock <= 0 ? null : () => _adjustStockDelta(item, false),
                          ),
                          IconButton(
                            tooltip: 'Tambah Stok (+)',
                            icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                            onPressed: () => _adjustStockDelta(item, true),
                          ),
                          IconButton(
                            tooltip: 'Opname / Koreksi Fisik',
                            icon: const Icon(Icons.edit_note_rounded),
                            onPressed: () => _opnameStock(item),
                          ),
                        ] else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Lihat Saja', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _KpiBox extends StatelessWidget {
  const _KpiBox({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
