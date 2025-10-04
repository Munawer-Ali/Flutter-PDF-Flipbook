import 'package:flutter/material.dart';
import '../models/app_state.dart';

class AnimatedPage extends StatelessWidget {
  final AppState appState;
  final Animation<double> rotationAnimation;
  final double finalPageWidth;
  final double finalPageHeight;

  const AnimatedPage({
    Key? key,
    required this.appState,
    required this.rotationAnimation,
    required this.finalPageWidth,
    required this.finalPageHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: appState.isSwipingLeft
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: AnimatedBuilder(
        animation: rotationAnimation,
        builder: (context, child) {
          double rotationValue = rotationAnimation.value;
          bool isFront = rotationValue <= 0.5;
          
          // Calculate indices safely
          final frontPageIndex = !appState.isSwipingLeft
              ? appState.currentPageComplete * 2
              : appState.currentPageComplete * 2 + 1;
          final backPageIndex = appState.isSwipingLeft
              ? appState.currentPageComplete * 2 + 2
              : appState.currentPage * 2 + 1;
          
          // Check if pages exist
          final hasFrontPage = frontPageIndex < appState.pageImages.length;
          final hasBackPage = backPageIndex < appState.pageImages.length;
          
          return Transform(
            alignment: appState.isSwipingLeft
                ? Alignment.centerLeft
                : Alignment.centerRight,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0004)
              ..rotateY(appState.isSwipingLeft
                  ? rotationValue * 3.14
                  : -rotationValue * 3.14),
            child: Stack(
              children: [
                Container(
                  height: finalPageHeight,
                  width: finalPageWidth,
                  color: Colors.white,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(isFront ? 0 : 3.14),
                    child: (isFront && hasFrontPage) || (!isFront && hasBackPage)
                        ? Image.memory(
                            isFront
                                ? appState.pageImages[frontPageIndex].bytes
                                : appState.pageImages[backPageIndex].bytes,
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
                Positioned(
                  left: appState.isSwipingLeft && isFront || !appState.isSwipingLeft && isFront 
                      ? null 
                      : -20,
                  right: !appState.isSwipingLeft && isFront ? -20 : null,
                  child: Container(
                    width: !appState.isSwipingLeft && isFront 
                        ? 40 
                        : appState.isSwipingLeft && isFront || !appState.isSwipingLeft && !isFront 
                            ? 0 
                            : 40,
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
              ],
            ),
          );
        },
      ),
    );
  }
}
