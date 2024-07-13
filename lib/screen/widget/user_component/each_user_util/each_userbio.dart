import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EachUserBio extends StatelessWidget {
  final String userBio;
  const EachUserBio({super.key, required this.userBio});

  @override
  Widget build(BuildContext context) {
    return Text(
      userBio,
      style: GoogleFonts.poppins(
        fontSize: 12,
        color: Theme.of(context).colorScheme.tertiary,
        fontWeight: FontWeight.w300,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
