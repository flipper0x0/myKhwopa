import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../services/notice_service.dart';
import '../models/notice_model.dart';
import '../screens/pdf_viewer_screen.dart';

class IOETab extends StatelessWidget {
  const IOETab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              indicatorColor: theme.colorScheme.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
              tabs: const [
                Tab(icon: Icon(Icons.notifications_active_outlined, size: 18), text: 'Notices'),
                Tab(icon: Icon(Icons.calculate_outlined, size: 18), text: 'Calculator'),
                Tab(icon: Icon(Icons.calendar_month_outlined, size: 18), text: 'Calendar'),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                NoticesView(),
                PercentageCalculatorView(),
                CalendarView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Notices Tab ----
class NoticesView extends StatefulWidget {
  const NoticesView({super.key});
  @override
  State<NoticesView> createState() => _NoticesViewState();
}

class _NoticesViewState extends State<NoticesView> {
  final List<Notice> _notices = [];
  String? _nextCursor;
  bool _hasMore = true;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchInitialNotices();
    _scrollController.addListener(() {
      if (!_isLoadingMore &&
          _hasMore &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200) {
        _loadMoreNotices();
      }
    });
  }

  Future<void> _fetchInitialNotices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasMore = true;
      _nextCursor = null;
    });
    try {
      _notices.clear();
      final result = await NoticeService.fetchNoticesWithCursor();
      setState(() {
        _notices.addAll(result.notices);
        _nextCursor = result.nextCursor;
        _hasMore = result.nextCursor != null && result.nextCursor!.isNotEmpty;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreNotices() async {
    if (_isLoadingMore || !_hasMore || _nextCursor == null) return;
    setState(() {
      _isLoadingMore = true;
    });
    try {
      final result =
          await NoticeService.fetchNoticesWithCursor(cursor: _nextCursor);
      if (!mounted) return;
      if (result.notices.isEmpty) {
        setState(() {
          _hasMore = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("You've reached the end!"),
          duration: Duration(seconds: 1),
        ));
      } else {
        setState(() {
          _notices.addAll(result.notices);
          _nextCursor = result.nextCursor;
          _hasMore =
              result.nextCursor != null && result.nextCursor!.isNotEmpty;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load more notices.')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.cloud_off_rounded,
                size: 100, color: Colors.red.shade300),
            const SizedBox(height: 20),
            const Text('Service Unavailable',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
                'Could not connect to the IOE server. Please check your internet connection or try again later.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: _fetchInitialNotices),
          ]),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchInitialNotices,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
        itemCount: _notices.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _notices.length) {
            return const Center(
                child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator()));
          }
          return NoticeCard(notice: _notices[index]);
        },
      ),
    );
  }
}

class NoticeCard extends StatelessWidget {
  final Notice notice;
  const NoticeCard({super.key, required this.notice});

  @override
  Widget build(BuildContext context) {
    final bool isPdf = notice.downloadUrl.toLowerCase().endsWith('.pdf');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (isPdf) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PdfViewerScreen(
                  pdfUrl: notice.downloadUrl,
                  title: notice.title,
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoticeDetailWebViewScreen(
                  url: notice.downloadUrl,
                  title: notice.title,
                ),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Image.network(
                'https://exam.ioe.tu.edu.np/assets/logo.png',
                width: 45,
                height: 45,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.school, size: 45, color: Colors.grey.shade400),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notice.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Text(notice.date,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(isPdf ? Icons.picture_as_pdf_outlined : Icons.open_in_new,
                  color: Theme.of(context).colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class NoticeDetailWebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const NoticeDetailWebViewScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<NoticeDetailWebViewScreen> createState() =>
      _NoticeDetailWebViewScreenState();
}

class _NoticeDetailWebViewScreenState extends State<NoticeDetailWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) {
              setState(() {
                _progress = progress / 100;
              });
            }
          },
          onPageStarted: (url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (error) {
            debugPrint("Notice WebView Error: ${error.description}");
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser_rounded),
            tooltip: 'Open in Browser',
            onPressed: () async {
              try {
                final uri = Uri.parse(widget.url);
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } catch (_) {}
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => _controller.reload(),
          ),
        ],
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3.0),
                child: LinearProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                  backgroundColor: theme.colorScheme.surfaceContainerHigh,
                ),
              )
            : null,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

// ---- Percentage Calculator Tab (No Changes Here) ----
class PercentageCalculatorView extends StatefulWidget {
  const PercentageCalculatorView({super.key});

  @override
  State<PercentageCalculatorView> createState() =>
      _PercentageCalculatorViewState();
}

class _PercentageCalculatorViewState extends State<PercentageCalculatorView> {
  final Map<String, List<int>> _fullMarks = {
    'BCT': [725, 650, 875, 900, 875, 825, 825, 750],
    'BCE': [675, 700, 700, 750, 875, 750, 750, 650],
    'BEL': [725, 650, 875, 750, 800, 725, 825, 850],
  };

  String? _selectedFaculty;
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _controllers =
      List.generate(8, (_) => TextEditingController());
  double? _aggregatePercentage;
  String? _grade;

  String _getGrade(double percentage) {
    if (percentage >= 80) return 'A+ (Distinction)';
    if (percentage >= 70) return 'A (First Division)';
    if (percentage >= 65) return 'B+ (First Division)';
    if (percentage >= 60) return 'B (Second Division)';
    if (percentage >= 50) return 'C+ (Second Division)';
    if (percentage >= 40) return 'C (Pass)';
    return 'F (Fail)';
  }

  void _calculatePercentage() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      final fullMarksList = _fullMarks[_selectedFaculty]!;
      final obtainedMarks =
          _controllers.map((c) => double.tryParse(c.text) ?? 0).toList();
      double getYearPercentage(int sem1Index, int sem2Index) {
        final yearObtained =
            obtainedMarks[sem1Index] + obtainedMarks[sem2Index];
        final yearFullMarks =
            fullMarksList[sem1Index] + fullMarksList[sem2Index];
        return yearFullMarks == 0 ? 0 : (yearObtained / yearFullMarks) * 100;
      }

      final year1Percent = getYearPercentage(0, 1);
      final year2Percent = getYearPercentage(2, 3);
      final year3Percent = getYearPercentage(4, 5);
      final year4Percent = getYearPercentage(6, 7);
      final finalPercentage = (0.20 * year1Percent) +
          (0.20 * year2Percent) +
          (0.30 * year3Percent) +
          (0.30 * year4Percent);
      setState(() {
        _aggregatePercentage = finalPercentage;
        _grade = _getGrade(finalPercentage);
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                  labelText: 'Select Faculty',
                  prefixIcon: const Icon(Icons.school_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12))),
              value: _selectedFaculty,
              items: _fullMarks.keys
                  .map((String faculty) => DropdownMenuItem<String>(
                      value: faculty, child: Text(faculty)))
                  .toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedFaculty = newValue;
                  _aggregatePercentage = null;
                  _grade = null;
                  for (var controller in _controllers) {
                    controller.clear();
                  }
                });
              },
              validator: (value) =>
                  value == null ? 'Please select a faculty' : null,
            ),
            const SizedBox(height: 20),
            if (_selectedFaculty != null) ..._buildSemesterFields(),
            if (_aggregatePercentage != null && _grade != null)
              _buildResultCard(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSemesterFields() {
    final fullMarksList = _fullMarks[_selectedFaculty]!;
    return [
      ...List.generate(
          8,
          (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: TextFormField(
                  controller: _controllers[index],
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      labelText: 'Semester ${index + 1} Marks',
                      hintText: 'Out of ${fullMarksList[index]}',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter marks';
                    }
                    final marks = double.tryParse(value);
                    if (marks == null) return 'Invalid number';
                    if (marks < 0 || marks > fullMarksList[index]) {
                      return 'Marks must be between 0 and ${fullMarksList[index]}';
                    }
                    return null;
                  },
                ),
              )),
      const SizedBox(height: 20),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
        onPressed: _calculatePercentage,
        child:
            const Text('Calculate Aggregate', style: TextStyle(fontSize: 16)),
      ),
      const SizedBox(height: 20),
    ];
  }

  Widget _buildResultCard() {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 4,
      color: colorScheme.primaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Column(
          children: [
            const Text('WEIGHTED AGGREGATE RESULT',
                style:
                    TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            Text(
              '${_aggregatePercentage!.toStringAsFixed(2)}%',
              style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(_grade!,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSecondaryContainer)),
              backgroundColor: colorScheme.secondaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Calendar Tab (MODIFIED SECTION) ----
class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late TransformationController _transformationController;
  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails?.localPosition ?? Offset.zero;
      _transformationController.value = Matrix4.identity()
        ..translate(-position.dx * 1.5, -position.dy * 1.5)
        ..scale(2.5);
    }
  }

  void _zoomIn() {
    final matrix = _transformationController.value.clone();
    matrix.scale(1.3);
    _transformationController.value = matrix;
  }

  void _zoomOut() {
    final matrix = _transformationController.value.clone();
    matrix.scale(0.75);
    _transformationController.value = matrix;
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  void _openFullScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: const Text('Academic Calendar'),
          ),
          body: const FullScreenCalendarViewer(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        GestureDetector(
          onDoubleTapDown: _handleDoubleTapDown,
          onDoubleTap: _handleDoubleTap,
          child: InteractiveViewer(
            transformationController: _transformationController,
            boundaryMargin: const EdgeInsets.all(300.0),
            minScale: 0.8,
            maxScale: 5.0,
            clipBehavior: Clip.none,
            child: Center(
              child: Image.asset(
                'lib/assets/calender_1.jpg',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported_outlined,
                              color: Colors.red, size: 60),
                          SizedBox(height: 16),
                          Text(
                            'Could not load calendar image.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        // Floating Controls Bar for Easy Zooming
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.zoom_in_rounded),
                  tooltip: 'Zoom In',
                  onPressed: _zoomIn,
                ),
                IconButton(
                  icon: const Icon(Icons.zoom_out_rounded),
                  tooltip: 'Zoom Out',
                  onPressed: _zoomOut,
                ),
                IconButton(
                  icon: const Icon(Icons.restart_alt_rounded),
                  tooltip: 'Reset Zoom',
                  onPressed: _resetZoom,
                ),
                IconButton(
                  icon: const Icon(Icons.fullscreen_rounded),
                  tooltip: 'Full Screen',
                  onPressed: () => _openFullScreen(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class FullScreenCalendarViewer extends StatefulWidget {
  const FullScreenCalendarViewer({super.key});

  @override
  State<FullScreenCalendarViewer> createState() =>
      _FullScreenCalendarViewerState();
}

class _FullScreenCalendarViewerState extends State<FullScreenCalendarViewer> {
  late TransformationController _controller;
  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _controller = TransformationController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_controller.value != Matrix4.identity()) {
      _controller.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails?.localPosition ?? Offset.zero;
      _controller.value = Matrix4.identity()
        ..translate(-position.dx * 1.5, -position.dy * 1.5)
        ..scale(2.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _handleDoubleTapDown,
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _controller,
        boundaryMargin: const EdgeInsets.all(500.0),
        minScale: 0.5,
        maxScale: 6.0,
        child: Center(
          child: Image.asset(
            'lib/assets/calender_1.jpg',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
