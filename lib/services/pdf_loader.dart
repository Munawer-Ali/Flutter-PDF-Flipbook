import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';
import '../models/app_state.dart';

class PdfLoader {
  final AppState appState;

  PdfLoader(this.appState);

  Future<Uint8List> fetchPdfAsBytes(String url) async {
    try {
      final proxyUrl =
          'https://workers-playground-tiny-snow-5cbb.munawera808.workers.dev?url=${Uri.encodeComponent(url)}';
      final response = await http.get(Uri.parse(proxyUrl));

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return response.bodyBytes;
      } else {
        throw Exception(
            'Failed to load PDF via Worker. Status: ${response.statusCode}');
      }
    } catch (e) {
      return Uint8List(0);
    }
  }

  Future<void> loadPdf(String url) async {
    try {
      appState.isLoading = true;

      /// Download PDF as bytes
      final bytes = await fetchPdfAsBytes(url);

      if (bytes.isEmpty) {
        throw Exception("PDF file is empty or could not be downloaded.");
      }

      /// Validate PDF format by checking magic bytes
      if (bytes.length < 4 ||
          !(bytes[0] == 0x25 &&
              bytes[1] == 0x50 &&
              bytes[2] == 0x44 &&
              bytes[3] == 0x46)) {
        throw Exception(
            "Invalid PDF format. File does not appear to be a valid PDF.");
      }

      /// Open PDF document
      final document = await PdfDocument.openData(bytes);

      if (document.pagesCount == 0) {
        throw Exception("PDF document has no pages.");
      }

      /// Save in your app state
      appState.document = document;
      appState.totalPages = document.pagesCount;
      appState.isLoading = false;

      /// Load initial pages
      await loadPages(0, null);
    } catch (e) {
      appState.isLoading = false;
      throw Exception("Failed to load PDF: $e");
    }
  }

  Future<void> loadPages(int index, int? pageNumber) async {
    if (appState.isLoading || appState.document == null) return;

    appState.isLoading = true;

    try {
      int pagesToLoad;

      if (pageNumber == null) {
        if (index == 0 || index == 1) {
          pagesToLoad = 6;
        } else {
          pagesToLoad = 4 + appState.pageImages.length;
        }
      } else {
        pagesToLoad = 4 + pageNumber;
      }

      for (int i = 0; i < pagesToLoad; i++) {
        if (appState.alreadyAdded.any((element) => element == i)) {
          continue;
        }

        if (i >= appState.document!.pagesCount) {
          continue;
        }

        final newAlreadyAdded = List<int>.from(appState.alreadyAdded);
        newAlreadyAdded.add(i);
        appState.alreadyAdded = newAlreadyAdded;

        final page = await appState.document!.getPage(i + 1);

        /// Render at much higher resolution for better quality
        final image = await page.render(
          width: page.width * 2,
          height: page.height * 2,
          format: PdfPageImageFormat.png,
          quality: 100,
          forPrint: true,
        );

        if (image != null) {
          final newPageImages = List<PdfPageImage>.from(appState.pageImages);
          newPageImages.add(image);
          if (i == 0 && appState.currentTotalPages != 2) {
            newPageImages.add(image);
          }

          if (appState.document!.pagesCount == (i + 1)) {
            if ((i + 1) % 2 % 2 != 0) {
              newPageImages.add(image);
              appState.showLastPage = false;
            }
          }

          appState.pageImages = newPageImages;
        }

        await page.close();
      }

      appState.animationComplete = false;

      if (pageNumber != null) {
        appState.currentPage = (pageNumber / 2).toInt();
        appState.currentPageComplete = appState.currentPage;
      }
    } finally {
      appState.isLoading = false;
    }
  }

  Future<void> navigateToPage(int pageNumber) async {
    if (appState.document == null) return;

    if (pageNumber < 1 || pageNumber > appState.document!.pagesCount) {
      return;
    }
    pageNumber++;

    /// Calculate which page spread this page belongs to
    int targetPage = (pageNumber - 1) ~/ 2;

    /// Clear existing pages and load the target page
    appState.pageImages = [];
    appState.alreadyAdded = [];

    /// Load pages around the target page
    await loadPages(targetPage, pageNumber);

    /// Update current page tracking
    appState.currentPage = targetPage;
    appState.currentPageComplete = targetPage;
  }
}
