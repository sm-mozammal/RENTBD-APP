import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../config/app_environment.dart';
import '../theme/app_colors.dart';

/// Universal image widget that intelligently displays:
/// 1. Remote HTTP/HTTPS network URLs
/// 2. Relative URLs (/media/...) with automatic base URL expansion
/// 3. Android Emulator 127.0.0.1 -> 10.0.2.2 host mapping
/// 4. Local device filesystem paths (e.g. from camera/gallery)
/// 5. Clean placeholder fallback upon loading error or empty path
class BariImage extends StatelessWidget {
  const BariImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholderIcon = Icons.apartment_rounded,
    this.placeholderColor,
  });

  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;
  final Color? placeholderColor;

  static String normalizeUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    String url = raw.trim();

    if (url.startsWith('/media/') || url.startsWith('/static/')) {
      final base = AppEnvironment.baseUrl.replaceAll('/api/v1', '');
      url = '$base$url';
    }

    if (!kIsWeb) {
      try {
        if (Platform.isAndroid) {
          if (url.contains('127.0.0.1:8000')) {
            url = url.replaceAll('127.0.0.1:8000', '10.0.2.2:8000');
          } else if (url.contains('localhost:8000')) {
            url = url.replaceAll('localhost:8000', '10.0.2.2:8000');
          }
        }
      } catch (_) {}
    }
    return url;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: placeholderColor ?? AppColors.primarySoft,
      child: Center(
        child: Icon(
          placeholderIcon,
          size: (width != null && width! < 60) ? 22 : 36,
          color: AppColors.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cleaned = normalizeUrl(imageUrl);
    Widget imageWidget;

    if (cleaned.isEmpty) {
      imageWidget = _buildPlaceholder();
    } else if (cleaned.startsWith('http://') || cleaned.startsWith('https://')) {
      imageWidget = Image.network(
        cleaned,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (ctx, err, stack) => _buildPlaceholder(),
        loadingBuilder: (ctx, child, progress) {
          if (progress == null) return child;
          return Container(
            width: width,
            height: height,
            color: AppColors.lightBackground,
            child: const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
            ),
          );
        },
      );
    } else {
      // Local device filesystem path (e.g. from camera/gallery)
      final filePath = cleaned.replaceFirst('file://', '');
      final file = File(filePath);
      if (file.existsSync()) {
        imageWidget = Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (ctx, err, stack) => _buildPlaceholder(),
        );
      } else {
        imageWidget = _buildPlaceholder();
      }
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
