import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:message_app/screen/widget/user_component/each_user_util/each_username.dart';
import 'package:message_app/screen/widget/user_component/each_user_util/each_userprofile.dart';

import '../user_component/user_util/username_comp.dart';
import '../user_component/user_util/userprofile_comp.dart';
import '../util/date/datemessage.dart';

class StatusCard extends StatelessWidget {
  final String statusURL, sentBy;
  final Timestamp timestamp;
  final void Function() onDelete, onTap;
  final String statusUserName, statusUserAvatar;
  const StatusCard(
      {super.key,
      required this.statusURL,
      required this.sentBy,
      required this.timestamp,
      required this.onDelete,
      required this.onTap,
      required this.statusUserName,
      required this.statusUserAvatar});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onDelete,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Stack(children: [
          GestureDetector(onTap: onTap, child: buildPhotos(statusURL)),
          Positioned(
            bottom: 0,
            left: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Row(
                children: [
                  EachUserProfile(userProfile: statusUserAvatar, radius: 30),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    statusUserName,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  )
                ],
              ),
            ),
          ),
          Positioned(top: 5, left: 5, child: DateMessage(timestamp: timestamp)),
        ]),
      ),
    );
  }

  Widget buildPhotos(String photos) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: photos == ''
          ? Image.asset('assets/userchat.png', fit: BoxFit.cover)
          : CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: photos,
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
    );
  }
}
