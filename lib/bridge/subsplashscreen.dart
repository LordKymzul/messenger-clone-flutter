import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/intro_page.dart';
import '../screen/sub_screen/setupprofile_page.dart';
import '../mainscreen.dart';

class SubSplashScreen extends StatelessWidget {
  SubSplashScreen({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('UserProfile')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.black,
            ),
          );
        } else if (snapshot.hasError) {
          return const Center(child: Text('Something was error'));
        } else if (snapshot.hasData) {
          if (snapshot.data!.exists) {
            return MainScreen();
          } else {
            return IntroPage();
          }
        } else {
          return IntroPage();
        }
      },
    );
  }
}
