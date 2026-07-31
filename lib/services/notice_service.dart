// lib/services/notice_service.dart
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import '../models/notice_model.dart';

class NoticeFetchResult {
  final List<Notice> notices;
  final String? nextCursor;

  NoticeFetchResult({
    required this.notices,
    this.nextCursor,
  });
}

class NoticeService {
  static const String _baseUrl = 'https://exam.ioe.tu.edu.np';

  static Future<NoticeFetchResult> fetchNoticesWithCursor({
    String? cursor,
    int retries = 3,
  }) async {
    int attempt = 0;
    while (attempt < retries) {
      attempt++;
      try {
        final String url = (cursor != null && cursor.isNotEmpty)
            ? '$_baseUrl/notices?cursor=$cursor'
            : '$_baseUrl/notices';

        final response = await http.get(
          Uri.parse(url),
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          },
        ).timeout(const Duration(seconds: 12));

        if (response.statusCode == 200) {
          var document = parser.parse(response.body);

          // HTML Parsing for Notice Items (.recent-post-wrapper)
          var postWrappers = document.querySelectorAll('.recent-post-wrapper');

          List<Notice> notices = postWrappers
              .map((wrapper) {
                final dateElement = wrapper.querySelector('.nep_date') ??
                    wrapper.querySelector('.date');
                final titleElement = wrapper.querySelector('.detail h5') ??
                    wrapper.querySelector('.detail a');
                final linkElement = wrapper.querySelector('.detail a');

                if (titleElement == null || linkElement == null) return null;

                final title = titleElement.text.trim();
                final date = dateElement?.text.trim() ?? '';
                final href = linkElement.attributes['href'] ?? '';

                if (title.isEmpty || href.isEmpty) return null;

                final downloadUrl =
                    href.startsWith('http') ? href : '$_baseUrl$href';

                return Notice(
                    title: title, date: date, downloadUrl: downloadUrl);
              })
              .whereType<Notice>()
              .toList();

          // Extract next page cursor from pagination element (<ul class="pagination">)
          String? nextCursor;
          var nextLink = document.querySelector('a.page-link[rel="next"]');
          if (nextLink == null) {
            final pageLinks = document.querySelectorAll('a.page-link');
            for (var link in pageLinks) {
              final hrefAttr = link.attributes['href'] ?? '';
              if (hrefAttr.contains('cursor=')) {
                nextLink = link;
                break;
              }
            }
          }

          if (nextLink != null) {
            String href = nextLink.attributes['href'] ?? '';
            try {
              Uri parsedUri = Uri.parse(href);
              nextCursor = parsedUri.queryParameters['cursor'];
            } catch (_) {}
          }

          return NoticeFetchResult(notices: notices, nextCursor: nextCursor);
        }
      } catch (e) {
        if (attempt >= retries) {
          throw Exception(
              'Failed to connect to IOE server after $retries attempts: $e');
        }
        await Future.delayed(Duration(milliseconds: 800 * attempt));
      }
    }
    throw Exception('Failed to load notices after $retries attempts');
  }

  /// Backward-compatible method
  static Future<List<Notice>> fetchNotices({int page = 1}) async {
    final result = await fetchNoticesWithCursor();
    return result.notices;
  }
}
