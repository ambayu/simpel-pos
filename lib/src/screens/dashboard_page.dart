import 'package:flutter/material.dart';

import '../models.dart';
import '../pos_store.dart';
import '../theme/app_theme.dart';

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
        padding: EdgeInsets.zero,
        children: [
          _DashboardHeader(store: store, onNewOrder: onNewOrder),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Pesanan Terbaru',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: onNewOrder,
                      child: const Text('Lihat Semua'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (store.transactions.isEmpty && store.pendingOrders.isEmpty)
                  const _EmptyOrders()
                else ...[
                  ...store.pendingOrders.values.map(
                    (order) => _OrderTile(
                      code: order.label,
                      title: '${order.itemCount} item aktif',
                      amount: order.total,
                      time: order.elapsedLabel,
                      pending: true,
                    ),
                  ),
                  ...store.transactions
                      .take(5)
                      .map(
                        (transaction) => _OrderTile(
                          code:
                              '#${transaction.id.substring(transaction.id.length - 4)}',
                          title: transaction.items.isEmpty
                              ? transaction.orderLabel
                              : transaction.items.first.productName,
                          amount: transaction.total,
                          time: _clock(transaction.createdAt),
                          pending: false,
                        ),
                      ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _clock(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.store, required this.onNewOrder});

  final PosStore store;
  final VoidCallback onNewOrder;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: const BoxDecoration(color: AppColors.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang, ${store.role}!',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatDate(now),
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: .82),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 720 ? 4 : 2;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: columns,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.95,
                children: [
                  _StatCard(
                    label: 'Omzet Hari Ini',
                    value: rupiah(store.todaySales),
                    delta: '12%',
                  ),
                  _StatCard(
                    label: 'Total Transaksi',
                    value: '${store.todayTransactions}',
                    delta: '9%',
                  ),
                  _StatCard(
                    label: 'Estimasi Keuntungan',
                    value: rupiah(store.estimatedProfit),
                    delta: '15%',
                  ),
                  _StatCard(
                    label: 'Meja Terisi',
                    value:
                        '${store.occupiedTables.length} / ${store.tables.length}',
                    delta: store.tables.isEmpty
                        ? '0%'
                        : '${((store.occupiedTables.length / store.tables.length) * 100).round()}%',
                    showArrow: false,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onNewOrder,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text('Buat Pesanan Baru'),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime value) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${days[value.weekday - 1]}, ${value.day} '
        '${months[value.month - 1]} ${value.year}';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.delta,
    this.showArrow = true,
  });

  final String label;
  final String value;
  final String delta;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              if (showArrow)
                const Icon(
                  Icons.arrow_upward_rounded,
                  size: 11,
                  color: AppColors.success,
                ),
              Text(
                delta,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({
    required this.code,
    required this.title,
    required this.amount,
    required this.time,
    required this.pending,
  });

  final String code;
  final String title;
  final int amount;
  final String time;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 58,
            child: Text(
              code,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            rupiah(amount),
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: pending ? AppColors.accentGold : AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            time,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 40,
            color: AppColors.textMuted,
          ),
          SizedBox(height: 10),
          Text(
            'Belum ada pesanan hari ini',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
