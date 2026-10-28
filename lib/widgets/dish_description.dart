import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shows a dish description, retaining list / emphasis formatting and making
/// web addresses tappable. The editable description itself remains plain text.
class DishDescription extends StatefulWidget {
  const DishDescription({
    super.key,
    required this.description,
    this.style,
    this.emptyStyle,
  });

  final String description;
  final TextStyle? style;
  final TextStyle? emptyStyle;

  @override
  State<DishDescription> createState() => _DishDescriptionState();
}

class _DescriptionLine {
  const _DescriptionLine({required this.text, required this.isBullet});

  final String text;
  final bool isBullet;
}

class _DishDescriptionState extends State<DishDescription> {
  // Recognize links with http(s)://, www., and common bare domains.
  // Full URLs take precedence over *_ emphasis tokens so that underscores
  // within a URL are never interpreted as italic formatting.
  static const _urlPatternSource =
      r'(?<![\w@])(?:(?:https?:\/\/|www\.)[^\s<>"`]+|'
      r'(?:[a-z0-9-]+\.)+[a-z]{2,24}'
      r'(?:[\/?#][^\s<>"`]+)?(?=$|[^\w-]))';
  // Markdown links such as [Rezept ansehen](https://example.com) can be
  // tapped on their visible label, not only on the URL in parentheses.
  static const _markdownLinkSource =
      r'\[[^\]\n]+\]\((?:(?:https?:\/\/|www\.)[^\s)]+|'
      r'(?:[a-z0-9-]+\.)+[a-z]{2,24}(?:\/[^\s)]*)?)\)';
  static final _markdownLinkPattern = RegExp(
    r'^\[([^\]\n]+)\]\(([^\s)]+)\)$',
    caseSensitive: false,
  );
  static final _urlPattern = RegExp(_urlPatternSource, caseSensitive: false);
  static final _tokenPattern = RegExp(
    '$_markdownLinkSource|$_urlPatternSource|\\*[^*\\n]+\\*|_[^_\\n]+_',
    caseSensitive: false,
  );

  final Map<String, TapGestureRecognizer> _recognizers = {};

  @override
  void didUpdateWidget(covariant DishDescription oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.description != widget.description) {
      _disposeRecognizers();
    }
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers.values) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  TapGestureRecognizer _recognizerFor(String address) {
    return _recognizers.putIfAbsent(
      address,
      () => TapGestureRecognizer()..onTap = () => _openLink(address),
    );
  }

  Future<void> _openLink(String address) async {
    final fullAddress =
        address.toLowerCase().startsWith('https://') ||
            address.toLowerCase().startsWith('http://')
        ? address
        : 'https://$address';
    final uri = Uri.tryParse(fullAddress);
    if (uri == null || uri.host.isEmpty) return;

    // On some Android versions the preferred external mode can fail even
    // though a browser is installed. Try the platform's default mode too.
    for (final mode in [
      LaunchMode.externalApplication,
      LaunchMode.platformDefault,
    ]) {
      try {
        if (await launchUrl(uri, mode: mode)) return;
      } catch (_) {
        // Try the next launch mode. A message is shown if both fail.
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link konnte nicht geöffnet werden.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = widget.style ?? Theme.of(context).textTheme.bodyLarge;

    if (widget.description.trim().isEmpty) {
      return Text(
        'Keine Beschreibung vorhanden',
        style: widget.emptyStyle ??
            baseStyle?.copyWith(color: Colors.grey.shade600),
      );
    }

    final lines = _parseDescription(widget.description);
    final Widget descriptionBody;
    if (lines.length == 1 && !lines.first.isBullet) {
      descriptionBody = _formattedText(lines.first.text, baseStyle);
    } else {
      descriptionBody = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines.map((line) {
          if (!line.isBullet) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _formattedText(line.text, baseStyle),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: baseStyle),
                Expanded(child: _formattedText(line.text, baseStyle)),
              ],
            ),
          );
        }).toList(),
      );
    }

    return descriptionBody;
  }

  Widget _formattedText(String text, TextStyle? style) {
    return Text.rich(
      TextSpan(style: style, children: _formattedSpans(text)),
    );
  }

  List<InlineSpan> _formattedSpans(String text) {
    final spans = <InlineSpan>[];
    var index = 0;

    for (final match in _tokenPattern.allMatches(text)) {
      if (match.start > index) {
        spans.add(TextSpan(text: text.substring(index, match.start)));
      }

      final token = match.group(0)!;
      final markdownLink = _markdownLinkPattern.firstMatch(token);
      if (markdownLink != null) {
        spans.add(
          _clickableLinkSpan(
            markdownLink.group(1)!,
            markdownLink.group(2)!,
          ),
        );
      } else if (token.startsWith('*') || token.startsWith('_')) {
        final isBold = token.startsWith('*');
        spans.add(
          TextSpan(
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : null,
              fontStyle: isBold ? null : FontStyle.italic,
            ),
            children: _linkSpans(token.substring(1, token.length - 1)),
          ),
        );
      } else {
        spans.addAll(_linkSpans(token));
      }
      index = match.end;
    }

    if (index < text.length) {
      spans.add(TextSpan(text: text.substring(index)));
    }
    return spans;
  }

  List<InlineSpan> _linkSpans(String text) {
    final spans = <InlineSpan>[];
    var index = 0;

    for (final match in _urlPattern.allMatches(text)) {
      if (match.start > index) {
        spans.add(TextSpan(text: text.substring(index, match.start)));
      }

      final candidate = match.group(0)!;
      final address = _cleanLink(candidate);
      final length = address.length;
      if (address.isNotEmpty) {
        spans.add(_clickableLinkSpan(address, address));
      }
      if (length < candidate.length) {
        spans.add(TextSpan(text: candidate.substring(length)));
      }
      index = match.end;
    }

    if (index < text.length) {
      spans.add(TextSpan(text: text.substring(index)));
    }
    return spans;
  }

  TextSpan _clickableLinkSpan(String label, String address) {
    final linkColor = Theme.of(context).colorScheme.primary;
    return TextSpan(
      text: label,
      // Links stay clickable, but are no longer underlined.
      style: TextStyle(color: linkColor, decoration: TextDecoration.none),
      recognizer: _recognizerFor(address),
    );
  }

  String _cleanLink(String candidate) {
    var length = candidate.length;
    const trailingPunctuation = '.,;:!?]}';
    while (length > 0) {
      final lastCharacter = candidate[length - 1];
      if (trailingPunctuation.contains(lastCharacter)) {
        length--;
      } else if (lastCharacter == ')' &&
          '('.allMatches(candidate.substring(0, length)).length <
              ')'.allMatches(candidate.substring(0, length)).length) {
        length--;
      } else {
        break;
      }
    }
    return candidate.substring(0, length);
  }

  List<_DescriptionLine> _parseDescription(String description) {
    final normalized = description.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final bulletPattern = RegExp(r'^\s*[-–—]\s*(.+)$');
    final rawLines = normalized.split('\n');
    final hasBullets = rawLines.any(
      (line) => bulletPattern.hasMatch(line.trim()),
    );

    if (hasBullets) {
      return rawLines
          .map((line) {
            final trimmed = line.trim();
            if (trimmed.isEmpty) return null;
            final bullet = bulletPattern.firstMatch(trimmed);
            return _DescriptionLine(
              text: bullet == null ? trimmed : bullet.group(1)!.trim(),
              isBullet: bullet != null,
            );
          })
          .whereType<_DescriptionLine>()
          .toList();
    }

    final semicolonItems = normalized
        .split(';')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (semicolonItems.length > 1) {
      return semicolonItems
          .map((item) => _DescriptionLine(text: item, isBullet: true))
          .toList();
    }

    return [_DescriptionLine(text: normalized.trim(), isBullet: false)];
  }
}
