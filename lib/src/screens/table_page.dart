import 'package:flutter/material.dart';

import '../models.dart';
import '../pos_store.dart';
import 'order_page.dart';

class TablePage extends StatelessWidget {
  const TablePage({super.key, required this.store});
  final PosStore store;

  void _openOrder(BuildContext context, String label) {
    store.startOrder(label);
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => OrderPage(store: store)));
  }

  void _addTable(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => TableFormPage(store: store)));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(12),
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 560;
              final title = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pilih Meja',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pilih meja pelanggan untuk membuka atau menambah pesanan',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              );
              final actions = Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _addTable(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Tambah Meja'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () =>
                        _openOrder(context, store.nextTakeAwayLabel()),
                    icon: const Icon(Icons.shopping_bag_rounded),
                    label: const Text('Take Away'),
                  ),
                ],
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 10), actions],
                );
              }

              return Row(
                children: [
                  Expanded(child: title),
                  actions,
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          const Wrap(
            spacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _Legend(color: Color(0xFF316B58), label: 'Kosong (Tersedia)'),
              _Legend(
                color: Color(0xFFD35400),
                label: 'Terisi (Pesanan Aktif)',
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (store.pendingOrders.keys.any(
            (label) => label.startsWith('Take Away'),
          )) ...[
            Text(
              'Pesanan Take Away Aktif',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: store.pendingOrders.values
                  .where((order) => order.label.startsWith('Take Away'))
                  .map(
                    (order) => ActionChip(
                      avatar: const Icon(Icons.shopping_bag_rounded, size: 18),
                      label: Text('${order.label} • ${order.itemCount} item'),
                      onPressed: () => _openOrder(context, order.label),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
          ],
          LayoutBuilder(
            builder: (context, constraints) {
              final count = constraints.maxWidth >= 1100
                  ? 5
                  : constraints.maxWidth >= 850
                  ? 4
                  : constraints.maxWidth >= 550
                  ? 3
                  : constraints.maxWidth >= 340
                  ? 2
                  : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: store.tables.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: count,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: constraints.maxWidth < 340 ? 1.35 : 0.98,
                ),
                itemBuilder: (context, index) {
                  final table = store.tables[index];
                  final occupied = store.occupiedTables.contains(table.number);
                  final tableLabel =
                      'Meja ${table.number.toString().padLeft(2, '0')}';
                  final pending = store.pendingOrders[tableLabel];

                  return _TableCard(
                    table: table,
                    occupied: occupied,
                    pending: pending,
                    onTap: () => _openOrder(context, tableLabel),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({
    required this.table,
    required this.occupied,
    required this.pending,
    required this.onTap,
  });

  final CafeTable table;
  final bool occupied;
  final PendingOrder? pending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final topBgColor = occupied
        ? const Color(0xFFFBECE6)
        : const Color(0xFFF3ECE6);
    final iconColor = occupied
        ? const Color(0xFFC05128)
        : const Color(0xFFC67C4E);
    final actionColor = occupied
        ? const Color(0xFFC05128)
        : const Color(0xFF316B58);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: occupied ? const Color(0xFFF3C5B5) : const Color(0xFFE8E0D6),
          width: 1.2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Section (Hero Icon Area - Bersih & Icon Besar Proporsional)
            Expanded(
              flex: 6,
              child: Container(
                color: topBgColor,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Status Badge di pojok kanan atas
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: occupied
                              ? const Color(0xFFFFDFD5)
                              : const Color(0xFFE4F3EC),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: occupied
                                ? const Color(0xFFF5A389)
                                : const Color(0xFFA3D8C0),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: occupied
                                    ? const Color(0xFFC05128)
                                    : const Color(0xFF316B58),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              occupied ? 'Terisi' : 'Kosong',
                              style: TextStyle(
                                color: occupied
                                    ? const Color(0xFF9E3D19)
                                    : const Color(0xFF225745),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Icon Besar Centerpiece (Ukuran 58)
                    Icon(
                      table.seats >= 4
                          ? Icons.table_restaurant_rounded
                          : Icons.table_bar_rounded,
                      size: 58,
                      color: iconColor,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Section (Putih Bersih, Teks Tegas, Tombol Bulat)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Meja ${table.number.toString().padLeft(2, '0')}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 3),
                        if (occupied && pending != null)
                          Text(
                            '${pending!.itemCount} item • ${rupiah(pending!.total)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFC05128),
                            ),
                          )
                        else
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.chair_rounded,
                                size: 14,
                                color: Color(0xFF316B58),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${table.seats} Kursi',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF316B58),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: actionColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      occupied ? Icons.edit_note_rounded : Icons.add_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TableFormPage extends StatefulWidget {
  const TableFormPage({super.key, required this.store});
  final PosStore store;

  @override
  State<TableFormPage> createState() => _TableFormPageState();
}

class _TableFormPageState extends State<TableFormPage> {
  int seats = 2;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Tambah Meja')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kapasitas meja',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Nomor meja akan dibuat otomatis agar tidak bentrok.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(
                        value: 2,
                        label: Text('2 kursi'),
                        icon: Icon(Icons.chair_rounded),
                      ),
                      ButtonSegment(
                        value: 4,
                        label: Text('4 kursi'),
                        icon: Icon(Icons.chair_alt_rounded),
                      ),
                      ButtonSegment(
                        value: 6,
                        label: Text('6 kursi'),
                        icon: Icon(Icons.groups_rounded),
                      ),
                    ],
                    selected: {seats},
                    onSelectionChanged: (value) =>
                        setState(() => seats = value.first),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        widget.store.addTable(seats: seats);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Simpan Meja'),
                    ),
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

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ],
  );
}
