import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:message_app/services/request_services.dart';
import 'package:message_app/model/friend_model.dart';

class RequestButton extends StatelessWidget {
  final String userlistId;
  final VoidCallback press;

  RequestButton({Key? key, required this.userlistId, required this.press})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final buttonstyle = GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('UserFriend')
          .doc(user.uid)
          .collection('MyFriend')
          .doc(userlistId)
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingButton(context);
        } else if (snapshot.hasError) {
          return loadingButton(context);
        } else if (snapshot.hasData && snapshot.data!.data() != null) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          FriendModel friendModel = FriendModel.fromJson(data);
          String statusFriend = friendModel.statusFriend;
          String statusProcess = friendModel.statusProcess;

          if (statusFriend == 'Requested') {
            if (statusProcess == 'Sender') {
              return addButton(true, buttonstyle, context, true);
            } else {
              return addButton(true, buttonstyle, context, false);
            }
          } else {
            return friendButton(buttonstyle, context);
          }
        } else {
          return addButton(false, buttonstyle, context, true);
        }
      },
    );
  }

  Widget addButton(bool isPending, TextStyle buttonstyle, BuildContext context,
      bool isSender) {
    return SizedBox(
      width: 110,
      height: 40,
      child: MaterialButton(
        color: isPending
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isPending
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.secondary,
            width: 2,
          ),
        ),
        onPressed: () {
          if (isPending) {
            if (isSender) {
              RequestServices.cancelRequest(userlistId, true);
            } else {
              RequestServices.cancelRequest(userlistId, false);
            }
          } else {
            RequestServices.sendRequest(userlistId);
          }
        },
        child: Center(
          child: Text(
            isPending ? 'Requested' : 'Add',
            style: isPending
                ? buttonstyle
                : GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
          ),
        ),
      ),
    );
  }

  Widget friendButton(TextStyle buttonstyle, BuildContext context) {
    return SizedBox(
      width: 110,
      height: 40,
      child: MaterialButton(
        color: Theme.of(context).colorScheme.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onPressed: press,
        child: Center(
          child: Text(
            'Friend',
            style: buttonstyle,
          ),
        ),
      ),
    );
  }

  Widget loadingButton(BuildContext context) {
    return Container(
      width: 100,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
