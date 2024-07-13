import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserEmpty extends StatelessWidget {
  final String textempty;
  const UserEmpty({super.key, required this.textempty});

  @override
  Widget build(BuildContext context) {
    final textstyle = GoogleFonts.poppins(
        fontSize: 15,
        color: Theme.of(context).colorScheme.tertiary,
        fontWeight: FontWeight.w300);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/empty-box.png',
          height: 200,
          width: 200,
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          textempty,
          style: textstyle,
        )
      ],
    );
  }
}
