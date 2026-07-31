import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../screens/geo_track_screen.dart';


class MarkingScheme {
  final String theoryAssessment;
  final String theoryFinal;
  final String practicalAssessment;
  final String practicalFinal;

  const MarkingScheme({
    required this.theoryAssessment,
    required this.theoryFinal,
    required this.practicalAssessment,
    required this.practicalFinal,
  });
}

class Subject {
  final String name;
  final String code;
  final MarkingScheme marks;

  const Subject(this.name, this.code, this.marks);
}

class UtilityItem {
  final String title;
  final IconData icon;
  final Color color;
  final void Function(BuildContext) onTap;

  const UtilityItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

// --- UI SCREENS ---
class UtilitiesTab extends StatelessWidget {
  const UtilitiesTab({super.key});

  Future<void> _launchURL(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.inAppWebView)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<UtilityItem> items = [
      UtilityItem(
        title: 'Courses',
        icon: Icons.menu_book_rounded,
        color: Colors.indigo,
        onTap: (ctx) => Navigator.push(ctx,
            MaterialPageRoute(builder: (_) => const FacultySelectionScreen())),
      ),
      UtilityItem(
        title: 'Academic Calendar',
        icon: Icons.calendar_today_rounded,
        color: Colors.teal,
        onTap: (ctx) => Navigator.push(
            ctx,
            MaterialPageRoute(
                builder: (_) => const PdfViewerScreen(
                      assetPath: 'lib/assets/KhEC83.pdf',
                      title: 'Academic Calendar',
                    ))),
      ),
      UtilityItem(
        title: 'Syllabus',
        icon: Icons.school_rounded,
        color: Colors.deepPurple,
        onTap: (ctx) => _launchURL(
            'https://drive.google.com/drive/folders/1DrOZzxt9BWfFqEHKMrtPlpF4_EqtHE-Q',
            ctx),
      ),
      UtilityItem(
        title: 'PYQs',
        icon: Icons.folder_copy_rounded,
        color: Colors.lightBlue,
        onTap: (ctx) => _launchURL(
            'https://drive.google.com/drive/folders/1_gOLVoO6HgkbpW_72HD1gXW8frIRn_2q',
            ctx),
      ),
      UtilityItem(
        title: 'Memo Pad',
        icon: Icons.note_alt_rounded,
        color: Colors.amber.shade800,
        onTap: (ctx) => Navigator.push(
            ctx, MaterialPageRoute(builder: (_) => const MemoScreen())),
      ),
      UtilityItem(
        title: 'Bus Tracker',
        icon: Icons.directions_bus_rounded,
        color: Colors.orange.shade800,
        onTap: (ctx) => Navigator.push(
            ctx, MaterialPageRoute(builder: (_) => const GeoTrackScreen())),
      ),
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => item.onTap(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: item.color.withOpacity(0.15),
                  child: Icon(item.icon, size: 32, color: item.color),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FacultySelectionScreen extends StatelessWidget {
  const FacultySelectionScreen({super.key});
  static const Map<String, IconData> facultyIcons = {
    'BCT': Icons.computer_rounded,
    'BCE': Icons.construction_rounded,
    'BEL': Icons.electrical_services_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Faculty')),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        itemCount: facultySyllabus.keys.length,
        itemBuilder: (context, index) {
          final faculty = facultySyllabus.keys.elementAt(index);
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor:
                    Theme.of(context).colorScheme.onPrimaryContainer,
                child: Icon(facultyIcons[faculty] ?? Icons.school),
              ),
              title: Text(faculty,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => SyllabusScreen(faculty: faculty))),
            ),
          );
        },
      ),
    );
  }
}

class SyllabusScreen extends StatelessWidget {
  final String faculty;
  const SyllabusScreen({super.key, required this.faculty});

  @override
  Widget build(BuildContext context) {
    final syllabusData = facultySyllabus[faculty]!;
    final subtitleColor = Theme.of(context).textTheme.bodySmall?.color;

    return Scaffold(
      appBar: AppBar(title: Text('$faculty Syllabus')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: syllabusData.keys.length,
        itemBuilder: (context, index) {
          final semester = syllabusData.keys.elementAt(index);
          final subjects = syllabusData[semester]!;
          return Card(
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              title: Text(semester,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16)),
              leading: Icon(Icons.school_outlined,
                  color: Theme.of(context).colorScheme.primary),
              children: subjects
                  .map((subject) => ListTile(
                        title: Text(subject.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text("Code: ${subject.code}"),
                            const SizedBox(height: 2),
                            Text(
                              "Theory: ${subject.marks.theoryAssessment} (Assess) + ${subject.marks.theoryFinal} (Final)",
                              style:
                                  TextStyle(color: subtitleColor, fontSize: 12),
                            ),
                            Text(
                              "Practical: ${subject.marks.practicalAssessment} (Assess) + ${subject.marks.practicalFinal} (Final)",
                              style:
                                  TextStyle(color: subtitleColor, fontSize: 12),
                            ),
                          ],
                        ),
                        contentPadding: const EdgeInsets.only(
                            left: 30, right: 16, bottom: 8, top: 4),
                        onTap: null,
                      ))
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}

class MemoScreen extends StatefulWidget {
  const MemoScreen({super.key});
  @override
  MemoScreenState createState() => MemoScreenState();
}

class MemoScreenState extends State<MemoScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = true;
  static const String _memoKey = 'user_memo_notes';

  @override
  void initState() {
    super.initState();
    _loadMemo();
    _controller.addListener(_saveMemo);
  }

  Future<void> _loadMemo() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _controller.text = prefs.getString(_memoKey) ?? '';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveMemo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_memoKey, _controller.text);
  }

  @override
  void dispose() {
    _controller.removeListener(_saveMemo);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memo Pad'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever_rounded),
            tooltip: "Clear All Notes",
            onPressed: () {
              _controller.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Notes cleared'),
                    duration: Duration(seconds: 1)),
              );
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainer,
                  hintText:
                      'Write down your assignments, homework, or thoughts...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary, width: 2),
                  ),
                ),
              ),
            ),
    );
  }
}

class PdfViewerScreen extends StatelessWidget {
  final String? assetPath;
  final String title;
  const PdfViewerScreen({super.key, this.assetPath, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SfPdfViewer.asset(
        assetPath!,
      ),
    );
  }
}


final Map<String, Map<String, List<Subject>>> facultySyllabus = {
  'BCT': {
    'First Semester': const [
      Subject(
          'Applied Mechanics',
          'CE 401',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Basic Electrical Engineering',
          'EE 401',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Engineering Physics',
          'SH 402',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Engineering Drawing I',
          'ME 401',
          MarkingScheme(
              theoryAssessment: '-',
              theoryFinal: '-',
              practicalAssessment: '50',
              practicalFinal: '50')),
      Subject(
          'Engineering Mathematics I',
          'SH 401',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Computer Programming',
          'CT 401',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25'))
    ],
    'Second Semester': const [
      Subject(
          'Engineering Mathematics II',
          'SH 451',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Engineering Drawing II',
          'ME 451',
          MarkingScheme(
              theoryAssessment: '-',
              theoryFinal: '-',
              practicalAssessment: '50',
              practicalFinal: '50')),
      Subject(
          'Basic Electronics Engineering',
          'EX 451',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Engineering Chemistry',
          'SH 453',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Fundamental of Thermodynamics & Heat Transfer',
          'ME 452',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Workshop Technology',
          'ME 453',
          MarkingScheme(
              theoryAssessment: '-',
              theoryFinal: '-',
              practicalAssessment: '50',
              practicalFinal: '50'))
    ],
    'Third Semester': const [
      Subject(
          'Engineering Mathematics III',
          'SH 501',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Object Oriented Programming',
          'CT 501',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Electric Circuit Theory',
          'EE 501',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Theory of Computation',
          'CT 502',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Electronics Devices and Circuit',
          'EX 501',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Digital Logic',
          'EX 502',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Electromagnetics',
          'EX 503',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-'))
    ],
    'Fourth Semester': const [
      Subject(
          'Numerical Method',
          'SH 553',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Applied Mathematics',
          'SH 551',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Instrumentation I',
          'EE 552',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Data Structure and Algorithm',
          'CT 552',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Microprocessor',
          'EX 551',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Discrete Structure',
          'CT 551',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Electrical Machine',
          'EE 554',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25'))
    ],
    'Fifth Semester': const [
      Subject(
          'Communication English',
          'SH 601',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Probability and Statistics',
          'SH 602',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Computer organization and Architecture',
          'CT 603',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Software Engineering',
          'CT 601',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Computer Graphics',
          'EX 603',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Instrumentation II',
          'EX 602',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Data Communication',
          'CT 602',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-'))
    ],
    'Sixth Semester': const [
      Subject(
          'Engineering Economics',
          'CE 655',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Object Oriented Analysis and Design',
          'CT 651',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Artificial Intelligence',
          'CT 653',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Operating System',
          'CT 656',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Embedded System',
          'CT 655',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Database Management System',
          'CT 652',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Minor Project',
          'CT 654',
          MarkingScheme(
              theoryAssessment: '-',
              theoryFinal: '-',
              practicalAssessment: '50',
              practicalFinal: '50'))
    ],
    'Seventh Semester': const [
      Subject(
          'ICT Project Management',
          'CT 701',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Organization and Management',
          'ME 708',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Energy Environment and Society',
          'EX 701',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Distributed System',
          'CT 703',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Computer Networks and Security',
          'CT 702',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Digital Signal Analysis and Processing',
          'CT 704',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Project (Part A)',
          'CT 707',
          MarkingScheme(
              theoryAssessment: '-',
              theoryFinal: '-',
              practicalAssessment: '100',
              practicalFinal: '-')),
      Subject(
          'Elective I : Advanced Java',
          'CT 725 01',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Elective I : Aeronautical Telecom',
          'EX 725 04',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Elective I : Biomedical Instrumentation',
          'Unknown',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
    ],
    'Eighth Semester': const [
      Subject(
          'Engineering Professional Practice',
          'CE 752',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Information Systems',
          'CT 751',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Internet and Intranet',
          'CT 754',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Project (Part B)',
          'CT 755',
          MarkingScheme(
              theoryAssessment: '-',
              theoryFinal: '-',
              practicalAssessment: '50',
              practicalFinal: '150')),
      Subject(
          'Simulation and Modelling',
          'CT 753',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Elective II : AGILE SOFTWARE DEVELOPMENT',
          'CT 765 02',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Elective III : ARTIFICIAL INTELLIGENCE',
          'CT 785 06',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
    ]
  },
  'BCE': {
    'First Semester': const [
      Subject(
          'Engineering Drawing I',
          'ME 401',
          MarkingScheme(
              theoryAssessment: '-',
              theoryFinal: '-',
              practicalAssessment: '50',
              practicalFinal: '50')),
      Subject(
          'Engineering Mathematics I',
          'SH 401',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Fundamental of Thermodynamics & Heat Transfer',
          'ME 452',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Engineering Chemistry',
          'SH 453',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Workshop Technology',
          'ME 453',
          MarkingScheme(
              theoryAssessment: '-',
              theoryFinal: '-',
              practicalAssessment: '50',
              practicalFinal: '50')),
      Subject(
          'Computer Programming',
          'CT 401',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25'))
    ],
    'Second Semester': const [
      Subject(
          'Engineering Mathematics II',
          'SH 451',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Basic Electronics Engineering',
          'EX 451',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Engineering Drawing II',
          'ME 451',
          MarkingScheme(
              theoryAssessment: '-',
              theoryFinal: '-',
              practicalAssessment: '50',
              practicalFinal: '50')),
      Subject(
          'Engineering Physics',
          'SH 402',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Applied Mechanics',
          'CE 451',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Basic Electrical Engineering',
          'EE 453',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25'))
    ],
    'Third Semester': const [
      Subject(
          'Civil Engineering Materials',
          'CE 506',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Engineering Mathematics III',
          'SH 501',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Applied Mechanics(Dynamics)',
          'CE 503',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Engineering Geology I',
          'CE 501',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Strength of Materials',
          'CE 502',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Surveying I',
          'CE 504',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Fluid mechanics',
          'CE 505',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25'))
    ],
    'Fourth Semester': const [
      Subject(
          'Hydraulics',
          'CE 555',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Surveying II',
          'CE 554',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Theory of Structures I',
          'CE 551',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Probability And Statistics',
          'SH 552',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Engineering Geology II',
          'CE 553',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Building Drawing',
          'CE 556',
          MarkingScheme(
              theoryAssessment: '-',
              theoryFinal: '-',
              practicalAssessment: '50',
              practicalFinal: '50')),
      Subject(
          'Soil Mechanics',
          'CE 552',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25'))
    ],
    'Fifth Semester': const [
      Subject(
          'Theory of structure II',
          'CE 601',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Water Supply Engineering',
          'CE 605',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Engineering hydrology',
          'CE 606',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Concrete Technology and masonry structure',
          'CE 603',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Numerical Methods',
          'SH 603',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Foundation Engineering',
          'CE 602',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Survey Camp',
          'CE 604',
          MarkingScheme(
              theoryAssessment: '-',
              theoryFinal: '-',
              practicalAssessment: '50',
              practicalFinal: '50'))
    ],
    'Sixth Semester': const [
      Subject(
          'Design of Steel and Timber Structure',
          'CE 651',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Communication English',
          'SH 651',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Engineering Economics',
          'CE 655',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Building Technology',
          'CE 652',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Sanitary Engineering',
          'CE 656',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Transportation Engineering',
          'CE 653',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Irrigation and Drainage',
          'CE 654',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25'))
    ],
    'Seventh Semester': const [
      Subject(
          'Hydropower Engineering',
          'CE 704',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Project Engineering',
          'CE 701',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Transportation Engineering II',
          'CE 703',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Estimating & Costing',
          'CE 705',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Design of RCC Structure',
          'CE 702',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Project (Part I)',
          'CE 707',
          MarkingScheme(
              theoryAssessment: '-',
              theoryFinal: '-',
              practicalAssessment: '50',
              practicalFinal: '-')),
      Subject(
          'Elective I : Structural Dynamics',
          'CE 72501',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
    ],
    'Eighth Semester': const [
      Subject(
          'Technology Environment and Society',
          'CE 753',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Construction Management',
          'CE 754',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Project (Part II)',
          'CE 755',
          MarkingScheme(
              theoryAssessment: '-',
              theoryFinal: '-',
              practicalAssessment: '50',
              practicalFinal: '100')),
      Subject(
          'Engineering Professional Practice',
          'CE 752',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Computational Techniques in Civil Engineering',
          'CE751',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Elective II : Design of Bridges',
          'CE 76502',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Elective III : GIS Application and Remote Sensing',
          'CE 78501',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
    ]
  },
  'BEL': {
    'First Semester': const [
      Subject(
          'Engineering Drawing I',
          'ME 401',
          MarkingScheme(
              theoryAssessment: '-',
              theoryFinal: '-',
              practicalAssessment: '50',
              practicalFinal: '50')),
      Subject(
          'Engineering Physics',
          'SH 402',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Applied Mechanics',
          'CE 401',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Basic Electrical Engineering',
          'EE 401',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Engineering Mathematics I',
          'SH 401',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Computer Programming',
          'CT 401',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25'))
    ],
    'Second Semester': const [
      Subject(
          'Engineering Mathematics II',
          'SH 451',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Engineering Drawing II',
          'ME 451',
          MarkingScheme(
              theoryAssessment: '-',
              theoryFinal: '-',
              practicalAssessment: '50',
              practicalFinal: '50')),
      Subject(
          'Basic Electronics Engineering',
          'EX 451',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Engineering Chemistry',
          'SH 453',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Fundamental of Thermodynamics & Heat Transfer',
          'ME 452',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Workshop Technology',
          'ME 453',
          MarkingScheme(
              theoryAssessment: '-',
              theoryFinal: '-',
              practicalAssessment: '50',
              practicalFinal: '50'))
    ],
    'Third Semester': const [
      Subject(
          'Engineering Mathematics III',
          'SH 501',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Object Oriented Programming',
          'CT 501',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Electric Circuit Theory',
          'EE 501',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Electronics Devices and Circuit',
          'EX 501',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Digital Logic',
          'EX 502',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Electrical Engineering Material',
          'EE 502',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Electromagnetics',
          'EX 503',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-'))
    ],
    'Fourth Semester': const [
      Subject(
          'Numerical Method',
          'SH 553',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Applied Mathematics',
          'SH 551',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Instrumentation I',
          'EE 552',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Microprocessor',
          'EX 551',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Power System Analysis I',
          'EE 555',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Electrical Machines I',
          'EE 550',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25'))
    ],
    'Fifth Semester': const [
      Subject(
          'Electric Machines - II',
          'EE 601',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Electric Machine Design',
          'EE 603',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Power System Analysis II',
          'EE 605',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Communication English',
          'SH 601',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Probability and Statistics',
          'SH 602',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Control System',
          'EE 602',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Instrumentation II',
          'EX 602',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25'))
    ],
    'Sixth Semester': const [
      Subject(
          'Engineering Economics',
          'CE 655',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Hydro Power',
          'CE 660',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Swichgear & Protection',
          'EE 651',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Digital Control System',
          'EE 652',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Industrial Power Distribution & Illumination',
          'EE 653',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Signal Analysis',
          'EX 651',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-'))
    ],
    'Seventh Semester': const [
      Subject(
          'Project Engineering',
          'CE 701',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Technology Environment and Society',
          'CE 708',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Power Electronics',
          'EE 701',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Organization and Management',
          'ME 708',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Utilization of Electrical Energy',
          'EE 702',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Power Plant Equipment',
          'EE 703',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Project (Part A)',
          'EE 707',
          MarkingScheme(
              theoryAssessment: '-',
              theoryFinal: '-',
              practicalAssessment: '100',
              practicalFinal: '-')),
      Subject(
          'Elective I : Rural Electrification',
          'Unknown',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
    ],
    'Eighth Semester': const [
      Subject(
          'Engineering Professional Practice',
          'CE 752',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'High Voltage Engineering',
          'EE 751',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Power Plant Design',
          'EE 753',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Transmission and Distribution System Design',
          'EE 754',
          MarkingScheme(
              theoryAssessment: '-',
              theoryFinal: '-',
              practicalAssessment: '25',
              practicalFinal: '25')),
      Subject(
          'Project (Part B)',
          'EE 755',
          MarkingScheme(
              theoryAssessment: '-',
              theoryFinal: '-',
              practicalAssessment: '50',
              practicalFinal: '150')),
      Subject(
          'Elective II : BIOMEDICAL INSTRUMENTATION',
          'Unknown',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
      Subject(
          'Elective III : Artificial Neural Network',
          'Unknown',
          MarkingScheme(
              theoryAssessment: '20',
              theoryFinal: '80',
              practicalAssessment: '-',
              practicalFinal: '-')),
    ]
  }
};
