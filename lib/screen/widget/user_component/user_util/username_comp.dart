import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:message_app/model/user_model.dart';

class UserListName extends StatelessWidget {
  final String userId;
  final double fontsize;
  const UserListName({super.key, required this.userId, required this.fontsize});

  @override
  Widget build(BuildContext context) {
    final namestyle = GoogleFonts.poppins(
        fontSize: fontsize,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.tertiary);
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('UserProfile')
          .doc(userId)
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else if (snapshot.hasError) {
          return loadingName();
        } else if (snapshot.hasData) {
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          UserModel userModel = UserModel.fromJson(userData);
          String username = userModel.username;
          return Text(
            username,
            style: namestyle,
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
