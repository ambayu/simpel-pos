import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models.dart';
import '../pos_store.dart';
import '../services/report_exporter.dart';
import '../theme/app_theme.dart';

enum DateRangePreset {
  all('Semua Waktu'),
  today('Hari Ini'),
  last7Days('7 Hari Terakhir'),
  thisMonth('Bulan Ini'),
  thisYear('Tahun Ini'),
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
  DateRangePreset selectedPreset = DateRangePreset.all;
  DateTimeRange? customDateRange;

  bool _passesDateFilter(SaleRecord t) {
    final now = DateTime.now();
    switch (selectedPreset) {
      case DateRangePreset.today:
        return t.createdAt.year == now.year &&
            t.createdAt.month == now.month &&
            t.createdAt.day == now.day;
      case DateRangePreset.last7Days:
        final start = DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 6));
        return !t.createdAt.isBefore(start);
      case DateRangePreset.thisMonth:
        return t.createdAt.year == now.year &&
            t.createdAt.month == now.month;
      case DateRangePreset.thisYear:
        return t.createdAt.year == now.year;
      case DateRangePreset.custom:
        if (customDateRange == null) return true;
        final start = DateTime(
          customDateRange!.start.year,
          customDateRange!.start.month,
          customDateRange!.start.day,
        );
        final end = DateTime(
          customDateRange!.end.year,
          customDateRange!.end.month,
          customDateRange!.end.day,
          23, 59, 59,
        );
        return !t.createdAt.isBefore(start) && !t.createdAt.isAfter(end);
      case DateRangePreset.all:
        return true;
    }
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: customDateRange,
      locale: const Locale('id'),
    );
    if (picked != null) {
      setState(() {
        customDateRange = picked;
        selectedPreset = DateRangePreset.custom;
      });
    }
  }

  bool get _hasActiveFilter =>
      selectedPreset != DateRangePreset.all ||
      selectedPayment != 'Semua' ||
      searchQuery.isNotEmpty;

  void _resetFilters() {
    setState(() {
      searchQuery = '';
      selectedPayment = 'Semua';
      selectedPreset = DateRangePreset.all;
      customDateRange = null;
    });
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.store,
    builder: (context, _) {
      final filteredTransactions = widget.store.transactions.where((t) {
        if (selectedPayment != 'Semua' &&
            t.paymentMethod != selectedPayment) {
          return false;
        }
        if (!_passesDateFilter(t)) return false;
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
        padding: EdgeInsets.zero,
        children: [
          HeaderCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Riwayat Transaksi',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Riwayat pembayaran yang sudah diselesaikan',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_hasActiveFilter)
                      TextButton.icon(
                        onPressed: _resetFilters,
                        icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                        label: const Text('Reset'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // Search bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari no. transaksi, meja, atau kasir...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () =>
                                setState(() => searchQuery = ''),
                          )
                        : null,
                  ),
                  onChanged: (v) => setState(() => searchQuery = v),
                ),
                const SizedBox(height: 12),

                // Filter rentang tanggal
                const Text(
                  'Periode',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...DateRangePreset.values.map((preset) {
                        if (preset == DateRangePreset.custom) {
                          final customLabel = customDateRange == null
                              ? 'Kustom...'
                              : '${customDateRange!.start.day}/${customDateRange!.start.month} - ${customDateRange!.end.day}/${customDateRange!.end.month}';
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ActionChip(
                              avatar: const Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                              ),
                              label: Text(customLabel),
                              backgroundColor:
                                  selectedPreset == DateRangePreset.custom
                                      ? AppColors.primarySoft
                                      : null,
                              side: BorderSide(
                                color: selectedPreset == DateRangePreset.custom
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                              onPressed: _pickCustomRange,
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(preset.label),
                            selected: selectedPreset == preset,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  selectedPreset = preset;
                                  if (preset != DateRangePreset.custom) {
                                    customDateRange = null;
                                  }
                                });
                              }
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Filter metode pembayaran
                const Text(
                  'Metode Bayar',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
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

                // Jumlah hasil
                const SizedBox(height: 10),
                Text(
                  '${filteredTransactions.length} transaksi ditemukan',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
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
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          transaction.orderLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          '${transaction.id} • ${_date(transaction.createdAt)}\n${transaction.itemCount} item • ${transaction.paymentMethod} (${transaction.cashier})',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        isThreeLine: true,
                        trailing: Text(
                          rupiah(transaction.total),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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

class _ReportPageState extends State<ReportPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  late final AnimationController _fabAnimController;
  late final Animation<double> _fabExpandAnim;
  bool _isFabExpanded = false;

  bool exportingSummary = false;
  bool exportingDetail = false;
  bool exportingPdf = false;
  bool importingExcel = false;

  DateRangePreset selectedPreset = DateRangePreset.today;
  DateTimeRange? customDateRange;
  String selectedPayment = 'Semua';
  String selectedOrderType = 'Semua';
  String searchKeyword = '';

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fabExpandAnim = CurvedAnimation(
      parent: _fabAnimController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _fabAnimController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
      if (_isFabExpanded) {
        _fabAnimController.forward();
      } else {
        _fabAnimController.reverse();
      }
    });
  }

  void _closeFab() {
    if (_isFabExpanded) {
      setState(() {
        _isFabExpanded = false;
        _fabAnimController.reverse();
      });
    }
  }

  void _showFilterBottomSheet() {
    _closeFab();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FilterBottomSheet(
        selectedPreset: selectedPreset,
        customDateRange: customDateRange,
        selectedPayment: selectedPayment,
        selectedOrderType: selectedOrderType,
        searchKeyword: searchKeyword,
        hasActiveFilter: _hasActiveFilter,
        onPresetChanged: (preset) => setState(() => selectedPreset = preset),
        onCustomDatePick: () {
          Navigator.pop(ctx);
          _pickCustomDateRange();
        },
        onPaymentChanged: (v) => setState(() => selectedPayment = v),
        onOrderTypeChanged: (v) => setState(() => selectedOrderType = v),
        onKeywordChanged: (v) => setState(() => searchKeyword = v),
        onReset: () {
          _resetFilter();
          Navigator.pop(ctx);
        },
      ),
    );
  }

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
        case DateRangePreset.thisYear:
          if (t.createdAt.year != now.year) return false;
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

  static String _formatPillDate(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String get _currentDateRangeLabel {
    final now = DateTime.now();
    switch (selectedPreset) {
      case DateRangePreset.today:
        return '${_formatPillDate(now)} - ${_formatPillDate(now)}';
      case DateRangePreset.last7Days:
        final start = now.subtract(const Duration(days: 6));
        return '${_formatPillDate(start)} - ${_formatPillDate(now)}';
      case DateRangePreset.thisMonth:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 0);
        return '${_formatPillDate(start)} - ${_formatPillDate(end)}';
      case DateRangePreset.thisYear:
        final start = DateTime(now.year, 1, 1);
        final end = DateTime(now.year, 12, 31);
        return '${_formatPillDate(start)} - ${_formatPillDate(end)}';
      case DateRangePreset.custom:
        if (customDateRange != null) {
          return '${_formatPillDate(customDateRange!.start)} - ${_formatPillDate(customDateRange!.end)}';
        }
        return 'Pilih Tanggal';
      case DateRangePreset.all:
        return 'Semua Waktu';
    }
  }

  void _showDateFilterSelector() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Rentang Tanggal Laporan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('Hari Ini'),
                  trailing: selectedPreset == DateRangePreset.today
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() {
                      selectedPreset = DateRangePreset.today;
                      customDateRange = null;
                    });
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  title: const Text('7 Hari Terakhir'),
                  trailing: selectedPreset == DateRangePreset.last7Days
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() {
                      selectedPreset = DateRangePreset.last7Days;
                      customDateRange = null;
                    });
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  title: const Text('Bulan Ini'),
                  trailing: selectedPreset == DateRangePreset.thisMonth
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() {
                      selectedPreset = DateRangePreset.thisMonth;
                      customDateRange = null;
                    });
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  title: const Text('Tahun Ini'),
                  trailing: selectedPreset == DateRangePreset.thisYear
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() {
                      selectedPreset = DateRangePreset.thisYear;
                      customDateRange = null;
                    });
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  title: const Text('Semua Waktu'),
                  trailing: selectedPreset == DateRangePreset.all
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() {
                      selectedPreset = DateRangePreset.all;
                      customDateRange = null;
                    });
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  title: const Text('Pilih Tanggal Kustom...'),
                  trailing: selectedPreset == DateRangePreset.custom
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickCustomDateRange();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
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
      selectedPreset = DateRangePreset.today;
      customDateRange = null;
      selectedPayment = 'Semua';
      selectedOrderType = 'Semua';
      searchKeyword = '';
    });
  }

  bool get _hasActiveFilter =>
      selectedPreset != DateRangePreset.today ||
      selectedPayment != 'Semua' ||
      selectedOrderType != 'Semua' ||
      searchKeyword.isNotEmpty;

  String? _buildFilterSuffix() {
    final parts = <String>[];
    if (selectedPayment != 'Semua') {
      parts.add(selectedPayment.toLowerCase());
    }
    if (selectedOrderType != 'Semua') {
      parts.add(selectedOrderType.toLowerCase().replaceAll(' ', '_'));
    }
    return parts.isEmpty ? null : parts.join('_');
  }

  ({DateTime start, DateTime end}) _getActiveDateRange(
    List<SaleRecord> transactions,
  ) {
    final now = DateTime.now();
    switch (selectedPreset) {
      case DateRangePreset.today:
        final today = DateTime(now.year, now.month, now.day);
        return (start: today, end: today);
      case DateRangePreset.last7Days:
        final start = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 6));
        final end = DateTime(now.year, now.month, now.day);
        return (start: start, end: end);
      case DateRangePreset.thisMonth:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 0);
        return (start: start, end: end);
      case DateRangePreset.thisYear:
        final start = DateTime(now.year, 1, 1);
        final end = DateTime(now.year, 12, 31);
        return (start: start, end: end);
      case DateRangePreset.custom:
        if (customDateRange != null) {
          return (start: customDateRange!.start, end: customDateRange!.end);
        }
        final today = DateTime(now.year, now.month, now.day);
        return (start: today, end: today);
      case DateRangePreset.all:
        if (transactions.isNotEmpty) {
          final sorted = transactions.map((t) => t.createdAt).toList()..sort();
          return (start: sorted.first, end: sorted.last);
        }
        final today = DateTime(now.year, now.month, now.day);
        return (start: today, end: today);
    }
  }

  Future<void> _exportSummary(List<SaleRecord> transactions) async {
    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data transaksi untuk diekspor')),
      );
      return;
    }
    setState(() => exportingSummary = true);
    try {
      final range = _getActiveDateRange(transactions);
      final path = await ReportExporter.exportSummary(
        transactions,
        startDate: range.start,
        endDate: range.end,
        suffix: _buildFilterSuffix(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Excel Rekap tersimpan di: $path'),
          backgroundColor: AppColors.primary,
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
        const SnackBar(content: Text('Tidak ada data transaksi untuk diekspor')),
      );
      return;
    }
    setState(() => exportingDetail = true);
    try {
      final range = _getActiveDateRange(transactions);
      final path = await ReportExporter.exportDetail(
        transactions,
        startDate: range.start,
        endDate: range.end,
        suffix: _buildFilterSuffix(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Excel Detail tersimpan di: $path'),
          backgroundColor: AppColors.primary,
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

  Future<void> _printPdf(List<SaleRecord> transactions) async {
    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data transaksi untuk dicetak')),
      );
      return;
    }
    setState(() => exportingPdf = true);
    try {
      final range = _getActiveDateRange(transactions);
      await ReportExporter.printPdf(
        transactions,
        startDate: range.start,
        endDate: range.end,
        suffix: _buildFilterSuffix(),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka cetak PDF: $error')),
      );
    } finally {
      if (mounted) setState(() => exportingPdf = false);
    }
  }

  Future<void> _importExcel() async {
    setState(() => importingExcel = true);
    try {
      final records = await ReportExporter.pickAndImportTransactions();
      if (!mounted) return;
      if (records.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada data yang diimpor')),
        );
        return;
      }
      final count = widget.store.importTransactions(records);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$count transaksi berhasil diimpor'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengimpor Excel: $error')),
      );
    } finally {
      if (mounted) setState(() => importingExcel = false);
    }
  }

  Widget _buildCollapsibleFab(List<SaleRecord> filteredList, bool isProcessing) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Sub-menu collapses (Cetak PDF, Rekap Excel, Detail Excel, Filter)
        if (_isFabExpanded || _fabAnimController.value > 0)
          SizeTransition(
            sizeFactor: _fabExpandAnim,
            axisAlignment: -1.0,
            child: FadeTransition(
              opacity: _fabExpandAnim,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Opsi 1: Filter Cepat
                      _SpeedDialItem(
                        label: 'Filter',
                        icon: Icons.tune_rounded,
                        color: AppColors.accentGold,
                        onTap: _showFilterBottomSheet,
                      ),
                      const SizedBox(height: 8),

                      // Opsi 2: Cetak PDF
                      _SpeedDialItem(
                        label: 'Cetak PDF',
                        icon: Icons.picture_as_pdf_rounded,
                        color: AppColors.primary,
                        onTap: () {
                          _closeFab();
                          _printPdf(filteredList);
                        },
                      ),
                      const SizedBox(height: 8),

                      // Opsi 3: Download Rekap (tahan 4 detik = import Excel)
                      _SpeedDialItemWithHold(
                        label: 'Download Rekap',
                        icon: Icons.summarize_rounded,
                        color: const Color(0xFF1E7E34),
                        onTap: () {
                          _closeFab();
                          _exportSummary(filteredList);
                        },
                        onHold: () {
                          _closeFab();
                          _importExcel();
                        },
                        holdDuration: const Duration(seconds: 4),
                      ),
                      const SizedBox(height: 8),

                      // Opsi 4: Download Detail
                      _SpeedDialItem(
                        label: 'Download Detail',
                        icon: Icons.list_alt_rounded,
                        color: const Color(0xFF0069D9),
                        onTap: () {
                          _closeFab();
                          _exportDetail(filteredList);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        // FAB Utama Berbentuk Logo / Icon Bulat Elegan
        Tooltip(
          message: _isFabExpanded ? 'Tutup Aksi' : 'Menu Laporan & Cetak',
          child: Material(
            key: const ValueKey('collapsible_fab_button'),
            elevation: 5,
            shadowColor: AppColors.primary.withValues(alpha: 0.4),
            shape: const CircleBorder(),
            color: AppColors.primary,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: isProcessing ? null : _toggleFab,
              child: SizedBox(
                width: 56,
                height: 56,
                child: Center(
                  child: isProcessing
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : AnimatedRotation(
                          turns: _isFabExpanded ? 0.25 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            _isFabExpanded
                                ? Icons.close_rounded
                                : Icons.receipt_long_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Map<int, double> _calculateHourlySales(List<SaleRecord> list) {
    final actual = <int, double>{};
    for (final t in list) {
      final hour = t.createdAt.hour;
      actual[hour] = (actual[hour] ?? 0) + t.total;
    }
    return actual;
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.store,
    builder: (context, _) {
      final filteredList = _filterTransactions(widget.store.transactions);

      final int revenue = filteredList.fold<int>(0, (sum, t) => sum + t.total);
      final int transactionCount = filteredList.length;

      final int average = transactionCount == 0
          ? 0
          : (revenue / transactionCount).round();

      final int profit = (revenue * 0.4).round();

      final int totalItems = filteredList.fold<int>(
        0,
        (sum, t) => sum + t.itemCount,
      );

      final hourlySales = _calculateHourlySales(filteredList);
      final maxVal = hourlySales.values.fold<double>(
        0,
        (max, v) => v > max ? v : max,
      );
      final double chartMax = maxVal > 1000000 ? maxVal * 1.15 : 1000000;

      final isProcessing = exportingSummary ||
          exportingDetail ||
          exportingPdf;

      return Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: _buildCollapsibleFab(filteredList, isProcessing),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 90),
        children: [
          HeaderCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Text(
                  'Laporan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: _showDateFilterSelector,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                _currentDateRangeLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2x2 Metric Cards Grid (Matching mockup screen 10)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 600;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isWide ? 4 : 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: isWide ? 2.2 : 1.62,
                      children: [
                        _KpiCard(
                          title: 'Total Omzet',
                          value: rupiah(revenue),
                          delta: transactionCount > 0 ? '+12%' : '-',
                          showArrow: transactionCount > 0,
                        ),
                        _KpiCard(
                          title: 'Total Transaksi',
                          value: '$transactionCount',
                          delta: transactionCount > 0 ? '+9%' : '-',
                          showArrow: transactionCount > 0,
                        ),
                        _KpiCard(
                          title: 'Rata-rata Transaksi',
                          value: rupiah(average),
                          delta: transactionCount > 0 ? '+5%' : '-',
                          showArrow: transactionCount > 0,
                        ),
                        _KpiCard(
                          title: 'Estimasi Keuntungan',
                          value: rupiah(profit),
                          delta: transactionCount > 0 ? '+15%' : '-',
                          showArrow: transactionCount > 0,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),

          // Grafik Penjualan Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Grafik Penjualan',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SalesBarChart(hourlySales: hourlySales, maxAmount: chartMax),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Ringkasan Data Terfilter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ringkasan Data Terfilter',
                      style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _DataLine(
                    label: 'Total transaksi tercatat',
                    value: '${filteredList.length} transaksi',
                  ),
                  _DataLine(
                    label: 'Total produk terjual',
                    value: '$totalItems item',
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
          ),
          const SizedBox(height: 24),
        ],
        ),
      );
    },
  );
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.delta,
    this.showArrow = true,
  });

  final String title;
  final String value;
  final String delta;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.5,
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
                fontSize: 16.5,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              if (showArrow) ...[
                const Icon(
                  Icons.arrow_upward_rounded,
                  size: 12,
                  color: AppColors.success,
                ),
                const SizedBox(width: 2),
              ],
              Text(
                delta,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: showArrow ? AppColors.success : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SalesBarChart extends StatelessWidget {
  const SalesBarChart({
    super.key,
    required this.hourlySales,
    this.maxAmount = 1000000,
  });

  final Map<int, double> hourlySales;
  final double maxAmount;

  static String _formatYAxis(double val) {
    if (val >= 1000000) {
      final m = val / 1000000;
      return m % 1 == 0 ? '${m.toInt()}M' : '${m.toStringAsFixed(1)}M';
    }
    if (val >= 1000) {
      return '${(val / 1000).round()}K';
    }
    return '${val.round()}';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Y-Axis Labels
          SizedBox(
            width: 36,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatYAxis(maxAmount),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _formatYAxis(maxAmount * 0.75),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _formatYAxis(maxAmount * 0.50),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _formatYAxis(maxAmount * 0.25),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  '0',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
          const SizedBox(width: 4),
          // Chart Canvas
          Expanded(
            child: CustomPaint(
              painter: _SalesChartPainter(
                hourlySales: hourlySales,
                maxAmount: maxAmount,
                barColor: AppColors.primary,
                gridColor: AppColors.border,
                labelColor: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesChartPainter extends CustomPainter {
  _SalesChartPainter({
    required this.hourlySales,
    required this.maxAmount,
    required this.barColor,
    required this.gridColor,
    required this.labelColor,
  });

  final Map<int, double> hourlySales;
  final double maxAmount;
  final Color barColor;
  final Color gridColor;
  final Color labelColor;

  static const hours = [
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
  ];

  static const labeledHours = {
    8: '08',
    10: '10',
    12: '12',
    14: '14',
    16: '16',
    18: '18',
    20: '20',
    22: '22',
  };

  @override
  void paint(Canvas canvas, Size size) {
    const bottomLabelHeight = 20.0;
    final chartHeight = size.height - bottomLabelHeight;
    final chartWidth = size.width;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    // 5 horizontal grid lines
    for (int i = 0; i < 5; i++) {
      final y = chartHeight * (i / 4.0);
      canvas.drawLine(Offset(0, y), Offset(chartWidth, y), gridPaint);
    }

    // Draw bars
    final totalSlots = hours.length;
    final slotWidth = chartWidth / totalSlots;
    final barWidth = (slotWidth * 0.65).clamp(4.0, 14.0);

    final barPaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < totalSlots; i++) {
      final hour = hours[i];
      final amount = hourlySales[hour] ?? 0.0;
      final ratio = (amount / maxAmount).clamp(0.0, 1.0);
      final barH = ratio * chartHeight;

      final xCenter = (i + 0.5) * slotWidth;
      final left = xCenter - barWidth / 2;
      final top = chartHeight - barH;
      final right = left + barWidth;
      final bottom = chartHeight;

      if (barH > 0) {
        final rrect = RRect.fromRectAndCorners(
          Rect.fromLTRB(left, top, right, bottom),
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
        );
        canvas.drawRRect(rrect, barPaint);
      }

      // X-Axis labels
      if (labeledHours.containsKey(hour)) {
        textPainter.text = TextSpan(
          text: labeledHours[hour],
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: labelColor,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(xCenter - textPainter.width / 2, chartHeight + 4),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SalesChartPainter oldDelegate) {
    return oldDelegate.hourlySales != hourlySales ||
        oldDelegate.maxAmount != maxAmount ||
        oldDelegate.barColor != barColor;
  }
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
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  );
}

class _SpeedDialItem extends StatelessWidget {
  const _SpeedDialItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label pill (tulisan) di kiri dengan background merah & tulisan putih
        Material(
          elevation: 3,
          shadowColor: Colors.red.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(8),
          color: Colors.red,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Mini FAB bulat icon di kanan (sejajar tombol FAB utama)
        Material(
          elevation: 3,
          shadowColor: color.withValues(alpha: 0.3),
          shape: const CircleBorder(),
          color: color,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 42,
              height: 42,
              child: Center(
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Varian SpeedDialItem yang mendukung long press tersembunyi.
/// Tap biasa → [onTap]. Tahan [holdDuration] → [onHold].
class _SpeedDialItemWithHold extends StatefulWidget {
  const _SpeedDialItemWithHold({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.onHold,
    this.holdDuration = const Duration(seconds: 4),
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onHold;
  final Duration holdDuration;

  @override
  State<_SpeedDialItemWithHold> createState() => _SpeedDialItemWithHoldState();
}

class _SpeedDialItemWithHoldState extends State<_SpeedDialItemWithHold> {
  DateTime? _pressStart;
  Timer? _holdTimer;

  void _onTapDown(TapDownDetails _) {
    _pressStart = DateTime.now();
    _holdTimer?.cancel();
    _holdTimer = Timer(widget.holdDuration, () {
      HapticFeedback.mediumImpact();
    });
  }

  void _onTapUp(TapUpDetails _) {
    _holdTimer?.cancel();
    if (_pressStart == null) return;
    final elapsed = DateTime.now().difference(_pressStart!);
    _pressStart = null;

    if (elapsed >= widget.holdDuration) {
      widget.onHold();
    } else {
      widget.onTap();
    }
  }

  void _onTapCancel() {
    _holdTimer?.cancel();
    _pressStart = null;
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          elevation: 3,
          shadowColor: Colors.red.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(8),
          color: Colors.red,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Material(
          elevation: 3,
          shadowColor: widget.color.withValues(alpha: 0.3),
          shape: const CircleBorder(),
          color: widget.color,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: SizedBox(
              width: 42,
              height: 42,
              child: Center(
                child: Icon(widget.icon, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  const _FilterBottomSheet({
    required this.selectedPreset,
    required this.customDateRange,
    required this.selectedPayment,
    required this.selectedOrderType,
    required this.searchKeyword,
    required this.hasActiveFilter,
    required this.onPresetChanged,
    required this.onCustomDatePick,
    required this.onPaymentChanged,
    required this.onOrderTypeChanged,
    required this.onKeywordChanged,
    required this.onReset,
  });

  final DateRangePreset selectedPreset;
  final DateTimeRange? customDateRange;
  final String selectedPayment;
  final String selectedOrderType;
  final String searchKeyword;
  final bool hasActiveFilter;
  final ValueChanged<DateRangePreset> onPresetChanged;
  final VoidCallback onCustomDatePick;
  final ValueChanged<String> onPaymentChanged;
  final ValueChanged<String> onOrderTypeChanged;
  final ValueChanged<String> onKeywordChanged;
  final VoidCallback onReset;

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late DateRangePreset _preset;
  late String _payment;
  late String _orderType;
  late String _keyword;

  @override
  void initState() {
    super.initState();
    _preset = widget.selectedPreset;
    _payment = widget.selectedPayment;
    _orderType = widget.selectedOrderType;
    _keyword = widget.searchKeyword;
  }

  void _applyAndClose() {
    widget.onPresetChanged(_preset);
    widget.onPaymentChanged(_payment);
    widget.onOrderTypeChanged(_orderType);
    widget.onKeywordChanged(_keyword);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Filter Laporan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (widget.hasActiveFilter)
                TextButton.icon(
                  onPressed: widget.onReset,
                  icon: const Icon(Icons.restart_alt_rounded, size: 15),
                  label: const Text('Reset', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),

          // Search
          TextField(
            controller: TextEditingController(text: _keyword)
              ..selection = TextSelection.collapsed(offset: _keyword.length),
            decoration: InputDecoration(
              hintText: 'Cari transaksi, produk, meja, kasir...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _keyword.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () => setState(() => _keyword = ''),
                    )
                  : null,
            ),
            onChanged: (v) => setState(() => _keyword = v),
          ),
          const SizedBox(height: 14),

          // Periode chips
          const Text(
            'Periode',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: DateRangePreset.values.map((preset) {
              if (preset == DateRangePreset.custom) {
                final customLabel = widget.customDateRange == null
                    ? 'Kustom...'
                    : '${widget.customDateRange!.start.day}/${widget.customDateRange!.start.month} - ${widget.customDateRange!.end.day}/${widget.customDateRange!.end.month}';
                return ActionChip(
                  avatar: const Icon(Icons.calendar_today_rounded, size: 14),
                  label: Text(customLabel),
                  backgroundColor: _preset == DateRangePreset.custom
                      ? AppColors.primarySoft
                      : null,
                  side: BorderSide(
                    color: _preset == DateRangePreset.custom
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                  onPressed: widget.onCustomDatePick,
                );
              }
              return ChoiceChip(
                label: Text(preset.label),
                selected: _preset == preset,
                onSelected: (selected) {
                  if (selected) setState(() => _preset = preset);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Metode bayar
          const Text(
            'Metode Bayar',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: ['Semua', 'Tunai', 'QRIS', 'Kartu', 'E-Wallet']
                .map(
                  (method) => ChoiceChip(
                    label: Text(method),
                    selected: _payment == method,
                    onSelected: (_) => setState(() => _payment = method),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 14),

          // Tipe pesanan
          const Text(
            'Tipe Pesanan',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: ['Semua', 'Meja', 'Take Away']
                .map(
                  (type) => ChoiceChip(
                    label: Text(type),
                    selected: _orderType == type,
                    onSelected: (_) => setState(() => _orderType = type),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),

          // Tombol Terapkan
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _applyAndClose,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Terapkan Filter'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
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
            const Icon(
              Icons.inbox_rounded,
              size: 40,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

class _HiddenActionExportButton extends StatefulWidget {
  const _HiddenActionExportButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.isLoading,
    required this.onNormalTap,
    required this.onHold3SecUpload,
    required this.onHold5SecTemplate,
  });

  final String label;
  final IconData icon;
  final bool isPrimary;
  final bool isLoading;
  final VoidCallback onNormalTap;
  final VoidCallback onHold3SecUpload;
  final VoidCallback onHold5SecTemplate;

  @override
  State<_HiddenActionExportButton> createState() =>
      _HiddenActionExportButtonState();
}

class _HiddenActionExportButtonState extends State<_HiddenActionExportButton> {
  DateTime? _pressStart;
  Timer? _timer3s;
  Timer? _timer5s;

  void _onTapDown(TapDownDetails _) {
    if (widget.isLoading) return;
    _pressStart = DateTime.now();
    _timer3s?.cancel();
    _timer5s?.cancel();

    _timer3s = Timer(const Duration(seconds: 3), () {
      HapticFeedback.lightImpact();
    });

    _timer5s = Timer(const Duration(seconds: 5), () {
      HapticFeedback.mediumImpact();
    });
  }

  void _onTapUp(TapUpDetails _) {
    _timer3s?.cancel();
    _timer5s?.cancel();
    if (widget.isLoading || _pressStart == null) return;

    final elapsed = DateTime.now().difference(_pressStart!);
    _pressStart = null;

    if (elapsed >= const Duration(seconds: 5)) {
      widget.onHold5SecTemplate();
    } else if (elapsed >= const Duration(seconds: 3)) {
      widget.onHold3SecUpload();
    } else {
      widget.onNormalTap();
    }
  }

  void _onTapCancel() {
    _timer3s?.cancel();
    _timer5s?.cancel();
    _pressStart = null;
  }

  @override
  void dispose() {
    _timer3s?.cancel();
    _timer5s?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isPrimary
        ? AppColors.primary
        : Theme.of(context).colorScheme.secondaryContainer;
    final fgColor = widget.isPrimary
        ? Colors.white
        : Theme.of(context).colorScheme.onSecondaryContainer;

    return Material(
      color: widget.isLoading ? bgColor.withValues(alpha: 0.7) : bgColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTapDown: widget.isLoading ? null : _onTapDown,
        onTapUp: widget.isLoading ? null : _onTapUp,
        onTapCancel: widget.isLoading ? null : _onTapCancel,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading)
                SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: fgColor,
                  ),
                )
              else
                Icon(widget.icon, size: 18, color: fgColor),
              const SizedBox(width: 8),
              Text(
                widget.isLoading ? 'Menyimpan...' : widget.label,
                style: TextStyle(
                  color: fgColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
