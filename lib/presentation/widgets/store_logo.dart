import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StoreLogo extends StatelessWidget {
  final String storeName;
  final double height;
  final TextStyle? textStyle;
  final Color? color;

  const StoreLogo({
    super.key,
    required this.storeName,
    this.height = 16,
    this.textStyle,
    this.color,
  });

  static const List<String> _knownLogos = [
    'adidas',
    'ajio',
    'amazon',
    'apple',
    'flipkart',
    'ikea',
    'meesho',
    'myntra',
    'nike',
    'nykaa',
    'paytm',
  ];

  // Logos that are primarily symbols/icons and look good at standard text height
  static const List<String> _symbols = [
    'apple',
    'nike',
    'adidas', // often vertical stack or symbol
  ];

  @override
  Widget build(BuildContext context) {
    final normalizedName = storeName.toLowerCase().trim();

    // Check if we have a logo for this store
    // We check partial matches too in case of "Amazon India" or "Amazon.in"
    // simple heuristic: checks if any known logo key is contained in the store name
    String? matchedLogo;
    for (final logo in _knownLogos) {
      if (normalizedName.contains(logo)) {
        matchedLogo = logo;
        break;
      }
    }

    if (matchedLogo != null) {
      // Logic: Wordmarks (text-based logos like Amazon) need to be slightly taller
      // to visually match the cap-height of the adjacent text, but not too much.
      // Symbols (Apple, Nike) need to be significantly larger to not look tiny.
      final isSymbol = _symbols.contains(matchedLogo);
      final scaleFactor = isSymbol ? 1.4 : 1.10;

      return Container(
        height:
            height *
            scaleFactor, // Allow container to grow with the scaled logo
        alignment: Alignment.centerLeft, // Align logo to the left
        child: SvgPicture.asset(
          'assets/logos/$matchedLogo.svg',
          height: height * scaleFactor,
          colorFilter: color != null
              ? ColorFilter.mode(color!, BlendMode.srcIn)
              : null,
          fit: BoxFit.contain, // Ensure it doesn't crop
        ),
      );
    }

    return Text(
      storeName,
      style: textStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
