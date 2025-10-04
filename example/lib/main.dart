import 'package:flutter/material.dart';
import 'package:flutter_pdf_flipbook/flutter_pdf_flipbook.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter PDF Flipbook Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'PDF Flipbook Viewer Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _currentPage = "1";
  String _totalPages = "0";

  /// Example PDF URLs - users can change these
  final String defaultPdfUrl =
      'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf';
  String currentPdfUrl =
      'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          /// PDF URL input section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PDF URL:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Enter PDF URL here',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.link),
                  ),
                  onChanged: (value) {
                    currentPdfUrl = value.isEmpty ? defaultPdfUrl : value;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Current Page: $_currentPage of $_totalPages',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          /// The PDF Book Viewer
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border:
                    Border.all(color: Colors.deepPurple.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: PdfBookViewer(
                  pdfUrl: currentPdfUrl,
                  onPageChanged: (currentPage, totalPages) {
                    setState(() {
                      _currentPage = currentPage.toString();
                      _totalPages = totalPages.toString();
                    });
                  },
                  onError: (error) {
                    print('PDF loading error: $error');
                  },
                  style: PdfBookViewerStyle.defaultStyle().copyWith(
                    backgroundColor: Colors.grey.shade100,
                    bookBackgroundColor: Colors.white,
                    loadingIndicatorColor: Colors.deepPurple,
                  ),
                  showNavigationControls: true,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showStyleOptions();
        },
        child: const Icon(Icons.palette),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  void _showStyleOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Style Options'),
          content: const Text(
            'This demonstrates the flexibility of the plugin. '
            'You can customize colors, sizes, and styling options.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

// Extension to support copyWith for PdfBookViewerStyle
extension PdfBookViewerStyleExtension on PdfBookViewerStyle {
  PdfBookViewerStyle copyWith({
    Color? backgroundColor,
    Color? bookBackgroundColor,
    Color? centerDividerColor,
    double? centerDividerWidth,
    Color? loadingIndicatorColor,
    BoxDecoration? bookContainerDecoration,
    NavigationControlsStyle? navigationControlsStyle,
  }) {
    return PdfBookViewerStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      bookBackgroundColor: bookBackgroundColor ?? this.bookBackgroundColor,
      centerDividerColor: centerDividerColor ?? this.centerDividerColor,
      centerDividerWidth: centerDividerWidth ?? this.centerDividerWidth,
      loadingIndicatorColor:
          loadingIndicatorColor ?? this.loadingIndicatorColor,
      bookContainerDecoration:
          bookContainerDecoration ?? this.bookContainerDecoration,
      navigationControlsStyle:
          navigationControlsStyle ?? this.navigationControlsStyle,
    );
  }
}
