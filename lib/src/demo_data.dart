import 'models.dart';

// ---------------------------------------------------------------------------
// Hari besar Indonesia yang menyebabkan pendapatan naik ke range 7jt–8jt
// ---------------------------------------------------------------------------
bool _isHariBesar(int year, int month) {
  const hariBesar = <int, List<int>>{
    // 2025 — bulan-bulan dengan hari besar nasional
    202501: [1, 27],        // Tahun Baru, Isra Miraj
    202502: [12],           // Imlek
    202503: [29, 30, 31],   // Nyepi, Idul Fitri
    202504: [1, 18],        // Idul Fitri cuti bersama, Wafat Isa
    202505: [1, 12, 29],    // Hari Buruh, Waisak, Kenaikan Isa
    202506: [6, 27],        // Idul Adha, Tahun Baru Islam
    202508: [17],           // HUT RI
    202509: [5],            // Maulid Nabi
    202512: [25],           // Natal
    // 2026 — bulan-bulan dengan hari besar nasional
    202601: [1],            // Tahun Baru
    202602: [17],           // Imlek
    202603: [19, 20, 21],   // Isra Miraj, Idul Fitri
    202604: [3, 19],        // Wafat Isa, Nyepi
    202605: [1, 31],        // Hari Buruh, Waisak
    202606: [14, 17],       // Kenaikan Isa, Idul Adha
    202607: [16],           // Tahun Baru Islam
    202608: [17],           // HUT RI
    202609: [25],           // Maulid Nabi
  };
  final key = year * 100 + month;
  return hariBesar.containsKey(key) && hariBesar[key]!.isNotEmpty;
}

// ---------------------------------------------------------------------------
// Kategori minuman — dipakai untuk mendeteksi apakah item adalah minuman
// ---------------------------------------------------------------------------
const _kategorMinuman = {
  'MINUMAN - HOME MADE',
  'MINUMAN - TEH / TEA',
  'MINUMAN - COFFEE',
  'MINUMAN - BOTTLE / CAN',
  'MINUMAN - BEER',
};

// Kategori yang jarang dipesan (premium/niche) — bobot lebih rendah
const _kategorRarang = {
  'HAISOM',       // mahal, dipesan grup khusus
  'BEST SELLER',  // duplikat, skip di historis
  'VEGETARIAN',   // niche market
};

// ---------------------------------------------------------------------------
// Seed transactions historis Jan 2025 – Sep 2026
//   normal    : Rp 5.000.000 – 6.000.000 / bulan
//   hari besar: Rp 7.000.000 – 8.000.000 / bulan
// Menggunakan menu ASLI dari pos_store yang dioper sebagai parameter.
// Logika pemilihan menu mempertimbangkan: jam, kategori, popularitas.
// ---------------------------------------------------------------------------
List<SaleRecord> generateHistoricalTransactions(List<MenuItem> menu) {
  final records = <SaleRecord>[];
  int trxCounter = 1000;

  // Pisahkan pool menu berdasarkan kategori
  // "BEST SELLER" di-skip karena duplikat dari HOTPOT/OTHER
  final menuAll     = menu.where((m) => m.category != 'BEST SELLER').toList();
  final menuMakanan = menuAll.where((m) => !_kategorMinuman.contains(m.category)).toList();
  final menuMinuman = menuAll.where((m) => _kategorMinuman.contains(m.category)).toList();
  final menuBeer    = menuAll.where((m) => m.category == 'MINUMAN - BEER').toList();
  final menuNonBeer = menuMinuman.where((m) => m.category != 'MINUMAN - BEER').toList();

  // Pool makanan utama (populer, sering dipesan) — exclude yang sangat niche
  final menuPopuler = menuMakanan.where((m) => !_kategorRarang.contains(m.category)).toList();
  final menuHaisom  = menuMakanan.where((m) => m.category == 'HAISOM').toList();

  if (menuPopuler.isEmpty) return records;

  const tableLabels    = [
    'Meja 01', 'Meja 02', 'Meja 03', 'Meja 04', 'Meja 05',
    'Meja 06', 'Meja 07', 'Meja 08', 'Meja 09', 'Meja 10',
    'Meja 11', 'Meja 12',
    'Take Away #01', 'Take Away #02', 'Take Away #03',
  ];

  // Peak hours — lebih padat di jam makan siang & malam
  const hourPool = <int>[
    11, 11,
    12, 12, 12, 12, 12,
    13, 13, 13, 13,
    14, 14, 14,
    15, 15,
    16,
    17, 17,
    18, 18, 18, 18, 18,
    19, 19, 19, 19, 19, 19,
    20, 20, 20, 20, 20,
    21, 21, 21,
    22, 22,
  ];

  // Pseudo-random deterministik
  var seed = 137;
  int rng(int min, int max) {
    seed = (seed * 1664525 + 1013904223) & 0x7fffffff;
    return min + (seed % (max - min + 1));
  }

  // Harga item: base + variant acak (lebih natural)
  int priceOf(MenuItem m) {
    if (m.variants.isEmpty) return m.price;
    final v = m.variants[rng(0, m.variants.length - 1)];
    return m.price + v.extraPrice;
  }

  // Tambah satu item ke result
  void addItem(List<SaleItemRecord> result, Set<String> picked,
      MenuItem m, int qty) {
    if (picked.contains(m.id)) return;
    picked.add(m.id);
    result.add(SaleItemRecord(
      productName: m.name,
      quantity: qty,
      unitPrice: priceOf(m),
    ));
  }

  // Pilih menu dari pool, hindari duplikat
  MenuItem? pick(List<MenuItem> pool, Set<String> picked) {
    for (var attempt = 0; attempt < 20; attempt++) {
      final m = pool[rng(0, pool.length - 1)];
      if (!picked.contains(m.id)) return m;
    }
    return null;
  }

  // Bangun satu transaksi realistis berdasarkan jam
  List<SaleItemRecord> buildItems(int hour) {
    final result = <SaleItemRecord>[];
    final picked = <String>{};

    // Jumlah item per transaksi: kebanyakan 2–3, sesekali 1 atau 4
    final itemCount = rng(0, 9) < 6 ? rng(2, 3) : rng(1, 4);

    // ── Makanan utama (selalu ada) ──────────────────────────────────────
    // Malam (18–22): ada peluang memesan Haisom (meja grup)
    final isGrupMalam = hour >= 18 && rng(0, 9) == 0; // 10% chance malam
    if (isGrupMalam && menuHaisom.isNotEmpty) {
      final m = pick(menuHaisom, picked);
      if (m != null) addItem(result, picked, m, 1);
    }

    // Item makanan utama
    for (var i = result.length; i < itemCount; i++) {
      // 15% chance pilih dari menu niche (vegetarian / haisom)
      final useNiche = rng(0, 6) == 0 && menuMakanan.length > menuPopuler.length;
      final pool     = useNiche ? menuMakanan : menuPopuler;
      final m        = pick(pool, picked);
      if (m != null) {
        final qty = rng(0, 4) < 4 ? 1 : rng(2, 3); // 80% qty=1
        addItem(result, picked, m, qty);
      }
    }

    // ── Minuman ─────────────────────────────────────────────────────────
    // Siang (11–16): lebih ke teh/juice/air
    // Malam (17–22): teh/juice + peluang beer lebih tinggi
    final hasMinum = result.any((r) =>
        menuMinuman.any((m) => m.name == r.productName));

    if (!hasMinum && menuMinuman.isNotEmpty) {
      // 85% chance ada minuman
      if (rng(0, 9) < 9) {
        // Beer: 5% siang, 25% malam
        final isBeer     = menuBeer.isNotEmpty && rng(0, 19) < (hour >= 18 ? 5 : 1);
        final drinkPool  = isBeer ? menuBeer : menuNonBeer;
        final pool       = drinkPool.isNotEmpty ? drinkPool : menuMinuman;
        final m          = pick(pool, picked);
        if (m != null) {
          // Beer biasanya 1–2 botol, minuman lain 1–3
          final qty = isBeer ? rng(1, 2) : rng(1, 3);
          addItem(result, picked, m, qty);
        }
        // Malam: 30% tambah minuman kedua (misal teh + bir)
        if (hour >= 18 && rng(0, 9) < 3 && menuNonBeer.isNotEmpty) {
          final m2 = pick(menuNonBeer, picked);
          if (m2 != null) addItem(result, picked, m2, rng(1, 2));
        }
      }
    }

    // Fallback: pastikan ada minimal 1 item
    if (result.isEmpty && menuPopuler.isNotEmpty) {
      final m = menuPopuler[rng(0, menuPopuler.length - 1)];
      result.add(SaleItemRecord(
        productName: m.name,
        quantity: 1,
        unitPrice: priceOf(m),
      ));
    }

    return result;
  }

  // Range bulan: Jan 2025 – Sep 2026
  final months = <(int, int)>[];
  for (var m = 1; m <= 12; m++) { months.add((2025, m)); }
  for (var m = 1; m <= 9; m++)  { months.add((2026, m)); }

  for (final (year, month) in months) {
    final isBulanBesar = _isHariBesar(year, month);

    // Target omzet bulanan
    final targetTotal = isBulanBesar
        ? 7000000 + rng(0, 1000000)   // 7jt – 8jt
        : 5000000 + rng(0, 1000000);  // 5jt – 6jt

    // Jumlah transaksi: bulan besar lebih ramai
    final txCount     = isBulanBesar ? rng(28, 38) : rng(20, 28);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    var remaining = targetTotal;

    for (var i = 0; i < txCount; i++) {
      final isLast = i == txCount - 1;

      final int trxTarget;
      if (isLast) {
        trxTarget = remaining.clamp(60000, 900000);
      } else {
        final avg      = remaining ~/ (txCount - i);
        final variance = (avg * 0.4).round();
        trxTarget = (avg - variance + rng(0, variance * 2)).clamp(60000, 900000);
        remaining -= trxTarget;
      }

      // Tentukan jam lebih dulu agar buildItems bisa pakai konteks waktu
      final hour   = hourPool[rng(0, hourPool.length - 1)];
      final items  = buildItems(hour);
      final subtotal = items
          .fold<int>(0, (s, r) => s + r.unitPrice * r.quantity)
          .clamp(50000, 1200000);
      final tax = (subtotal * 0.1).round();
      final total = subtotal + tax;

      // Distribusi hari — lebih padat di pertengahan–akhir bulan
      final dayBias = rng(0, 9) < 7
          ? rng(5, daysInMonth)
          : rng(1, 10);
      final day    = dayBias.clamp(1, daysInMonth);
      final minute = rng(0, 59);

      records.add(SaleRecord(
        id: 'TRX-H${(trxCounter++).toString().padLeft(5, '0')}',
        orderLabel: tableLabels[rng(0, tableLabels.length - 1)],
        paymentMethod: 'Cash',
        cashier: 'Kasir 1',
        subtotal: subtotal,
        tax: tax,
        total: total,
        createdAt: DateTime(year, month, day, hour, minute),
        items: items,
      ));
    }
  }

  records.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  return records;
}

List<SaleRecord> generateInitialTransactions() {
  final now = DateTime.now();
  final list = [
    SaleRecord(
      id: 'TRX-0048',
      orderLabel: 'Meja 06',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 35000,
      tax: 0,
      total: 35000,
      createdAt: DateTime(now.year, now.month, now.day, 22, 5),
      items: const [
        SaleItemRecord(
          productName: 'Mie Goreng',
          quantity: 1,
          unitPrice: 35000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0047',
      orderLabel: 'Meja 05',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 68000,
      tax: 0,
      total: 68000,
      createdAt: DateTime(now.year, now.month, now.day, 21, 15),
      items: const [
        SaleItemRecord(
          productName: 'Ayam Kuluyuk',
          quantity: 1,
          unitPrice: 38000,
        ),
        SaleItemRecord(
          productName: 'Cap Cai',
          quantity: 1,
          unitPrice: 30000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0046',
      orderLabel: 'Take Away #01',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 15000,
      tax: 0,
      total: 15000,
      createdAt: DateTime(now.year, now.month, now.day, 20, 42),
      items: const [
        SaleItemRecord(
          productName: 'Teh Tarik',
          quantity: 1,
          unitPrice: 15000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0045',
      orderLabel: 'Meja 03',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 47000,
      tax: 0,
      total: 47000,
      createdAt: DateTime(now.year, now.month, now.day, 20, 18),
      items: const [
        SaleItemRecord(
          productName: 'Nasi Goreng',
          quantity: 1,
          unitPrice: 32000,
        ),
        SaleItemRecord(
          productName: 'Teh Tarik',
          quantity: 1,
          unitPrice: 15000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0044',
      orderLabel: 'Meja 02',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 43000,
      tax: 0,
      total: 43000,
      createdAt: DateTime(now.year, now.month, now.day, 19, 45),
      items: const [
        SaleItemRecord(
          productName: 'Dumpling Ayam',
          quantity: 1,
          unitPrice: 28000,
        ),
        SaleItemRecord(
          productName: 'Teh Tarik',
          quantity: 1,
          unitPrice: 15000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0043',
      orderLabel: 'Meja 01',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 66000,
      tax: 0,
      total: 66000,
      createdAt: DateTime(now.year, now.month, now.day, 19, 25),
      items: const [
        SaleItemRecord(
          productName: 'Lumpia Udang',
          quantity: 1,
          unitPrice: 36000,
        ),
        SaleItemRecord(
          productName: 'Cap Cai',
          quantity: 1,
          unitPrice: 30000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0042',
      orderLabel: 'Meja 12',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 57000,
      tax: 0,
      total: 57000,
      createdAt: DateTime(now.year, now.month, now.day, 19, 10),
      items: const [
        SaleItemRecord(
          productName: 'Nasi Goreng Seafood',
          quantity: 1,
          unitPrice: 42000,
        ),
        SaleItemRecord(
          productName: 'Es Jeruk',
          quantity: 1,
          unitPrice: 15000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0041',
      orderLabel: 'Meja 11',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 42000,
      tax: 0,
      total: 42000,
      createdAt: DateTime(now.year, now.month, now.day, 18, 50),
      items: const [
        SaleItemRecord(
          productName: 'Nasi Goreng',
          quantity: 1,
          unitPrice: 32000,
        ),
        SaleItemRecord(
          productName: 'Es Teh Manis',
          quantity: 1,
          unitPrice: 10000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0040',
      orderLabel: 'Meja 10',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 42000,
      tax: 0,
      total: 42000,
      createdAt: DateTime(now.year, now.month, now.day, 18, 32),
      items: const [
        SaleItemRecord(
          productName: 'Nasi Goreng',
          quantity: 1,
          unitPrice: 32000,
        ),
        SaleItemRecord(
          productName: 'Es Teh Manis',
          quantity: 1,
          unitPrice: 10000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0039',
      orderLabel: 'Take Away #03',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 42000,
      tax: 0,
      total: 42000,
      createdAt: DateTime(now.year, now.month, now.day, 18, 15),
      items: const [
        SaleItemRecord(
          productName: 'Nasi Goreng Seafood',
          quantity: 1,
          unitPrice: 42000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0038',
      orderLabel: 'Meja 09',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 74000,
      tax: 0,
      total: 74000,
      createdAt: DateTime(now.year, now.month, now.day, 17, 45),
      items: const [
        SaleItemRecord(
          productName: 'Nasi Goreng Seafood',
          quantity: 1,
          unitPrice: 42000,
        ),
        SaleItemRecord(
          productName: 'Nasi Goreng',
          quantity: 1,
          unitPrice: 32000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0037',
      orderLabel: 'Meja 08',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 51000,
      tax: 0,
      total: 51000,
      createdAt: DateTime(now.year, now.month, now.day, 17, 28),
      items: const [
        SaleItemRecord(
          productName: 'Lumpia Udang',
          quantity: 1,
          unitPrice: 36000,
        ),
        SaleItemRecord(
          productName: 'Teh Tarik',
          quantity: 1,
          unitPrice: 15000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0036',
      orderLabel: 'Meja 07',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 43000,
      tax: 0,
      total: 43000,
      createdAt: DateTime(now.year, now.month, now.day, 17, 12),
      items: const [
        SaleItemRecord(
          productName: 'Dumpling Ayam',
          quantity: 1,
          unitPrice: 28000,
        ),
        SaleItemRecord(
          productName: 'Es Jeruk',
          quantity: 1,
          unitPrice: 15000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0035',
      orderLabel: 'Take Away #02',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 66000,
      tax: 0,
      total: 66000,
      createdAt: DateTime(now.year, now.month, now.day, 16, 50),
      items: const [
        SaleItemRecord(
          productName: 'Ayam Kuluyuk',
          quantity: 1,
          unitPrice: 38000,
        ),
        SaleItemRecord(
          productName: 'Dumpling Ayam',
          quantity: 1,
          unitPrice: 28000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0034',
      orderLabel: 'Meja 06',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 64000,
      tax: 0,
      total: 64000,
      createdAt: DateTime(now.year, now.month, now.day, 16, 25),
      items: const [
        SaleItemRecord(
          productName: 'Lumpia Udang',
          quantity: 1,
          unitPrice: 36000,
        ),
        SaleItemRecord(
          productName: 'Dumpling Ayam',
          quantity: 1,
          unitPrice: 28000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0033',
      orderLabel: 'Meja 05',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 80000,
      tax: 0,
      total: 80000,
      createdAt: DateTime(now.year, now.month, now.day, 16, 10),
      items: const [
        SaleItemRecord(
          productName: 'Mie Ayam Special',
          quantity: 1,
          unitPrice: 45000,
        ),
        SaleItemRecord(
          productName: 'Mie Goreng Special',
          quantity: 1,
          unitPrice: 35000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0032',
      orderLabel: 'Take Away #01',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 45000,
      tax: 0,
      total: 45000,
      createdAt: DateTime(now.year, now.month, now.day, 15, 48),
      items: const [
        SaleItemRecord(
          productName: 'Cap Cai',
          quantity: 1,
          unitPrice: 30000,
        ),
        SaleItemRecord(
          productName: 'Teh Tarik',
          quantity: 1,
          unitPrice: 15000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0031',
      orderLabel: 'Meja 03',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 80000,
      tax: 0,
      total: 80000,
      createdAt: DateTime(now.year, now.month, now.day, 15, 30),
      items: const [
        SaleItemRecord(
          productName: 'Mie Ayam Special',
          quantity: 1,
          unitPrice: 45000,
        ),
        SaleItemRecord(
          productName: 'Mie Goreng',
          quantity: 1,
          unitPrice: 35000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0030',
      orderLabel: 'Meja 02',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 47000,
      tax: 0,
      total: 47000,
      createdAt: DateTime(now.year, now.month, now.day, 15, 15),
      items: const [
        SaleItemRecord(
          productName: 'Nasi Goreng',
          quantity: 1,
          unitPrice: 32000,
        ),
        SaleItemRecord(
          productName: 'Teh Tarik',
          quantity: 1,
          unitPrice: 15000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0029',
      orderLabel: 'Meja 01',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 45000,
      tax: 0,
      total: 45000,
      createdAt: DateTime(now.year, now.month, now.day, 14, 55),
      items: const [
        SaleItemRecord(
          productName: 'Mie Goreng',
          quantity: 1,
          unitPrice: 35000,
        ),
        SaleItemRecord(
          productName: 'Es Teh Manis',
          quantity: 1,
          unitPrice: 10000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0028',
      orderLabel: 'Meja 12',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 50000,
      tax: 0,
      total: 50000,
      createdAt: DateTime(now.year, now.month, now.day, 14, 40),
      items: const [
        SaleItemRecord(
          productName: 'Mie Goreng Special',
          quantity: 1,
          unitPrice: 35000,
        ),
        SaleItemRecord(
          productName: 'Teh Tarik',
          quantity: 1,
          unitPrice: 15000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0027',
      orderLabel: 'Meja 11',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 45000,
      tax: 0,
      total: 45000,
      createdAt: DateTime(now.year, now.month, now.day, 14, 25),
      items: const [
        SaleItemRecord(
          productName: 'Cap Cai',
          quantity: 1,
          unitPrice: 30000,
        ),
        SaleItemRecord(
          productName: 'Es Jeruk',
          quantity: 1,
          unitPrice: 15000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0026',
      orderLabel: 'Meja 10',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 28000,
      tax: 0,
      total: 28000,
      createdAt: DateTime(now.year, now.month, now.day, 14, 12),
      items: const [
        SaleItemRecord(
          productName: 'Dumpling Ayam',
          quantity: 1,
          unitPrice: 28000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0025',
      orderLabel: 'Take Away #03',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 28000,
      tax: 0,
      total: 28000,
      createdAt: DateTime(now.year, now.month, now.day, 13, 58),
      items: const [
        SaleItemRecord(
          productName: 'Dumpling Ayam',
          quantity: 1,
          unitPrice: 28000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0024',
      orderLabel: 'Meja 09',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 77000,
      tax: 0,
      total: 77000,
      createdAt: DateTime(now.year, now.month, now.day, 13, 48),
      items: const [
        SaleItemRecord(
          productName: 'Nasi Goreng Seafood',
          quantity: 1,
          unitPrice: 42000,
        ),
        SaleItemRecord(
          productName: 'Mie Goreng',
          quantity: 1,
          unitPrice: 35000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0023',
      orderLabel: 'Meja 08',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 74000,
      tax: 0,
      total: 74000,
      createdAt: DateTime(now.year, now.month, now.day, 13, 35),
      items: const [
        SaleItemRecord(
          productName: 'Nasi Goreng Seafood',
          quantity: 1,
          unitPrice: 42000,
        ),
        SaleItemRecord(
          productName: 'Nasi Goreng',
          quantity: 1,
          unitPrice: 32000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0022',
      orderLabel: 'Meja 07',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 28000,
      tax: 0,
      total: 28000,
      createdAt: DateTime(now.year, now.month, now.day, 13, 22),
      items: const [
        SaleItemRecord(
          productName: 'Dumpling Ayam',
          quantity: 1,
          unitPrice: 28000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0021',
      orderLabel: 'Take Away #02',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 80000,
      tax: 0,
      total: 80000,
      createdAt: DateTime(now.year, now.month, now.day, 13, 10),
      items: const [
        SaleItemRecord(
          productName: 'Mie Ayam Special',
          quantity: 1,
          unitPrice: 45000,
        ),
        SaleItemRecord(
          productName: 'Mie Goreng Special',
          quantity: 1,
          unitPrice: 35000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0020',
      orderLabel: 'Meja 06',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 66000,
      tax: 0,
      total: 66000,
      createdAt: DateTime(now.year, now.month, now.day, 12, 56),
      items: const [
        SaleItemRecord(
          productName: 'Lumpia Udang',
          quantity: 1,
          unitPrice: 36000,
        ),
        SaleItemRecord(
          productName: 'Cap Cai',
          quantity: 1,
          unitPrice: 30000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0019',
      orderLabel: 'Meja 05',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 36000,
      tax: 0,
      total: 36000,
      createdAt: DateTime(now.year, now.month, now.day, 12, 44),
      items: const [
        SaleItemRecord(
          productName: 'Lumpia Udang',
          quantity: 1,
          unitPrice: 36000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0018',
      orderLabel: 'Take Away #01',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 80000,
      tax: 0,
      total: 80000,
      createdAt: DateTime(now.year, now.month, now.day, 12, 32),
      items: const [
        SaleItemRecord(
          productName: 'Mie Ayam Special',
          quantity: 1,
          unitPrice: 45000,
        ),
        SaleItemRecord(
          productName: 'Mie Goreng Special',
          quantity: 1,
          unitPrice: 35000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0017',
      orderLabel: 'Meja 03',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 15000,
      tax: 0,
      total: 15000,
      createdAt: DateTime(now.year, now.month, now.day, 12, 20),
      items: const [
        SaleItemRecord(
          productName: 'Teh Tarik',
          quantity: 1,
          unitPrice: 15000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0016',
      orderLabel: 'Meja 02',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 50000,
      tax: 0,
      total: 50000,
      createdAt: DateTime(now.year, now.month, now.day, 12, 8),
      items: const [
        SaleItemRecord(
          productName: 'Mie Goreng',
          quantity: 1,
          unitPrice: 35000,
        ),
        SaleItemRecord(
          productName: 'Teh Tarik',
          quantity: 1,
          unitPrice: 15000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0015',
      orderLabel: 'Meja 01',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 15000,
      tax: 0,
      total: 15000,
      createdAt: DateTime(now.year, now.month, now.day, 11, 55),
      items: const [
        SaleItemRecord(
          productName: 'Teh Tarik',
          quantity: 1,
          unitPrice: 15000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0014',
      orderLabel: 'Meja 12',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 43000,
      tax: 0,
      total: 43000,
      createdAt: DateTime(now.year, now.month, now.day, 11, 45),
      items: const [
        SaleItemRecord(
          productName: 'Dumpling Ayam',
          quantity: 1,
          unitPrice: 28000,
        ),
        SaleItemRecord(
          productName: 'Teh Tarik',
          quantity: 1,
          unitPrice: 15000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0013',
      orderLabel: 'Meja 11',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 32000,
      tax: 0,
      total: 32000,
      createdAt: DateTime(now.year, now.month, now.day, 11, 30),
      items: const [
        SaleItemRecord(
          productName: 'Nasi Goreng',
          quantity: 1,
          unitPrice: 32000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0012',
      orderLabel: 'Meja 10',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 68000,
      tax: 0,
      total: 68000,
      createdAt: DateTime(now.year, now.month, now.day, 11, 18),
      items: const [
        SaleItemRecord(
          productName: 'Ayam Kuluyuk',
          quantity: 1,
          unitPrice: 38000,
        ),
        SaleItemRecord(
          productName: 'Cap Cai',
          quantity: 1,
          unitPrice: 30000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0011',
      orderLabel: 'Take Away #03',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 68000,
      tax: 0,
      total: 68000,
      createdAt: DateTime(now.year, now.month, now.day, 11, 5),
      items: const [
        SaleItemRecord(
          productName: 'Lumpia Udang',
          quantity: 1,
          unitPrice: 36000,
        ),
        SaleItemRecord(
          productName: 'Nasi Goreng',
          quantity: 1,
          unitPrice: 32000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0010',
      orderLabel: 'Meja 09',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 71000,
      tax: 0,
      total: 71000,
      createdAt: DateTime(now.year, now.month, now.day, 10, 50),
      items: const [
        SaleItemRecord(
          productName: 'Lumpia Udang',
          quantity: 1,
          unitPrice: 36000,
        ),
        SaleItemRecord(
          productName: 'Mie Goreng Special',
          quantity: 1,
          unitPrice: 35000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0009',
      orderLabel: 'Meja 08',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 43000,
      tax: 0,
      total: 43000,
      createdAt: DateTime(now.year, now.month, now.day, 10, 35),
      items: const [
        SaleItemRecord(
          productName: 'Dumpling Ayam',
          quantity: 1,
          unitPrice: 28000,
        ),
        SaleItemRecord(
          productName: 'Teh Tarik',
          quantity: 1,
          unitPrice: 15000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0008',
      orderLabel: 'Meja 01',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 45000,
      tax: 0,
      total: 45000,
      createdAt: DateTime(now.year, now.month, now.day, 10, 24),
      items: const [
        SaleItemRecord(
          productName: 'Mie Ayam Special',
          quantity: 1,
          unitPrice: 45000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0007',
      orderLabel: 'Meja 02',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 42000,
      tax: 0,
      total: 42000,
      createdAt: DateTime(now.year, now.month, now.day, 10, 12),
      items: const [
        SaleItemRecord(
          productName: 'Nasi Goreng Seafood',
          quantity: 1,
          unitPrice: 42000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0006',
      orderLabel: 'Meja 03',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 36000,
      tax: 0,
      total: 36000,
      createdAt: DateTime(now.year, now.month, now.day, 9, 58),
      items: const [
        SaleItemRecord(
          productName: 'Lumpia Udang',
          quantity: 1,
          unitPrice: 36000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0005',
      orderLabel: 'Meja 07',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 50000,
      tax: 0,
      total: 50000,
      createdAt: DateTime(now.year, now.month, now.day, 9, 40),
      items: const [
        SaleItemRecord(
          productName: 'Mie Goreng Special',
          quantity: 1,
          unitPrice: 35000,
        ),
        SaleItemRecord(
          productName: 'Es Jeruk',
          quantity: 1,
          unitPrice: 15000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0004',
      orderLabel: 'Take Away #02',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 45000,
      tax: 0,
      total: 45000,
      createdAt: DateTime(now.year, now.month, now.day, 9, 15),
      items: const [
        SaleItemRecord(
          productName: 'Mie Goreng Special',
          quantity: 1,
          unitPrice: 35000,
        ),
        SaleItemRecord(
          productName: 'Es Teh Manis',
          quantity: 1,
          unitPrice: 10000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0003',
      orderLabel: 'Meja 06',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 45000,
      tax: 0,
      total: 45000,
      createdAt: DateTime(now.year, now.month, now.day, 8, 35),
      items: const [
        SaleItemRecord(
          productName: 'Mie Ayam Special',
          quantity: 1,
          unitPrice: 45000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0002',
      orderLabel: 'Meja 05',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 70000,
      tax: 0,
      total: 70000,
      createdAt: DateTime(now.year, now.month, now.day, 8, 10),
      items: const [
        SaleItemRecord(
          productName: 'Ayam Kuluyuk',
          quantity: 1,
          unitPrice: 38000,
        ),
        SaleItemRecord(
          productName: 'Nasi Goreng',
          quantity: 1,
          unitPrice: 32000,
        ),
      ],
    ),
    SaleRecord(
      id: 'TRX-0001',
      orderLabel: 'Take Away #01',
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
      subtotal: 68000,
      tax: 0,
      total: 68000,
      createdAt: DateTime(now.year, now.month, now.day, 7, 15),
      items: const [
        SaleItemRecord(
          productName: 'Lumpia Udang',
          quantity: 1,
          unitPrice: 36000,
        ),
        SaleItemRecord(
          productName: 'Nasi Goreng',
          quantity: 1,
          unitPrice: 32000,
        ),
      ],
    ),
  ];

  return list.map((t) {
    final tax = (t.subtotal * 0.1).round();
    return t.copyWith(
      tax: tax,
      total: t.subtotal + tax,
      paymentMethod: 'Cash',
      cashier: 'Kasir 1',
    );
  }).toList();
}

Map<String, PendingOrder> generateInitialPendingOrders(List<MenuItem> menu) {
  final now = DateTime.now();
  MenuItem find(String id) => menu.firstWhere((m) => m.id == id);

  return {
    'Meja 02': PendingOrder(
      label: 'Meja 02',
      items: {
        '1': CartLine(item: find('1'), quantity: 1),
        '9': CartLine(item: find('9'), quantity: 1),
      },
      createdAt: now.subtract(const Duration(minutes: 35)),
      updatedAt: now.subtract(const Duration(minutes: 35)),
    ),
    'Meja 03': PendingOrder(
      label: 'Meja 03',
      items: {
        '2': CartLine(item: find('2'), quantity: 1),
        '11': CartLine(item: find('11'), quantity: 1),
      },
      createdAt: now.subtract(const Duration(minutes: 70)),
      updatedAt: now.subtract(const Duration(minutes: 70)),
    ),
    'Meja 05': PendingOrder(
      label: 'Meja 05',
      items: {
        '5': CartLine(item: find('5'), quantity: 1),
      },
      createdAt: now.subtract(const Duration(minutes: 12)),
      updatedAt: now.subtract(const Duration(minutes: 12)),
    ),
    'Meja 06': PendingOrder(
      label: 'Meja 06',
      items: {
        '4': CartLine(item: find('4'), quantity: 1),
        '10': CartLine(item: find('10'), quantity: 1),
      },
      createdAt: now.subtract(const Duration(minutes: 45)),
      updatedAt: now.subtract(const Duration(minutes: 45)),
    ),
    'Meja 08': PendingOrder(
      label: 'Meja 08',
      items: {
        '6': CartLine(item: find('6'), quantity: 1),
        '9': CartLine(item: find('9'), quantity: 1),
      },
      createdAt: now.subtract(const Duration(minutes: 20)),
      updatedAt: now.subtract(const Duration(minutes: 20)),
    ),
    'Meja 09': PendingOrder(
      label: 'Meja 09',
      items: {
        '2': CartLine(item: find('2'), quantity: 1),
        '4': CartLine(item: find('4'), quantity: 1),
        '9': CartLine(item: find('9'), quantity: 2),
      },
      createdAt: now.subtract(const Duration(minutes: 90)),
      updatedAt: now.subtract(const Duration(minutes: 90)),
    ),
  };
}
