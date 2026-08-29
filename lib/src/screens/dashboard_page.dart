import 'package:flutter/material.dart';

import '../models.dart';
import '../pos_store.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.store,
    required this.onNewOrder,
  });
  final PosStore store;
  final VoidCallback onNewOrder;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _Header(role: store.role),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 720;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF316B58), Color(0xFF477F6C)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: wide
                    ? Row(
                        children: [
                          Expanded(child: _HeroCopy(onNewOrder: onNewOrder)),
                          const Icon(
                            Icons.point_of_sale_rounded,
                            size: 82,
                            color: Colors.white24,
                          ),
                        ],
                      )
                    : _HeroCopy(onNewOrder: onNewOrder),
              );
            },
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final count = constraints.maxWidth >= 900
                  ? 4
                  : constraints.maxWidth >= 360
                  ? 2
                  : 1;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: count,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: constraints.maxWidth < 360
                    ? 2.8
                    : constraints.maxWidth < 500
                    ? 1.75
                    : 2.05,
                children: [
                  _MetricCard(
                    icon: Icons.payments_rounded,
                    label: 'Omzet hari ini',
                    value: rupiah(store.todaySales),
                    tone: const Color(0xFF316B58),
                  ),
                  _MetricCard(
                    icon: Icons.receipt_long_rounded,
                    label: 'Transaksi',
                    value: '${store.todayTransactions}',
                    tone: const Color(0xFFC67C4E),
                  ),
                  _MetricCard(
                    icon: Icons.table_restaurant_rounded,
                    label: 'Meja terisi',
                    value: '${store.occupiedTables.length} / 16',
                    tone: const Color(0xFF9B6B43),
                  ),
                  const _MetricCard(
                    icon: Icons.trending_up_rounded,
                    label: 'Rata-rata order',
                    value: 'Rp59.200',
                    tone: Color(0xFF647A52),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Text(
            'Aktivitas meja',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 7),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: store.occupiedTables
                    .map(
                      (table) => Chip(
                        avatar: const Icon(Icons.table_bar_rounded, size: 18),
                        label: Text(
                          'Meja ${table.toString().padLeft(2, '0')} • Pesanan aktif',
                        ),
                        backgroundColor: const Color(0xFFFFE9DF),
                        side: BorderSide.none,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.role});
  final String role;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat pagi, $role 👋',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            const Text(
              'Jumat, 28 Agustus 2026 • Kopi Senja',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
      IconButton.filledTonal(
        onPressed: () {},
        icon: const Icon(Icons.notifications_none_rounded),
      ),
    ],
  );
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.onNewOrder});
  final VoidCallback onNewOrder;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Siap melayani pesanan baru?',
        style: TextStyle(
          color: Colors.white,
          fontSize: 21,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'Pilih meja dan tekan menu. Cepat, simpel, tanpa ribet.',
        style: TextStyle(color: Colors.white.withValues(alpha: .78)),
      ),
      const SizedBox(height: 12),
      FilledButton.icon(
        onPressed: onNewOrder,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFF2BD72),
          foregroundColor: const Color(0xFF244D41),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Buat Pesanan Baru',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    ],
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.tone,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color tone;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: tone.withValues(alpha: .12),
            child: Icon(icon, color: tone, size: 18),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black54, fontSize: 11),
          ),
        ],
      ),
    ),
  );
}
