import 'package:flutter/material.dart';
import '../models/app_state.dart';
import 'book_animation_controller.dart';

class PageNavigation {
  final AppState appState;
  final BookAnimationController animationController;

  PageNavigation({
    required this.appState,
    required this.animationController,
  });

  /// Handles horizontal drag gestures for page navigation
  void handleHorizontalDrag(DragUpdateDetails details) {
    // Only allow navigation when not zoomed and no swipe in progress
    if (appState.isZoomed || appState.isSwipeInProgress) return;
    
    // Determine swipe direction based on delta
    if (details.delta.dx < 0) {
      // Swipe left - go to next page
      appState.isSwipeInProgress = true;
      animationController.triggerFlip(true);
    } else if (details.delta.dx > 0) {
      // Swipe right - go to previous page
      appState.isSwipeInProgress = true;
      animationController.triggerFlip(false);
    }
  }
  
  /// Navigates to the previous page with error handling
  void navigateToPreviousPage(BuildContext context) {
    if (canNavigate(false)) {
      animationController.triggerFlip(false);
    } else {
      _showNavigationError(context, 'Already at the first page');
    }
  }
  
  /// Navigates to the next page with error handling
  void navigateToNextPage(BuildContext context) {
    if (canNavigate(true)) {
      animationController.triggerFlip(true);
    } else {
      _showNavigationError(context, 'Already at the last page');
    }
  }
  
  /// Checks if navigation is possible in the given direction
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
  
  /// Shows navigation error message
  void _showNavigationError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
