import 'package:flutter_test/flutter_test.dart';
import 'package:simpel_pos/src/pos_store.dart';

void main() {
  test('produk dan meja dapat ditambah sendiri', () {
    final store = PosStore();
    final productCount = store.menu.length;
    final tableCount = store.tables.length;

    store.addProduct(name: 'Es Teh Manis', category: 'Minuman', price: 12000);
    store.addTable(seats: 4);

    expect(store.menu.length, productCount + 1);
    expect(store.menu.last.name, 'Es Teh Manis');
    expect(store.tables.length, tableCount + 1);
    expect(store.tables.last.seats, 4);

    // Tambah meja custom dengan nomor dan status reservasi
    store.addTable(seats: 6, number: 99, reservedUntil: '19:30');
    expect(store.tables.any((t) => t.number == 99), isTrue);
    expect(store.reservedTables[99], '19:30');
    expect(store.statusOf(99).name, 'reserved');

    // Hapus meja yang belum terisi
    final deleted = store.deleteTable(99);
    expect(deleted, isTrue);
    expect(store.tables.any((t) => t.number == 99), isFalse);
    expect(store.reservedTables.containsKey(99), isFalse);
  });

  test('pesanan disimpan dahulu dan meja menjadi terisi', () {
    final store = PosStore(seedDemoData: false);
    store.startOrder('Meja 01');
    store.add(store.menu.first);

    store.savePendingOrder();

    expect(store.pendingOrders, contains('Meja 01'));
    expect(store.occupiedTables, contains(1));
    expect(store.transactions, isEmpty);
  });

  test('pesanan tersimpan dapat dibuka dan dibayar belakangan', () {
    final store = PosStore(seedDemoData: false);
    store.startOrder('Meja 01');
    store.add(store.menu.first);
    store.savePendingOrder();
    final expectedTotal = store.pendingOrders['Meja 01']!.total;

    store.startOrder('Meja 01');

    store.completeOrder('QRIS');

    expect(store.transactions, hasLength(1));
    expect(store.transactions.first.paymentMethod, 'QRIS');
    expect(store.transactions.first.total, expectedTotal);
    expect(store.pendingOrders, isNot(contains('Meja 01')));
    expect(store.occupiedTables, isNot(contains(1)));
    expect(store.cart, isEmpty);
  });
}
