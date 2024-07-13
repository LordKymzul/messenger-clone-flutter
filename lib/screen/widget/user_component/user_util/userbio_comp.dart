import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserListBio extends StatelessWidget {
  final String userId;
  const UserListBio({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final biostyle = GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w300,
        color: Theme.of(context).colorScheme.tertiary);
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('UserProfile')
          .doc(userId)
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingName();
        } else if (snapshot.hasError) {
          return loadingName();
        } else if (snapshot.hasData) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          return Text(
            data['userbio'],
            style: biostyle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          );
        } else {
          return loadingName();
        }
      },
    );
  }

  Widget loadingName() {
    return Container(
      width: 50,
      height: 10,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), color: Colors.grey),
    );
  }
}
