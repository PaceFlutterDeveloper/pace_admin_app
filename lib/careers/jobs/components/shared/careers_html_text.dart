import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../../shared/theme/careers_tokens.dart';

/// Renders job copy that the API returns as HTML using the careers body style.
///
/// Plain-text values render unchanged, so this is safe for both shapes.
class CareersHtmlText extends StatelessWidget {
  final String html;

  const CareersHtmlText({super.key, required this.html});

  static final RegExp _tag = RegExp(r'<[a-z!/][^>]*>', caseSensitive: false);

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;
    final palette = context.careers;
    final heading = _cssHex(palette.textPrimary);
    final link = _cssHex(palette.accentText);

    if (!_tag.hasMatch(html)) {
      return Text(html, style: bodyStyle);
    }

    return HtmlWidget(
      html,
      textStyle: bodyStyle,
      customStylesBuilder: (element) {
        switch (element.localName) {
          case 'h1':
          case 'h2':
          case 'h3':
          case 'h4':
            return {
              'font-size': '15px',
              'font-weight': '600',
              'margin': '12px 0 6px',
              'color': heading,
            };
          case 'p':
            return {'margin': '0 0 10px'};
          case 'ul':
          case 'ol':
            return {'margin': '0 0 10px', 'padding-left': '18px'};
          case 'li':
            return {'margin': '0 0 6px'};
          case 'a':
            return {'color': link, 'text-decoration': 'none'};
          case 'strong':
          case 'b':
            return {'color': heading};
          default:
            return null;
        }
      },
      renderMode: RenderMode.column,
    );
  }

  static String _cssHex(Color color) {
    final rgb = color.toARGB32() & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0')}';
  }
}

/// Bullet list rendered from a newline or comma separated string.
class CareersBulletList extends StatelessWidget {
  final List<String> items;

  const CareersBulletList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 7),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: context.careers.accentText,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(item, style: bodyStyle)),
              ],
            ),
          ),
      ],
    );
  }
}
