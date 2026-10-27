import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

/// Shared building blocks for the My tickets and Manage tickets screens, so
/// both modules read as part of the same staff design.

String formatTicketDate(String raw) {
  final dt = DateTime.tryParse(raw);
  if (dt == null) return raw;
  return DateFormat('d MMM yyyy, h:mm a').format(dt);
}

enum TicketPriority { high, medium, low }

TicketPriority ticketPriorityOf(String name) {
  switch (name.trim().toLowerCase()) {
    case 'high':
    case 'urgent':
    case 'critical':
      return TicketPriority.high;
    case 'medium':
    case 'normal':
      return TicketPriority.medium;
    default:
      return TicketPriority.low;
  }
}

StaffAccent ticketPriorityAccent(TicketPriority p) => switch (p) {
  TicketPriority.high => StaffAccent.pink,
  TicketPriority.medium => StaffAccent.amber,
  TicketPriority.low => StaffAccent.green,
};

/// Parses an API colour such as `#28a745` or `28a745`.
Color? parseTicketColor(String raw) {
  var hex = raw.trim().replaceFirst('#', '');
  if (hex.length == 3) {
    hex = hex.split('').map((c) => '$c$c').join();
  }
  if (hex.length != 6) return null;
  final value = int.tryParse(hex, radix: 16);
  return value == null ? null : Color(0xFF000000 | value);
}

/// Tinted pill: priority level with a flag.
class PriorityBadge extends StatelessWidget {
  const PriorityBadge(this.name, {super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final level = ticketPriorityOf(name);
    final tint = p.tint(ticketPriorityAccent(level));
    final fg = level == TicketPriority.high ? p.dangerText : tint.foreground;
    final bg = level == TicketPriority.high
        ? p.danger.withValues(alpha: p.isDark ? 0.18 : 0.12)
        : tint.background;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StaffIcon(StaffGlyphs.flag, size: 12, color: fg, strokeWidth: 2),
          const SizedBox(width: 5),
          Text(
            name.isEmpty ? 'Normal' : name,
            maxLines: 1,
            style: sora(11, weight: FontWeight.w700, color: fg),
          ),
        ],
      ),
    );
  }
}

/// Neutral pill with a coloured status dot.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.name, this.colorHex = ''});

  final String name;
  final String colorHex;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final dot = parseTicketColor(colorHex) ?? p.amber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: p.surfaceRaised,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: p.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: sora(11, weight: FontWeight.w600, color: p.text),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small icon and text chip (location, block, attachment).
class TicketMetaChip extends StatelessWidget {
  const TicketMetaChip({super.key, required this.glyph, required this.label});

  final String glyph;
  final String label;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: p.surfaceRaised,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StaffIcon(glyph, size: 13, color: p.muted, strokeWidth: 2),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: sora(11.5, weight: FontWeight.w500, color: p.muted),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded initial tile for a person, tinted by the first letter.
class PersonTile extends StatelessWidget {
  const PersonTile({super.key, required this.name, this.size = 30});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final trimmed = name.trim();
    final letter = trimmed.isEmpty
        ? '?'
        : trimmed.characters.first.toUpperCase();
    const accents = StaffAccent.values;
    final tint = p.tint(accents[letter.codeUnitAt(0) % accents.length]);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tint.background,
        borderRadius: BorderRadius.circular(size * 0.34),
      ),
      child: Text(
        letter,
        style: sora(
          size * 0.42,
          weight: FontWeight.w800,
          color: tint.foreground,
        ),
      ),
    );
  }
}

/// One ticket in a list. Shared by My tickets and Manage tickets.
class TicketTile extends StatelessWidget {
  const TicketTile({
    super.key,
    required this.id,
    required this.category,
    required this.createdAt,
    required this.description,
    required this.priority,
    required this.status,
    required this.statusColor,
    required this.location,
    required this.block,
    required this.onTap,
    this.requester,
    this.hasAttachment = false,
  });

  final int id;
  final String category;
  final String createdAt;
  final String description;
  final String priority;
  final String status;
  final String statusColor;
  final String location;
  final String block;
  final String? requester;
  final bool hasAttachment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final accent = ticketPriorityAccent(ticketPriorityOf(priority));
    return StaffCard(
      radius: 22,
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassIconTile(
                glyph: StaffGlyphs.ticket,
                accent: accent,
                size: 42,
                radius: 14,
                iconSize: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.isEmpty ? 'Ticket' : category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sora(14.5, weight: FontWeight.w700, color: p.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '#$id · ${formatTicketDate(createdAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sora(
                        11.5,
                        weight: FontWeight.w400,
                        color: p.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PriorityBadge(priority),
            ],
          ),
          if (description.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              description.trim(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: sora(
                12.5,
                weight: FontWeight.w400,
                color: p.muted,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StatusBadge(name: status, colorHex: statusColor),
              if (location.isNotEmpty)
                TicketMetaChip(glyph: StaffGlyphs.pin, label: location),
              if (block.isNotEmpty)
                TicketMetaChip(glyph: StaffGlyphs.building, label: block),
              if (hasAttachment)
                const TicketMetaChip(
                  glyph: StaffGlyphs.paperclip,
                  label: 'Attachment',
                ),
            ],
          ),
          if (requester != null && requester!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(height: 1, color: p.border),
            const SizedBox(height: 10),
            Row(
              children: [
                PersonTile(name: requester!, size: 26),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Raised by ${requester!.trim()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: sora(12, weight: FontWeight.w500, color: p.text),
                  ),
                ),
                StaffIcon(
                  StaffGlyphs.chevronRight,
                  size: 16,
                  color: p.muted,
                  strokeWidth: 2,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Segmented control with a count per segment (To do / In progress / Done).
class TicketSegments extends StatelessWidget {
  const TicketSegments({
    super.key,
    required this.labels,
    required this.counts,
    required this.selected,
    required this.onChanged,
  });

  final List<String> labels;
  final List<int> counts;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  height: 40,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: i == selected ? p.amber : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          labels[i],
                          style: sora(
                            12.5,
                            weight: FontWeight.w700,
                            color: i == selected ? p.onAmber : p.muted,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          constraints: const BoxConstraints(minWidth: 20),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: i == selected
                                ? p.onAmber.withValues(alpha: 0.14)
                                : p.surfaceRaised,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${counts[i]}',
                            textAlign: TextAlign.center,
                            style: sora(
                              11,
                              weight: FontWeight.w800,
                              color: i == selected ? p.onAmber : p.text,
                            ),
                          ),
                        ),
                      ],
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

/// Label and value row inside a details card.
class TicketInfoRow extends StatelessWidget {
  const TicketInfoRow({
    super.key,
    required this.glyph,
    required this.accent,
    required this.label,
    required this.value,
  });

  final String glyph;
  final StaffAccent accent;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          GlassIconTile(
            glyph: glyph,
            accent: accent,
            size: 32,
            radius: 11,
            iconSize: 16,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: sora(12.5, weight: FontWeight.w500, color: p.muted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: sora(13, weight: FontWeight.w600, color: p.text),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card that stacks [children] with hairline dividers.
class TicketGroup extends StatelessWidget {
  const TicketGroup({super.key, required this.children, this.margin});

  final List<Widget> children;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return StaffCard(
      margin: margin,
      radius: 22,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Divider(height: 1, indent: 14, endIndent: 14, color: p.border),
          ],
        ],
      ),
    );
  }
}

/// Shimmer placeholders while a ticket list loads.
class TicketListSkeleton extends StatelessWidget {
  const TicketListSkeleton({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Shimmer.fromColors(
      baseColor: p.surfaceRaised,
      highlightColor: p.surface,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => Container(
          height: 136,
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
    );
  }
}
