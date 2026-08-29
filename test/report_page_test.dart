import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simpel_pos/src/models.dart';
import 'package:simpel_pos/src/pos_store.dart';
import 'package:simpel_pos/src/screens/report_page.dart';
import 'package:simpel_pos/src/screens/table_page.dart';

void main() {
  testWidgets(
    'ReportPage menampilkan filter dan tombol download rekap & detail',
    (tester) async {
      final store = PosStore();
      // Tambah 1 transaksi contoh
      store.transactions.add(
        SaleRecord(
          id: 'TRX-TEST-001',
          orderLabel: 'Meja 01',
          items: [
            const SaleItemRecord(
              productName: 'Cappuccino',
              quantity: 2,
              unitPrice: 25000,
            ),
          ],
          subtotal: 50000,
          tax: 5000,
          total: 55000,
          paymentMethod: 'QRIS',
          cashier: 'Kasir',
          createdAt: DateTime.now(),
        ),
      );

      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ReportPage(store: store)),
        ),
      );

      expect(find.text('Laporan Penjualan'), findsOneWidget);
      expect(find.text('Download Rekap'), findsOneWidget);
      expect(find.text('Download Detail'), findsOneWidget);
      expect(find.text('Filter Laporan'), findsOneWidget);
      expect(find.text('Hari Ini'), findsOneWidget);
      expect(find.text('QRIS'), findsWidgets);
      expect(find.textContaining('TRX-TEST-001'), findsWidgets);
    },
  );

  testWidgets(
    'TablePage menampilkan layout kartu meja dua warna dan tombol aksi',
    (tester) async {
      final store = PosStore();

      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TablePage(store: store)),
        ),
      );

      expect(find.text('Pilih Meja'), findsOneWidget);
      expect(find.text('Meja 01'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsWidgets);
    },
  );
}
