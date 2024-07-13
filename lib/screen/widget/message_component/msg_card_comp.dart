import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:message_app/services/chat_services.dart';
import 'package:message_app/model/message_model.dart';
import 'package:message_app/screen/widget/user_component/each_user_util/each_username.dart';
import 'package:message_app/screen/widget/user_component/each_user_util/each_userprofile.dart';
import 'package:message_app/screen/widget/user_component/user_util/userprofile_comp.dart';
import 'package:message_app/screen/widget/util/date/datemessage.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class MesageCard extends StatelessWidget {
  final String groupID;
  final void Function() onDelete, onView;
  final MessageModel messageModel;

  MesageCard(
      {super.key,
      required this.groupID,
      required this.onDelete,
      required this.onView,
      required this.messageModel});

  final user = FirebaseAuth.instance.currentUser!;
  final pc = PageController(viewportFraction: 0.8, keepPage: true);

  bool isUser() {
    if (user.uid == messageModel.sentBy) {
      return true;
    } else {
      return false;
    }
  }

  bool isCaptionEmpty() {
    if (messageModel.messageText.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final senderstyle = GoogleFonts.poppins(
        fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white);
    final receiverstyle = GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.tertiary);
    return GestureDetector(
        onLongPress: onDelete,
        child: TextORMedia(context, senderstyle, receiverstyle));
  }

  Widget TextORMedia(
      BuildContext context, TextStyle senderstyle, TextStyle receiverstyle) {
    if (messageModel.messageURL.isEmpty ||
        messageModel.messageURLName.isEmpty) {
      return UserTextBubble(context, senderstyle, receiverstyle);
    } else {
      return UserMediaBubble(context, senderstyle, receiverstyle);
    }
  }

  Widget UserTextBubble(
      BuildContext context, TextStyle senderstyle, TextStyle receiverstyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        children: [
          if (!isUser())
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: Row(
                mainAxisAlignment:
                    isUser() ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  EachUserName(userName: messageModel.sentByName, fontSize: 12)
                ],
              ),
            ),
          Container(
            alignment: isUser() ? Alignment.topRight : Alignment.topLeft,
            margin: isUser()
                ? const EdgeInsets.only(left: 40)
                : const EdgeInsets.only(right: 40),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  color: isUser()
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.primary),
              child: Text(messageModel.messageText,
                  style: isUser() ? senderstyle : receiverstyle),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment:
                isUser() ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isUser())
                EachUserProfile(
                    userProfile: messageModel.sentByAvatar, radius: 30),
              const SizedBox(
                width: 10,
              ),
              DateMessage(timestamp: messageModel.sentAt)
            ],
          ),
        ],
      ),
    );
  }

  Widget UserMediaBubble(
      BuildContext context, TextStyle senderstyle, TextStyle receiverstyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        children: [
          if (!isUser())
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: Row(
                mainAxisAlignment:
                    isUser() ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  EachUserName(userName: messageModel.sentByName, fontSize: 12)
                ],
              ),
            ),
          Container(
              alignment: isUser() ? Alignment.topRight : Alignment.topLeft,
              margin: isUser()
                  ? const EdgeInsets.only(left: 60)
                  : const EdgeInsets.only(right: 60),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isUser()
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.primary),
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: onView,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: 350,
                          child: PageView.builder(
                            itemCount: messageModel.messageURL.length,
                            itemBuilder: (context, index) {
                              var eachImage = messageModel.messageURL[index];
                              return buildPhotos(eachImage);
                            },
                          ),
                        )),
                  ),
                  if (!isCaptionEmpty())
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(messageModel.messageText,
                          style: isUser() ? senderstyle : receiverstyle),
                    ),
                ],
              )),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment:
                isUser() ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isUser())
                EachUserProfile(
                    userProfile: messageModel.sentByAvatar, radius: 30),
              const SizedBox(
                width: 10,
              ),
              DateMessage(timestamp: messageModel.sentAt)
            ],
          )
        ],
      ),
    );
  }

  Widget buildPhotos(String photos) {
    return SizedBox(
        height: 350,
        child: ClipRRect(
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
        ));
  }
}
