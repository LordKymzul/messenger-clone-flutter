import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:message_app/services/userprofile_services.dart';
import 'package:message_app/auth/signin_page.dart';
import 'package:message_app/auth/verifyemail_page.dart';

import '../constant/snakbar.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _tcemail = TextEditingController();
  final _tcpassword = TextEditingController();
  final _tccpassword = TextEditingController();
  bool isVisible = false;
  UserProfileServices userProfileServices = UserProfileServices();
  String invalidUrl = 'https://static.thenounproject.com/png/1520709-200.png';

  Future<void> signupAccount(String email, String password,
      String confirmpassword, BuildContext context) async {
    try {
      if (email.isEmpty || password.isEmpty || confirmpassword.isEmpty) {
        SnackBarUtil.showSnackBar('Fields cannot be empty', Colors.red);
      } else {
        if (password != confirmpassword) {
          SnackBarUtil.showSnackBar('Password not matched', Colors.red);
        } else {
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: password);

          userProfileServices.createUserProfile(
              invalidUrl, 'No Name Yet', 'No Bio Yet', 0);
          SnackBarUtil.showSnackBar(
              'Succesfully created an account', Colors.green);
          // ignore: use_build_context_synchronously
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => VerifyEmailPage(),
          ));
        }
      }
    } on FirebaseAuthException catch (e) {
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
      print(e.toString());
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
              'Create your account here',
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
        const SizedBox(
          height: 10,
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.primary),
          child: TextField(
            controller: _tccpassword,
            obscureText: isVisible,
            decoration: InputDecoration(
                hintText: 'Confrim Password',
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
            signupAccount(_tcemail.text.trim(), _tcpassword.text.trim(),
                _tccpassword.text.trim(), context);
          },
          child: Center(
              child: Text(
            'Sign Up',
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
          'Already have an account?',
          style: style1,
        ),
        const SizedBox(
          width: 5,
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SignInPage(),
            ));
          },
          child: Text(
            'Sign In',
            style: style2,
          ),
        )
      ],
    );
  }
}
