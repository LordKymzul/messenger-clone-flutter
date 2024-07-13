import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:message_app/auth/signup_page.dart';
import 'package:message_app/auth/verifyemail_page.dart';

import '../constant/snakbar.dart';

class SignInPage extends StatefulWidget {
  SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _tcemail = TextEditingController();
  final _tcpassword = TextEditingController();
  bool isVisible = false;

  Future<void> signinAccount(
      String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid;

      print('Sign-in success for UID: $uid');
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => VerifyEmailPage(),
      ));
    } on FirebaseAuthException catch (e) {
      print(e.message);
      print('Sign-in failed with error: ${e.message}');
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerstyle = GoogleFonts.poppins(
        fontSize: 21,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.tertiary);
    final buttonstyle = GoogleFonts.poppins(
        fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white);

    final googlebuttonstyle = GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.tertiary);

    final textbuttomstyle1 = GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w300,
        color: Theme.of(context).colorScheme.tertiary);

    final textbuttomstyle2 = GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.secondary);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Theme.of(context).colorScheme.tertiary,
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/messenger.png',
              height: 150,
              width: 150,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'Welcome Back',
              style: headerstyle,
            ),
            const SizedBox(
              height: 20,
            ),
            InputField(context),
            const SizedBox(
              height: 40,
            ),
            Buttons(buttonstyle, googlebuttonstyle, context),
            const SizedBox(
              height: 40,
            ),
            textbuttom(textbuttomstyle1, textbuttomstyle2)
          ],
        ),
      ),
    );
  }

  Widget InputField(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.primary),
          child: TextField(
            controller: _tcemail,
            obscureText: false,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400),
                suffixIcon: const Icon(
                  Icons.email_outlined,
                  color: Colors.grey,
                ),
                enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent)),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent))),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.primary),
          child: TextField(
            controller: _tcpassword,
            obscureText: isVisible,
            decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      isVisible = !isVisible;
                    });
                  },
                  icon: Icon(isVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined),
                  color: Colors.grey,
                ),
                enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent)),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent))),
          ),
        ),
      ],
    );
  }

  Widget Buttons(TextStyle buttonstyle, TextStyle googlebuttonstyle,
      BuildContext context) {
    return Column(
      children: [
        MaterialButton(
          padding: const EdgeInsets.symmetric(vertical: 16),
          color: Theme.of(context).colorScheme.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          onPressed: () {
            String email = _tcemail.text.trim();
            String password = _tcpassword.text.trim();
            if (email.isEmpty || password.isEmpty) {
              SnackBarUtil.showSnackBar('Fields cannot be empty', Colors.red);
            } else {
              signinAccount(email, password, context);
            }
          },
          child: Center(
              child: Text(
            'Sign In',
            style: buttonstyle,
          )),
        ),
      ],
    );
  }

  Widget textbuttom(TextStyle style1, TextStyle style2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'New to this app?',
          style: style1,
        ),
        const SizedBox(
          width: 5,
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SignUpPage(),
            ));
          },
          child: Text(
            'Sign Up',
            style: style2,
          ),
        )
      ],
    );
  }
}
