import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimatedBar extends StatelessWidget {
  final AnimationController animationController;
  final int positon;
  final int currentIndex;
  const AnimatedBar(
      {super.key,
      required this.animationController,
      required this.positon,
      required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.5),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                _buildContainer(
                    double.infinity,
                    positon < currentIndex
                        ? Colors.white
                        : Colors.white.withOpacity(0.5)),
                positon == currentIndex
                    ? AnimatedBuilder(
                        animation: animationController,
                        builder: (context, child) {
                          return _buildContainer(
                              constraints.maxWidth * animationController.value,
                              Colors.white);
                        },
                      )
                    : const SizedBox.shrink()
              ],
            );
          },
        ),
      ),
    );
  }

  Container _buildContainer(double width, Color color) {
    return Container(
      height: 5,
      width: width,
      decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black26, width: 0.8),
          borderRadius: BorderRadius.circular(3)),
    );
  }
}
