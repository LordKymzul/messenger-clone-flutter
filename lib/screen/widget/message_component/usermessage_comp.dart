import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:message_app/services/chat_services.dart';
import 'package:message_app/screen/widget/message_component/msg_noti_comp.dart';
import 'package:message_app/screen/widget/user_component/user_util/username_comp.dart';
import 'package:message_app/screen/widget/user_component/user_util/userprofile_comp.dart';

import '../../sub_screen/chat_page/message/message_page.dart';
import '../util/date/date.dart';

class UserMessageCard extends StatelessWidget {
  final String userlistId, lastMessage, groupID;
  final Timestamp lastTime;
  final void Function() onTap;
  const UserMessageCard(
      {super.key,
      required this.userlistId,
      required this.lastMessage,
      required this.groupID,
      required this.lastTime,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final contentstyle = GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w300,
        color: Theme.of(context).colorScheme.tertiary);
    final notistyle = GoogleFonts.poppins(
        fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white);
    return Slidable(
      endActionPane: ActionPane(motion: const StretchMotion(), children: [
        SlidableAction(
          onPressed: (context) {},
          borderRadius: BorderRadius.circular(12),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          icon: Icons.archive,
        )
      ]),
      child: messagelist(userlistId, lastMessage, contentstyle, notistyle,
          context, groupID, lastTime),
    );
  }

  Widget messagelist(
      String userlistId,
      String lastMessage,
      TextStyle contentstyle,
      TextStyle notistyle,
      BuildContext context,
      String groupID,
      Timestamp timestamp) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: ListTile(
                leading: UserListProfile(
                  userId: userlistId,
                  radius: 50,
                ),
                title: UserListName(
                  userId: userlistId,
                  fontsize: 15,
                ),
                subtitle: Text(
                  lastMessage,
                  style: contentstyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Date(timestamp: timestamp),
                  const SizedBox(
                    height: 10,
                  ),
                  NotiMessage(groupID: groupID)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
