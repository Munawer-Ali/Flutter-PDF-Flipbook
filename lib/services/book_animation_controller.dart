import 'package:flutter/material.dart';
import '../models/app_state.dart';
import 'pdf_loader.dart';

class BookAnimationController {
  final AppState appState;
  final PdfLoader pdfLoader;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  BookAnimationController({
    required this.appState,
    required this.pdfLoader,
    required TickerProvider vsync,
  }) {
    _animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1200),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.fastOutSlowIn),
    );
  }

  AnimationController get animationController => _animationController;
  Animation<double> get rotationAnimation => _rotationAnimation;

  /// Handles page flipping animation with smart interruption for fast navigation
  Future<void> triggerFlip(bool swipeLeft) async {
    // Check if we can navigate in the requested direction
    if (!canNavigate(swipeLeft)) return;
    
    
    // Handle animation interruption if one is currently playing
    if (_animationController.isAnimating) {
      await _interruptAndSkipToNext(swipeLeft);
      return;
    }
    
    // Check if animation is ready (not in fast navigation mode)
    if (!appState.isAnimationReady) {
      return;
    }
    
    // Start the flip animation
    await _performFlipAnimation(swipeLeft);
  }
  
  /// Interrupts current animation and immediately goes to next page for fast navigation
  Future<void> _interruptAndSkipToNext(bool swipeLeft) async {
    // Stop current animation
    _animationController.stop();
    _animationController.reset();
    
    // Mark animation as not ready during fast navigation
    appState.isAnimationReady = false;
    
    // Show fast navigation indicator
    appState.updateMultiple(
      currentPageComplete: appState.currentPage,
      animationComplete: true,
      animationEnd: true,
    );
    
    // Load new pages immediately
    await pdfLoader.loadPages(appState.currentPage, null);
    
    // Hide fast navigation indicator and ensure animation state is ready
    Future.delayed(Duration(milliseconds: 300), () {
      appState.updateMultiple(
        animationEnd: true,
        animationComplete: false,
        isAnimationReady: true,
        isSwipeInProgress: false,
      );
    });
    
    await _performFlipAnimation(swipeLeft);
  }
  
  bool canNavigate(bool swipeLeft) {
    if (appState.document == null) return false;
    final totalPages = appState.document!.pagesCount;
    final currentPageIndex = appState.currentPage * 2;

    if (swipeLeft) {
      if (totalPages % 2 == 0) {
        // Even number of pages: allow if currentPageIndex < totalPages - 2 or at the last spread
        return currentPageIndex < (totalPages - 2) || currentPageIndex == (totalPages - 2);
      } else {
        // Odd number of pages: allow if currentPageIndex < totalPages - 1
        return currentPageIndex < (totalPages - 1);
      }
    } else {
      // Can't go backward if at first page
      return appState.currentPage > 0;
    }
  }
  
  /// Performs the actual flip animation
  Future<void> _performFlipAnimation(bool swipeLeft) async {
    
    // Update animation state
    appState.updateMultiple(
      animationEnd: false,
      isSwipingLeft: swipeLeft,
      currentPage: appState.currentPage + (swipeLeft ? 1 : -1),
    );

    // Run the animation
    await _animationController.forward();
    
    // Load new pages and complete the animation
     pdfLoader.loadPages(appState.currentPage, null);
    
    appState.updateMultiple(
      animationComplete: true,
      currentPageComplete: appState.currentPage,
      animationEnd: true,
      isSwipeInProgress: false,
    );
    
    // Reset for next animation
    _animationController.reset();
  }

  void dispose() {
    _animationController.dispose();
  }
}
