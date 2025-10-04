# Quick Usage Guide

## How to Use the Plugin in Your Project

### 1. Add to pubspec.yaml

```yaml
dependencies:
  flutter_book_flip_plugin:
    path: /path/to/flutter_book_flip_plugin
```

For Git repository:
```yaml
dependencies:
  flutter_book_flip_plugin:
    git:
      url: https://github.com/yourusername/flutter_book_flip_plugin.git
```

### 2. Import and Use

```dart
import 'package:flutter/material.dart';
import 'package:flutter_book_flip_plugin/flutter_book_flip_plugin.dart';

class MyPDFReader extends StatelessWidget {
  final String documentUrl = 'https://your-pdf-url.com/document.pdf';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PDF Reader')),
      body: PdfBookViewer(
        pdfUrl: documentUrl,
        onPageChanged: (currentPage, totalPages) {
          // Handle page changes
          print('Now viewing page $currentPage of $totalPages');
        },
      ),
    );
  }
}
```

### 3. Customize Appearance

```dart
PdfBookViewer(
  pdfUrl: 'https://example.com/document.pdf',
  backgroundColor: Colors.black,          // Dark theme
  showNavigationControls: true,           // Show/hide controls
  style: PdfBookViewerStyle(
    centerDividerColor: Colors.amber,     // Golden divider
    loadingIndicatorColor: Colors.blue,    // Blue loading spinner
    navigationControlsStyle: NavigationControlsStyle(
      buttonColor: Colors.deepOrange,     // Orange buttons
      iconColor: Colors.white,             // White icons
    ),
  ),
)
```

### 4. Handle Local Files

```dart
// For local assets
PdfBookViewer(
  pdfUrl: 'https://localhost:8080/local.pdf',
)

// Or use asset bundles
PdfBookViewer(
  pdfUrl: 'assets/documents/sample.pdf',
)
```

That's it! Your PDF is now displayed with beautiful book flip animations! 📖✨
