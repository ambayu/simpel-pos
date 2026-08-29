import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models.dart';
import '../pos_store.dart';
import '../services/receipt_printer.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key, required this.store});
  final PosStore store;

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String category = 'Semua';

  void saveOrder({bool closeSheet = false}) {
    if (widget.store.cart.isEmpty) return;
    widget.store.savePendingOrder();
    if (closeSheet) Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  Future<void> checkout({bool closeCartSheet = false}) async {
    if (widget.store.cart.isEmpty) return;
    final paymentMethod = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentSheet(store: widget.store),
    );
    if (paymentMethod != null && mounted) {
      final messenger = ScaffoldMessenger.of(context);
      final confirmed = await _confirmPayment(paymentMethod);
      if (confirmed != true || !mounted) return;
      final transaction = widget.store.completeOrder(paymentMethod);
      if (transaction == null) return;
      if (closeCartSheet) Navigator.of(context).pop();
      Navigator.of(context).pop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Pembayaran berhasil. Meja sudah kosong kembali.'),
        ),
      );
      await _printReceipt(transaction);
    }
  }

  Future<bool?> _confirmPayment(String paymentMethod) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pembayaran'),
        content: Text(
          'Pastikan uang/pembayaran sudah benar-benar diterima. Tandai pesanan ini lunas dengan metode $paymentMethod?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Belum, batal'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.check_circle_rounded),
            label: const Text('Sudah diterima'),
          ),
        ],
      ),
    );
  }

  Future<void> _printReceipt(SaleRecord transaction) async {
    try {
      await ReceiptPrinter.printReceipt(transaction);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaksi berhasil, tapi struk gagal dicetak: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final categories = widget.store.categories;
        if (!categories.contains(category)) category = 'Semua';
        final items = widget.store.menu
            .where((item) => category == 'Semua' || item.category == category)
            .toList();
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.store.activeOrder ?? 'Pesanan Baru'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Chip(
                  visualDensity: VisualDensity.compact,
                  avatar: const Icon(Icons.person_rounded, size: 15),
                  label: Text(widget.store.role),
                ),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final split = constraints.maxWidth >= 900;
              final menu = _MenuPanel(
                categories: categories,
                category: category,
                items: items,
                store: widget.store,
                onCategory: (value) => setState(() => category = value),
              );
              final cart = _CartPanel(
                store: widget.store,
                canPay: widget.store.pendingOrders.containsKey(
                  widget.store.activeOrder,
                ),
                onSave: split ? saveOrder : () => saveOrder(closeSheet: true),
                onCheckout: split
                    ? checkout
                    : () => checkout(closeCartSheet: true),
              );
              if (split) {
                return Row(
                  children: [
                    Expanded(child: menu),
                    SizedBox(width: 360, child: cart),
                  ],
                );
              }
              return Stack(
                children: [
                  menu,
                  if (widget.store.cartCount > 0)
                    Positioned(
                      left: 10,
                      right: 10,
                      bottom: 8,
                      child: FilledButton.icon(
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => SizedBox(
                            height: MediaQuery.sizeOf(context).height * .84,
                            child: cart,
                          ),
                        ),
                        icon: const Icon(Icons.shopping_basket_rounded),
                        label: Text(
                          '${widget.store.cartCount} item • ${rupiah(widget.store.total)}',
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _MenuPanel extends StatelessWidget {
  const _MenuPanel({
    required this.categories,
    required this.category,
    required this.items,
    required this.store,
    required this.onCategory,
  });
  final List<String> categories;
  final String category;
  final List<MenuItem> items;
  final PosStore store;
  final ValueChanged<String> onCategory;

  @override
  Widget build(BuildContext context) => CustomScrollView(
    slivers: [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
        sliver: SliverToBoxAdapter(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 380;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pilih Menu',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: compact ? 22 : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tekan kartu menu untuk langsung menambah pesanan',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories
                          .map(
                            (value) => Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: ChoiceChip(
                                label: Text(value),
                                selected: value == category,
                                onSelected: (_) => onCategory(value),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(12, 2, 12, 70),
        sliver: SliverGrid.builder(
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 170,
            mainAxisExtent: 188,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            final quantity = store.cart[item.id]?.quantity ?? 0;
            final hasImage =
                item.imagePath != null && File(item.imagePath!).existsSync();
            return Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFEBE6DF), width: 1.2),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => store.add(item),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Container(
                        width: double.infinity,
                        color: const Color(0xFFF3ECE6),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: (hasImage && !kIsWeb)
                                  ? Image.file(
                                      File(item.imagePath!),
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Center(
                                                child: Icon(
                                                  item.icon,
                                                  color: item.color,
                                                  size: 48,
                                                ),
                                              ),
                                    )
                                  : Center(
                                      child: Icon(
                                        item.icon,
                                        color: item.color,
                                        size: 48,
                                      ),
                                    ),
                            ),
                            if (quantity > 0)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: CircleAvatar(
                                  backgroundColor: const Color(0xFF316B58),
                                  foregroundColor: Colors.white,
                                  radius: 13,
                                  child: Text(
                                    '$quantity',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    rupiah(item.price),
                                    style: const TextStyle(
                                      color: Color(0xFF316B58),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF316B58),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add_rounded,
                                    color: Colors.white,
                                    size: 18,
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
            );
          },
        ),
      ),
    ],
  );
}

class _CartPanel extends StatelessWidget {
  const _CartPanel({
    required this.store,
    required this.canPay,
    required this.onSave,
    required this.onCheckout,
  });

  final PosStore store;
  final bool canPay;
  final VoidCallback onSave;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.all(8),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Ringkasan Pesanan',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              if (store.cart.isNotEmpty)
                Text(
                  '${store.cartCount} item',
                  style: const TextStyle(color: Colors.black54),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            store.activeOrder ?? 'Pesanan',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const Divider(),
          Expanded(
            child: store.cart.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_basket_outlined,
                          size: 48,
                          color: Colors.black26,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Keranjang masih kosong.\nPilih menu di sebelah kiri.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    children: store.cart.values
                        .map(
                          (line) => Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F7F5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        line.item.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        '${line.quantity}x @ ${rupiah(line.item.price)}',
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton.filledTonal(
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => store.remove(line.item),
                                  icon: const Icon(
                                    Icons.remove_rounded,
                                    size: 16,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    '${line.quantity}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                IconButton.filled(
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => store.add(line.item),
                                  icon: const Icon(Icons.add_rounded, size: 16),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
          const Divider(),
          _PriceLine(label: 'Subtotal', value: rupiah(store.subtotal)),
          _PriceLine(label: 'Pajak 10%', value: rupiah(store.tax)),
          const SizedBox(height: 5),
          _PriceLine(label: 'Total', value: rupiah(store.total), bold: true),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: store.cart.isEmpty ? null : onSave,
              icon: const Icon(Icons.save_rounded),
              label: Text(canPay ? 'Simpan Perubahan' : 'Simpan Pesanan'),
            ),
          ),
          if (canPay) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: store.cart.isEmpty ? null : onCheckout,
                icon: const Icon(Icons.payments_rounded),
                label: const Text('Bayar Sekarang'),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

class _PriceLine extends StatelessWidget {
  const _PriceLine({
    required this.label,
    required this.value,
    this.bold = false,
  });
  final String label;
  final String value;
  final bool bold;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.normal,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 18 : 14,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _PaymentSheet extends StatefulWidget {
  const _PaymentSheet({required this.store});
  final PosStore store;
  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  String payment = 'Tunai';
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(
      16,
      10,
      16,
      14 + MediaQuery.paddingOf(context).bottom,
    ),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Pilih Pembayaran',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          Text(
            'Total ${rupiah(widget.store.total)}',
            style: const TextStyle(
              color: Color(0xFF316B58),
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                [
                      ('Tunai', Icons.payments_rounded),
                      ('QRIS', Icons.qr_code_2_rounded),
                      ('Kartu', Icons.credit_card_rounded),
                      ('E-Wallet', Icons.account_balance_wallet_rounded),
                    ]
                    .map(
                      (method) => ChoiceChip(
                        avatar: Icon(method.$2, size: 19),
                        label: Text(method.$1),
                        selected: payment == method.$1,
                        onSelected: (_) => setState(() => payment = method.$1),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.pop(context, payment),
              icon: const Icon(Icons.check_circle_rounded),
              label: Text('Bayar dengan $payment'),
            ),
          ),
        ],
      ),
    ),
  );
}
