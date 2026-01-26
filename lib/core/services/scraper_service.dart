import 'package:dio/dio.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

class ScrapedDealData {
  final String? title;
  final String? description;
  final String? imageUrl;
  final String? storeName;
  final double? price;
  final String? currency;

  ScrapedDealData({
    this.title,
    this.description,
    this.imageUrl,
    this.storeName,
    this.price,
    this.currency,
  });

  @override
  String toString() {
    return 'ScrapedDealData(title: $title, price: $price, store: $storeName)';
  }
}

class ScraperService {
  final Dio _dio;

  ScraperService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {
                'User-Agent':
                    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                'Accept':
                    'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
                'Accept-Language': 'en-US,en;q=0.9',
              },
            ),
          );

  Future<ScrapedDealData?> scrapeUrl(String url) async {
    try {
      // Ensure URL has protocol
      if (!url.startsWith('http')) {
        url = 'https://$url';
      }

      final response = await _dio.get(url);

      if (response.statusCode != 200 || response.data == null) {
        return null;
      }

      final document = parser.parse(response.data);

      final title = _extractTitle(document);
      final description = _extractDescription(document);
      final image = _extractImage(document);
      final siteName = _extractSiteName(document);
      final price = _extractPrice(document);

      return ScrapedDealData(
        title: title,
        description: description,
        imageUrl: image,
        storeName: siteName,
        price: price,
      );
    } catch (e) {
      // Rethrow to let the UI know what went wrong
      throw Exception('Scraping error: $e');
    }
  }

  String? _extractTitle(dom.Document document) {
    // Try OpenGraph
    var title = _getMetaContent(document, 'property', 'og:title');
    if (title != null && title.isNotEmpty) return title;

    // Try Twitter Card
    title = _getMetaContent(document, 'name', 'twitter:title');
    if (title != null && title.isNotEmpty) return title;

    // Try standard title tag
    return document.head?.querySelector('title')?.text.trim();
  }

  String? _extractDescription(dom.Document document) {
    // Try OpenGraph
    var desc = _getMetaContent(document, 'property', 'og:description');
    if (desc != null && desc.isNotEmpty) return desc;

    // Try Twitter Card
    desc = _getMetaContent(document, 'name', 'twitter:description');
    if (desc != null && desc.isNotEmpty) return desc;

    // Try standard description
    desc = _getMetaContent(document, 'name', 'description');
    if (desc != null && desc.isNotEmpty) return desc;

    return null;
  }

  String? _extractImage(dom.Document document) {
    // Try OpenGraph
    var image = _getMetaContent(document, 'property', 'og:image:secure_url');
    if (image != null && image.isNotEmpty) return image;

    image = _getMetaContent(document, 'property', 'og:image');
    if (image != null && image.isNotEmpty) return image;

    // Try Twitter Card
    image = _getMetaContent(document, 'name', 'twitter:image');
    if (image != null && image.isNotEmpty) return image;

    // Try finding first large image
    // This is a naive heuristic
    final imgs = document.body?.querySelectorAll('img');
    if (imgs != null) {
      for (final img in imgs) {
        final src = img.attributes['src'];
        if (src != null && src.startsWith('http') && !src.contains('logo')) {
          // Check for likely product images based on size attributes if available
          // For now just return the first valid looking HTTP image
          return src;
        }
      }
    }

    return null;
  }

  String? _extractSiteName(dom.Document document) {
    var name = _getMetaContent(document, 'property', 'og:site_name');
    if (name != null && name.isNotEmpty) return name;

    return null;
  }

  double? _extractPrice(dom.Document document) {
    // 1. Try Structured Data (Product Schema) - simple regex on script tags
    // This is robust for many e-commerce sites
    final scripts = document.querySelectorAll(
      'script[type="application/ld+json"]',
    );
    for (var script in scripts) {
      final content = script.text;
      if (content.contains('"price":')) {
        final match = RegExp(r'"price":\s*"?([\d\.]+)"?').firstMatch(content);
        if (match != null) {
          return double.tryParse(match.group(1) ?? '');
        }
      }
    }

    // 2. Try common meta tags
    final priceStr =
        _getMetaContent(document, 'property', 'product:price:amount') ??
        _getMetaContent(document, 'name', 'price');

    if (priceStr != null) {
      return double.tryParse(priceStr);
    }

    // 3. Last fallback: Look for price currency symbols in text
    // Very naive, can match wrong things
    // Ignoring for safety to avoid bad data

    return null;
  }

  String? _getMetaContent(
    dom.Document document,
    String attributeName,
    String attributeValue,
  ) {
    final meta = document.head?.querySelector(
      'meta[$attributeName="$attributeValue"]',
    );
    return meta?.attributes['content']?.trim();
  }
}
