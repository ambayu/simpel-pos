import 'package:flutter/material.dart';

enum TableStatus { free, occupied, reserved }

class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.icon,
    required this.color,
    this.imagePath,
    this.assetPath,
    this.description = '',
    this.variants = const <MenuVariant>[],
    this.favorite = false,
    this.stock = 50,
  });

  final String id;
  final String name;
  final String category;
  final int price;
  final IconData icon;
  final Color color;
  final String? imagePath;
  final String? assetPath;
  final String description;
  final List<MenuVariant> variants;
  final bool favorite;
  final int stock;

  MenuItem copyWith({
    String? id,
    String? name,
    String? category,
    int? price,
    IconData? icon,
    Color? color,
    String? imagePath,
    String? assetPath,
    String? description,
    List<MenuVariant>? variants,
    bool? favorite,
    int? stock,
    bool clearImagePath = false,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      imagePath: clearImagePath ? null : (imagePath ?? this.imagePath),
      assetPath: assetPath ?? this.assetPath,
      description: description ?? this.description,
      variants: variants ?? this.variants,
      favorite: favorite ?? this.favorite,
      stock: stock ?? this.stock,
    );
  }
}

class MenuVariant {
  const MenuVariant({required this.label, this.extraPrice = 0});

  final String label;
  final int extraPrice;
}

class CartLine {
  CartLine({
    required this.item,
    this.quantity = 1,
    this.variantLabel = '',
    this.variantExtraPrice = 0,
    this.note = '',
  });

  final MenuItem item;
  final String variantLabel;
  final int variantExtraPrice;
  int quantity;
  String note;

  int get unitPrice => item.price + variantExtraPrice;
  int get total => unitPrice * quantity;

  String get displayName =>
      variantLabel.isEmpty ? item.name : '${item.name} ($variantLabel)';

  static String buildKey(String productId, String variantLabel) =>
      variantLabel.isEmpty ? productId : '$productId::$variantLabel';

  String get key => buildKey(item.id, variantLabel);

  CartLine clone() => CartLine(
    item: item,
    quantity: quantity,
    variantLabel: variantLabel,
    variantExtraPrice: variantExtraPrice,
    note: note,
  );
}

class CafeTable {
  const CafeTable({
    required this.number,
    required this.seats,
    this.reservedUntil,
  });

  final int number;
  final int seats;
  final String? reservedUntil;
}

class SaleRecord {
  const SaleRecord({
    required this.id,
    required this.orderLabel,
    required this.items,
    required this.subtotal,
    this.discount = 0,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    int? paidAmount,
    required this.cashier,
    required this.createdAt,
  }) : paidAmount = paidAmount ?? total;

  final String id;
  final String orderLabel;
  final List<SaleItemRecord> items;
  final int subtotal;
  final int discount;
  final int tax;
  final int total;
  final String paymentMethod;
  final int paidAmount;
  final String cashier;
  final DateTime createdAt;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  int get change => (paidAmount - total).clamp(0, paidAmount);

  SaleRecord copyWith({
    String? paymentMethod,
    String? cashier,
    DateTime? createdAt,
    String? orderLabel,
    int? tax,
    int? total,
  }) {
    return SaleRecord(
      id: id,
      orderLabel: orderLabel ?? this.orderLabel,
      items: items,
      subtotal: subtotal,
      discount: discount,
      tax: tax ?? this.tax,
      total: total ?? (tax != null ? (subtotal - discount + tax) : this.total),
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paidAmount: paidAmount,
      cashier: cashier ?? this.cashier,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SaleItemRecord {
  const SaleItemRecord({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  final String productName;
  final int quantity;
  final int unitPrice;
  int get total => quantity * unitPrice;
}

class PendingOrder {
  PendingOrder({
    required this.label,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  final String label;
  final Map<String, CartLine> items;
  final DateTime createdAt;
  DateTime updatedAt;

  int get itemCount => items.values.fold(0, (sum, line) => sum + line.quantity);
  int get subtotal => items.values.fold(0, (sum, line) => sum + line.total);
  int get tax => (subtotal * .1).round();
  int get total => subtotal + tax;

  Duration get elapsed => DateTime.now().difference(createdAt);

  String get elapsedLabel {
    final minutes = elapsed.inMinutes;
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${remainder.toString().padLeft(2, '0')}';
  }
}

String rupiah(num value) {
  final rounded = value.round();
  final negative = rounded < 0;
  final digits = rounded.abs().toString();
  final output = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) output.write('.');
    output.write(digits[index]);
  }
  return '${negative ? '-' : ''}Rp $output';
}

enum SimpelPermission {
  dashboard,
  table,
  tableAksi,
  order,
  orderAksi,
  report,
  reportAksi,
  product,
  productAksi,
  stock,
  stockAksi,
  settings,
  userManagement,
}

extension SimpelPermissionX on SimpelPermission {
  String get label {
    switch (this) {
      case SimpelPermission.dashboard:
        return 'Menu Beranda (Dashboard)';
      case SimpelPermission.table:
        return 'Menu Denah Meja (Lihat)';
      case SimpelPermission.tableAksi:
        return 'Aksi Meja (Tambah & Kelola Meja)';
      case SimpelPermission.order:
        return 'Menu Pesanan & Kasir (Lihat)';
      case SimpelPermission.orderAksi:
        return 'Aksi Kasir (Buat Pesanan & Bayar)';
      case SimpelPermission.report:
        return 'Menu Laporan (Lihat)';
      case SimpelPermission.reportAksi:
        return 'Aksi Laporan (Cetak & Ekspor)';
      case SimpelPermission.product:
        return 'Menu Produk & Menu (Lihat)';
      case SimpelPermission.productAksi:
        return 'Aksi Produk (Tambah, Edit, Hapus Menu)';
      case SimpelPermission.stock:
        return 'Menu Penyimpanan Stok (Lihat)';
      case SimpelPermission.stockAksi:
        return 'Aksi Stok (Tambah Masuk, Kurang, Opname)';
      case SimpelPermission.settings:
        return 'Menu Pengaturan Restoran';
      case SimpelPermission.userManagement:
        return 'Manajemen User & Role Permission';
    }
  }

  bool get isAction =>
      this == SimpelPermission.tableAksi ||
      this == SimpelPermission.orderAksi ||
      this == SimpelPermission.reportAksi ||
      this == SimpelPermission.productAksi ||
      this == SimpelPermission.stockAksi;
}

class UserAccount {
  const UserAccount({
    required this.username,
    required this.password,
    required this.role,
  });

  final String username;
  final String password;
  final String role;

  UserAccount copyWith({
    String? username,
    String? password,
    String? role,
  }) {
    return UserAccount(
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }
}

class RoleAccess {
  const RoleAccess({
    required this.roleName,
    required this.permissions,
  });

  final String roleName;
  final Set<SimpelPermission> permissions;

  RoleAccess copyWith({
    String? roleName,
    Set<SimpelPermission>? permissions,
  }) {
    return RoleAccess(
      roleName: roleName ?? this.roleName,
      permissions: permissions ?? this.permissions,
    );
  }
}
