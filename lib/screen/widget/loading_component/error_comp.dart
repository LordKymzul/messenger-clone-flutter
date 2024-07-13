import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';

class ErrorUI extends StatelessWidget {
  String error;
  ErrorUI({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
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
        ),
        Text(
          error,
          style: GoogleFonts.poppins(
              fontSize: 21, color: Colors.red, fontWeight: FontWeight.w300),
        )
      ],
    );
  }
}
