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
      final store = PosStore(seedDemoData: false);
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

      expect(find.text('Laporan Penjualan'), findsNothing);
      expect(find.byKey(const ValueKey('collapsible_fab_button')), findsOneWidget);
      // Filter (Periode/Metode chips) dipindah ke bottom sheet
      expect(find.text('Hari Ini'), findsNothing);
      // KPI cards tampil
      expect(find.text('Total Omzet'), findsOneWidget);
      expect(find.text('Grafik Penjualan'), findsOneWidget);
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

      expect(find.text('Denah Meja'), findsOneWidget);
      expect(find.text('Kosong'), findsWidgets);
      expect(find.text('Take Away / Bungkus'), findsOneWidget);
    },
  );

  testWidgets(
    'ReportPage menampilkan layout sesuai mockup Screen 10 (Laporan, 2x2 KPI, Grafik Penjualan)',
    (tester) async {
      final store = PosStore(seedDemoData: true);

      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ReportPage(store: store)),
        ),
      );

      // 1. Header Laporan
      expect(find.text('Laporan'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);

      // 2. 4 Kartu KPI (2x2 Grid)
      expect(find.text('Total Omzet'), findsOneWidget);
      expect(find.text('Total Transaksi'), findsOneWidget);
      expect(find.text('Rata-rata Transaksi'), findsOneWidget);
      expect(find.text('Estimasi Keuntungan'), findsOneWidget);
      expect(find.text('+12%'), findsOneWidget);
      expect(find.text('+9%'), findsOneWidget);
      expect(find.text('+5%'), findsOneWidget);
      expect(find.text('+15%'), findsOneWidget);

      // Nilai KPI default store sesuai mockup (Rp 2.450.000, 48, Rp 51.042, Rp 980.000)
      expect(find.text('Rp 2.450.000'), findsOneWidget);
      expect(find.text('48'), findsOneWidget);
      expect(find.text('Rp 51.042'), findsOneWidget);
      expect(find.text('Rp 980.000'), findsOneWidget);

      // 3. Grafik Penjualan
      expect(find.text('Grafik Penjualan'), findsOneWidget);
      expect(find.text('Lihat Detail'), findsOneWidget);
      expect(find.byType(SalesBarChart), findsOneWidget);
    },
  );

  testWidgets(
    'ReportPage menampilkan Rp 0 dan state bersih ketika tanpa demo data',
    (tester) async {
      final store = PosStore(seedDemoData: false);

      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ReportPage(store: store)),
        ),
      );

      expect(find.text('Rp 0'), findsNWidgets(3)); // Omzet, Rata-rata, Estimasi Keuntungan
      expect(find.text('0'), findsWidgets); // Total Transaksi
      expect(find.text('Tidak ada data transaksi yang sesuai dengan filter di atas.'), findsOneWidget);
    },
  );

  testWidgets(
    'Tombol collapsible FAB menampilkan sub-menu aksi cetak, unduh, dan filter',
    (tester) async {
      final store = PosStore();

      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ReportPage(store: store)),
        ),
      );

      final fabFinder = find.byKey(const ValueKey('collapsible_fab_button'));
      expect(fabFinder, findsOneWidget);

      // Sebelum diklik, sub-menu belum terlihat
      expect(find.text('Filter'), findsNothing);
      expect(find.text('Cetak PDF'), findsNothing);

      // Klik FAB untuk membuka collapse speed dial
      await tester.tap(fabFinder);
      await tester.pumpAndSettle();

      // Memastikan sub-menu aksi muncul secara collapsible
      expect(find.text('Filter'), findsOneWidget);
      expect(find.text('Cetak PDF'), findsOneWidget);
      expect(find.text('Download Rekap'), findsOneWidget);
      expect(find.text('Download Detail'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    },
  );
}
