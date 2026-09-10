import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../models.dart';

class ReportExporter {
  static String formatTimestampForFileName(DateTime dateTime) {
    String two(int n) => n.toString().padLeft(2, '0');
    final y = dateTime.year.toString();
    final m = two(dateTime.month);
    final d = two(dateTime.day);
    final h = two(dateTime.hour);
    final min = two(dateTime.minute);
    final s = two(dateTime.second);
    return '$y$m${d}_$h$min$s';
  }

  static String generateSummaryFileName({DateTime? now, String? suffix}) {
    final timestamp = formatTimestampForFileName(now ?? DateTime.now());
    if (suffix != null && suffix.trim().isNotEmpty) {
      return 'laporan_rekap_penjualan_${suffix.trim()}_$timestamp.xlsx';
    }
    return 'laporan_rekap_penjualan_$timestamp.xlsx';
  }

  static String generateDetailFileName({DateTime? now, String? suffix}) {
    final timestamp = formatTimestampForFileName(now ?? DateTime.now());
    if (suffix != null && suffix.trim().isNotEmpty) {
      return 'laporan_detail_penjualan_${suffix.trim()}_$timestamp.xlsx';
    }
    return 'laporan_detail_penjualan_$timestamp.xlsx';
  }

  static String generateTemplateFileName({DateTime? now}) {
    final timestamp = formatTimestampForFileName(now ?? DateTime.now());
    return 'template_import_transaksi_$timestamp.xlsx';
  }

  /// Simpan bytes dan buka file secara cross-platform (Web, Desktop, Mobile)
  static Future<String> saveAndOpenFile({
    required Uint8List bytes,
    required String fileName,
    String dialogTitle = 'Simpan File Excel',
  }) async {
    if (kIsWeb) {
      final savedUri = await FilePicker.saveFile(
        dialogTitle: dialogTitle,
        fileName: fileName,
        bytes: bytes,
        mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
      return savedUri?.toString() ?? fileName;
    }

    if (Platform.isAndroid || Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}${Platform.pathSeparator}$fileName');
      await file.writeAsBytes(bytes, flush: true);
      await OpenFilex.open(file.path);
      return file.path;
    }

    // Windows / macOS / Linux Desktop
    try {
      final savedUri = await FilePicker.saveFile(
        dialogTitle: dialogTitle,
        fileName: fileName,
        bytes: bytes,
        mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );

      if (savedUri != null) {
        final filePath = savedUri.scheme == 'file' ? savedUri.toFilePath() : savedUri.path;
        if (filePath.isNotEmpty) {
          await OpenFilex.open(filePath);
          return filePath;
        }
      }
    } catch (_) {
      // Fallback jika dialog save picker tidak didukung lingkungan runtime
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}${Platform.pathSeparator}$fileName');
    await file.writeAsBytes(bytes, flush: true);
    await OpenFilex.open(file.path);
    return file.path;
  }

  /// Ekspor Rekap Ringkasan Transaksi Penjualan
  static Future<String> exportSummary(
    List<SaleRecord> transactions, {
    String? filterTitle,
    String? suffix,
  }) async {
    final workbook = Excel.createExcel();
    final sheet = workbook['Rekap Transaksi'];

    sheet.appendRow([
      TextCellValue('No.'),
      TextCellValue('No. Transaksi'),
      TextCellValue('Tanggal & Waktu'),
      TextCellValue('Pesanan / Meja'),
      TextCellValue('Kasir'),
      TextCellValue('Metode Bayar'),
      TextCellValue('Jumlah Item'),
      TextCellValue('Subtotal (Rp)'),
      TextCellValue('Diskon (Rp)'),
      TextCellValue('Pajak (Rp)'),
      TextCellValue('Total (Rp)'),
    ]);

    var totalItemCount = 0;
    var grandSubtotal = 0;
    var grandDiscount = 0;
    var grandTax = 0;
    var grandTotal = 0;

    for (var i = 0; i < transactions.length; i++) {
      final t = transactions[i];
      totalItemCount += t.itemCount;
      grandSubtotal += t.subtotal;
      grandDiscount += t.discount;
      grandTax += t.tax;
      grandTotal += t.total;

      sheet.appendRow([
        IntCellValue(i + 1),
        TextCellValue(t.id),
        TextCellValue(_formatDateTime(t.createdAt)),
        TextCellValue(t.orderLabel),
        TextCellValue(t.cashier),
        TextCellValue(t.paymentMethod),
        IntCellValue(t.itemCount),
        IntCellValue(t.subtotal),
        IntCellValue(t.discount),
        IntCellValue(t.tax),
        IntCellValue(t.total),
      ]);
    }

    sheet.appendRow([
      TextCellValue(''),
      TextCellValue('TOTAL'),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      IntCellValue(totalItemCount),
      IntCellValue(grandSubtotal),
      IntCellValue(grandDiscount),
      IntCellValue(grandTax),
      IntCellValue(grandTotal),
    ]);

    // Sheet 2: Rekap Metode Pembayaran
    final methodSheet = workbook['Rekap Metode Pembayaran'];
    methodSheet.appendRow([
      TextCellValue('Metode Bayar'),
      TextCellValue('Jumlah Transaksi'),
      TextCellValue('Total Penjualan (Rp)'),
    ]);

    final methodMap = <String, ({int count, int amount})>{};
    for (final t in transactions) {
      final existing = methodMap[t.paymentMethod] ?? (count: 0, amount: 0);
      methodMap[t.paymentMethod] = (
        count: existing.count + 1,
        amount: existing.amount + t.total,
      );
    }

    for (final entry in methodMap.entries) {
      methodSheet.appendRow([
        TextCellValue(entry.key),
        IntCellValue(entry.value.count),
        IntCellValue(entry.value.amount),
      ]);
    }

    workbook.delete('Sheet1');
    final bytes = workbook.save();
    if (bytes == null) throw StateError('Gagal membuat file Excel Rekap');

    final fileName = generateSummaryFileName(suffix: suffix);
    return saveAndOpenFile(
      bytes: Uint8List.fromList(bytes),
      fileName: fileName,
      dialogTitle: 'Simpan Laporan Rekap Excel',
    );
  }

  /// Ekspor Detail Rincian Item Penjualan
  static Future<String> exportDetail(
    List<SaleRecord> transactions, {
    String? filterTitle,
    String? suffix,
  }) async {
    final workbook = Excel.createExcel();
    final sheet = workbook['Detail Penjualan Item'];

    sheet.appendRow([
      TextCellValue('No.'),
      TextCellValue('No. Transaksi'),
      TextCellValue('Tanggal & Waktu'),
      TextCellValue('Pesanan / Meja'),
      TextCellValue('Kasir'),
      TextCellValue('Metode Bayar'),
      TextCellValue('Nama Produk'),
      TextCellValue('Qty'),
      TextCellValue('Harga Satuan (Rp)'),
      TextCellValue('Total Item (Rp)'),
    ]);

    var rowNumber = 1;
    var totalQuantity = 0;
    var totalItemValue = 0;
    final productSummary = <String, ({int qty, int revenue})>{};

    for (final t in transactions) {
      for (final item in t.items) {
        totalQuantity += item.quantity;
        totalItemValue += item.total;

        final existing =
            productSummary[item.productName] ?? (qty: 0, revenue: 0);
        productSummary[item.productName] = (
          qty: existing.qty + item.quantity,
          revenue: existing.revenue + item.total,
        );

        sheet.appendRow([
          IntCellValue(rowNumber++),
          TextCellValue(t.id),
          TextCellValue(_formatDateTime(t.createdAt)),
          TextCellValue(t.orderLabel),
          TextCellValue(t.cashier),
          TextCellValue(t.paymentMethod),
          TextCellValue(item.productName),
          IntCellValue(item.quantity),
          IntCellValue(item.unitPrice),
          IntCellValue(item.total),
        ]);
      }
    }

    sheet.appendRow([
      TextCellValue(''),
      TextCellValue('TOTAL'),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      IntCellValue(totalQuantity),
      TextCellValue(''),
      IntCellValue(totalItemValue),
    ]);

    final productSheet = workbook['Rekap Penjualan Produk'];
    productSheet.appendRow([
      TextCellValue('Nama Produk'),
      TextCellValue('Total Terjual (Qty)'),
      TextCellValue('Total Pendapatan (Rp)'),
    ]);

    final sortedProducts = productSummary.entries.toList()
      ..sort((a, b) => b.value.qty.compareTo(a.value.qty));

    for (final entry in sortedProducts) {
      productSheet.appendRow([
        TextCellValue(entry.key),
        IntCellValue(entry.value.qty),
        IntCellValue(entry.value.revenue),
      ]);
    }

    workbook.delete('Sheet1');
    final bytes = workbook.save();
    if (bytes == null) throw StateError('Gagal membuat file Excel Detail');

    final fileName = generateDetailFileName(suffix: suffix);
    return saveAndOpenFile(
      bytes: Uint8List.fromList(bytes),
      fileName: fileName,
      dialogTitle: 'Simpan Laporan Detail Excel',
    );
  }

  /// Ekspor Template Excel untuk Import Transaksi
  static Future<String> exportTemplate() async {
    final workbook = Excel.createExcel();
    final sheet = workbook['Template Transaksi'];

    sheet.appendRow([
      TextCellValue('No. Transaksi'),
      TextCellValue('Tanggal & Waktu'),
      TextCellValue('Pesanan / Meja'),
      TextCellValue('Kasir'),
      TextCellValue('Metode Bayar'),
      TextCellValue('Nama Produk'),
      TextCellValue('Qty'),
      TextCellValue('Harga Satuan (Rp)'),
      TextCellValue('Diskon (Rp)'),
      TextCellValue('Pajak (Rp)'),
    ]);

    // Contoh data siap pakai
    sheet.appendRow([
      TextCellValue('TRX-1001'),
      TextCellValue('2026-09-10 12:30'),
      TextCellValue('Meja 01'),
      TextCellValue('Kasir'),
      TextCellValue('QRIS'),
      TextCellValue('Mie Goreng Special'),
      IntCellValue(2),
      IntCellValue(35000),
      IntCellValue(0),
      IntCellValue(7000),
    ]);
    sheet.appendRow([
      TextCellValue('TRX-1001'),
      TextCellValue('2026-09-10 12:30'),
      TextCellValue('Meja 01'),
      TextCellValue('Kasir'),
      TextCellValue('QRIS'),
      TextCellValue('Es Teh Tawar'),
      IntCellValue(2),
      IntCellValue(8000),
      IntCellValue(0),
      IntCellValue(0),
    ]);
    sheet.appendRow([
      TextCellValue('TRX-1002'),
      TextCellValue('2026-09-10 13:15'),
      TextCellValue('Take Away #01'),
      TextCellValue('Kasir'),
      TextCellValue('Tunai'),
      TextCellValue('Ayam Kuluyuk'),
      IntCellValue(1),
      IntCellValue(38000),
      IntCellValue(0),
      IntCellValue(3800),
    ]);
    sheet.appendRow([
      TextCellValue('TRX-1002'),
      TextCellValue('2026-09-10 13:15'),
      TextCellValue('Take Away #01'),
      TextCellValue('Kasir'),
      TextCellValue('Tunai'),
      TextCellValue('Es Jeruk Peras'),
      IntCellValue(1),
      IntCellValue(12000),
      IntCellValue(0),
      IntCellValue(0),
    ]);

    // Sheet Panduan
    final guideSheet = workbook['Panduan Pengisian'];
    guideSheet.appendRow([
      TextCellValue('PANDUAN PENGISIAN TEMPLATE IMPORT TRANSAKSI SIMPEL POS'),
    ]);
    guideSheet.appendRow([TextCellValue('')]);
    guideSheet.appendRow([
      TextCellValue('1. Jangan mengubah nama kolom pada baris pertama di Sheet "Template Transaksi".'),
    ]);
    guideSheet.appendRow([
      TextCellValue('2. Baris dengan No. Transaksi yang SAMA otomatis digabung menjadi satu transaksi dengan beberapa item pesanan.'),
    ]);
    guideSheet.appendRow([
      TextCellValue('3. Format Tanggal: YYYY-MM-DD HH:mm (contoh: 2026-09-10 14:30) atau DD/MM/YYYY HH:mm.'),
    ]);
    guideSheet.appendRow([
      TextCellValue('4. Kolom Diskon dan Pajak bersifat opsional. Jika kosong, pajak otomatis dihitung 10%.'),
    ]);
    guideSheet.appendRow([
      TextCellValue('5. Simpan file dalam format .xlsx lalu gunakan fitur Import Excel di aplikasi.'),
    ]);

    workbook.delete('Sheet1');
    final bytes = workbook.save();
    if (bytes == null) throw StateError('Gagal membuat template Excel');

    final fileName = generateTemplateFileName();
    return saveAndOpenFile(
      bytes: Uint8List.fromList(bytes),
      fileName: fileName,
      dialogTitle: 'Download Template Excel Import',
    );
  }

  /// Parsing file Excel (bytes) menjadi daftar SaleRecord
  static List<SaleRecord> parseTransactionsFromExcel(Uint8List bytes) {
    final excel = Excel.decodeBytes(bytes);
    if (excel.tables.isEmpty) return [];

    // Cari sheet yang relevan
    Sheet? sheet;
    for (final name in [
      'Template Transaksi',
      'Detail Penjualan Item',
      'Rekap Penjualan',
      'Rekap Transaksi',
    ]) {
      if (excel.tables.containsKey(name)) {
        sheet = excel.tables[name];
        break;
      }
    }
    sheet ??= excel.tables.values.firstWhere(
      (s) => s.rows.length > 1,
      orElse: () => excel.tables.values.first,
    );

    if (sheet.rows.length <= 1) return [];

    // Resolusi Header
    final headerRow = sheet.rows.first;
    final headers = headerRow.map((cell) => _normalizeHeader(_cellText(cell))).toList();

    final orderIdIdx = _findHeaderIndex(headers, [
      'notransaksi',
      'transaksi',
      'orderid',
      'kodestruk',
      'invoice',
      'id',
    ]);
    final dateIdx = _findHeaderIndex(headers, [
      'tanggalwaktu',
      'tanggal',
      'waktu',
      'date',
      'time',
    ]);
    final labelIdx = _findHeaderIndex(headers, [
      'pesananmeja',
      'meja',
      'pesanan',
      'orderlabel',
      'jenismesanan',
      'ordertype',
    ]);
    final cashierIdx = _findHeaderIndex(headers, [
      'kasir',
      'cashier',
      'staff',
      'petugas',
    ]);
    final paymentIdx = _findHeaderIndex(headers, [
      'metodebayar',
      'metode',
      'pembayaran',
      'paymentmethod',
      'payment',
    ]);
    final productIdx = _findHeaderIndex(headers, [
      'namaproduk',
      'produk',
      'item',
      'barang',
      'menu',
    ]);
    final qtyIdx = _findHeaderIndex(headers, ['qty', 'jumlah', 'kuantitas', 'banyak']);
    final priceIdx = _findHeaderIndex(headers, [
      'hargasatuan',
      'hargasatuanrp',
      'harga',
      'price',
      'tarif',
    ]);
    final discountIdx = _findHeaderIndex(headers, ['diskon', 'diskonrp', 'discount']);
    final taxIdx = _findHeaderIndex(headers, ['pajak', 'pajakrp', 'tax', 'ppn']);

    if (productIdx < 0 && orderIdIdx < 0) {
      throw const FormatException('Format Excel tidak sesuai: kolom Nama Produk atau No. Transaksi tidak ditemukan.');
    }

    final grouped = <String, _GroupedTransaction>{};
    var autoIndex = 1;

    for (final row in sheet.rows.skip(1)) {
      final productName = productIdx >= 0 && productIdx < row.length
          ? _cellText(row[productIdx]).trim()
          : '';

      // Abaikan baris kosong atau baris rekapitulasi TOTAL
      if (productName.isEmpty ||
          productName.toUpperCase() == 'TOTAL' ||
          productName.startsWith('---')) {
        continue;
      }

      final rawOrderId = orderIdIdx >= 0 && orderIdIdx < row.length
          ? _cellText(row[orderIdIdx]).trim()
          : '';
      final rawDate = dateIdx >= 0 && dateIdx < row.length ? row[dateIdx] : null;
      final parsedDate = _parseDate(rawDate) ?? DateTime.now();

      final rawLabel = labelIdx >= 0 && labelIdx < row.length
          ? _cellText(row[labelIdx]).trim()
          : '';
      final orderLabel = rawLabel.isNotEmpty ? rawLabel : 'Pesanan #$autoIndex';

      final rawCashier = cashierIdx >= 0 && cashierIdx < row.length
          ? _cellText(row[cashierIdx]).trim()
          : '';
      final cashier = rawCashier.isNotEmpty ? rawCashier : 'Kasir';

      final rawPayment = paymentIdx >= 0 && paymentIdx < row.length
          ? _cellText(row[paymentIdx]).trim()
          : '';
      final payment = rawPayment.isNotEmpty ? rawPayment : 'Tunai';

      final qty = qtyIdx >= 0 && qtyIdx < row.length
          ? _parseNumber(row[qtyIdx]?.value).clamp(1, 99999)
          : 1;

      final price = priceIdx >= 0 && priceIdx < row.length
          ? _parseNumber(row[priceIdx]?.value)
          : 0;

      final discount = discountIdx >= 0 && discountIdx < row.length
          ? _parseNumber(row[discountIdx]?.value)
          : 0;

      final tax = taxIdx >= 0 && taxIdx < row.length
          ? _parseNumber(row[taxIdx]?.value)
          : 0;

      final key = rawOrderId.isNotEmpty ? rawOrderId : '$orderLabel-${parsedDate.millisecondsSinceEpoch}';

      if (!grouped.containsKey(key)) {
        grouped[key] = _GroupedTransaction(
          id: rawOrderId.isNotEmpty ? rawOrderId : 'TRX-IMP-${DateTime.now().millisecondsSinceEpoch}-${autoIndex++}',
          orderLabel: orderLabel,
          cashier: cashier,
          paymentMethod: payment,
          createdAt: parsedDate,
          discount: discount,
          tax: tax,
          items: [],
        );
      }

      grouped[key]!.items.add(
        SaleItemRecord(
          productName: productName,
          quantity: qty,
          unitPrice: price,
        ),
      );
    }

    return grouped.values.map((group) {
      final subtotal = group.items.fold(0, (sum, it) => sum + it.total);
      final discount = group.discount.clamp(0, subtotal);
      final effectiveTax = group.tax > 0
          ? group.tax
          : ((subtotal - discount) * 0.1).round();
      final total = (subtotal - discount + effectiveTax).clamp(0, 999999999);

      return SaleRecord(
        id: group.id,
        orderLabel: group.orderLabel,
        items: group.items,
        subtotal: subtotal,
        discount: discount,
        tax: effectiveTax,
        total: total,
        paymentMethod: group.paymentMethod,
        paidAmount: total,
        cashier: group.cashier,
        createdAt: group.createdAt,
      );
    }).toList();
  }

  /// Buka FilePicker dan parse transaksi
  static Future<List<SaleRecord>> pickAndImportTransactions() async {
    final picked = await FilePicker.pickFile(
      dialogTitle: 'Pilih File Excel Transaksi',
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (picked == null) return [];

    final bytes = await picked.readAsBytes();
    if (bytes.isEmpty) {
      throw const FormatException('File Excel tidak dapat dibaca atau kosong.');
    }

    return parseTransactionsFromExcel(bytes);
  }

  // Alias untuk backward-compatibility
  static Future<String> exportSales(List<SaleRecord> transactions) =>
      exportSummary(transactions);

  static String _formatDateTime(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(value.day)}/${two(value.month)}/${value.year} ${two(value.hour)}:${two(value.minute)}';
  }

  static String _cellText(Data? cell) {
    if (cell == null || cell.value == null) return '';
    final val = cell.value;
    if (val is TextCellValue) return val.value.text ?? '';
    return val.toString();
  }

  static String _normalizeHeader(String raw) {
    return raw
        .replaceAll('\uFEFF', '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
        .trim()
        .toLowerCase();
  }

  static int _findHeaderIndex(List<String> headers, List<String> aliases) {
    return headers.indexWhere((header) {
      for (final alias in aliases) {
        final norm = _normalizeHeader(alias);
        if (header == norm || header.contains(norm)) {
          return true;
        }
      }
      return false;
    });
  }

  static int _parseNumber(dynamic val) {
    if (val == null) return 0;
    if (val is IntCellValue) return val.value;
    if (val is DoubleCellValue) return val.value.round();
    if (val is num) return val.round();
    final str = val
        .toString()
        .replaceAll('Rp', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    final parsed = double.tryParse(str);
    return parsed?.round() ?? 0;
  }

  static DateTime? _parseDate(Data? cell) {
    if (cell == null || cell.value == null) return null;
    final val = cell.value;
    if (val is DateTimeCellValue) {
      return DateTime(
        val.year,
        val.month,
        val.day,
        val.hour,
        val.minute,
        val.second,
      );
    }
    if (val is DateCellValue) {
      return DateTime(val.year, val.month, val.day);
    }

    final text = _cellText(cell).trim();
    if (text.isEmpty) return null;

    final iso = DateTime.tryParse(text.replaceAll('/', '-'));
    if (iso != null) return iso;

    final regex = RegExp(
      r'^(\d{1,2})[/-](\d{1,2})[/-](\d{4})(?:\s+(\d{1,2}):(\d{1,2})(?::(\d{1,2}))?)?',
    );
    final match = regex.firstMatch(text);
    if (match != null) {
      final d = int.parse(match.group(1)!);
      final m = int.parse(match.group(2)!);
      final y = int.parse(match.group(3)!);
      final h = int.tryParse(match.group(4) ?? '0') ?? 0;
      final min = int.tryParse(match.group(5) ?? '0') ?? 0;
      final s = int.tryParse(match.group(6) ?? '0') ?? 0;
      return DateTime(y, m, d, h, min, s);
    }

    final numVal = double.tryParse(text);
    if (numVal != null && numVal > 20000 && numVal < 70000) {
      final epoch = DateTime(1899, 12, 30);
      final millis = (numVal * 86400000).round();
      return epoch.add(Duration(milliseconds: millis));
    }

    return null;
  }
}

class _GroupedTransaction {
  _GroupedTransaction({
    required this.id,
    required this.orderLabel,
    required this.cashier,
    required this.paymentMethod,
    required this.createdAt,
    required this.discount,
    required this.tax,
    required this.items,
  });

  final String id;
  final String orderLabel;
  final String cashier;
  final String paymentMethod;
  final DateTime createdAt;
  final int discount;
  final int tax;
  final List<SaleItemRecord> items;
}
