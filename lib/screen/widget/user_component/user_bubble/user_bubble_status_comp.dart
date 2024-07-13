import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:message_app/screen/widget/user_component/user_util/username_comp.dart';
import 'package:message_app/screen/widget/user_component/user_util/userprofile_comp.dart';

class UserBubbleStatus extends StatelessWidget {
  final String userlistId;

  final void Function() onTap;
  const UserBubbleStatus(
      {super.key, required this.userlistId, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final namestyle = GoogleFonts.poppins(
        fontSize: 12,
        color: Theme.of(context).colorScheme.tertiary,
        fontWeight: FontWeight.w400);
    return GestureDetector(onTap: onTap, child: buildProfile(namestyle));
  }

  Widget buildProfile(TextStyle namestyle) {
    return Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 40,
                child: UserListProfile(userId: userlistId, radius: 76)),
            const SizedBox(
              height: 5,
            ),
            UserListName(userId: userlistId, fontsize: 12)
          ],
        ));
  }
}
