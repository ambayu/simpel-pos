import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Renders a product picture from either a bundled asset or a user picked file,
/// falling back to a themed icon placeholder when no valid image is available.
class FoodImage extends StatelessWidget {
  const FoodImage({
    super.key,
    this.assetPath,
    this.filePath,
    required this.fallbackIcon,
    required this.fallbackColor,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
    this.iconSize = 34,
  });

  final String? assetPath;
  final String? filePath;
  final IconData fallbackIcon;
  final Color fallbackColor;
  final double borderRadius;
  final BoxFit fit;
  final double iconSize;

  bool get _hasLocalFile {
    final path = filePath;
    if (path == null || path.isEmpty || kIsWeb) return false;
    return File(path).existsSync();
  }

  @override
  Widget build(BuildContext context) {
    final Widget content;

    if (_hasLocalFile) {
      content = Image.file(
        File(filePath!),
        fit: fit,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    } else if (assetPath != null && assetPath!.isNotEmpty) {
      content = Image.asset(
        assetPath!,
        fit: fit,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    } else {
      content = _placeholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox.expand(child: content),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.surfaceMuted,
      alignment: Alignment.center,
      child: Icon(fallbackIcon, size: iconSize, color: fallbackColor),
    );
  }
}
