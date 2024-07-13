import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EachUserName extends StatelessWidget {
  final String userName;
  final double fontSize;
  const EachUserName(
      {super.key, required this.userName, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Text(
      userName,
      style: GoogleFonts.poppins(
          fontSize: fontSize,
          color: Theme.of(context).colorScheme.tertiary,
          fontWeight: FontWeight.w600),
    );
  }
}
