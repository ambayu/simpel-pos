import 'package:flutter/material.dart';

/// Centralized design tokens for the hotpot themed point of sale UI.
class AppBrand {
  const AppBrand._();

  static const name = 'The Legend Hotpot';
  static const tagline = 'Rasa Legenda, Layanan Lebih Cepat';
  static const description = 'Solusi Kasir Modern untuk Restoran Hotpot';
}

class AppColors {
  const AppColors._();

  static const primary = Color(0xFFC1272D);
  static const primaryDark = Color(0xFF8C1A1F);
  static const primarySoft = Color(0xFFFDECEC);
  static const accentGold = Color(0xFFD4A24C);

  static const background = Color(0xFFF8F8F8);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF5F5F5);
  static const border = Color(0xFFE5E5E5);

  static const textPrimary = Color(0xFF1F2937);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFF9CA3AF);

  static const statusFreeBg = Color(0xFFE8F5EC);
  static const statusFreeBorder = Color(0xFFA9D8BA);
  static const statusFreeText = Color(0xFF1F7A45);

  static const statusOccupiedBg = Color(0xFFFBE3E3);
  static const statusOccupiedBorder = Color(0xFFEFA9A9);
  static const statusOccupiedText = Color(0xFFB0242A);

  static const statusReservedBg = Color(0xFFFDF3DC);
  static const statusReservedBorder = Color(0xFFE7C67B);
  static const statusReservedText = Color(0xFF9A6B12);

  static const success = Color(0xFF16A34A);
  static const danger = Color(0xFFDC2626);
}

/// Static asset paths bundled with the application.
class AppAssets {
  const AppAssets._();

  static const logo = 'assets/branding/logo.png';
  static const landingCollage = 'assets/branding/landing_food_collage.png';
  static const cherryBlossom = 'assets/branding/cherry_blossom_decor.png';
  static const leftDimSumBowl = 'assets/branding/left_dim_sum_bowl.png';
  static const rightFoodBowl = 'assets/branding/right_food_bowl.png';
  static const chinaLandscape =
      'assets/lanskap_tiongkok_minimalis_dengan_bunga_sakura.png';
  static const culinaryBackground =
      'assets/latar_kuliner_tionghoa_dengan_bunga_sakura.png';

  static const roleOwner =
      'assets/roles/avatar_manajer_bisnis_bersetelan_merah_transparent.png';
  static const roleAdmin =
      'assets/roles/avatar_admin_wanita_berambut_cokelat_transparent.png';
  static const roleCashier =
      'assets/roles/avatar_kasir_ramah_beruniform_merah_transparent.png';
  static const roleStaff =
      'assets/roles/avatar_pelayan_restoran_bergaya_flat_transparent.png';

  static const heroMieGorengSpecial = 'assets/food/mie_goreng_special_hero.png';
  static const ayamKuluyuk = 'assets/food/ayam_kuluyuk.png';
  static const mieGoreng = 'assets/food/mie_goreng.png';
  static const nasiGoreng = 'assets/food/nasi_goreng.png';
  static const capCai = 'assets/food/cap_cai.png';
  static const dumplingAyam = 'assets/food/dumpling_ayam.png';
  static const lumpiaUdang = 'assets/food/lumpia_udang.png';
  static const cartMieGorengSpecial = 'assets/food/cart_mie_goreng_special.png';
  static const cartNasiGorengSeafood =
      'assets/food/cart_nasi_goreng_seafood.png';
  static const cartLumpiaUdang = 'assets/food/cart_lumpia_udang.png';
}

class AppTheme {
  const AppTheme._();

  static ThemeData build() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.accentGold,
          surface: AppColors.surface,
          error: AppColors.danger,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Segoe UI',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceMuted,
        selectedColor: AppColors.primary,
        side: const BorderSide(color: AppColors.border),
        labelStyle: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceMuted,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: AppColors.primary, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 24,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primarySoft,
        elevation: 0,
        height: 62,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.textMuted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class AdminBackdrop extends StatelessWidget {
  const AdminBackdrop({
    super.key,
    required this.child,
    this.imageOpacity = .28,
    this.overlayOpacity = .55,
  });

  final Widget child;
  final double imageOpacity;
  final double overlayOpacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: imageOpacity,
          child: Image.asset(
            AppAssets.chinaLandscape,
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
            errorBuilder: (_, _, _) =>
                const ColoredBox(color: AppColors.background),
          ),
        ),
        ColoredBox(color: Colors.white.withValues(alpha: overlayOpacity)),
        child,
      ],
    );
  }
}
