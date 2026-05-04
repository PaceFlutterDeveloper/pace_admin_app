import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/themes/app_design_tokens.dart';

enum AppAvatarSize {
  xs,
  sm,
  md,
  lg,
  xl,
}

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final AppAvatarSize size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? fallbackIcon;
  final VoidCallback? onTap;
  final Widget? badge;
  final bool showBorder;
  final Color? borderColor;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = AppAvatarSize.md,
    this.backgroundColor,
    this.foregroundColor,
    this.fallbackIcon,
    this.onTap,
    this.badge,
    this.showBorder = false,
    this.borderColor,
  });

  double get _size {
    switch (size) {
      case AppAvatarSize.xs:
        return 24;
      case AppAvatarSize.sm:
        return AppSizes.avatarSm;
      case AppAvatarSize.md:
        return AppSizes.avatarMd;
      case AppAvatarSize.lg:
        return AppSizes.avatarLg;
      case AppAvatarSize.xl:
        return AppSizes.avatarXl;
    }
  }

  double get _fontSize {
    switch (size) {
      case AppAvatarSize.xs:
        return 10;
      case AppAvatarSize.sm:
        return 13;
      case AppAvatarSize.md:
        return 15;
      case AppAvatarSize.lg:
        return 20;
      case AppAvatarSize.xl:
        return 28;
    }
  }

  double get _iconSize {
    switch (size) {
      case AppAvatarSize.xs:
        return 14;
      case AppAvatarSize.sm:
        return 18;
      case AppAvatarSize.md:
        return 22;
      case AppAvatarSize.lg:
        return 28;
      case AppAvatarSize.xl:
        return 36;
    }
  }

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '';

    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Color _generateColor(String text) {
    if (text.isEmpty) return AppColors.iosSystemGray4;

    final hash = text.codeUnits.fold<int>(0, (prev, char) => prev + char);
    final colors = [
      const Color(0xFF5B2ED4),
      const Color(0xFF007AFF),
      const Color(0xFF34C759),
      const Color(0xFFFF9500),
      const Color(0xFFFF3B30),
      const Color(0xFFAF52DE),
      const Color(0xFF5AC8FA),
      const Color(0xFFFFCC00),
    ];
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final hasName = name != null && name!.isNotEmpty;
    final initials = hasName ? _getInitials(name!) : '';

    final effectiveBackgroundColor = backgroundColor ??
        (hasName
            ? _generateColor(name!)
            : (isDark ? AppColors.iosSystemGray : AppColors.iosSystemGray4));

    final effectiveForegroundColor = foregroundColor ?? Colors.white;

    Widget avatarContent;
    if (hasImage) {
      avatarContent = ClipOval(
        child: Image.network(
          imageUrl!,
          width: _size,
          height: _size,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildFallback(
              initials,
              effectiveBackgroundColor,
              effectiveForegroundColor,
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildFallback(
              initials,
              effectiveBackgroundColor,
              effectiveForegroundColor,
            );
          },
        ),
      );
    } else {
      avatarContent = _buildFallback(
        initials,
        effectiveBackgroundColor,
        effectiveForegroundColor,
      );
    }

    Widget avatar = Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: borderColor ?? (isDark ? Colors.white : Colors.white),
                width: size == AppAvatarSize.xl ? 3 : 2,
              )
            : null,
      ),
      child: avatarContent,
    );

    if (badge != null) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: -2,
            bottom: -2,
            child: badge!,
          ),
        ],
      );
    }

    if (onTap != null) {
      avatar = GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildFallback(
    String initials,
    Color backgroundColor,
    Color foregroundColor,
  ) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: initials.isNotEmpty
          ? Text(
              initials,
              style: GoogleFonts.inter(
                fontSize: _fontSize,
                fontWeight: FontWeight.w600,
                color: foregroundColor,
                letterSpacing: -0.3,
              ),
            )
          : Icon(
              fallbackIcon ?? Icons.person_outline_rounded,
              size: _iconSize,
              color: foregroundColor,
            ),
    );
  }
}

class AppAvatarGroup extends StatelessWidget {
  final List<AvatarData> avatars;
  final int maxVisible;
  final AppAvatarSize size;
  final VoidCallback? onOverflowTap;

  const AppAvatarGroup({
    super.key,
    required this.avatars,
    this.maxVisible = 4,
    this.size = AppAvatarSize.sm,
    this.onOverflowTap,
  });

  double get _size {
    switch (size) {
      case AppAvatarSize.xs:
        return 24;
      case AppAvatarSize.sm:
        return AppSizes.avatarSm;
      case AppAvatarSize.md:
        return AppSizes.avatarMd;
      case AppAvatarSize.lg:
        return AppSizes.avatarLg;
      case AppAvatarSize.xl:
        return AppSizes.avatarXl;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final visibleAvatars = avatars.take(maxVisible).toList();
    final overflowCount = avatars.length - maxVisible;
    final overlap = _size * 0.3;

    return SizedBox(
      width: (_size * visibleAvatars.length) -
          (overlap * (visibleAvatars.length - 1)) +
          (overflowCount > 0 ? _size - overlap : 0),
      height: _size,
      child: Stack(
        children: [
          for (int i = visibleAvatars.length - 1; i >= 0; i--)
            Positioned(
              left: i * (_size - overlap),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    width: 2,
                  ),
                ),
                child: AppAvatar(
                  imageUrl: visibleAvatars[i].imageUrl,
                  name: visibleAvatars[i].name,
                  size: size,
                ),
              ),
            ),
          if (overflowCount > 0)
            Positioned(
              left: visibleAvatars.length * (_size - overlap),
              child: GestureDetector(
                onTap: onOverflowTap,
                child: Container(
                  width: _size,
                  height: _size,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '+$overflowCount',
                    style: GoogleFonts.inter(
                      fontSize: _size * 0.35,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AvatarData {
  final String? imageUrl;
  final String? name;

  const AvatarData({
    this.imageUrl,
    this.name,
  });
}
