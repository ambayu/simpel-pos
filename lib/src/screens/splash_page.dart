import 'package:flutter/material.dart';

import '../pos_store.dart';
import '../theme/app_theme.dart';
import 'login_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key, required this.store});

  final PosStore store;

  void _start(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => LoginPage(store: store)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;
            final compact = constraints.maxHeight < 720;

            if (isLandscape) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    AppAssets.landingLandscape,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (_, _, _) =>
                        const ColoredBox(color: AppColors.background),
                  ),
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: constraints.maxWidth * 0.08,
                    width: 320,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 95,
                            child: Image.asset(
                              AppAssets.logo,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.ramen_dining_rounded,
                                color: AppColors.primary,
                                size: 40,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              style: TextStyle(
                                fontFamily: 'Segoe UI',
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                height: 1.05,
                              ),
                              children: [
                                TextSpan(
                                  text: 'The Legend ',
                                  style: TextStyle(color: AppColors.textPrimary),
                                ),
                                TextSpan(
                                  text: 'Hotpot',
                                  style: TextStyle(color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            AppBrand.tagline,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 240,
                            child: FilledButton.icon(
                              onPressed: () => _start(context),
                              iconAlignment: IconAlignment.end,
                              icon: const Icon(Icons.chevron_right_rounded),
                              label: const Text('Mulai Sekarang'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  AppAssets.culinaryBackground,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (_, _, _) =>
                      const ColoredBox(color: AppColors.background),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: constraints.maxHeight * (compact ? .41 : .43),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: compact ? 160 : 195,
                          height: compact ? 125 : 155,
                          child: Image.asset(
                            AppAssets.logo,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.ramen_dining_rounded,
                              color: AppColors.primary,
                              size: 44,
                            ),
                          ),
                        ),
                        SizedBox(height: compact ? 2 : 4),
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(
                              fontFamily: 'Segoe UI',
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                            ),
                            children: [
                              TextSpan(
                                text: 'The Legend\n',
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                              TextSpan(
                                text: 'Hotpot',
                                style: TextStyle(color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: compact ? 4 : 6),
                        const Text(
                          AppBrand.tagline,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: compact ? 16 : 22),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _PageDot(active: true),
                            _PageDot(active: false),
                            _PageDot(active: false),
                          ],
                        ),
                        SizedBox(height: compact ? 12 : 16),
                        SizedBox(
                          width: constraints.maxWidth > 270
                              ? 270
                              : constraints.maxWidth - 40,
                          child: FilledButton.icon(
                            onPressed: () => _start(context),
                            iconAlignment: IconAlignment.end,
                            icon: const Icon(Icons.chevron_right_rounded),
                            label: const Text('Mulai Sekarang'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PageDot extends StatelessWidget {
  const _PageDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: active ? 18 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}
