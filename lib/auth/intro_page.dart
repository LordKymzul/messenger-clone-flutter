import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:message_app/auth/signin_page.dart';
import 'package:message_app/auth/signup_page.dart';

class IntroPage extends StatelessWidget {
  IntroPage({super.key});

  String introtext =
      'Experience Messenger - Where Innovation Meets Convenience';

  String introsubtext =
      'Connect with others effortlessly, and explore innovative solutions right at your fingertips';
  @override
  Widget build(BuildContext context) {
    final introstyle = GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.tertiary);

    final introsubstyle = GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w300,
        color: Theme.of(context).colorScheme.tertiary);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IntroMedia(introstyle, introsubstyle),
            const SizedBox(
              height: 40,
            ),
            IntroButtons(context),
          ],
        ),
      ),
    );
  }

  Widget IntroMedia(TextStyle introstyle, TextStyle introsubstyle) {
    return Column(
      children: [
        Image.asset(
          'assets/messenger.png',
          height: 200,
          width: 200,
        ),
        const SizedBox(
          height: 40,
        ),
        Text(
          introtext,
          style: introstyle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          introsubtext,
          style: introsubstyle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget IntroButtons(BuildContext context) {
    return Column(
      children: [
        MaterialButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SignInPage(),
            ));
          },
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.secondary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          child: Center(
            child: Text(
              'Sign In',
              style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        MaterialButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SignUpPage(),
            ));
          },
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.tertiary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          child: Center(
            child: Text(
              'Sign Up',
              style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.background),
            ),
          ),
        )
      ],
    );
  }
}
