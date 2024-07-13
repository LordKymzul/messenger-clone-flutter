import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:message_app/services/chat_services.dart';
import 'package:message_app/model/group_model.dart';
import 'package:message_app/model/read_mode.dart';

class ReadServices {
  static User get user => FirebaseAuth.instance.currentUser!;
  static Future<void> createUnReadMessage(
      String groupID, String userlistID) async {
    try {
      final docgroup = FirebaseFirestore.instance
          .collection('UserGroup')
          .doc(groupID)
          .collection('ReadBy')
          .doc(userlistID);

      final read = ReadModel(readBy: userlistID, numUnRead: 0);
      await docgroup.set(read.toJson());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<void> removeUnReadMessage(
      String groupID, String userlistID) async {
    try {
      final docgroup = FirebaseFirestore.instance
          .collection('UserGroup')
          .doc(groupID)
          .collection('ReadBy')
          .doc(userlistID);

      await docgroup.delete();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<void> updateUnReadMessage(String groupID, bool isDelete) async {
    int newnumRead = 0;
    GroupModel? groupModel;
    try {
      groupModel = await ChatServices.fetchGroupDetail(groupID);
      List<String> membersID = groupModel!.membersID;

      for (var eachMember in membersID) {
        DocumentReference documentReference = FirebaseFirestore.instance
            .collection('UserGroup')
            .doc(groupID)
            .collection('ReadBy')
            .doc(eachMember);

        DocumentSnapshot documentSnapshot = await documentReference.get();
        var data = documentSnapshot.data() as Map<String, dynamic>;
        ReadModel readModel = ReadModel.fromJson(data);
        int numRead = readModel.numUnRead;
        if (isDelete) {
          if (numRead == 0) {
            newnumRead = 0;
          } else {
            newnumRead = numRead - 1;
          }
        } else {
          newnumRead = numRead + 1;
        }

        documentReference.update({'numUnRead': newnumRead});
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<void> resetUnReadMessage(String groupID) async {
    int newnumRead = 0;

    try {
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('UserGroup')
          .doc(groupID)
          .collection('ReadBy')
          .doc(user.uid);

      documentReference.update({'numUnRead': newnumRead});
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
