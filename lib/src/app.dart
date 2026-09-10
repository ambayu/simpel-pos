import 'package:flutter/material.dart';

import 'pos_store.dart';
import 'screens/splash_page.dart';
import 'theme/app_theme.dart';

class SimpelPosApp extends StatefulWidget {
  const SimpelPosApp({super.key});

  @override
  State<SimpelPosApp> createState() => _SimpelPosAppState();
}

class _SimpelPosAppState extends State<SimpelPosApp> {
  final store = PosStore();

  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppBrand.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: SplashPage(store: store),
    );
  }
}
