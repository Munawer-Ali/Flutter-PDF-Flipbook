import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../services/pdf_loader.dart';
import '../services/book_animation_controller.dart';
import '../services/page_navigation.dart';
import 'book_page.dart';
import 'animated_page.dart';
import 'navigation_controls.dart';

/// A beautiful book flip animation widget for displaying PDFs
///
/// Usage:
/// ```dart
/// PdfBookViewer(
///   pdfUrl: 'https://example.com/document.pdf',
/// )
/// ```
class PdfBookViewer extends StatefulWidget {
  /// The URL of the PDF to display
  final String pdfUrl;

  /// Optional styling for the book viewer
  final PdfBookViewerStyle? style;

  /// Callback when page changes
  final void Function(int currentPage, int totalPages)? onPageChanged;

  /// Callback when an error occurs
  final void Function(String error)? onError;

  /// Whether to show navigation controls
  final bool showNavigationControls;

  /// Custom background color
  final Color? backgroundColor;

  const PdfBookViewer({
    Key? key,
    required this.pdfUrl,
    this.style,
    this.onPageChanged,
    this.onError,
    this.showNavigationControls = true,
    this.backgroundColor,
  }) : super(key: key);

  @override
  _PdfBookViewerState createState() => _PdfBookViewerState();
}

class _PdfBookViewerState extends State<PdfBookViewer>
    with SingleTickerProviderStateMixin {
  late AppState appState;
  late PdfLoader pdfLoader;
  late BookAnimationController animationController;
  late PageNavigation pageNavigation;
  late TransformationController transformationController;
  TextEditingController pageController = TextEditingController();

  @override
  void initState() {
    super.initState();

    /// Initialize state management
    appState = AppState();
    appState.addListener(_onPageChanged);

    transformationController = TransformationController();
    transformationController.addListener(_onTransformationChanged);

    /// Initialize services
    pdfLoader = PdfLoader(appState);
    animationController = BookAnimationController(
      appState: appState,
      pdfLoader: pdfLoader,
      vsync: this,
    );
    pageNavigation = PageNavigation(
      appState: appState,
      animationController: animationController,
    );

    /// Load the PDF
    _loadPdfWithErrorHandling();
  }

  @override
  void didUpdateWidget(PdfBookViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pdfUrl != widget.pdfUrl) {
      /// Defer state updates to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          _resetState();
          await pdfLoader.loadPdf(widget.pdfUrl);
        } catch (e) {
          final errorMsg = 'Failed to load PDF: ${e.toString()}';
          appState.errorMessage = errorMsg;
          if (widget.onError != null) {
            widget.onError!(errorMsg);
          }
        }
      });
    }
  }

  void _resetState() {
    appState.pageImages = [];
    appState.alreadyAdded = [];
    appState.currentPage = 0;
    appState.currentPageComplete = 0;
    appState.totalPages = 0;
    appState.document = null;
    appState.isLoading = false;
    appState.errorMessage = null;
  }

  Future<void> _loadPdfWithErrorHandling() async {
    try {
      appState.errorMessage = null; /// Clear any previous error
      await pdfLoader.loadPdf(widget.pdfUrl);
    } catch (e) {
      final errorMsg = 'Failed to load PDF: ${e.toString()}';
      appState.errorMessage = errorMsg;
      if (widget.onError != null) {
        widget.onError!(errorMsg);
      }
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    transformationController.dispose();
    appState.removeListener(_onPageChanged);
    appState.dispose();
    super.dispose();
  }

  void _onTransformationChanged() {
    final Matrix4 matrix = transformationController.value;
    final double scaleX = matrix.getMaxScaleOnAxis();
    bool newZoomed = scaleX > 1.01;

    if (appState.isZoomed != newZoomed) {
      appState.isZoomed = newZoomed;
    }
  }

  int? currentPage;
  int? totalPages;
  void _onPageChanged() {
    if (widget.onPageChanged != null) {
      if (currentPage != appState.currentPageComplete * 2 + 1 ||
          totalPages != appState.currentTotalPages) {
        currentPage = appState.currentPageComplete * 2 + 1;
        totalPages = appState.currentTotalPages;
        /// Defer the callback to the next frame to avoid setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onPageChanged!(currentPage!, totalPages!);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? PdfBookViewerStyle.defaultStyle();

    return Scaffold(
      backgroundColor: widget.backgroundColor ??
          style.backgroundColor ??
          Colors.grey.shade800,
      body: Stack(
        children: [
          Column(
            children: [
              ListenableBuilder(
                listenable: appState,
                builder: (context, child) {
                  /// Show error message if there's an error
                  if (appState.errorMessage != null) {
                    return Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.grey.shade600,
                            ),
                            SizedBox(height: 16),
                            Text(
                              appState.errorMessage!,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  /// Show loading indicator if no error and no pages loaded
                  return appState.pageImages.isEmpty
                      ? Expanded(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: style.loadingIndicatorColor,
                            ),
                          ),
                        )
                      : Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final screenWidth = constraints.maxWidth;
                              final screenHeight = constraints.maxHeight;

                              /// Calculate proper aspect ratio for PDF pages
                              final pageAspectRatio = appState
                                      .pageImages.first.width!
                                      .toDouble() /
                                  appState.pageImages.first.height!.toDouble();

                              /// Calculate maximum height available (leave some padding)
                              final maxHeight = screenHeight -
                                  (widget.showNavigationControls ? 100 : 50);

                              /// Calculate width for single page based on aspect ratio
                              final singlePageWidth =
                                  maxHeight * pageAspectRatio;

                              /// Calculate total width for both pages (book spread)
                              final totalBookWidth = singlePageWidth * 2;

                              /// Scale down if book is too wide for screen
                              double scaleFactor = 1.0;
                              if (totalBookWidth > screenWidth * 0.9) {
                                scaleFactor =
                                    (screenWidth * 0.9) / totalBookWidth;
                              }

                              /// Apply scale factor
                              final finalPageWidth =
                                  singlePageWidth * scaleFactor;
                              final finalPageHeight = maxHeight * scaleFactor;

                              return MouseRegion(
                                cursor: appState.isZoomed
                                    ? SystemMouseCursors.grab
                                    : SystemMouseCursors.basic,
                                child: InteractiveViewer(
                                  transformationController:
                                      transformationController,
                                  boundaryMargin: EdgeInsets.zero,
                                  minScale: 1.0,
                                  child: Center(
                                    child: Container(
                                      width: finalPageWidth * 2,
                                      height: finalPageHeight,
                                      decoration: style.bookContainerDecoration,
                                      child: Column(
                                        children: [
                                          appState.pageImages.isEmpty
                                              ? Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: style
                                                        .loadingIndicatorColor,
                                                  ),
                                                )
                                              : GestureDetector(
                                                  onHorizontalDragUpdate: appState
                                                          .isZoomed
                                                      ? null
                                                      : pageNavigation
                                                          .handleHorizontalDrag,
                                                  child: Stack(
                                                    children: [
                                                      /// Center divider
                                                      Center(
                                                        child: Container(
                                                          width: style
                                                              .centerDividerWidth,
                                                          color: style
                                                              .centerDividerColor,
                                                        ),
                                                      ),

                                                      /// Book pages
                                                      BookPage(
                                                        appState: appState,
                                                        finalPageWidth:
                                                            finalPageWidth,
                                                        finalPageHeight:
                                                            finalPageHeight,
                                                      ),

                                                      /// Animated page during flip
                                                      if (animationController
                                                          .animationController
                                                          .isAnimating)
                                                        AnimatedPage(
                                                          appState: appState,
                                                          rotationAnimation:
                                                              animationController
                                                                  .rotationAnimation,
                                                          finalPageWidth:
                                                              finalPageWidth,
                                                          finalPageHeight:
                                                              finalPageHeight,
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                },
              ),
              SizedBox(height: widget.showNavigationControls ? 50 : 0),
            ],
          ),
          if (widget.showNavigationControls)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: NavigationControls(
                  appState: appState,
                  pageNavigation: pageNavigation,
                  pdfLoader: pdfLoader,
                  pageController: pageController,
                  style: style.navigationControlsStyle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Styling options for the PDF book viewer
class PdfBookViewerStyle {
  final Color? backgroundColor;
  final Color? bookBackgroundColor;
  final Color? centerDividerColor;
  final double centerDividerWidth;
  final Color? loadingIndicatorColor;
  final BoxDecoration? bookContainerDecoration;
  final NavigationControlsStyle? navigationControlsStyle;

  const PdfBookViewerStyle({
    this.backgroundColor,
    this.bookBackgroundColor,
    this.centerDividerColor,
    this.centerDividerWidth = 5.0,
    this.loadingIndicatorColor,
    this.bookContainerDecoration,
    this.navigationControlsStyle,
  });

  static PdfBookViewerStyle defaultStyle() {
    return PdfBookViewerStyle(
      backgroundColor: Colors.grey.shade800,
      centerDividerColor: Colors.black.withValues(alpha: 0.5),
      loadingIndicatorColor: Colors.blue,
    );
  }
}

/// Styling options for navigation controls
class NavigationControlsStyle {
  final Color buttonColor;
  final Color iconColor;
  final BoxShadow? shadow;

  const NavigationControlsStyle({
    this.buttonColor = Colors.grey,
    this.iconColor = Colors.white,
    this.shadow,
  });
}
