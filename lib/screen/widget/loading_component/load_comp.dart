import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class LoadingUI extends StatelessWidget {
  const LoadingUI({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: 100,
      child: LoadingIndicator(
        indicatorType: Indicator.ballPulse,
        colors: [
          Colors.blue.shade900,
          Colors.blue.shade500,
          Colors.blue.shade200
        ],
      ),
    );
  }
}
