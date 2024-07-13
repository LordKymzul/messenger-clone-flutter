import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:message_app/services/chat_services.dart';
import 'package:message_app/services/request_services.dart';
import 'package:message_app/services/userprofile_services.dart';
import 'package:message_app/model/user_model.dart';
import 'package:message_app/screen/widget/buttons_component/requestbtn_comp.dart';
import 'package:message_app/screen/widget/empty_component/user_empty_comp.dart';
import 'package:message_app/screen/widget/loading_component/error_comp.dart';
import 'package:message_app/screen/widget/loading_component/messageload_comp.dart';
import 'package:message_app/screen/widget/profile_component/userprofile_comp.dart';
import 'package:message_app/screen/widget/user_component/user_util/userbio_comp.dart';
import 'package:message_app/screen/widget/user_component/user_util/username_comp.dart';
import 'package:message_app/screen/widget/user_component/user_util/userprofile_comp.dart';

class Friend extends StatelessWidget {
  Friend({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: buildFriendList());
  }

  Widget buildFriendList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('UserProfile')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildUserLoad();
        } else if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());
          return Center(child: ErrorUI(error: snapshot.error.toString()));
        } else if (snapshot.hasData) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          UserModel userModel = UserModel.fromJson(data);
          List<String> friendsList = userModel.friends;
          if (friendsList.isEmpty) {
            return const Center(
              child: UserEmpty(
                  textempty: 'Currently, there are no friends in your list.'),
            );
          } else {
            return ListView.builder(
              itemCount: friendsList.length,
              itemBuilder: (context, index) {
                String userlistID = friendsList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: UserListProfile(userId: userlistID, radius: 50),
                    title: UserListName(userId: userlistID, fontsize: 15),
                    subtitle: UserListBio(userId: userlistID),
                    trailing: RequestButton(
                      userlistId: userlistID,
                      press: () async {
                        String groupID =
                            await ChatServices.getOneToOneGroupID(userlistID);
                        debugPrint('Group ID: $groupID');

                        showDialogDelete(context, groupID, userlistID);
                      },
                    ),
                  ),
                );
              },
            );
          }
        } else {
          return buildUserLoad();
        }
      },
    );
  }

  Widget buildUserLoad() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return const MessageLoad();
      },
    );
  }

  void showDialogDelete(
      BuildContext context, String groupID, String userlistId) {
    showGeneralDialog(
      context: context,
      barrierLabel: '',
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              title: Text(
                'Delete Friend',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.tertiary,
                    fontWeight: FontWeight.w600),
              ),
              content: SizedBox(
                height: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Are you sure want to delete ?',
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.tertiary,
                          fontWeight: FontWeight.w300),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'All your chats and photos will be delete',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.tertiary,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.tertiary,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    RequestServices.removeFriend(userlistId, groupID);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Confirm',
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.tertiary,
                        fontWeight: FontWeight.w600),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
