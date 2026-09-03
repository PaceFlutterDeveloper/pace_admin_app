import 'dart:io';

import 'package:admin_app/UI/public/user/utils/careers_media_url.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Displays a careers profile photo from a picked local preview or a
/// server-provided path/URL/base64 value. Never falls back to disk cache.
class CareersProfileImage extends StatelessWidget {
  final String? remoteSource;
  final File? localFile;
  final double size;
  final BoxFit fit;
  final IconData placeholderIcon;

  const CareersProfileImage({
    super.key,
    this.remoteSource,
    this.localFile,
    required this.size,
    this.fit = BoxFit.cover,
    this.placeholderIcon = CupertinoIcons.person_fill,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placeholder = _placeholder(theme);

    final file = localFile;
    if (file != null && file.existsSync()) {
      return ClipOval(
        child: Image.file(
          file,
          width: size,
          height: size,
          fit: fit,
          errorBuilder: (_, __, ___) => placeholder,
        ),
      );
    }

    final remote = remoteSource?.trim();
    if (remote == null ||
        remote.isEmpty ||
        CareersMediaUrl.isLocalFilePath(remote)) {
      return ClipOval(child: placeholder);
    }

    if (CareersMediaUrl.isEmbeddedFileData(remote)) {
      final embeddedBytes = CareersMediaUrl.decodeEmbeddedBytes(remote);
      if (embeddedBytes != null) {
        return ClipOval(
          child: Image.memory(
            embeddedBytes,
            key: ValueKey(remote.hashCode),
            width: size,
            height: size,
            fit: fit,
            errorBuilder: (_, __, ___) => placeholder,
          ),
        );
      }
      return ClipOval(child: placeholder);
    }

    final resolvedUrl = CareersMediaUrl.resolve(remote);
    if (resolvedUrl == null) {
      return ClipOval(child: placeholder);
    }

    return ClipOval(
      child: Image.network(
        resolvedUrl,
        key: ValueKey(resolvedUrl),
        width: size,
        height: size,
        fit: fit,
        errorBuilder: (_, __, ___) => placeholder,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return placeholder;
        },
      ),
    );
  }

  Widget _placeholder(ThemeData theme) {
    return Container(
      width: size,
      height: size,
      color: theme.colorScheme.primary.withValues(alpha: 0.12),
      child: Icon(
        placeholderIcon,
        size: size * 0.45,
        color: theme.colorScheme.primary,
      ),
    );
  }
}
