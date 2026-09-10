import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:simpel_pos/src/app.dart';

void main() {
  testWidgets('menampilkan quick login dan masuk ke dashboard', (tester) async {
    await tester.pumpWidget(const SimpelPosApp());

    expect(find.text('Mulai Sekarang'), findsOneWidget);
    await tester.tap(find.text('Mulai Sekarang'));
    await tester.pumpAndSettle();

    expect(find.text('Pilih Peran Anda'), findsOneWidget);
    expect(find.text('Masuk sebagai Kasir'), findsOneWidget);

    final loginButtonFinder = find.text('Masuk sebagai Kasir');
    await tester.ensureVisible(loginButtonFinder);
    await tester.tap(loginButtonFinder);
    await tester.pumpAndSettle();

    expect(find.textContaining('Selamat Datang, Kasir'), findsOneWidget);
    expect(find.text('Buat Pesanan Baru'), findsOneWidget);
  });

  testWidgets('layout mobile login dan navigasi utama tidak overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SimpelPosApp());
    expect(find.text('Mulai Sekarang'), findsOneWidget);

    await tester.tap(find.text('Mulai Sekarang'));
    await tester.pumpAndSettle();
    expect(find.text('Pilih Peran Anda'), findsOneWidget);

    await tester.ensureVisible(find.text('Masuk sebagai Kasir'));
    await tester.tap(find.text('Masuk sebagai Kasir'));
    await tester.pumpAndSettle();

    expect(find.text('Beranda'), findsWidgets);
    expect(find.text('Meja'), findsWidgets);
    expect(find.text('Pesanan'), findsWidgets);
    expect(find.text('Laporan'), findsWidgets);

    await tester.tap(find.text('Meja').last);
    await tester.pumpAndSettle();
    expect(find.text('Denah Meja'), findsOneWidget);
  });
}
