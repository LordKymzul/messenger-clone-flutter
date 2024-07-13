import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:message_app/services/read_services.dart';
import 'package:message_app/services/userprofile_services.dart';
import 'package:message_app/constant/snakbar.dart';
import 'package:message_app/model/group_model.dart';
import 'package:message_app/model/message_model.dart';
import 'package:message_app/model/user_model.dart';

class ChatServices {
  static User get user => FirebaseAuth.instance.currentUser!;

  static Future<GroupModel?> fetchGroupDetail(String groupID) async {
    try {
      final docgroup =
          FirebaseFirestore.instance.collection('UserGroup').doc(groupID);
      DocumentSnapshot documentSnapshot = await docgroup.get();
      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic>;
        return GroupModel.fromJson(data);
      } else {
        debugPrint('Not Exist');
        return null;
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<void> createdGroup(List<String> membersID, String userlistId,
      String groupName, bool isGroup, String groupURL) async {
    try {
      final docgroup = FirebaseFirestore.instance.collection('UserGroup').doc();
      final group = GroupModel(
        groupID: docgroup.id,
        createdBy: user.uid,
        createdAt: Timestamp.now(),
        lastMessage: 'Start a conversation here',
        lastTime: Timestamp.now(),
        membersID: membersID,
        groupName: groupName,
        lastSender: '',
        isGroup: isGroup,
        groupURL: groupURL,
      );

      await docgroup.set(group.toJson());

      if (isGroup) {
        for (var eachID in membersID) {
          DocumentReference userlistref =
              FirebaseFirestore.instance.collection('UserProfile').doc(eachID);
          userlistref.update({
            'groups': FieldValue.arrayUnion([docgroup.id])
          });
          ReadServices.createUnReadMessage(docgroup.id, eachID);
        }
      } else {
        List<String> members = [];
        members.addAll([user.uid, userlistId]);
        addGroupList(docgroup.id, userlistId);
        for (var eachID in members) {
          ReadServices.createUnReadMessage(docgroup.id, eachID);
        }
      }

      SnackBarUtil.showSnackBar('Group Created', Colors.green);
    } catch (e) {
      debugPrint(e.toString());
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
    }
  }

  static Future<void> addGroupList(String groupID, String userlistId) async {
    try {
      DocumentReference userref =
          FirebaseFirestore.instance.collection('UserProfile').doc(user.uid);
      DocumentReference userlistref =
          FirebaseFirestore.instance.collection('UserProfile').doc(userlistId);
      userref.update({
        'groups': FieldValue.arrayUnion([groupID])
      });
      userlistref.update({
        'groups': FieldValue.arrayUnion([groupID])
      });
    } catch (e) {
      debugPrint(e.toString());
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
    }
  }

  static Future<void> removeGroup(
      String groupID, List<dynamic> membersID) async {
    try {
      final groupRef =
          FirebaseFirestore.instance.collection('UserGroup').doc(groupID);
      final messageRef = groupRef.collection('Messages');
      final messageSnapshot = await messageRef.get();
      for (var eachMessage in messageSnapshot.docs) {
        var data = eachMessage.data();
        MessageModel messageModel = MessageModel.fromJson(data);

        List<dynamic> messageURLName = messageModel.messageURLName;
        if (messageURLName.isEmpty) {
          debugPrint('Unable to delete messageURL');
        } else {
          String sentBy = messageModel.sentBy;
          for (var eachMessageURLName in messageURLName) {
            final ref = FirebaseStorage.instance
                .ref()
                .child('UserMessage')
                .child(sentBy)
                .child(eachMessageURLName);

            await ref.delete();
          }
        }
        await eachMessage.reference.delete();
      }
      for (var eachMember in membersID) {
        removeUserGroupList(groupID, eachMember);
        ReadServices.removeUnReadMessage(groupID, eachMember);
      }

      await groupRef.delete();
    } catch (e) {
      debugPrint(e.toString());
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
    }
  }

  static Future<void> removeOneToOneGroup(
    String groupID,
    String userlistId,
  ) async {
    try {
      final docgroup =
          FirebaseFirestore.instance.collection('UserGroup').doc(groupID);

      await docgroup.delete();
      removeUserGroupList(groupID, userlistId);

      SnackBarUtil.showSnackBar('Group Removed', Colors.red);
    } catch (e) {
      debugPrint(e.toString());
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
    }
  }

  static Future<void> leaveGroup(String groupID) async {
    try {
      DocumentReference docgroup =
          FirebaseFirestore.instance.collection('UserGroup').doc(groupID);

      await docgroup.update({
        'membersID': FieldValue.arrayRemove([UserProfileServices.user.uid])
      });

      DocumentReference docuser = FirebaseFirestore.instance
          .collection('UserProfile')
          .doc(UserProfileServices.user.uid);
      await docuser.update({
        'groups': FieldValue.arrayRemove([groupID])
      });
    } catch (e) {
      debugPrint(e.toString());
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
    }
  }

  static Future<void> removeUserGroupList(
      String groupID, String userlistId) async {
    try {
      DocumentReference userref =
          FirebaseFirestore.instance.collection('UserProfile').doc(user.uid);
      DocumentReference userlistref =
          FirebaseFirestore.instance.collection('UserProfile').doc(userlistId);
      await userref.update({
        'groups': FieldValue.arrayRemove([groupID])
      });
      await userlistref.update({
        'groups': FieldValue.arrayRemove([groupID])
      });
    } catch (e) {
      debugPrint(e.toString());
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
    }
  }

  static Future<void> updateGroupLatestData(
    String groupID,
    String lastMessage,
    Timestamp lastTime,
    String lastSender,
  ) async {
    try {
      final docgroup =
          FirebaseFirestore.instance.collection('UserGroup').doc(groupID);

      await docgroup.update({
        'lastMessage': lastMessage,
        'lastTime': lastTime,
        'lastSender': lastSender,
      });
    } catch (e) {
      debugPrint(e.toString());
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
    }
  }

  static Future<List<GroupModel>> groupCommonsData(String userlistId) async {
    List<GroupModel> groups = [];
    List<dynamic> membersID1 = [];
    List<dynamic> membersID2 = [];

    try {
      final querySnapshot1 = await FirebaseFirestore.instance
          .collection('UserGroup')
          .where('membersID', arrayContains: user.uid)
          .get();

      final querySnapshot2 = await FirebaseFirestore.instance
          .collection('UserGroup')
          .where('membersID', arrayContains: userlistId)
          .get();

      for (var each1 in querySnapshot1.docs) {
        for (var each2 in querySnapshot2.docs) {
          if (each1.id == each2.id) {
            membersID1 = each1['membersID'];
            membersID2 = each2['membersID'];

            if (membersID1.length < 3 || membersID2.length < 3) {
              debugPrint('ID Unvalid: ${membersID1.length} ${each1.id}');
            } else {
              Map<String, dynamic> data = each1.data();
              debugPrint('ID Invalid: ${membersID1.length} ${each1.id}');
              final group = GroupModel.fromJson(data);
              groups.add(group);
            }
          }
        }
      }

      debugPrint(groups.length.toString());

      return groups;
    } catch (e) {
      debugPrint('Services: ${e.toString()}');
      return [];
    }
  }

  static Future<void> addnewMembers(
      String groupID, List<String> membersID) async {
    try {
      DocumentReference docgroup =
          FirebaseFirestore.instance.collection('UserGroup').doc(groupID);

      docgroup.update({'membersID': FieldValue.arrayUnion(membersID)});

      for (var userID in membersID) {
        DocumentReference docuser =
            FirebaseFirestore.instance.collection('UserProfile').doc(userID);
        docuser.update({
          'groups': FieldValue.arrayUnion([groupID])
        });
        ReadServices.createUnReadMessage(docgroup.id, userID);
      }
      SnackBarUtil.showSnackBar('Sucessfully Added', Colors.green);
    } catch (e) {
      debugPrint(e.toString());
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
    }
  }

  static Future<void> removeMembersFromGroup(
      String groupID, String userlistId) async {
    try {
      DocumentReference docgroup =
          FirebaseFirestore.instance.collection('UserGroup').doc(groupID);

      docgroup.update({
        'membersID': FieldValue.arrayRemove([userlistId])
      });
      DocumentReference docuser =
          FirebaseFirestore.instance.collection('UserProfile').doc(userlistId);
      docuser.update({
        'groups': FieldValue.arrayRemove([groupID])
      });
      ReadServices.removeUnReadMessage(groupID, userlistId);
      SnackBarUtil.showSnackBar('Removed', Colors.green);
    } catch (e) {
      debugPrint(e.toString());
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
    }
  }

  static Future<String> getOneToOneGroupID(String userlistId) async {
    try {
      final docgroup = FirebaseFirestore.instance.collection('UserGroup').where(
          'membersID',
          arrayContainsAny: [user.uid]).where('isGroup', isEqualTo: false);
      QuerySnapshot querySnapshot = await docgroup.get();
      for (var eachDoc in querySnapshot.docs) {
        var data = eachDoc.data() as Map<String, dynamic>;
        GroupModel groupModel = GroupModel.fromJson(data);

        List<String> membersList = groupModel.membersID;
        if (membersList.contains(userlistId)) {
          debugPrint(groupModel.groupID);
          return groupModel.groupID;
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return '';
  }

  static Future<GroupModel?> getOneToOneGroupModel(String userlistId) async {
    GroupModel? groupModel;
    try {
      final docgroup = FirebaseFirestore.instance
          .collection('UserGroup')
          .where('membersID', arrayContainsAny: [user.uid]);
      QuerySnapshot querySnapshot = await docgroup.get();
      for (var eachDoc in querySnapshot.docs) {
        var data = eachDoc.data() as Map<String, dynamic>;
        GroupModel group = GroupModel.fromJson(data);

        List<String> membersList = group.membersID;
        if (membersList.length < 3 && membersList.contains(userlistId)) {
          groupModel = group;
        }
      }

      return groupModel;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<List<UserModel?>> fetchGroupMembersDetail(
      String groupID) async {
    List<UserModel?> userModels = [];
    UserModel? userModel;
    try {
      final docgroup =
          FirebaseFirestore.instance.collection('UserGroup').doc(groupID);
      DocumentSnapshot documentSnapshot = await docgroup.get();
      var data = documentSnapshot.data() as Map<String, dynamic>;
      GroupModel groupModel = GroupModel.fromJson(data);
      List<dynamic> membersList = groupModel.membersID;
      for (var eachMember in membersList) {
        userModel = await UserProfileServices.getUserDetail(eachMember);
        userModels.add(userModel);
      }

      return userModels;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  static Stream<List<UserModel?>> fetchGroupMembersDetailStream(
      String groupID) {
    StreamController<List<UserModel?>> controller =
        StreamController<List<UserModel?>>();
    try {
      final docgroup =
          FirebaseFirestore.instance.collection('UserGroup').doc(groupID);

      docgroup.snapshots().listen((DocumentSnapshot documentSnapshot) async {
        var data = documentSnapshot.data() as Map<String, dynamic>;
        GroupModel groupModel = GroupModel.fromJson(data);
        List<dynamic> membersList = groupModel.membersID;
        List<UserModel?> userModels = [];

        for (var eachMember in membersList) {
          UserModel? userModel =
              await UserProfileServices.getUserDetail(eachMember);
          userModels.add(userModel);
        }

        controller.add(userModels);
      });

      return controller.stream;
    } catch (e) {
      debugPrint(e.toString());
      controller.addError(e.toString());
      return controller.stream;
    }
  }
}
