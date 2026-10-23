import 'package:flutter/material.dart';
import '../config.dart';
import '../models/enums.dart';

/// Shows the photo uploaded for a vehicle. A vehicle without photo (or whose photo cannot be
/// loaded) shows the default picture of its category, bundled in assets/images/vehicles.
class VehicleImage extends StatelessWidget {
  const VehicleImage({
    super.key,
    required this.photoUrl,
    required this.category,
    this.fit = BoxFit.cover,
  });

  final String? photoUrl;
  final VehicleCategory category;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final fallback = Image.asset(category.photoAsset, fit: fit, width: double.infinity, height: double.infinity);
    final url = photoUrl;
    if (url == null || url.isEmpty) return fallback;
    return Image.network(
      AppConfig.url(url),
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      // the default picture stays visible while the real one downloads
      loadingBuilder: (context, child, progress) => progress == null ? child : fallback,
      errorBuilder: (context, error, stack) => fallback,
    );
  }
}
