import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatelessWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // The AppBar will automatically adopt the app's theme
        title: Text(
          title,
          style: const TextStyle(fontSize: 16), // Smaller font for long titles
        ),
      ),
      body: SfPdfViewer.network(
        pdfUrl,
        // Shows a loading indicator while the PDF is downloading
        canShowScrollHead: true,
        canShowScrollStatus: true,
      ),
    );
  }
}
