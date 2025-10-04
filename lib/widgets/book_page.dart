import 'package:flutter/material.dart';
import '../models/app_state.dart';

class BookPage extends StatelessWidget {
  final AppState appState;
  final double finalPageWidth;
  final double finalPageHeight;

  const BookPage({
    Key? key,
    required this.appState,
    required this.finalPageWidth,
    required this.finalPageHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate indices safely
    final leftPageIndex = appState.isSwipingLeft 
        ? appState.currentPageComplete * 2 
        : appState.currentPage * 2;
    final rightPageIndex = appState.isSwipingLeft 
        ? appState.currentPage * 2 + 1 
        : appState.currentPageComplete * 2 + 1;
    
    // Check if pages exist
    final hasLeftPage = leftPageIndex < appState.pageImages.length;
    final hasRightPage = rightPageIndex < appState.pageImages.length;
    
    return Stack(
      children: [
        // Left page
        Visibility(
          visible: hasLeftPage && !(!appState.isSwipingLeft 
              ? appState.currentPage == 0 
              : appState.currentPageComplete == 0),
          child: Container(
            height: finalPageHeight,
            width: finalPageWidth,
              color: Colors.white,
            child: hasLeftPage 
                ? Image.memory(
                    appState.pageImages[leftPageIndex].bytes,
                    fit: BoxFit.fill,
                    gaplessPlayback: true,
                  )
                : Container(
                    color: Colors.grey.shade300,
                    child: Center(
                      child: Text(
                        'Loading...',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  ),
          ),
        ),

        // Center shadow
        Center(
          child: Container(
            width: 40,
            height: finalPageHeight,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  spreadRadius: 0,
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
          ),
        ),

        // Right page
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: Visibility(
            visible: hasRightPage,
            child: Container(
              height: finalPageHeight,
              width: finalPageWidth,
              color: Colors.white,
              child: hasRightPage 
                  ? Image.memory(
                      appState.pageImages[rightPageIndex].bytes,
                      fit: BoxFit.fill,
                      gaplessPlayback: true,
                    )
                  : Container(
                      color: Colors.grey.shade300,
                      child: Center(
                        child: Text(
                          'Loading...',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
