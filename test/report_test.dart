import 'package:flutter_test/flutter_test.dart';
import 'package:simpel_pos/src/models.dart';
import 'package:simpel_pos/src/services/report_exporter.dart';

void main() {
  test(
    'generateSummaryFileName dan generateDetailFileName menghasilkan format yang rapi dan konsisten',
    () {
      final fixedDate = DateTime(2026, 8, 28, 16, 45, 30);
      final summaryName = ReportExporter.generateSummaryFileName(
        now: fixedDate,
      );
      final detailName = ReportExporter.generateDetailFileName(now: fixedDate);

      expect(summaryName, 'Laporan_Rekap_Penjualan_2026-08-28_164530.xlsx');
      expect(detailName, 'Laporan_Detail_Penjualan_2026-08-28_164530.xlsx');
    },
  );

  test(
    'generateFileName dengan suffix menambahkan konteks filter ke nama file',
    () {
      final fixedDate = DateTime(2026, 8, 28, 16, 45, 30);
      final summaryWithSuffix = ReportExporter.generateSummaryFileName(
        now: fixedDate,
        suffix: 'hari_ini_qris',
      );
      expect(
        summaryWithSuffix,
        'Laporan_Rekap_Penjualan_hari_ini_qris_2026-08-28_164530.xlsx',
      );
    },
  );

  test(
    'SaleRecord dan SaleItemRecord menghitung itemCount dan total dengan benar',
    () {
      final items = [
        const SaleItemRecord(
          productName: 'Kopi Susu Gula Aren',
          quantity: 2,
          unitPrice: 22000,
        ),
        const SaleItemRecord(
          productName: 'Croissant Butter',
          quantity: 1,
          unitPrice: 19000,
        ),
      ];

      final record = SaleRecord(
        id: 'TRX-101',
        orderLabel: 'Meja 02',
        items: items,
        subtotal: 63000,
        tax: 6300,
        total: 69300,
        paymentMethod: 'QRIS',
        cashier: 'Kasir',
        createdAt: DateTime(2026, 8, 28, 10, 0),
      );

      expect(record.itemCount, 3);
      expect(record.items[0].total, 44000);
      expect(record.items[1].total, 19000);
      expect(record.total, 69300);
    },
  );
}
