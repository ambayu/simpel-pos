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
// Seed transactions historis Jan 2025 – Sep 2026 dengan total bulanan:
//   normal   : Rp 5.000.000 – 6.000.000
//   hari besar: Rp 7.000.000 – 8.000.000
// Setiap bulan di-split menjadi ~20–25 transaksi harian dengan item realistis.
// ---------------------------------------------------------------------------
List<SaleRecord> generateHistoricalTransactions() {
  final records = <SaleRecord>[];
  int trxCounter = 1000;

  // Produk-produk yang digunakan sebagai item historis (subset menu restoran)
  final historicalItems = [
    const SaleItemRecord(productName: 'Collagen Soup (200 gram)', quantity: 1, unitPrice: 70000),
    const SaleItemRecord(productName: 'Mala Collagen Soup (200 gram)', quantity: 1, unitPrice: 70000),
    const SaleItemRecord(productName: 'Haisom LongChuan (Porsi M)', quantity: 1, unitPrice: 250000),
    const SaleItemRecord(productName: 'Kepiting Soka Lada Hitam (Porsi M)', quantity: 1, unitPrice: 125000),
    const SaleItemRecord(productName: 'Ikan Asam Pedas (Steam)', quantity: 1, unitPrice: 250000),
    const SaleItemRecord(productName: 'Udang Bakar Portuguese (Porsi M)', quantity: 1, unitPrice: 135000),
    const SaleItemRecord(productName: 'Bebek Asap Nenas Saus Plam (Porsi M)', quantity: 1, unitPrice: 125000),
    const SaleItemRecord(productName: 'Peking Duck Roll With Lotus Bun', quantity: 3, unitPrice: 100000),
    const SaleItemRecord(productName: 'Ayam Goreng KamHeong (Porsi M)', quantity: 1, unitPrice: 130000),
    const SaleItemRecord(productName: 'Nasi Goreng Seafood', quantity: 1, unitPrice: 60000),
    const SaleItemRecord(productName: 'Nasi Goreng Ayam', quantity: 2, unitPrice: 50000),
    const SaleItemRecord(productName: 'Mie Goreng Legend (200 gram)', quantity: 1, unitPrice: 70000),
    const SaleItemRecord(productName: 'Braised Tofu with Mushroom', quantity: 1, unitPrice: 80000),
    const SaleItemRecord(productName: 'Brokoli Scallop X.O (Porsi S)', quantity: 1, unitPrice: 80000),
    const SaleItemRecord(productName: 'Teh Tawar (Hot)', quantity: 2, unitPrice: 10000),
    const SaleItemRecord(productName: 'Teh Manis (Ice)', quantity: 2, unitPrice: 12000),
    const SaleItemRecord(productName: 'Ice Lychee Tea', quantity: 1, unitPrice: 25000),
    const SaleItemRecord(productName: 'Chinese Tea (2-5 pax)', quantity: 1, unitPrice: 25000),
    const SaleItemRecord(productName: 'Mineral Water', quantity: 2, unitPrice: 18000),
    const SaleItemRecord(productName: 'Bir Bintang Botol (Besar)', quantity: 1, unitPrice: 58000),
    const SaleItemRecord(productName: 'Chicken Nugget', quantity: 1, unitPrice: 25000),
    const SaleItemRecord(productName: 'Kentang Goreng', quantity: 1, unitPrice: 25000),
    const SaleItemRecord(productName: 'Cumi Salted Egg (Porsi S)', quantity: 1, unitPrice: 100000),
    const SaleItemRecord(productName: 'Mapo Tofu', quantity: 1, unitPrice: 80000),
    const SaleItemRecord(productName: 'US Beef in Black Pepper Sauce (Porsi M)', quantity: 1, unitPrice: 125000),
  ];

  final paymentMethods = ['Tunai', 'QRIS', 'E-Wallet', 'Kartu'];
  final cashiers = ['Kasir', 'Budi', 'Sari', 'Rini'];
  final tableLabels = [
    'Meja 01', 'Meja 02', 'Meja 03', 'Meja 04', 'Meja 05',
    'Meja 06', 'Meja 07', 'Meja 08', 'Meja 09', 'Meja 10',
    'Take Away #01', 'Take Away #02',
  ];

  // Range bulan: Jan 2025 – Sep 2026
  final months = <(int, int)>[];
  for (var m = 1; m <= 12; m++) { months.add((2025, m)); }
  for (var m = 1; m <= 9; m++) { months.add((2026, m)); }

  // Pseudo-random deterministik pakai seed manual
  var seed = 42;
  int rng(int min, int max) {
    seed = (seed * 1103515245 + 12345) & 0x7fffffff;
    return min + (seed % (max - min + 1));
  }

  for (final (year, month) in months) {
    final isBulanBesar = _isHariBesar(year, month);
    final targetTotal = isBulanBesar
        ? 7000000 + rng(0, 1000000)  // 7jt – 8jt
        : 5000000 + rng(0, 1000000); // 5jt – 6jt

    // Jumlah transaksi per bulan: 20–28
    final txCount = rng(20, 28);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // Distribusi total transaksi ke txCount transaksi
    var remaining = targetTotal;
    for (var i = 0; i < txCount; i++) {
      final isLast = i == txCount - 1;
      final int trxTotal;
      if (isLast) {
        trxTotal = remaining.clamp(80000, 800000);
      } else {
        final avg = remaining ~/ (txCount - i);
        final variance = (avg * 0.3).round();
        trxTotal = (avg - variance + rng(0, variance * 2)).clamp(80000, 800000);
        remaining -= trxTotal;
      }

      // Pilih item untuk transaksi ini
      final itemIdx1 = rng(0, historicalItems.length - 1);
      var itemIdx2 = rng(0, historicalItems.length - 1);
      while (itemIdx2 == itemIdx1) {
        itemIdx2 = rng(0, historicalItems.length - 1);
      }
      final items = [historicalItems[itemIdx1], historicalItems[itemIdx2]];

      final subtotal = trxTotal; // tax 0 supaya konsisten dengan data existing
      final day = rng(1, daysInMonth);
      final hour = rng(10, 22);
      final minute = rng(0, 59);
      final tableLabel = tableLabels[rng(0, tableLabels.length - 1)];
      final payment = paymentMethods[rng(0, paymentMethods.length - 1)];
      final cashier = cashiers[rng(0, cashiers.length - 1)];

      records.add(SaleRecord(
        id: 'TRX-H${(trxCounter++).toString().padLeft(5, '0')}',
        orderLabel: tableLabel,
        paymentMethod: payment,
        cashier: cashier,
        subtotal: subtotal,
        tax: 0,
        total: subtotal,
        createdAt: DateTime(year, month, day, hour, minute),
        items: items,
      ));
    }
  }

  // Urutkan dari terlama ke terbaru
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
