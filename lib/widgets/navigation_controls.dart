import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../services/page_navigation.dart';
import '../services/pdf_loader.dart';
import 'pdf_book_viewer.dart'; /// Import for NavigationControlsStyle

class NavigationControls extends StatelessWidget {
  final AppState appState;
  final PageNavigation pageNavigation;
  final PdfLoader pdfLoader;
  final TextEditingController pageController;
  final NavigationControlsStyle? style;

  const NavigationControls({
    Key? key,
    required this.appState,
    required this.pageNavigation,
    required this.pdfLoader,
    required this.pageController,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controlStyle = style ?? NavigationControlsStyle();

    return Container(
      width: 320,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          controlStyle.shadow ??
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.stretch, /// Make children fill vertically
        children: [
          /// Previous button
          Container(
            decoration: BoxDecoration(
              color: controlStyle.buttonColor,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: controlStyle.iconColor),
              onPressed: () => pageNavigation.navigateToPreviousPage(context),
            ),
          ),

          /// TextField for page number
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: pageController,
                    decoration: InputDecoration(
                      hintText: "Page #",
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: EdgeInsets.only(bottom: 8),
                    ),
                    style: TextStyle(color: Colors.black),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),

          /// Button to navigate to page
          Container(
            decoration: BoxDecoration(
              color: controlStyle.buttonColor,
            ),
            child: IconButton(
              icon: Icon(Icons.search, color: controlStyle.iconColor),
              onPressed: () {
                if (pageController.text.isNotEmpty) {
                  int pageNumber = int.parse(pageController.text);
                  if ((pageNumber / 2).toInt() == appState.currentPage) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Page number must be between 1 and ${appState.document!.pagesCount}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  if (pageNumber > 0 &&
                      pageNumber <= appState.document!.pagesCount) {
                    pdfLoader.navigateToPage(pageNumber);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Page number must be between 1 and ${appState.document!.pagesCount}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ),

          /// Next button
          Container(
            decoration: BoxDecoration(
              color: controlStyle.buttonColor,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_forward, color: controlStyle.iconColor),
              onPressed: () => pageNavigation.navigateToNextPage(context),
            ),
          ),
        ],
      ),
    );
  }
}
