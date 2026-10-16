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
// Katalog menu lengkap untuk data historis — dikelompokkan per kategori
// sehingga kombinasi item per transaksi terasa natural (makanan + minuman)
// ---------------------------------------------------------------------------
class _MenuItem {
  const _MenuItem(this.name, this.price);
  final String name;
  final int price;
}

const _menuMakanan = <_MenuItem>[
  _MenuItem('Collagen Soup (200 gram)', 70000),
  _MenuItem('Mala Collagen Soup (200 gram)', 70000),
  _MenuItem('Collagen Soup (300 gram)', 105000),
  _MenuItem('Haisom LongChuan (Porsi M)', 250000),
  _MenuItem('Haisom LongChuan (Porsi L)', 450000),
  _MenuItem('Kepiting Soka Lada Hitam (Porsi M)', 125000),
  _MenuItem('Kepiting Soka X.O Bao (Porsi S)', 80000),
  _MenuItem('Ikan Asam Pedas (Steam)', 250000),
  _MenuItem('Ikan Asam Manis', 250000),
  _MenuItem('Ikan Saus Nyonya Special', 250000),
  _MenuItem('Ikan Crispy Saus Thai', 250000),
  _MenuItem('Ikan Fillet Bakar Portugues (Porsi M)', 80000),
  _MenuItem('Udang Bakar Portuguese (Porsi M)', 135000),
  _MenuItem('Udang Goreng Spesial (Porsi M)', 135000),
  _MenuItem('Udang KamHeong (Porsi S)', 80000),
  _MenuItem('Bebek Asap Nenas Saus Plam (Porsi M)', 125000),
  _MenuItem('Peking Duck Roll With Lotus Bun', 100000),
  _MenuItem('Crispy Peking Duck Roll (Porsi M)', 80000),
  _MenuItem('Ayam Goreng KamHeong (Porsi M)', 130000),
  _MenuItem('Ayam Saus Tape (Porsi S)', 80000),
  _MenuItem('Ayam Kung Pao (Porsi M)', 80000),
  _MenuItem('Ayam Kampung Hainam (Porsi M)', 150000),
  _MenuItem('Ayam Goreng Thai (Porsi S)', 60000),
  _MenuItem('Szechuan Mala Chicken (Porsi S)', 70000),
  _MenuItem('US Beef in Black Pepper Sauce (Porsi M)', 125000),
  _MenuItem('US Beef in Teriyaki Sauce (Porsi M)', 125000),
  _MenuItem('Cumi Salted Egg (Porsi S)', 100000),
  _MenuItem('Cumi Goreng Spesial (Porsi S)', 70000),
  _MenuItem('Mapo Tofu', 80000),
  _MenuItem('Braised Tofu with Mushroom', 80000),
  _MenuItem('Tahu Bumbu Bawang', 50000),
  _MenuItem('Brokoli Scallop X.O (Porsi S)', 80000),
  _MenuItem('Brokoli Bebek Asap (Porsi S)', 80000),
  _MenuItem('Brokoli Salted Egg', 125000),
  _MenuItem('Fu Yung Hai (Porsi S)', 50000),
  _MenuItem('Nasi Goreng Seafood', 60000),
  _MenuItem('Nasi Goreng Ayam', 50000),
  _MenuItem('Nasi Goreng Telur', 40000),
  _MenuItem('Mie Goreng Legend (200 gram)', 70000),
  _MenuItem('Mie Goreng Legend (300 gram)', 105000),
  _MenuItem('Chicken Nugget', 25000),
  _MenuItem('Kentang Goreng', 25000),
  _MenuItem('Pisang Goreng Crispy', 35000),
];

const _menuMinuman = <_MenuItem>[
  _MenuItem('Teh Tawar (Hot)', 10000),
  _MenuItem('Teh Tawar (Ice)', 12000),
  _MenuItem('Teh Manis (Hot)', 10000),
  _MenuItem('Teh Manis (Ice)', 12000),
  _MenuItem('Ice Lemon Tea', 15000),
  _MenuItem('Ice Lychee Tea', 25000),
  _MenuItem('Chinese Tea (2-5 pax)', 25000),
  _MenuItem('Chinese Tea (6-10 pax)', 45000),
  _MenuItem('Manggo Lychee', 25000),
  _MenuItem('Juice Semboi', 25000),
  _MenuItem('Teh Markisa', 25000),
  _MenuItem('Black Coffee (Hot)', 30000),
  _MenuItem('Milk Coffee (Ice)', 35000),
  _MenuItem('Mineral Water', 18000),
  _MenuItem('Green Tea', 18000),
  _MenuItem('Chrysanthemum Tea', 20000),
  _MenuItem('Wang Lo Kat Tea', 28000),
  _MenuItem('Bir Bintang Kaleng (Kecil)', 38000),
  _MenuItem('Bir Bintang Botol (Besar)', 58000),
  _MenuItem('Bir Heineken Kaleng (Kecil)', 45000),
];

// ---------------------------------------------------------------------------
// Seed transactions historis Jan 2025 – Sep 2026
//   normal    : Rp 5.000.000 – 6.000.000 / bulan
//   hari besar: Rp 7.000.000 – 8.000.000 / bulan
// Data dibuat se-realistis mungkin: variasi item, qty, jam peak/off-peak,
// distribusi harian yang tidak rata, dan kombinasi makanan + minuman.
// ---------------------------------------------------------------------------
List<SaleRecord> generateHistoricalTransactions() {
  final records = <SaleRecord>[];
  int trxCounter = 1000;

  const paymentMethods = ['Tunai', 'QRIS', 'QRIS', 'E-Wallet', 'Kartu'];
  const cashiers       = ['Kasir', 'Budi', 'Sari', 'Rini', 'Budi', 'Kasir'];
  const tableLabels    = [
    'Meja 01', 'Meja 02', 'Meja 03', 'Meja 04', 'Meja 05',
    'Meja 06', 'Meja 07', 'Meja 08', 'Meja 09', 'Meja 10',
    'Meja 11', 'Meja 12',
    'Take Away #01', 'Take Away #02', 'Take Away #03',
  ];

  // Peak hours — lebih banyak transaksi di jam makan siang & malam
  // [jam, bobot] → bobot lebih tinggi = lebih sering dipilih
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

  // Bangun satu transaksi realistis dari pool menu
  List<SaleItemRecord> buildItems() {
    final itemCount = rng(0, 9) < 6 ? rng(2, 3) : rng(1, 4); // 60% → 2-3 item
    final picked = <String>{};
    final result  = <SaleItemRecord>[];

    // Selalu ambil minimal 1 makanan
    for (var attempt = 0; attempt < 10 && result.isEmpty; attempt++) {
      final m = _menuMakanan[rng(0, _menuMakanan.length - 1)];
      if (!picked.contains(m.name)) {
        picked.add(m.name);
        final qty = rng(0, 5) < 4 ? 1 : rng(2, 3);
        result.add(SaleItemRecord(productName: m.name, quantity: qty, unitPrice: m.price));
      }
    }

    // Tambah item makanan/minuman berikutnya
    for (var i = result.length; i < itemCount; i++) {
      final isMinum = rng(0, 2) == 0; // 33% minuman
      final pool    = isMinum ? _menuMinuman : _menuMakanan;
      for (var attempt = 0; attempt < 10; attempt++) {
        final m = pool[rng(0, pool.length - 1)];
        if (!picked.contains(m.name)) {
          picked.add(m.name);
          final qty = isMinum ? rng(1, 3) : (rng(0, 4) < 4 ? 1 : 2);
          result.add(SaleItemRecord(productName: m.name, quantity: qty, unitPrice: m.price));
          break;
        }
      }
    }

    // Hampir selalu ada minuman di akhir jika belum ada
    final hasMinum = result.any((r) => _menuMinuman.any((m) => m.name == r.productName));
    if (!hasMinum && rng(0, 3) > 0) {
      final m = _menuMinuman[rng(0, _menuMinuman.length - 1)];
      if (!picked.contains(m.name)) {
        result.add(SaleItemRecord(productName: m.name, quantity: rng(1, 3), unitPrice: m.price));
      }
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
    final txCount    = isBulanBesar ? rng(28, 38) : rng(20, 28);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // Distribusi harian — bukan rata, lebih banyak di tengah & akhir bulan
    // (weekend effect disimulasikan lewat bobot)
    var remaining = targetTotal;

    for (var i = 0; i < txCount; i++) {
      final isLast = i == txCount - 1;

      // Nominal per transaksi — distribusikan dengan variasi natural
      final int trxTarget;
      if (isLast) {
        trxTarget = remaining.clamp(60000, 900000);
      } else {
        final avg      = remaining ~/ (txCount - i);
        final variance = (avg * 0.4).round();
        trxTarget = (avg - variance + rng(0, variance * 2)).clamp(60000, 900000);
        remaining -= trxTarget;
      }

      // Bangun items, hitung subtotal real dari item
      final items   = buildItems();
      final rawTotal = items.fold<int>(0, (s, r) => s + r.unitPrice * r.quantity);

      // Jika rawTotal jauh dari trxTarget, coba ulangi sekali lagi
      // (tidak memaksa match persis — natural itu tidak pernah tepat)
      final subtotal = rawTotal.clamp(50000, 1200000);

      // Pilih hari: distribusi tidak rata (lebih padat di hari 10–25)
      final dayBias = rng(0, 9) < 7
          ? rng(5, daysInMonth)         // 70% → pertengahan–akhir bulan
          : rng(1, 10);                 // 30% → awal bulan
      final day    = dayBias.clamp(1, daysInMonth);
      final hour   = hourPool[rng(0, hourPool.length - 1)];
      final minute = rng(0, 59);

      records.add(SaleRecord(
        id: 'TRX-H${(trxCounter++).toString().padLeft(5, '0')}',
        orderLabel: tableLabels[rng(0, tableLabels.length - 1)],
        paymentMethod: paymentMethods[rng(0, paymentMethods.length - 1)],
        cashier: cashiers[rng(0, cashiers.length - 1)],
        subtotal: subtotal,
        tax: 0,
        total: subtotal,
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
  return [
    SaleRecord(
      id: 'TRX-0048',
      orderLabel: 'Meja 06',
      paymentMethod: 'QRIS',
      cashier: 'Budi',
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
      paymentMethod: 'Tunai',
      cashier: 'Kasir',
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
      paymentMethod: 'E-Wallet',
      cashier: 'Budi',
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
      paymentMethod: 'QRIS',
      cashier: 'Kasir',
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
      paymentMethod: 'Kartu',
      cashier: 'Budi',
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
      paymentMethod: 'Tunai',
      cashier: 'Kasir',
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
      paymentMethod: 'QRIS',
      cashier: 'Budi',
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
      paymentMethod: 'Tunai',
      cashier: 'Kasir',
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
      paymentMethod: 'QRIS',
      cashier: 'Budi',
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
      paymentMethod: 'Tunai',
      cashier: 'Kasir',
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
      paymentMethod: 'E-Wallet',
      cashier: 'Budi',
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
      paymentMethod: 'QRIS',
      cashier: 'Kasir',
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
      paymentMethod: 'Kartu',
      cashier: 'Budi',
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
      paymentMethod: 'Tunai',
      cashier: 'Kasir',
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
      paymentMethod: 'QRIS',
      cashier: 'Budi',
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
      paymentMethod: 'Tunai',
      cashier: 'Kasir',
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
      paymentMethod: 'QRIS',
      cashier: 'Budi',
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
      paymentMethod: 'Tunai',
      cashier: 'Kasir',
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
      paymentMethod: 'E-Wallet',
      cashier: 'Budi',
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
      paymentMethod: 'QRIS',
      cashier: 'Kasir',
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
      paymentMethod: 'Kartu',
      cashier: 'Budi',
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
      paymentMethod: 'Tunai',
      cashier: 'Kasir',
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
      paymentMethod: 'QRIS',
      cashier: 'Budi',
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
      paymentMethod: 'Tunai',
      cashier: 'Kasir',
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
      paymentMethod: 'QRIS',
      cashier: 'Budi',
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
      paymentMethod: 'Tunai',
      cashier: 'Kasir',
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
      paymentMethod: 'E-Wallet',
      cashier: 'Budi',
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
      paymentMethod: 'QRIS',
      cashier: 'Kasir',
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
      paymentMethod: 'Kartu',
      cashier: 'Budi',
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
      paymentMethod: 'Tunai',
      cashier: 'Kasir',
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
      paymentMethod: 'QRIS',
      cashier: 'Budi',
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
      paymentMethod: 'Tunai',
      cashier: 'Kasir',
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
      paymentMethod: 'QRIS',
      cashier: 'Budi',
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
      paymentMethod: 'Tunai',
      cashier: 'Kasir',
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
      paymentMethod: 'E-Wallet',
      cashier: 'Budi',
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
      paymentMethod: 'QRIS',
      cashier: 'Kasir',
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
      paymentMethod: 'Kartu',
      cashier: 'Budi',
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
      paymentMethod: 'Tunai',
      cashier: 'Kasir',
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
      paymentMethod: 'QRIS',
      cashier: 'Budi',
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
      paymentMethod: 'Tunai',
      cashier: 'Kasir',
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
      paymentMethod: 'Tunai',
      cashier: 'Kasir',
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
      paymentMethod: 'QRIS',
      cashier: 'Budi',
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
      paymentMethod: 'Tunai',
      cashier: 'Kasir',
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
      paymentMethod: 'QRIS',
      cashier: 'Budi',
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
      paymentMethod: 'Tunai',
      cashier: 'Kasir',
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
      paymentMethod: 'E-Wallet',
      cashier: 'Budi',
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
      paymentMethod: 'QRIS',
      cashier: 'Kasir',
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
      paymentMethod: 'Kartu',
      cashier: 'Budi',
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
