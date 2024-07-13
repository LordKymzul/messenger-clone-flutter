import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:message_app/services/request_services.dart';
import 'package:message_app/screen/widget/profile_component/userprofile_comp.dart';
import 'package:message_app/screen/widget/user_component/user_util/userbio_comp.dart';
import 'package:message_app/screen/widget/user_component/user_util/username_comp.dart';
import 'package:message_app/screen/widget/user_component/user_util/userprofile_comp.dart';

class UserRequest extends StatelessWidget {
  final String userlistId;

  UserRequest({
    required this.userlistId,
    Key? key,
  }) : super(key: key);

  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    final deletebtnstyle = GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.tertiary,
    );
    final confirmbtnstyle = GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );
    final contentstyle = GoogleFonts.poppins(
      fontSize: 15,
      fontWeight: FontWeight.w300,
      color: Theme.of(context).colorScheme.tertiary,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: UserListProfile(
          userId: userlistId,
          radius: 50,
        ),
        title: UserListName(
          userId: userlistId,
          fontsize: 15,
        ),
        subtitle: UserListBio(userId: userlistId),
        trailing: SizedBox(
          width: 180,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildButton(context, true, confirmbtnstyle, deletebtnstyle),
              buildButton(context, false, confirmbtnstyle, deletebtnstyle)
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButton(BuildContext context, bool isConfirm,
      TextStyle confirmbtnstyle, TextStyle deletebtnstyle) {
    return MaterialButton(
      color: isConfirm
          ? Theme.of(context).colorScheme.secondary
          : Theme.of(context).colorScheme.primary,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onPressed: () {
        isConfirm
            ? RequestServices.acceptRequest(userlistId, [user.uid, userlistId])
            : RequestServices.cancelRequest(userlistId, false);
      },
      child: Text(
        isConfirm ? 'Confirm' : 'Delete',
        style: isConfirm ? confirmbtnstyle : deletebtnstyle,
      ),
    );
  }
}


  /*
   Row(
            children: [
              IconButton(
                  onPressed: () {
                    RequestServices.cancelRequest(widget.userlistId);
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  )),
              IconButton(
                  onPressed: () {
                    RequestServices.acceptRequest(
                        widget.userlistId, [user.uid, widget.userlistId]);
                  },
                  icon: const Icon(
                    Icons.done,
                    color: Colors.green,
                  ))
            ],
          ),*/

