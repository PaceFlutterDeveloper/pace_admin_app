// import 'dart:io';

// import 'package:admin_app/UI/public/user/utils/careers_media_url.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// /// Displays a careers profile photo from a local file, API path/URL, or
// /// inline base64 text returned by the API.
// class CareersProfileImage extends StatelessWidget {
//   final String? remoteSource;
//   final File? localFile;
//   final double size;
//   final BoxFit fit;
//   final IconData placeholderIcon;

//   const CareersProfileImage({
//     super.key,
//     this.remoteSource,
//     this.localFile,
//     required this.size,
//     this.fit = BoxFit.cover,
//     this.placeholderIcon = CupertinoIcons.person_fill,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final placeholder = _placeholder(theme);
//     final remote = remoteSource?.trim();
//     final hasRemote = remote != null && remote.isNotEmpty;

//     if (hasRemote) {
//       if (CareersMediaUrl.isEmbeddedFileData(remote)) {
//         final embeddedBytes = CareersMediaUrl.decodeEmbeddedBytes(remote);
//         if (embeddedBytes != null) {
//           return ClipOval(
//             child: Image.memory(
//               embeddedBytes,
//               key: ValueKey(remote.hashCode),
//               width: size,
//               height: size,
//               fit: fit,
//               errorBuilder: (_, __, ___) => _localOrPlaceholder(placeholder),
//             ),
//           );
//         }
//         return ClipOval(child: _localOrPlaceholder(placeholder));
//       }

//       final resolvedUrl = CareersMediaUrl.resolve(remote);
//       if (resolvedUrl != null) {
//         return ClipOval(
//           child: Image.network(
//             resolvedUrl,
//             key: ValueKey(resolvedUrl),
//             width: size,
//             height: size,
//             fit: fit,
//             errorBuilder: (_, __, ___) => _localOrPlaceholder(placeholder),
//             loadingBuilder: (context, child, progress) {
//               if (progress == null) return child;
//               return _localOrPlaceholder(placeholder, showLoading: false);
//             },
//           ),
//         );
//       }
//     }

//     return ClipOval(child: _localOrPlaceholder(placeholder));
//   }

//   Widget _localOrPlaceholder(Widget placeholder, {bool showLoading = true}) {
//     final file = localFile;
//     if (file != null && file.existsSync()) {
//       return Image.file(
//         file,
//         width: size,
//         height: size,
//         fit: fit,
//         errorBuilder: (_, __, ___) => placeholder,
//       );
//     }
//     return placeholder;
//   }

//   Widget _placeholder(ThemeData theme) {
//     return Container(
//       width: size,
//       height: size,
//       color: theme.colorScheme.primary.withValues(alpha: 0.12),
//       child: Icon(
//         placeholderIcon,
//         size: size * 0.45,
//         color: theme.colorScheme.primary,
//       ),
//     );
//   }
// }


import 'dart:io';

import 'package:admin_app/UI/public/user/utils/careers_avatar_cache.dart';
import 'package:admin_app/UI/public/user/utils/careers_media_url.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Displays a careers profile photo from a local file, API path/URL, or
/// inline base64 text returned by the API.
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

    // Priority 1: local file (picked or cached) — always prefer this
    final file = localFile ?? CareersAvatarCache.getCachedFile();
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

    // Priority 2: remote source (URL or valid embedded base64)
    final remote = remoteSource?.trim();
    final hasRemote = remote != null && remote.isNotEmpty;

    // ── DEBUG ──────────────────────────────────────────────────────────────
    debugPrint('=== CareersProfileImage ===');
    debugPrint('remoteSource length : ${remote?.length}');
    debugPrint('isEmbedded          : ${CareersMediaUrl.isEmbeddedFileData(remote)}');
    debugPrint('decodedBytes length : ${CareersMediaUrl.decodeEmbeddedBytes(remote)?.length}');
    debugPrint('resolvedUrl         : ${CareersMediaUrl.resolve(remote)}');
    debugPrint('localFile path      : ${localFile?.path}');
    debugPrint('localFile exists    : ${localFile?.existsSync()}');
    debugPrint('hasRemote           : $hasRemote');
    // ───────────────────────────────────────────────────────────────────────

    if (hasRemote) {
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
      if (resolvedUrl != null) {
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
    }

    return ClipOval(child: placeholder);
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