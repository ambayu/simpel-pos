import 'package:flutter/material.dart';

import '../models.dart';
import '../pos_store.dart';
import '../theme/app_theme.dart';
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_rounded, size: 20),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(width: 30),
                ),
                const SizedBox(width: 4),
                const Expanded(
                  child: Text(
                    'Denah Meja',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TableFormPage(store: store),
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(42, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: const Text('Atur Meja'),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Legend(color: AppColors.statusFreeText, label: 'Kosong'),
                _Legend(color: AppColors.statusOccupiedText, label: 'Terisi'),
                _Legend(
                  color: AppColors.statusReservedText,
                  label: 'Reservasi',
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1000
                    ? 6
                    : constraints.maxWidth >= 700
                    ? 4
                    : 3;
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
                  itemCount: store.tables.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final table = store.tables[index];
                    final label =
                        'Meja ${table.number.toString().padLeft(2, '0')}';
                    final status = store.statusOf(table.number);
                    return _TableTile(
                      table: table,
                      status: status,
                      pending: store.pendingOrders[label],
                      reservedAt: store.reservedTables[table.number],
                      onTap: () => _openOrder(context, label),
                    );
                  },
                );
              },
            ),
          ),
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
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primarySoft,
                  foregroundColor: AppColors.primary,
                ),
                onPressed: () => _openOrder(context, store.nextTakeAwayLabel()),
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Take Away / Bungkus'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableTile extends StatelessWidget {
  const _TableTile({
    required this.table,
    required this.status,
    required this.pending,
    required this.reservedAt,
    required this.onTap,
  });

  final CafeTable table;
  final TableStatus status;
  final PendingOrder? pending;
  final String? reservedAt;
  final VoidCallback onTap;

  ({Color bg, Color border, Color text, String label}) get _palette {
    switch (status) {
      case TableStatus.occupied:
        return (
          bg: AppColors.statusOccupiedBg,
          border: AppColors.statusOccupiedBorder,
          text: AppColors.statusOccupiedText,
          label: 'Terisi',
        );
      case TableStatus.reserved:
        return (
          bg: AppColors.statusReservedBg,
          border: AppColors.statusReservedBorder,
          text: AppColors.statusReservedText,
          label: 'Reservasi',
        );
      case TableStatus.free:
        return (
          bg: AppColors.statusFreeBg,
          border: AppColors.statusFreeBorder,
          text: AppColors.statusFreeText,
          label: 'Kosong',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette;
    final subtitle = switch (status) {
      TableStatus.occupied => pending?.elapsedLabel ?? '00:00',
      TableStatus.reserved => reservedAt ?? '-',
      TableStatus.free => '${table.seats} kursi',
    };

    return Material(
      color: palette.bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: palette.border, width: 1.4),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${table.number}',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: palette.text,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                palette.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: palette.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: palette.text.withValues(alpha: .75),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TableFormPage extends StatefulWidget {
  const TableFormPage({
    super.key,
    required this.store,
    this.initialTableNumber,
  });

  final PosStore store;
  final int? initialTableNumber;

  @override
  State<TableFormPage> createState() => _TableFormPageState();
}

class _TableFormPageState extends State<TableFormPage> {
  late TextEditingController numberController;
  late TextEditingController reservedTimeController;
  int seats = 2;
  bool isReserved = false;

  @override
  void initState() {
    super.initState();
    final initialNum =
        widget.initialTableNumber ?? widget.store.nextTableNumber;
    numberController = TextEditingController(text: '$initialNum');
    reservedTimeController = TextEditingController(text: '19:00');

    if (widget.initialTableNumber != null) {
      final existing = widget.store.tables
          .where((t) => t.number == widget.initialTableNumber)
          .firstOrNull;
      if (existing != null) {
        seats = existing.seats;
      }
      final reserved = widget.store.reservedTables[widget.initialTableNumber];
      if (reserved != null) {
        isReserved = true;
        reservedTimeController.text = reserved;
      }
    }
  }

  @override
  void dispose() {
    numberController.dispose();
    reservedTimeController.dispose();
    super.dispose();
  }

  void _editTable(CafeTable table) {
    setState(() {
      numberController.text = '${table.number}';
      seats = table.seats;
      final reserved = widget.store.reservedTables[table.number];
      if (reserved != null) {
        isReserved = true;
        reservedTimeController.text = reserved;
      } else {
        isReserved = false;
      }
    });
  }

  void _saveTable() {
    final rawNum = int.tryParse(numberController.text.trim());
    if (rawNum == null || rawNum <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor meja harus berupa angka positif.')),
      );
      return;
    }

    final reservedStr = isReserved ? reservedTimeController.text.trim() : null;
    widget.store.addTable(
      seats: seats,
      number: rawNum,
      reservedUntil: reservedStr,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Meja $rawNum berhasil disimpan!'),
        backgroundColor: AppColors.success,
      ),
    );

    // Siapkan nomor meja baru berikutnya
    setState(() {
      numberController.text = '${widget.store.nextTableNumber}';
      isReserved = false;
    });
  }

  void _confirmDelete(int tableNum) {
    if (widget.store.occupiedTables.contains(tableNum)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Meja ini sedang terisi pesanan aktif dan tidak dapat dihapus.',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hapus Meja $tableNum?'),
        content: const Text(
          'Meja ini akan dihapus dari denah restoran secara permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              widget.store.deleteTable(tableNum);
              Navigator.pop(ctx);
              setState(() {
                numberController.text = '${widget.store.nextTableNumber}';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Meja $tableNum telah dihapus.')),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final previewNumber =
        int.tryParse(numberController.text.trim()) ??
        widget.store.nextTableNumber;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Atur Meja')),
      body: AdminBackdrop(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: AnimatedBuilder(
              animation: widget.store,
              builder: (context, _) => ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  // Form Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primarySoft,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.table_restaurant_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tambah / Edit Meja',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'Atur nomor, kapasitas kursi, & status meja',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Nomor Meja
                          const Text(
                            'Nomor Meja',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: numberController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: 'Contoh: 1, 2, 13',
                                    prefixIcon: Icon(Icons.tag_rounded),
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    numberController.text =
                                        '${widget.store.nextTableNumber}';
                                  });
                                },
                                tooltip: 'Isi nomor otomatis',
                                icon: const Icon(Icons.autorenew_rounded),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Kapasitas Kursi
                          const Text(
                            'Kapasitas Kursi',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ...[2, 4, 6, 8].map((qty) {
                                final selected = seats == qty;
                                return ChoiceChip(
                                  label: Text('$qty Kursi'),
                                  selected: selected,
                                  onSelected: (_) =>
                                      setState(() => seats = qty),
                                );
                              }),
                              Container(
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: seats > 1
                                          ? () => setState(() => seats--)
                                          : null,
                                      borderRadius:
                                          const BorderRadius.horizontal(
                                            left: Radius.circular(8),
                                          ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        child: Icon(
                                          Icons.remove_rounded,
                                          size: 16,
                                          color: seats > 1
                                              ? AppColors.textPrimary
                                              : AppColors.textMuted,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        '$seats',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: seats < 30
                                          ? () => setState(() => seats++)
                                          : null,
                                      borderRadius:
                                          const BorderRadius.horizontal(
                                            right: Radius.circular(8),
                                          ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        child: Icon(
                                          Icons.add_rounded,
                                          size: 16,
                                          color: seats < 30
                                              ? AppColors.textPrimary
                                              : AppColors.textMuted,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Status Awal
                          const Text(
                            'Status Awal Meja',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SegmentedButton<bool>(
                            showSelectedIcon: false,
                            segments: const [
                              ButtonSegment(
                                value: false,
                                label: Text('Kosong', maxLines: 1),
                                icon: Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 16,
                                ),
                              ),
                              ButtonSegment(
                                value: true,
                                label: Text('Reservasi', maxLines: 1),
                                icon: Icon(Icons.schedule_rounded, size: 16),
                              ),
                            ],
                            selected: {isReserved},
                            onSelectionChanged: (val) {
                              setState(() => isReserved = val.first);
                            },
                          ),

                          if (isReserved) ...[
                            const SizedBox(height: 12),
                            TextField(
                              controller: reservedTimeController,
                              decoration: const InputDecoration(
                                labelText: 'Jam Reservasi',
                                hintText: 'Contoh: 19:00',
                                prefixIcon: Icon(Icons.access_time_rounded),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              children: ['18:00', '19:00', '20:00', '21:00']
                                  .map(
                                    (time) => ActionChip(
                                      label: Text(time),
                                      onPressed: () {
                                        setState(() {
                                          reservedTimeController.text = time;
                                        });
                                      },
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                          const SizedBox(height: 20),

                          // Preview Box
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                // Mini Table Card Preview
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: isReserved
                                        ? AppColors.statusReservedBg
                                        : AppColors.statusFreeBg,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isReserved
                                          ? AppColors.statusReservedBorder
                                          : AppColors.statusFreeBorder,
                                      width: 1.4,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '$previewNumber',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          color: isReserved
                                              ? AppColors.statusReservedText
                                              : AppColors.statusFreeText,
                                        ),
                                      ),
                                      Text(
                                        isReserved ? 'Reservasi' : 'Kosong',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: isReserved
                                              ? AppColors.statusReservedText
                                              : AppColors.statusFreeText,
                                        ),
                                      ),
                                      Text(
                                        isReserved
                                            ? reservedTimeController.text
                                            : '$seats kursi',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: isReserved
                                              ? AppColors.statusReservedText
                                              : AppColors.statusFreeText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Pratinjau Meja',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Meja ${previewNumber.toString().padLeft(2, '0')} • $seats Kursi • ${isReserved ? 'Reservasi jam ${reservedTimeController.text}' : 'Tersedia'}',
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Submit button
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _saveTable,
                              icon: const Icon(Icons.save_rounded),
                              label: const Text('Simpan Meja'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Daftar Meja Terdaftar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daftar Meja (${widget.store.tables.length})',
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Total Kapasitas: ${widget.store.tables.fold(0, (sum, t) => sum + t.seats)} kursi',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (widget.store.tables.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(
                        child: Text(
                          'Belum ada meja. Tambahkan meja pertama menggunakan form di atas.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  else
                    ...widget.store.tables.map((table) {
                      final status = widget.store.statusOf(table.number);
                      final isOccupied = status == TableStatus.occupied;
                      final isRes = status == TableStatus.reserved;
                      final resTime = widget.store.reservedTables[table.number];

                      Color badgeBg;
                      Color badgeText;
                      String statusLabel;

                      if (isOccupied) {
                        badgeBg = AppColors.statusOccupiedBg;
                        badgeText = AppColors.statusOccupiedText;
                        statusLabel = 'Terisi';
                      } else if (isRes) {
                        badgeBg = AppColors.statusReservedBg;
                        badgeText = AppColors.statusReservedText;
                        statusLabel = 'Reservasi ($resTime)';
                      } else {
                        badgeBg = AppColors.statusFreeBg;
                        badgeText = AppColors.statusFreeText;
                        statusLabel = 'Kosong';
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: badgeBg,
                            child: Text(
                              '${table.number}',
                              style: TextStyle(
                                color: badgeText,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          title: Text(
                            'Meja ${table.number.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              children: [
                                Text(
                                  '${table.seats} Kursi',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: badgeBg,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    statusLabel,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: badgeText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                tooltip: 'Edit Meja',
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                onPressed: () => _editTable(table),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                  color: isOccupied
                                      ? AppColors.textMuted
                                      : AppColors.danger,
                                ),
                                tooltip: isOccupied
                                    ? 'Sedang Terisi'
                                    : 'Hapus Meja',
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                onPressed: isOccupied
                                    ? null
                                    : () => _confirmDelete(table.number),
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
        ),
      ),
    );
  }
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
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    ],
  );
}
