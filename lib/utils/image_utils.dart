import 'package:flutter/foundation.dart';

/// Image URL utilities.
class ImageUrlUtils {
  static const String _ossParam = 'x-oss-process=image/quality,q_30';

  /// Append OSS quality suffix for optimized loading.
  ///
  /// - Skips if url is empty, not a network url, or already contains the param.
  /// - Preserves existing query params by using '&' when needed.
  static String optimize(String? url) {
    if (url == null) return '';
    final String trimmed = url.trim();
    if (trimmed.isEmpty) return trimmed;
    // Only handle http/https
    if (!(trimmed.startsWith('http://') || trimmed.startsWith('https://'))) {
      return trimmed;
    }
    if (trimmed.contains('x-oss-process=')) {
      return trimmed;
    }
    // If URL already has query parameters, append with '&'
    if (trimmed.contains('?')) {
      return '$trimmed&$_ossParam';
    }
    return '$trimmed?$_ossParam';
  }
}


