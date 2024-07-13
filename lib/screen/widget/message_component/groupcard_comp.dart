import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:message_app/services/read_services.dart';
import 'package:message_app/services/userprofile_services.dart';
import 'package:message_app/model/read_mode.dart';
import 'package:message_app/screen/widget/message_component/msg_noti_comp.dart';
import 'package:message_app/screen/widget/util/date/date.dart';
import 'package:message_app/screen/widget/util/date/datemessage.dart';

class UserGroupCard extends StatelessWidget {
  final String groupName, lastMessage, groupURL, groupID;
  final Timestamp sentAt;
  final void Function() onTap;
  const UserGroupCard(
      {super.key,
      required this.groupName,
      required this.lastMessage,
      required this.groupURL,
      required this.onTap,
      required this.sentAt,
      required this.groupID});

  @override
  Widget build(BuildContext context) {
    final titlestyle = GoogleFonts.poppins(
        fontSize: 15,
        color: Theme.of(context).colorScheme.tertiary,
        fontWeight: FontWeight.w600);
    final subtitlestyle = GoogleFonts.poppins(
        fontSize: 12,
        color: Theme.of(context).colorScheme.tertiary,
        fontWeight: FontWeight.w300);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: ListTile(
                leading: buildProfilePicture(groupURL, 50.0),
                title: Text(
                  groupName,
                  style: titlestyle,
                ),
                subtitle: Text(
                  lastMessage,
                  style: subtitlestyle,
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
                  Date(timestamp: sentAt),
                  NotiMessage(groupID: groupID)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildProfilePicture(String userProfile, radius) {
    return SizedBox(
        height: radius,
        width: radius,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius / 2),
          child: userProfile == ''
              ? Image.asset('assets/userchat.png', fit: BoxFit.cover)
              : CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: userProfile,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                  ),
                ),
        ));
  }
}
