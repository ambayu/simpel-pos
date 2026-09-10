import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simpel_pos/src/pos_store.dart';
import 'package:simpel_pos/src/screens/order_page.dart';
import 'package:simpel_pos/src/screens/table_page.dart';

void main() {
  testWidgets('TableFormPage menampilkan form tambah meja dan menyimpan meja baru', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = PosStore();
    final initialCount = store.tables.length;

    await tester.pumpWidget(
      MaterialApp(
        home: TableFormPage(store: store),
      ),
    );

    expect(find.text('Atur Meja'), findsOneWidget);
    expect(find.text('Simpan Meja'), findsOneWidget);
    expect(find.textContaining('Daftar Meja'), findsOneWidget);

    // Tekan Simpan Meja
    await tester.tap(find.text('Simpan Meja'));
    await tester.pumpAndSettle();

    expect(store.tables.length, initialCount + 1);
  });

  testWidgets('TableFormPage tidak overflow pada layar mobile sempit', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = PosStore();

    await tester.pumpWidget(
      MaterialApp(
        home: TableFormPage(store: store),
      ),
    );

    expect(find.text('2 Kursi'), findsOneWidget);
    expect(find.text('4 Kursi'), findsOneWidget);
    expect(find.text('6 Kursi'), findsOneWidget);
    expect(find.text('8 Kursi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Pesanan Take Away tidak menampilkan tombol Simpan Meja saat checkout', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = PosStore();
    store.startOrder('Take Away #01');
    store.add(store.menu.first);

    await tester.pumpWidget(
      MaterialApp(
        home: OrderPage(store: store),
      ),
    );

    // Buka keranjang / pesanan saya
    await tester.tap(find.textContaining('Pesanan Saya'));
    await tester.pumpAndSettle();

    // Pastikan tidak ada tombol 'Simpan Meja' untuk Take Away
    expect(find.text('Simpan Meja'), findsNothing);
    expect(find.text('Lanjut Pembayaran'), findsOneWidget);
  });
}
