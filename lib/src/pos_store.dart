import 'package:flutter/material.dart';

import 'models.dart';
import 'theme/app_theme.dart';

class PosStore extends ChangeNotifier {
  PosStore() {
    _seedTables();
  }

  static const taxRate = .1;

  final tables = <CafeTable>[];
  final cart = <String, CartLine>{};
  final pendingOrders = <String, PendingOrder>{};
  final transactions = <SaleRecord>[];
  final reservedTables = <int, String>{};

  int todaySales = 2450000;
  int todayTransactions = 48;
  int discount = 0;
  String role = 'Kasir';
  String? activeOrder;

  final menu = <MenuItem>[
    MenuItem(
      id: '1',
      name: 'Mie Goreng Special',
      category: 'Mie',
      price: 35000,
      icon: Icons.ramen_dining_rounded,
      color: AppColors.primary,
      assetPath: AppAssets.heroMieGorengSpecial,
      description:
          'Mie goreng dengan ayam, udang, sayuran dan bumbu spesial ala resto.',
      favorite: true,
      variants: [
        MenuVariant(label: 'Original'),
        MenuVariant(label: 'Pedas'),
        MenuVariant(label: 'Extra Udang', extraPrice: 10000),
      ],
    ),
    MenuItem(
      id: '2',
      name: 'Ayam Kuluyuk',
      category: 'Makanan',
      price: 38000,
      icon: Icons.set_meal_rounded,
      color: AppColors.primary,
      assetPath: AppAssets.ayamKuluyuk,
      description: 'Ayam goreng crispy dengan saus asam manis khas Tionghoa.',
      favorite: true,
      variants: [
        MenuVariant(label: 'Original'),
        MenuVariant(label: 'Pedas'),
        MenuVariant(label: 'Porsi Besar', extraPrice: 12000),
      ],
    ),
    MenuItem(
      id: '3',
      name: 'Mie Goreng',
      category: 'Mie',
      price: 35000,
      icon: Icons.ramen_dining_rounded,
      color: AppColors.primary,
      assetPath: AppAssets.mieGoreng,
      description: 'Mie goreng klasik dengan sayuran segar dan telur.',
      favorite: true,
      variants: [
        MenuVariant(label: 'Original'),
        MenuVariant(label: 'Pedas'),
        MenuVariant(label: 'Extra Telur', extraPrice: 6000),
      ],
    ),
    MenuItem(
      id: '4',
      name: 'Nasi Goreng',
      category: 'Nasi',
      price: 32000,
      icon: Icons.rice_bowl_rounded,
      color: AppColors.primary,
      assetPath: AppAssets.nasiGoreng,
      description: 'Nasi goreng gurih dengan potongan ayam dan sayuran.',
      favorite: true,
      variants: [
        MenuVariant(label: 'Original'),
        MenuVariant(label: 'Pedas'),
        MenuVariant(label: 'Seafood', extraPrice: 10000),
      ],
    ),
    MenuItem(
      id: '5',
      name: 'Cap Cai',
      category: 'Makanan',
      price: 30000,
      icon: Icons.dinner_dining_rounded,
      color: AppColors.primary,
      assetPath: AppAssets.capCai,
      description: 'Aneka sayuran segar tumis dengan saus gurih kental.',
      favorite: true,
      variants: [
        MenuVariant(label: 'Original'),
        MenuVariant(label: 'Seafood', extraPrice: 12000),
      ],
    ),
    MenuItem(
      id: '6',
      name: 'Dumpling Ayam',
      category: 'Dumpling',
      price: 28000,
      icon: Icons.tapas_rounded,
      color: AppColors.primary,
      assetPath: AppAssets.dumplingAyam,
      description: 'Dumpling isi ayam cincang, dikukus lembut dan juicy.',
      favorite: true,
      variants: [
        MenuVariant(label: 'Kukus'),
        MenuVariant(label: 'Goreng'),
      ],
    ),
    MenuItem(
      id: '7',
      name: 'Lumpia Udang',
      category: 'Dumpling',
      price: 28000,
      icon: Icons.bakery_dining_rounded,
      color: AppColors.primary,
      assetPath: AppAssets.lumpiaUdang,
      description: 'Lumpia renyah dengan isian udang pilihan dan rebung.',
      favorite: true,
      variants: [
        MenuVariant(label: 'Original'),
        MenuVariant(label: 'Extra Saus', extraPrice: 5000),
      ],
    ),
    MenuItem(
      id: '8',
      name: 'Nasi Goreng Seafood',
      category: 'Nasi',
      price: 42000,
      icon: Icons.rice_bowl_rounded,
      color: AppColors.primary,
      assetPath: AppAssets.cartNasiGorengSeafood,
      description: 'Nasi goreng dengan udang, cumi, dan bakso ikan.',
      variants: [
        MenuVariant(label: 'Original'),
        MenuVariant(label: 'Pedas'),
      ],
    ),
    MenuItem(
      id: '9',
      name: 'Es Teh Tawar',
      category: 'Minuman',
      price: 8000,
      icon: Icons.local_cafe_rounded,
      color: AppColors.accentGold,
      description: 'Teh melati dingin segar penawar rasa gurih.',
      variants: [
        MenuVariant(label: 'Dingin'),
        MenuVariant(label: 'Panas'),
      ],
    ),
    MenuItem(
      id: '10',
      name: 'Es Jeruk Peras',
      category: 'Minuman',
      price: 12000,
      icon: Icons.local_drink_rounded,
      color: AppColors.accentGold,
      description: 'Jeruk peras asli dengan es batu, manis segar.',
      variants: [
        MenuVariant(label: 'Dingin'),
        MenuVariant(label: 'Panas'),
      ],
    ),
    MenuItem(
      id: '11',
      name: 'Teh Giok Melati',
      category: 'Minuman',
      price: 15000,
      icon: Icons.emoji_food_beverage_rounded,
      color: AppColors.accentGold,
      description: 'Teh hijau melati premium disajikan dalam teko keramik.',
      variants: [
        MenuVariant(label: 'Panas'),
        MenuVariant(label: 'Dingin'),
      ],
    ),
    MenuItem(
      id: '12',
      name: 'Bakpao Cokelat',
      category: 'Dumpling',
      price: 18000,
      icon: Icons.cake_rounded,
      color: AppColors.primary,
      description: 'Bakpao empuk dengan lelehan cokelat di dalamnya.',
      variants: [
        MenuVariant(label: 'Kukus'),
        MenuVariant(label: 'Goreng'),
      ],
    ),
  ];

  void _seedTables() {
    tables
      ..clear()
      ..addAll(
        List.generate(
          12,
          (index) => CafeTable(number: index + 1, seats: index % 3 == 0 ? 4 : 2),
        ),
      );
    reservedTables
      ..clear()
      ..addAll({4: '19:00', 11: '20:00'});
  }

  int get cartCount => cart.values.fold(0, (sum, line) => sum + line.quantity);
  int get subtotal => cart.values.fold(0, (sum, line) => sum + line.total);
  int get taxableBase => (subtotal - discount).clamp(0, subtotal);
  int get tax => (taxableBase * taxRate).round();
  int get total => taxableBase + tax;

  int get averageTransaction =>
      todayTransactions == 0 ? 0 : (todaySales / todayTransactions).round();
  int get estimatedProfit => (todaySales * .4).round();

  Set<int> get occupiedTables => pendingOrders.keys
      .where((label) => label.startsWith('Meja '))
      .map((label) => int.tryParse(label.replaceAll(RegExp(r'[^0-9]'), '')))
      .whereType<int>()
      .toSet();

  TableStatus statusOf(int tableNumber) {
    if (occupiedTables.contains(tableNumber)) return TableStatus.occupied;
    if (reservedTables.containsKey(tableNumber)) return TableStatus.reserved;
    return TableStatus.free;
  }

  List<String> get categories {
    final values = menu.map((item) => item.category).toSet().toList()..sort();
    return ['Semua', ...values];
  }

  List<MenuItem> get favorites =>
      menu.where((item) => item.favorite).toList(growable: false);

  void setRole(String value) {
    role = value;
    notifyListeners();
  }

  void setDiscount(int value) {
    discount = value.clamp(0, subtotal);
    notifyListeners();
  }

  void startOrder(String label) {
    activeOrder = label;
    discount = 0;
    cart.clear();
    final pending = pendingOrders[label];
    if (pending != null) {
      for (final entry in pending.items.entries) {
        cart[entry.key] = entry.value.clone();
      }
    }
    notifyListeners();
  }

  String nextTakeAwayLabel() {
    var number = 1;
    while (pendingOrders.containsKey(
      'Take Away #${number.toString().padLeft(2, '0')}',
    )) {
      number++;
    }
    return 'Take Away #${number.toString().padLeft(2, '0')}';
  }

  void savePendingOrder() {
    if (activeOrder == null || cart.isEmpty) return;
    final now = DateTime.now();
    final current = pendingOrders[activeOrder];
    pendingOrders[activeOrder!] = PendingOrder(
      label: activeOrder!,
      items: {
        for (final entry in cart.entries) entry.key: entry.value.clone(),
      },
      createdAt: current?.createdAt ?? now,
      updatedAt: now,
    );
    cart.clear();
    discount = 0;
    activeOrder = null;
    notifyListeners();
  }

  void addItem(
    MenuItem item, {
    String variantLabel = '',
    int variantExtraPrice = 0,
    int quantity = 1,
    String note = '',
  }) {
    if (quantity <= 0) return;
    final key = CartLine.buildKey(item.id, variantLabel);
    final existing = cart[key];
    if (existing == null) {
      cart[key] = CartLine(
        item: item,
        quantity: quantity,
        variantLabel: variantLabel,
        variantExtraPrice: variantExtraPrice,
        note: note,
      );
    } else {
      existing.quantity += quantity;
      if (note.isNotEmpty) existing.note = note;
    }
    notifyListeners();
  }

  void add(MenuItem item) => addItem(item);

  void incrementLine(String key) {
    final line = cart[key];
    if (line == null) return;
    line.quantity++;
    notifyListeners();
  }

  void decrementLine(String key) {
    final line = cart[key];
    if (line == null) return;
    line.quantity--;
    if (line.quantity <= 0) cart.remove(key);
    if (discount > subtotal) discount = subtotal;
    notifyListeners();
  }

  void removeLine(String key) {
    cart.remove(key);
    if (discount > subtotal) discount = subtotal;
    notifyListeners();
  }

  void clearCart() {
    cart.clear();
    discount = 0;
    notifyListeners();
  }

  void addProduct({
    required String name,
    required String category,
    required int price,
    String? imagePath,
    String description = '',
  }) {
    menu.add(
      MenuItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name.trim(),
        category: category.trim(),
        price: price,
        icon: Icons.restaurant_menu_rounded,
        color: AppColors.primary,
        imagePath: imagePath,
        description: description.trim(),
        variants: const [
          MenuVariant(label: 'Original'),
          MenuVariant(label: 'Pedas'),
        ],
      ),
    );
    notifyListeners();
  }

  void updateProduct(
    MenuItem current, {
    required String name,
    required String category,
    required int price,
    String? imagePath,
    String? description,
    bool clearImagePath = false,
  }) {
    final index = menu.indexWhere((item) => item.id == current.id);
    if (index < 0) return;
    menu[index] = current.copyWith(
      name: name.trim(),
      category: category.trim(),
      price: price,
      imagePath: imagePath,
      description: description?.trim(),
      clearImagePath: clearImagePath,
    );
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final index = menu.indexWhere((item) => item.id == id);
    if (index < 0) return;
    menu[index] = menu[index].copyWith(favorite: !menu[index].favorite);
    notifyListeners();
  }

  void deleteProduct(String id) {
    menu.removeWhere((item) => item.id == id);
    cart.removeWhere((_, line) => line.item.id == id);
    notifyListeners();
  }

  int get nextTableNumber => tables.isEmpty
      ? 1
      : tables.map((table) => table.number).reduce((a, b) => a > b ? a : b) + 1;

  void addTable({required int seats, int? number, String? reservedUntil}) {
    final targetNumber = number ?? nextTableNumber;
    final existingIndex = tables.indexWhere((t) => t.number == targetNumber);
    final newTable = CafeTable(
      number: targetNumber,
      seats: seats,
      reservedUntil: reservedUntil,
    );

    if (existingIndex >= 0) {
      tables[existingIndex] = newTable;
    } else {
      tables.add(newTable);
      tables.sort((a, b) => a.number.compareTo(b.number));
    }

    if (reservedUntil != null && reservedUntil.trim().isNotEmpty) {
      reservedTables[targetNumber] = reservedUntil.trim();
    } else {
      reservedTables.remove(targetNumber);
    }
    notifyListeners();
  }

  bool deleteTable(int number) {
    if (occupiedTables.contains(number)) return false;
    tables.removeWhere((table) => table.number == number);
    reservedTables.remove(number);
    notifyListeners();
    return true;
  }

  SaleRecord? completeOrder(String paymentMethod, {int? paidAmount}) {
    if (cart.isEmpty) return null;
    final now = DateTime.now();
    final grandTotal = total;
    final transaction = SaleRecord(
      id: 'TRX-${now.millisecondsSinceEpoch}',
      orderLabel: activeOrder ?? 'Take Away',
      items: cart.values
          .map(
            (line) => SaleItemRecord(
              productName: line.displayName,
              quantity: line.quantity,
              unitPrice: line.unitPrice,
            ),
          )
          .toList(),
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      total: grandTotal,
      paymentMethod: paymentMethod,
      paidAmount: paidAmount ?? grandTotal,
      cashier: role,
      createdAt: now,
    );
    transactions.insert(0, transaction);
    todaySales += grandTotal;
    todayTransactions++;
    if (activeOrder != null) {
      pendingOrders.remove(activeOrder);
      final tableNumber = int.tryParse(
        activeOrder!.replaceAll(RegExp(r'[^0-9]'), ''),
      );
      if (activeOrder!.startsWith('Meja ') && tableNumber != null) {
        reservedTables.remove(tableNumber);
      }
    }
    cart.clear();
    discount = 0;
    activeOrder = null;
    notifyListeners();
    return transaction;
  }

  int importTransactions(List<SaleRecord> newRecords) {
    if (newRecords.isEmpty) return 0;
    var importedCount = 0;
    for (final rec in newRecords) {
      final idx = transactions.indexWhere((t) => t.id == rec.id);
      if (idx >= 0) {
        transactions[idx] = rec;
      } else {
        transactions.add(rec);
        importedCount++;
      }
    }
    transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _syncSalesStats();
    notifyListeners();
    return importedCount > 0 ? importedCount : newRecords.length;
  }

  void _syncSalesStats() {
    if (transactions.isEmpty) return;
    final now = DateTime.now();
    final todayTrx = transactions.where((t) =>
      t.createdAt.year == now.year &&
      t.createdAt.month == now.month &&
      t.createdAt.day == now.day
    ).toList();
    if (todayTrx.isNotEmpty) {
      todaySales = todayTrx.fold(0, (sum, t) => sum + t.total);
      todayTransactions = todayTrx.length;
    }
  }
}
