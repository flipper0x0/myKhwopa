import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart'; 

// UI/UX Packages
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart' as html_parser;

import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:photo_view/photo_view.dart';

part 'articles_tab.g.dart';

//==============================================================================
// DATA MODELS first
//==============================================================================
@HiveType(typeId: 0)
class Notice extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String fileUrl;
  @HiveField(3)
  final String hits;
  @HiveField(4)
  final DateTime postDate;
  @HiveField(5)
  final String descriptionHtml;

  Notice({
    required this.id,
    required this.title,
    required this.postDate,
    required this.fileUrl,
    required this.hits,
    required this.descriptionHtml,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    String rawUrl = json['image'] ?? '';
    return Notice(
      id: json['id'] ?? '',
      title: (json['title'] as String?)?.trim() ?? 'No Title',
      postDate:
          DateTime.parse(json['post_date'] ?? DateTime.now().toIso8601String()),
      fileUrl: rawUrl.isEmpty
          ? ''
          : (rawUrl.startsWith('http') ? rawUrl : 'https://khwopa.edu.np$rawUrl'),
      hits: json['hits'] ?? '0',
      descriptionHtml: json['description'] ?? '',
    );
  }
}

@HiveType(typeId: 1)
class News extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String imageUrl;
  @HiveField(3)
  final String descriptionHtml;
  @HiveField(4)
  final String hits;
  @HiveField(5)
  final DateTime postDate;

  News(
      {required this.id,
      required this.title,
      required this.postDate,
      required this.imageUrl,
      required this.descriptionHtml,
      required this.hits});

  factory News.fromJson(Map<String, dynamic> json) {
    String rawImageUrl = json['image'] ?? '';
    return News(
      id: json['id'] ?? '',
      title: (json['title'] as String?)?.trim() ?? 'No Title',
      postDate:
          DateTime.parse(json['post_date'] ?? DateTime.now().toIso8601String()),
      imageUrl: rawImageUrl.startsWith('http')
          ? rawImageUrl
          : 'https://khwopa.edu.np$rawImageUrl',
      descriptionHtml: json['description'] ?? '',
      hits: json['hits'] ?? '0',
    );
  }
}

@HiveType(typeId: 2)
class Newsletter extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String pdfUrl;
  @HiveField(3)
  final String coverImageUrl;
  @HiveField(4)
  final DateTime postDate;

  Newsletter(
      {required this.id,
      required this.title,
      required this.postDate,
      required this.pdfUrl,
      required this.coverImageUrl});

  factory Newsletter.fromJson(Map<String, dynamic> json) {
    String rawPdfUrl = json['image'] ?? '';
    String rawCoverUrl = json['url'] ?? '';
    return Newsletter(
      id: json['id'] ?? '',
      title: (json['title'] as String?)?.trim() ?? 'No Title',
      postDate:
          DateTime.parse(json['post_date'] ?? DateTime.now().toIso8601String()),
      pdfUrl: rawPdfUrl.startsWith('http')
          ? rawPdfUrl
          : 'https://khwopa.edu.np$rawPdfUrl',
      coverImageUrl: rawCoverUrl.startsWith('http')
          ? rawCoverUrl
          : 'https://khwopa.edu.np$rawCoverUrl',
    );
  }
}

@HiveType(typeId: 3)
class Event extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String descriptionHtml;
  @HiveField(3)
  final String hits;
  @HiveField(4)
  final DateTime postDate;
  @HiveField(5)
  final String imageUrl;

  Event({
    required this.id,
    required this.title,
    required this.postDate,
    required this.descriptionHtml,
    required this.hits,
    required this.imageUrl,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    String rawImageUrl = json['image'] ?? '';
    return Event(
      id: json['id'] ?? '',
      title: (json['title'] as String?)?.trim() ?? 'No Title',
      postDate:
          DateTime.parse(json['post_date'] ?? DateTime.now().toIso8601String()),
      descriptionHtml: json['description'] ?? '',
      hits: json['hits'] ?? '0',
      imageUrl: rawImageUrl.startsWith('http')
          ? rawImageUrl
          : 'https://khwopa.edu.np$rawImageUrl',
    );
  }
}

class DataRepository {
  static const String _baseUrl = 'https://khwopa.edu.np/api';
  static const String _newsBox = 'newsBox';
  static const String _noticesBox = 'noticesBox';
  static const String _newslettersBox = 'newslettersBox';
  static const String _eventsBox = 'eventsBox';

  Future<List<T>> _fetchAndCacheData<T extends HiveObject>({
    required String endpoint,
    required String boxName,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final connectivityResults = await Connectivity().checkConnectivity();
    final bool isOnline = connectivityResults.isNotEmpty &&
        !connectivityResults.contains(ConnectivityResult.none);
    final box = await Hive.openBox<T>(boxName);

    if (isOnline) {
      try {
        final response = await http.get(Uri.parse('$_baseUrl/$endpoint'));
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          final List<T> items = data.map((item) => fromJson(item)).toList();

          await box.clear();
          await box.addAll(items);
          return items;
        } else {
          if (box.isNotEmpty) return box.values.toList();
          throw Exception('Failed to load data (Code: ${response.statusCode})');
        }
      } catch (e) {
        if (box.isNotEmpty) return box.values.toList();
        throw Exception('You are offline and no data has been saved yet.');
      }
    } else {
      if (box.isNotEmpty) {
        return box.values.toList();
      } else {
        throw Exception('You are offline and no data has been saved yet.');
      }
    }
  }

  Future<List<Notice>> fetchNotices({int deptId = 99}) => _fetchAndCacheData<Notice>(
        endpoint: 'fetch_main_notice?dept_id=$deptId',
        boxName: '${_noticesBox}_$deptId', // Dynamically cache each department in its own Box
        fromJson: (json) => Notice.fromJson(json),
      );

  Future<List<News>> fetchNews() => _fetchAndCacheData<News>(
        endpoint: 'fetch_news',
        boxName: _newsBox,
        fromJson: (json) => News.fromJson(json),
      );

  Future<List<Event>> fetchEvents() => _fetchAndCacheData<Event>(
        endpoint: 'fetch_events',
        boxName: _eventsBox,
        fromJson: (json) => Event.fromJson(json),
      );

  Future<List<Newsletter>> fetchNewsletters() => _fetchAndCacheData<Newsletter>(
        endpoint: 'fetch_newsletter',
        boxName: _newslettersBox,
        fromJson: (json) => Newsletter.fromJson(json),
      );
}


class PdfCacheManager {
  static Future<File> getOrDownloadPdf(String url) async {
    final dir = await getApplicationDocumentsDirectory();
    final filename = '${sha1.convert(utf8.encode(url)).toString()}.pdf';
    final file = File('${dir.path}/$filename');

    if (await file.exists()) {
      return file;
    } else {
      final connectivityResults = await Connectivity().checkConnectivity();
      final bool isOffline = connectivityResults.isEmpty ||
          connectivityResults.contains(ConnectivityResult.none);
      if (isOffline) {
        throw Exception(
            "You are offline. This PDF hasn't been downloaded yet.");
      }
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);
          return file;
        } else {
          throw Exception(
              'Failed to download PDF (Code: ${response.statusCode})');
        }
      } catch (e) {
        throw Exception('Could not download PDF. Check your connection.');
      }
    }
  }
}


class ArticlesTab extends StatefulWidget {
  const ArticlesTab({super.key});

  @override
  State<ArticlesTab> createState() => _ArticlesTabState();
}

class _ArticlesTabState extends State<ArticlesTab> {
  final DataRepository _dataRepository = DataRepository();
  late Future<List<News>> _newsFuture;
  late Future<List<Notice>> _noticesFuture;
  late Future<List<Newsletter>> _newslettersFuture;
  late Future<List<Event>> _eventsFuture;

  int _selectedDeptId = 99; // Default: General (All Departments)

  final List<Map<String, dynamic>> _departments = const [
    {'id': 99, 'name': 'General', 'icon': Icons.notifications_active_rounded},
    {'id': 3, 'name': 'Computer', 'icon': Icons.computer_rounded},
    {'id': 1, 'name': 'Civil', 'icon': Icons.construction_rounded},
    {'id': 2, 'name': 'Electrical', 'icon': Icons.electrical_services_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _newsFuture = _dataRepository.fetchNews();
      _noticesFuture = _dataRepository.fetchNotices(deptId: _selectedDeptId);
      _newslettersFuture = _dataRepository.fetchNewsletters();
      _eventsFuture = _dataRepository.fetchEvents();
    });
  }

  void _changeDepartment(int deptId) {
    if (_selectedDeptId != deptId) {
      setState(() {
        _selectedDeptId = deptId;
        _noticesFuture = _dataRepository.fetchNotices(deptId: _selectedDeptId);
      });
    }
  }

  void _navigateToContentView(BuildContext context, {required dynamic item}) {
    Widget screen;
    if (item is News || item is Event) {
      screen = GenericArticleScreen(
        title: item.title,
        imageUrl: (item is News) ? item.imageUrl : item.imageUrl,
        postDate: item.postDate,
        hits: item.hits,
        descriptionHtml: item.descriptionHtml,
      );
    } else if (item is Notice) {
      if (item.fileUrl.isEmpty) {
        // Handle notices with NO attachments cleanly using GenericArticleScreen to render rich HTML descriptions
        screen = GenericArticleScreen(
          title: item.title,
          imageUrl: '',
          postDate: item.postDate,
          hits: item.hits,
          descriptionHtml: item.descriptionHtml.isNotEmpty
              ? item.descriptionHtml
              : '<p>No description text provided. Please check the college website.</p>',
        );
      } else {
        // Handle notices with attachments as before
        final lowerCaseUrl = item.fileUrl.toLowerCase();
        if (lowerCaseUrl.endsWith('.pdf')) {
          screen = InAppPdfViewer(pdfUrl: item.fileUrl, title: item.title);
        } else {
          screen = InAppImageViewer(imageUrl: item.fileUrl, title: item.title);
        }
      }
    } else if (item is Newsletter) {
      screen = InAppPdfViewer(pdfUrl: item.pdfUrl, title: item.title);
    } else {
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _buildDepartmentSelector(ThemeData theme) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _departments.length,
        itemBuilder: (context, index) {
          final dept = _departments[index];
          final isSelected = _selectedDeptId == dept['id'];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              showCheckmark: false,
              avatar: Icon(
                dept['icon'],
                color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
                size: 18,
              ),
              label: Text(
                dept['name'],
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                ),
              ),
              selected: isSelected,
              selectedColor: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : theme.colorScheme.outlineVariant.withOpacity(0.5),
                ),
              ),
              onSelected: (_) => _changeDepartment(dept['id']),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      color: theme.primaryColor,
      child: SingleChildScrollView(
        key: const PageStorageKey<String>('articles'),
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildNewsCarousel(),
            _buildSection<Notice>(
                title: 'Notices',
                height: 180,
                future: _noticesFuture,
                extraHeaderWidget: _buildDepartmentSelector(theme),
                builder: (item) => _NoticeCard(
                    notice: item,
                    onTap: () => _navigateToContentView(context, item: item))),
            _buildSection<Newsletter>(
                title: 'Newsletters',
                height: 220,
                future: _newslettersFuture,
                builder: (item) => _NewsletterCard(
                    newsletter: item,
                    onTap: () => _navigateToContentView(context, item: item))),
            _buildSection<Event>(
                title: 'Events',
                height: 200,
                future: _eventsFuture,
                builder: (item) => _EventCard(
                    event: item,
                    onTap: () => _navigateToContentView(context, item: item))),
            _buildAllNewsList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection<T>(
      {required String title,
      required double height,
      required Future<List<T>> future,
      required Widget Function(T) builder,
      Widget? extraHeaderWidget}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: title),
        if (extraHeaderWidget != null) ...[
          extraHeaderWidget,
          const SizedBox(height: 8),
        ],
        SizedBox(
          height: height,
          child: FutureBuilder<List<T>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildHorizontalListShimmer(
                    itemWidth: title == 'Newsletters'
                        ? 150
                        : (title == 'Events' ? 180 : 250));
              }
              if (snapshot.hasError) {
                return _buildErrorWidget(snapshot.error.toString(), _loadData,
                    isCompact: true);
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildErrorWidget("No content available.", _loadData,
                    isCompact: true);
              }

              final items = snapshot.data!;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length > 5 ? 5 : items.length,
                itemBuilder: (context, index) => _FadeIn(
                    delay: Duration(milliseconds: 100 * index),
                    child: builder(items[index])),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewsCarousel() {
    return FutureBuilder<List<News>>(
      future: _newsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _CarouselShimmer();
        }
        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString(), _loadData);
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildErrorWidget("No news available.", _loadData);
        }

        final newsList = snapshot.data!.take(5).toList();
        return CarouselSlider.builder(
          itemCount: newsList.length,
          itemBuilder: (context, index, realIndex) {
            final newsItem = newsList[index];
            return _NewsCarouselCard(
                news: newsItem,
                onTapped: () =>
                    _navigateToContentView(context, item: newsItem));
          },
          options: CarouselOptions(
              height: 220,
              autoPlay: true,
              enlargeCenterPage: true,
              aspectRatio: 16 / 9,
              viewportFraction: 0.85,
              autoPlayInterval: const Duration(seconds: 5)),
        );
      },
    );
  }

  Widget _buildAllNewsList() {
    return FutureBuilder<List<News>>(
      future: _newsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _AllNewsShimmer();
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        return PaginatedNewsList(
            allNews: snapshot.data!,
            onTap: (newsItem) =>
                _navigateToContentView(context, item: newsItem));
      },
    );
  }

  Widget _buildErrorWidget(String message, VoidCallback onRetry,
      {bool isCompact = false}) {
    bool isOfflineError = message.toLowerCase().contains('offline');
    String title = isOfflineError ? "You are Offline" : "An Error Occurred";
    String displayMessage = isOfflineError
        ? "Please check your internet connection."
        : "We couldn't load the content. Please try again.";

    return Container(
      height: isCompact ? 150 : 220,
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withAlpha(150),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
              isOfflineError ? Icons.wifi_off_rounded : Icons.cloud_off_rounded,
              color: Theme.of(context).colorScheme.onErrorContainer,
              size: 32),
          const SizedBox(height: 10),
          Text(title,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            displayMessage,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHorizontalListShimmer({required double itemWidth}) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          highlightColor: Theme.of(context).colorScheme.onSurface.withAlpha(15),
          child: Container(
            width: itemWidth,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}


class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(title,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold)),
    );
  }
}

class _NewsCarouselCard extends StatelessWidget {
  final News news;
  final VoidCallback onTapped;
  const _NewsCarouselCard({required this.news, required this.onTapped});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapped,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Stack(
            children: [
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: news.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                      color: Theme.of(context).colorScheme.secondaryContainer),
                  errorWidget: (context, url, error) => Container(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      child: const Icon(Icons.error)),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withAlpha(204)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Text(
                  news.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(blurRadius: 4.0, color: Colors.black54)
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final Notice notice;
  final VoidCallback onTap;
  const _NoticeCard({required this.notice, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isPdf = notice.fileUrl.toLowerCase().endsWith('.pdf');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer.withAlpha(120),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(isPdf ? Icons.picture_as_pdf_rounded : Icons.article_rounded,
                  color: isPdf ? Colors.red.shade400 : theme.primaryColor,
                  size: 36),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(isPdf ? 'PDF Document' : 'Notice',
                      style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer)))
            ]),
            Text(notice.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold, height: 1.4)),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _InfoChip(
                  icon: Icons.calendar_today_outlined,
                  text: DateFormat.yMMMd().format(notice.postDate)),
              _InfoChip(icon: Icons.visibility_outlined, text: notice.hits),
            ]),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const _EventCard({required this.event, required this.onTap});

  // <<< MODIFIED >>> This function is now smarter.
  String _stripHtml(String htmlString) {
    final document = html_parser.parse(htmlString);
    // This will get all the text content, replace multiple newlines/spaces with a single space, and then trim.
    final String parsedString =
        document.body?.text.replaceAll(RegExp(r'\s+'), ' ').trim() ?? '';
    return parsedString;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cleanDescription = _stripHtml(event.descriptionHtml);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline.withAlpha(80)),
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.event_available_rounded,
                    color: theme.colorScheme.secondary, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold, height: 1.3),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              cleanDescription,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant, height: 1.4),
            ),
            const Spacer(),
            const Divider(height: 16),
            _InfoChip(
              icon: Icons.calendar_today_outlined,
              text: DateFormat.yMMMd().format(event.postDate),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsletterCard extends StatelessWidget {
  final Newsletter newsletter;
  final VoidCallback onTap;
  const _NewsletterCard({required this.newsletter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shadowColor: theme.shadowColor.withAlpha(70),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                  imageUrl: newsletter.coverImageUrl,
                  height: 160,
                  width: 150,
                  fit: BoxFit.cover,
                  placeholder: (c, u) =>
                      Container(color: theme.colorScheme.secondaryContainer),
                  errorWidget: (c, u, e) => Container(
                      color: theme.colorScheme.secondaryContainer,
                      child: const Icon(Icons.error))),
            ),
            const SizedBox(height: 8),
            Text(newsletter.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(text,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class PaginatedNewsList extends StatefulWidget {
  final List<News> allNews;
  final Function(News) onTap;
  const PaginatedNewsList(
      {required this.allNews, required this.onTap, super.key});

  @override
  State<PaginatedNewsList> createState() => _PaginatedNewsListState();
}

class _PaginatedNewsListState extends State<PaginatedNewsList> {
  final int _itemsPerPage = 7;
  List<News> _currentNews = [];

  @override
  void initState() {
    super.initState();
    _currentNews = widget.allNews.take(_itemsPerPage).toList();
  }

  void _loadMore() {
    setState(() {
      final currentLength = _currentNews.length;
      final moreNews = widget.allNews.skip(currentLength).take(_itemsPerPage);
      _currentNews.addAll(moreNews);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool canLoadMore = _currentNews.length < widget.allNews.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'All News'),
        ListView.separated(
          itemCount: _currentNews.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _FadeIn(
                delay: Duration(milliseconds: 100 * (index % _itemsPerPage)),
                child: _NewsListCard(
                    news: _currentNews[index],
                    onTap: () => widget.onTap(_currentNews[index])));
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: canLoadMore
                ? Center(
                    child: FilledButton.tonalIcon(
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Load More'),
                      onPressed: _loadMore,
                      style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12)),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

class _NewsListCard extends StatelessWidget {
  final News news;
  final VoidCallback onTap;
  const _NewsListCard({required this.news, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shadowColor: theme.shadowColor.withAlpha(30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: news.imageUrl,
                  width: 100,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (c, u) =>
                      Container(color: theme.colorScheme.secondaryContainer),
                  errorWidget: (c, u, e) => Container(
                      color: theme.colorScheme.secondaryContainer,
                      child: const Icon(Icons.image_not_supported)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(news.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold, height: 1.4)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _InfoChip(
                            icon: Icons.calendar_today_outlined,
                            text: DateFormat.yMMMd().format(news.postDate)),
                        const Spacer(),
                        _InfoChip(
                            icon: Icons.visibility_outlined, text: news.hits),
                        const SizedBox(width: 8),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _FadeIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _FadeIn({required this.child, this.delay = Duration.zero});

  @override
  State<_FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<_FadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _opacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: widget.child);
  }
}

//==============================================================================
// 7. IN-APP VIEWERS (GenericArticleScreen MODIFIED)
//==============================================================================
class GenericArticleScreen extends StatelessWidget {
  final String title;
  final String imageUrl;
  final DateTime postDate;
  final String hits;
  final String descriptionHtml;

  const GenericArticleScreen(
      {required this.title,
      required this.imageUrl,
      required this.postDate,
      required this.hits,
      required this.descriptionHtml,
      super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = imageUrl.isNotEmpty;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: hasImage ? 250.0 : 0,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                title,
                style: const TextStyle(
                    shadows: [Shadow(blurRadius: 8, color: Colors.black)]),
              ),
              titlePadding:
                  const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
              centerTitle: false,
              background: hasImage
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                              color: theme.colorScheme.secondaryContainer),
                          placeholder: (context, url) => Container(
                              color: theme.colorScheme.secondaryContainer),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withAlpha(153)
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.center,
                            ),
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(children: [
                    _InfoChip(
                        icon: Icons.calendar_today_outlined,
                        text: DateFormat.yMMMMd().format(postDate)),
                    const SizedBox(width: 16),
                    _InfoChip(icon: Icons.visibility_outlined, text: hits),
                  ]),
                  const Divider(height: 32),
                  Html(
                    data: descriptionHtml,
                    // <<< MODIFIED >>> Added onLinkTap to handle clicks
                    onLinkTap: (url, attributes, element) async {
                      if (url != null) {
                        final uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) {
                          // Launches the URL in an external browser
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Could not open the link: $url')),
                            );
                          }
                        }
                      }
                    },
                    style: {
                      "body": Style(
                        fontSize: FontSize(16.0),
                        lineHeight: const LineHeight(1.5),
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                      "p": Style(margin: Margins.only(bottom: 12)),
                      "li": Style(padding: HtmlPaddings.only(bottom: 8)),
                      // Make links look clickable
                      "a": Style(
                        color: theme.colorScheme.secondary,
                        textDecoration: TextDecoration.underline,
                      ),
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InAppImageViewer extends StatelessWidget {
  final String imageUrl;
  final String title;

  const InAppImageViewer(
      {required this.imageUrl, required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PhotoView(
        imageProvider: CachedNetworkImageProvider(imageUrl),
        loadingBuilder: (context, event) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, color: Colors.grey, size: 50),
              SizedBox(height: 16),
              Text("Image not available offline."),
            ],
          ),
        ),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 4,
        initialScale: PhotoViewComputedScale.contained,
        heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
      ),
    );
  }
}

class InAppPdfViewer extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const InAppPdfViewer({required this.pdfUrl, required this.title, super.key});

  @override
  State<InAppPdfViewer> createState() => _InAppPdfViewerState();
}

class _InAppPdfViewerState extends State<InAppPdfViewer> {
  late Future<File> _pdfFileFuture;

  @override
  void initState() {
    super.initState();
    _pdfFileFuture = PdfCacheManager.getOrDownloadPdf(widget.pdfUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<File>(
        future: _pdfFileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 50),
                    const SizedBox(height: 16),
                    Text(
                      snapshot.error.toString().replaceAll("Exception: ", ""),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            );
          }
          if (snapshot.hasData) {
            return SfPdfViewer.file(snapshot.data!);
          }
          return const Center(child: Text("Could not load PDF."));
        },
      ),
    );
  }
}

//==============================================================================
// 8. SHIMMER PLACEHOLDERS (No changes here)
//==============================================================================
class _CarouselShimmer extends StatelessWidget {
  const _CarouselShimmer();
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.onSurface.withAlpha(15),
      child: Container(
        height: 220,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16.0)),
      ),
    );
  }
}

class _AllNewsShimmer extends StatelessWidget {
  const _AllNewsShimmer();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: "All News"),
          ...List.generate(4, (index) => const _NewsListCardShimmer()),
        ],
      ),
    );
  }
}

class _NewsListCardShimmer extends StatelessWidget {
  const _NewsListCardShimmer();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceContainerHighest,
      highlightColor: theme.colorScheme.onSurface.withAlpha(15),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(bottom: 12),
        child: const SizedBox(height: 104),
      ),
    );
  }
}
