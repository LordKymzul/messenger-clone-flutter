import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/userprofile_services.dart';
import '../../../model/read_mode.dart';

class NotiMessage extends StatelessWidget {
  final String groupID;
  const NotiMessage({super.key, required this.groupID});

  @override
  Widget build(BuildContext context) {
    final notistyle = GoogleFonts.poppins(
        fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white);
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('UserGroup')
          .doc(groupID)
          .collection('ReadBy')
          .doc(UserProfileServices.user.uid)
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 20,
            width: 20,
          );
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else if (snapshot.hasData) {
          if (snapshot.data!.exists) {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            ReadModel readModel = ReadModel.fromJson(data);
            int isRead = readModel.numUnRead;
            if (isRead == 0) {
              return const SizedBox(
                height: 20,
                width: 20,
              );
            } else {
              return isReadContainer(context, notistyle, isRead);
            }
          } else {
            return const SizedBox(
              height: 20,
              width: 20,
            );
          }
        } else {
          return const SizedBox(
            height: 20,
            width: 20,
          );
        }
      },
    );
  }

  Widget isReadContainer(
      BuildContext context, TextStyle notistyle, int numMessage) {
    return Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.secondary),
      child: Center(
          child: Text(
        numMessage.toString(),
        style: notistyle,
      )),
    );
  }
}
