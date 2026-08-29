import 'package:flutter/material.dart';

import '../models.dart';
import '../pos_store.dart';
import '../services/report_exporter.dart';

enum DateRangePreset {
  all('Semua Waktu'),
  today('Hari Ini'),
  last7Days('7 Hari Terakhir'),
  thisMonth('Bulan Ini'),
  custom('Kustom');

  const DateRangePreset(this.label);
  final String label;
}

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key, required this.store});
  final PosStore store;

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  String searchQuery = '';
  String selectedPayment = 'Semua';

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.store,
    builder: (context, _) {
      final filteredTransactions = widget.store.transactions.where((t) {
        if (selectedPayment != 'Semua' && t.paymentMethod != selectedPayment) {
          return false;
        }
        if (searchQuery.isNotEmpty) {
          final q = searchQuery.toLowerCase();
          final matchId = t.id.toLowerCase().contains(q);
          final matchLabel = t.orderLabel.toLowerCase().contains(q);
          final matchCashier = t.cashier.toLowerCase().contains(q);
          if (!matchId && !matchLabel && !matchCashier) return false;
        }
        return true;
      }).toList();

      return ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text(
            'Transaksi',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            'Riwayat pembayaran yang sudah diselesaikan',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: 'Cari no. transaksi, meja, atau kasir...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () => setState(() => searchQuery = ''),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            onChanged: (v) => setState(() => searchQuery = v),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text(
                  'Metode: ',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                ...['Semua', 'Tunai', 'QRIS', 'Kartu', 'E-Wallet'].map(
                  (method) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(method),
                      selected: selectedPayment == method,
                      onSelected: (_) =>
                          setState(() => selectedPayment = method),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (filteredTransactions.isEmpty)
            const _EmptyReport(
              message:
                  'Tidak ada transaksi yang cocok dengan filter atau pencarian.',
            )
          else
            ...filteredTransactions.map(
              (transaction) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE7F5ED),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: Color(0xFF316B58),
                    ),
                  ),
                  title: Text(
                    transaction.orderLabel,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    '${transaction.id} • ${_date(transaction.createdAt)}\n${transaction.itemCount} item • ${transaction.paymentMethod} (${transaction.cashier})',
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    rupiah(transaction.total),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: Color(0xFF316B58),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}

class ReportPage extends StatefulWidget {
  const ReportPage({super.key, required this.store});
  final PosStore store;

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  bool exportingSummary = false;
  bool exportingDetail = false;

  DateRangePreset selectedPreset = DateRangePreset.all;
  DateTimeRange? customDateRange;
  String selectedPayment = 'Semua';
  String selectedOrderType = 'Semua'; // Semua, Meja, Take Away
  String searchKeyword = '';

  List<SaleRecord> _filterTransactions(List<SaleRecord> all) {
    final now = DateTime.now();
    return all.where((t) {
      // Filter tanggal
      switch (selectedPreset) {
        case DateRangePreset.today:
          if (t.createdAt.year != now.year ||
              t.createdAt.month != now.month ||
              t.createdAt.day != now.day) {
            return false;
          }
          break;
        case DateRangePreset.last7Days:
          final start = DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(const Duration(days: 6));
          if (t.createdAt.isBefore(start)) return false;
          break;
        case DateRangePreset.thisMonth:
          if (t.createdAt.year != now.year || t.createdAt.month != now.month) {
            return false;
          }
          break;
        case DateRangePreset.custom:
          if (customDateRange != null) {
            final start = DateTime(
              customDateRange!.start.year,
              customDateRange!.start.month,
              customDateRange!.start.day,
            );
            final end = DateTime(
              customDateRange!.end.year,
              customDateRange!.end.month,
              customDateRange!.end.day,
              23,
              59,
              59,
            );
            if (t.createdAt.isBefore(start) || t.createdAt.isAfter(end)) {
              return false;
            }
          }
          break;
        case DateRangePreset.all:
          break;
      }

      // Filter metode bayar
      if (selectedPayment != 'Semua' && t.paymentMethod != selectedPayment) {
        return false;
      }

      // Filter tipe pesanan
      if (selectedOrderType == 'Meja' && !t.orderLabel.startsWith('Meja')) {
        return false;
      }
      if (selectedOrderType == 'Take Away' &&
          !t.orderLabel.startsWith('Take Away')) {
        return false;
      }

      // Filter keyword
      if (searchKeyword.trim().isNotEmpty) {
        final q = searchKeyword.toLowerCase();
        final matchId = t.id.toLowerCase().contains(q);
        final matchLabel = t.orderLabel.toLowerCase().contains(q);
        final matchCashier = t.cashier.toLowerCase().contains(q);
        final matchItem = t.items.any(
          (item) => item.productName.toLowerCase().contains(q),
        );
        if (!matchId && !matchLabel && !matchCashier && !matchItem) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<void> _pickCustomDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDateRange:
          customDateRange ??
          DateTimeRange(
            start: DateTime(now.year, now.month, now.day),
            end: DateTime(now.year, now.month, now.day),
          ),
      helpText: 'Pilih Rentang Tanggal Laporan',
      cancelText: 'Batal',
      confirmText: 'Terapkan',
    );

    if (picked != null) {
      setState(() {
        customDateRange = picked;
        selectedPreset = DateRangePreset.custom;
      });
    }
  }

  void _resetFilter() {
    setState(() {
      selectedPreset = DateRangePreset.all;
      customDateRange = null;
      selectedPayment = 'Semua';
      selectedOrderType = 'Semua';
      searchKeyword = '';
    });
  }

  bool get _hasActiveFilter =>
      selectedPreset != DateRangePreset.all ||
      selectedPayment != 'Semua' ||
      selectedOrderType != 'Semua' ||
      searchKeyword.isNotEmpty;

  Future<void> _exportSummary(List<SaleRecord> transactions) async {
    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada data transaksi untuk diekspor'),
        ),
      );
      return;
    }
    setState(() => exportingSummary = true);
    try {
      final path = await ReportExporter.exportSummary(transactions);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Excel Rekap tersimpan di: $path'),
          backgroundColor: const Color(0xFF316B58),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat Excel Rekap: $error')),
      );
    } finally {
      if (mounted) setState(() => exportingSummary = false);
    }
  }

  Future<void> _exportDetail(List<SaleRecord> transactions) async {
    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada data transaksi untuk diekspor'),
        ),
      );
      return;
    }
    setState(() => exportingDetail = true);
    try {
      final path = await ReportExporter.exportDetail(transactions);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Excel Detail tersimpan di: $path'),
          backgroundColor: const Color(0xFF316B58),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat Excel Detail: $error')),
      );
    } finally {
      if (mounted) setState(() => exportingDetail = false);
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.store,
    builder: (context, _) {
      final filteredList = _filterTransactions(widget.store.transactions);
      final revenue = filteredList.fold<int>(
        0,
        (sum, transaction) => sum + transaction.total,
      );
      final items = filteredList.fold<int>(
        0,
        (sum, transaction) => sum + transaction.itemCount,
      );
      final average = filteredList.isEmpty ? 0 : revenue ~/ filteredList.length;

      return ListView(
        padding: const EdgeInsets.all(12),
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 620;
              final headerInfo = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Laporan Penjualan',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Unduh rekap & detail penjualan lengkap dengan filter',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              );
              final actionButtons = Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: (exportingSummary || exportingDetail)
                        ? null
                        : () => _exportSummary(filteredList),
                    icon: exportingSummary
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.summarize_rounded, size: 18),
                    label: Text(
                      exportingSummary ? 'Menyimpan...' : 'Download Rekap',
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: (exportingSummary || exportingDetail)
                        ? null
                        : () => _exportDetail(filteredList),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF316B58),
                      foregroundColor: Colors.white,
                    ),
                    icon: exportingDetail
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.list_alt_rounded, size: 18),
                    label: Text(
                      exportingDetail ? 'Menyimpan...' : 'Download Detail',
                    ),
                  ),
                ],
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headerInfo,
                    const SizedBox(height: 12),
                    actionButtons,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: headerInfo),
                  const SizedBox(width: 12),
                  actionButtons,
                ],
              );
            },
          ),
          const SizedBox(height: 14),

          // Filter Container
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.tune_rounded,
                        size: 20,
                        color: Color(0xFF316B58),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Filter Laporan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      if (_hasActiveFilter)
                        TextButton.icon(
                          onPressed: _resetFilter,
                          icon: const Icon(Icons.restart_alt_rounded, size: 16),
                          label: const Text('Reset Filter'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari transaksi, produk, meja, kasir...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: searchKeyword.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () =>
                                  setState(() => searchKeyword = ''),
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                    onChanged: (v) => setState(() => searchKeyword = v),
                  ),
                  const SizedBox(height: 10),

                  // Periode Waktu
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      const Text(
                        'Periode: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      ...DateRangePreset.values.map((preset) {
                        if (preset == DateRangePreset.custom) {
                          final customLabel = customDateRange == null
                              ? 'Kustom...'
                              : '${customDateRange!.start.day}/${customDateRange!.start.month} - ${customDateRange!.end.day}/${customDateRange!.end.month}';
                          return ActionChip(
                            avatar: const Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                            ),
                            label: Text(customLabel),
                            backgroundColor:
                                selectedPreset == DateRangePreset.custom
                                ? const Color(0xFFE7F5ED)
                                : null,
                            side: BorderSide(
                              color: selectedPreset == DateRangePreset.custom
                                  ? const Color(0xFF316B58)
                                  : const Color(0xFFE2E8F0),
                            ),
                            onPressed: _pickCustomDateRange,
                          );
                        }
                        return ChoiceChip(
                          label: Text(preset.label),
                          selected: selectedPreset == preset,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => selectedPreset = preset);
                            }
                          },
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Metode Bayar & Tipe Pesanan
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          const Text(
                            'Metode: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          ...[
                            'Semua',
                            'Tunai',
                            'QRIS',
                            'Kartu',
                            'E-Wallet',
                          ].map(
                            (method) => ChoiceChip(
                              label: Text(method),
                              selected: selectedPayment == method,
                              onSelected: (_) =>
                                  setState(() => selectedPayment = method),
                            ),
                          ),
                        ],
                      ),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          const Text(
                            'Tipe: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          ...['Semua', 'Meja', 'Take Away'].map(
                            (type) => ChoiceChip(
                              label: Text(type),
                              selected: selectedOrderType == type,
                              onSelected: (_) =>
                                  setState(() => selectedOrderType = type),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Metrics
          LayoutBuilder(
            builder: (context, constraints) => GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: constraints.maxWidth >= 750 ? 3 : 1,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: constraints.maxWidth >= 750 ? 2.5 : 3.8,
              children: [
                _ReportMetric(
                  label: 'Total Penjualan (${filteredList.length} trx)',
                  value: rupiah(revenue),
                  icon: Icons.payments_rounded,
                ),
                _ReportMetric(
                  label: 'Total Produk Terjual',
                  value: '$items item',
                  icon: Icons.shopping_bag_rounded,
                ),
                _ReportMetric(
                  label: 'Rata-rata Transaksi',
                  value: rupiah(average),
                  icon: Icons.analytics_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan Data Terfilter',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  _DataLine(
                    label: 'Total transaksi tercatat',
                    value: '${filteredList.length} transaksi',
                  ),
                  _DataLine(
                    label: 'Total produk terjual',
                    value: '$items item',
                  ),
                  _DataLine(
                    label: 'Pembayaran tunai',
                    value:
                        '${filteredList.where((item) => item.paymentMethod == 'Tunai').length} transaksi (${rupiah(filteredList.where((item) => item.paymentMethod == 'Tunai').fold(0, (s, t) => s + t.total))})',
                  ),
                  _DataLine(
                    label: 'Pembayaran non-tunai',
                    value:
                        '${filteredList.where((item) => item.paymentMethod != 'Tunai').length} transaksi (${rupiah(filteredList.where((item) => item.paymentMethod != 'Tunai').fold(0, (s, t) => s + t.total))})',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),
          Text(
            'Daftar Transaksi (${filteredList.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),

          if (filteredList.isEmpty)
            const _EmptyReport(
              message:
                  'Tidak ada data transaksi yang sesuai dengan filter di atas.',
            )
          else
            ...filteredList.map(
              (transaction) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE7F5ED),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: Color(0xFF316B58),
                    ),
                  ),
                  title: Text(
                    '${transaction.orderLabel} • ${transaction.id}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    '${_date(transaction.createdAt)} • ${transaction.paymentMethod} • Kasir: ${transaction.cashier}\nItem: ${transaction.items.map((i) => '${i.productName} (${i.quantity}x)').join(', ')}',
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    rupiah(transaction.total),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: Color(0xFF316B58),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}

class _ReportMetric extends StatelessWidget {
  const _ReportMetric({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFE7F5ED),
            child: Icon(icon, color: const Color(0xFF316B58), size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
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
        ],
      ),
    ),
  );
}

class _DataLine extends StatelessWidget {
  const _DataLine({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: Colors.black87)),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );
}

class _EmptyReport extends StatelessWidget {
  const _EmptyReport({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.inbox_rounded, size: 44, color: Colors.black26),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    ),
  );
}

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
