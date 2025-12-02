import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';

/// Cached network image with offline support
/// Perfect for profile photos and chat images
Widget imageshow({required String imageUrl, required String imageAsset}) {
  if (imageUrl.isEmpty) {
    return Image.asset(imageAsset, fit: BoxFit.cover);
  }

  return CachedNetworkImage(
    imageUrl: imageUrl,
    fit: BoxFit.cover,
    placeholder: (context, url) => Center(
      child: CircularProgressIndicator(
        color: AppPalette.blue,
        strokeWidth: 2,
      ),
    ),
    errorWidget: (context, url, error) => Image.asset(
      imageAsset,
      fit: BoxFit.cover,
    ),
    fadeInDuration: const Duration(milliseconds: 300),
    fadeOutDuration: const Duration(milliseconds: 300),
  );
}