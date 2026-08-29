import 'dart:io';

import 'package:excel/excel.dart';
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

  static Future<String> exportSummary(
    List<SaleRecord> transactions, {
    String? filterTitle,
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
      TextCellValue('Pajak (Rp)'),
      TextCellValue('Total (Rp)'),
    ]);

    var totalItemCount = 0;
    var grandSubtotal = 0;
    var grandTax = 0;
    var grandTotal = 0;

    for (var i = 0; i < transactions.length; i++) {
      final t = transactions[i];
      totalItemCount += t.itemCount;
      grandSubtotal += t.subtotal;
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
      IntCellValue(grandTax),
      IntCellValue(grandTotal),
    ]);

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

    final directory = await getApplicationDocumentsDirectory();
    final fileName = generateSummaryFileName();
    final file = File('${directory.path}${Platform.pathSeparator}$fileName');
    await file.writeAsBytes(bytes, flush: true);
    await OpenFilex.open(file.path);
    return file.path;
  }

  static Future<String> exportDetail(
    List<SaleRecord> transactions, {
    String? filterTitle,
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

    final directory = await getApplicationDocumentsDirectory();
    final fileName = generateDetailFileName();
    final file = File('${directory.path}${Platform.pathSeparator}$fileName');
    await file.writeAsBytes(bytes, flush: true);
    await OpenFilex.open(file.path);
    return file.path;
  }

  // Alias untuk kompatibilitas ke belakang
  static Future<String> exportSales(List<SaleRecord> transactions) =>
      exportSummary(transactions);

  static String _formatDateTime(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(value.day)}/${two(value.month)}/${value.year} ${two(value.hour)}:${two(value.minute)}';
  }
}
