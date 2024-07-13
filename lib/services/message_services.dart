import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:message_app/services/chat_services.dart';
import 'package:message_app/services/read_services.dart';
import 'package:message_app/services/userprofile_services.dart';
import 'package:message_app/model/message_model.dart';
import 'package:message_app/model/user_model.dart';

import '../constant/snakbar.dart';

class MessageServices {
  static Future<void> sendMessage(
      String groupID,
      String messageText,
      List<dynamic> selectedImages,
      List<dynamic> selectedImagesNames,
      bool isText) async {
    try {
      UserModel? userModel =
          await UserProfileServices.getUserDetail(UserProfileServices.user.uid);
      String sentByName = userModel!.username;
      String sentByAvatar = userModel.userprofile;

      final docmessage = FirebaseFirestore.instance
          .collection('UserGroup')
          .doc(groupID)
          .collection('Messages')
          .doc();

      final message = MessageModel(
          messageID: docmessage.id,
          messageText: messageText,
          messageURL: selectedImages,
          messageURLName: selectedImagesNames,
          sentBy: UserProfileServices.user.uid,
          sentAt: Timestamp.now(),
          isText: isText,
          sentByName: sentByName,
          sentByAvatar: sentByAvatar);

      await docmessage.set(message.toJson());

      ChatServices.updateGroupLatestData(
        groupID,
        messageText,
        Timestamp.now(),
        UserProfileServices.user.uid,
      );

      ReadServices.updateUnReadMessage(groupID, false);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<void> deleteMessage(
      String groupID,
      String messageID,
      String recentMessage,
      Timestamp recentTime,
      List<dynamic> messageURLName,
      String lastSender) async {
    try {
      final docmessage = FirebaseFirestore.instance
          .collection('UserGroup')
          .doc(groupID)
          .collection('Messages')
          .doc(messageID);
      await docmessage.delete();

      if (messageURLName.isNotEmpty) {
        for (var eachImageName in messageURLName) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('UserMessage')
              .child(UserProfileServices.user.uid)
              .child(eachImageName);

          await ref.delete();
        }
      }

      ChatServices.updateGroupLatestData(
        groupID,
        recentMessage,
        recentTime,
        lastSender,
      );
      ReadServices.updateUnReadMessage(groupID, true);
    } catch (e) {
      debugPrint(e.toString());
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
    }
  }

  static Future<void> deleteEachMessageURL(
      String groupID,
      String messageID,
      String eachMessageURL,
      String eachMessageURLName,
      List<dynamic> messageURL,
      List<dynamic> messageURLName) async {
    try {
      DocumentReference docmessage = FirebaseFirestore.instance
          .collection('UserGroup')
          .doc(groupID)
          .collection('Messages')
          .doc(messageID);

      docmessage.update({
        'messageURL': FieldValue.arrayRemove([eachMessageURL]),
        'messageURLName': FieldValue.arrayRemove([eachMessageURLName])
      });

      if (eachMessageURLName.isEmpty) {
        return;
      }

      final ref = FirebaseStorage.instance
          .ref()
          .child('UserMessage')
          .child(UserProfileServices.user.uid)
          .child(eachMessageURLName);

      await ref.delete();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<List<int>> searchMessage(
      String groupID, String searchChat) async {
    int searchIndex = 0;
    List<int> searchListIndex = [];
    try {
      final docchat = FirebaseFirestore.instance
          .collection('UserGroup')
          .doc(groupID)
          .collection('Messages')
          .orderBy('sendAt', descending: true);
      QuerySnapshot querySnapshot = await docchat.get();

      if (searchChat.isEmpty) {
        debugPrint(null);
      } else {
        for (int index = 0; index < querySnapshot.docs.length; index++) {
          var data = querySnapshot.docs[index].data() as Map<String, dynamic>;
          MessageModel messageModel = MessageModel.fromJson(data);
          String messageText = messageModel.messageText;

          if (messageText
              .toString()
              .toLowerCase()
              .contains(searchChat.toLowerCase())) {
            debugPrint('$messageText $index');
            searchIndex = index;
            searchListIndex.add(searchIndex);
          }
        }
      }

      return searchListIndex;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }
}
