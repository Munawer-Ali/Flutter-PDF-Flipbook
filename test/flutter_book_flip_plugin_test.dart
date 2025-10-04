import 'package:flutter_pdf_flipbook/widgets/pdf_book_viewer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Plugin Tests', () {
    test('PdfBookViewer widget initialization', () {
      expect(
        () => PdfBookViewer(pdfUrl: 'https://example.com/test.pdf'),
        returnsNormally,
      );
    });

    test('PdfBookViewerStyle default values', () {
      final style = PdfBookViewerStyle.defaultStyle();
      expect(style.centerDividerWidth, 5.0);
      expect(style.backgroundColor, isNotNull);
    });

    test('NavigationControlsStyle default values', () {
      /// Note: NavigationControlsStyle is imported from the main package
      expect(() => NavigationControlsStyle(), returnsNormally);
    });
  });
}
