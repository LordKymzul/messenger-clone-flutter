import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:message_app/model/group_model.dart';
import 'package:message_app/model/message_model.dart';
import 'package:message_app/model/status_model.dart';

import '../constant/snakbar.dart';
import '../model/user_model.dart';

class UserProfileServices {
  static User get user => FirebaseAuth.instance.currentUser!;

  Future<void> createUserProfile(
      String profile, String name, String bio, int number) async {
    try {
      final docUserProfile =
          FirebaseFirestore.instance.collection('UserProfile').doc(user.uid);
      final userprofile = UserModel(
          userId: user.uid,
          useremail: user.email!,
          userprofile: profile,
          username: name,
          userbio: bio,
          usernumber: number,
          createdAt: Timestamp.now(),
          isOnline: false,
          lastActive: Timestamp.now(),
          groups: [],
          friends: [user.uid],
          lastStatus: Timestamp.now(),
          numRequest: 0);

      await docUserProfile.set(userprofile.toJson());
    } catch (e) {
      print(e.toString());
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
    }
  }

  static Future<UserModel?> getUserDetail(String userID) async {
    UserModel? userModel;
    try {
      final docUser =
          FirebaseFirestore.instance.collection('UserProfile').doc(userID);

      DocumentSnapshot documentSnapshot = await docUser.get();
      if (documentSnapshot.exists) {
        userModel =
            UserModel.fromJson(documentSnapshot.data() as Map<String, dynamic>);
      } else {
        debugPrint('Document Does not exist');
        userModel = null;
      }
    } catch (e) {
      debugPrint(e.toString());
      userModel = null;
    }
    return userModel;
  }

  static Future<bool> checkUserExist() async {
    return (await FirebaseFirestore.instance
            .collection('UserProfile')
            .doc(user.uid)
            .get())
        .exists;
  }

  static Future<List<dynamic>> UngetFriendsID() async {
    try {
      final friendsID =
          FirebaseFirestore.instance.collection('UserProfile').doc(user.uid);

      DocumentSnapshot<Map<String, dynamic>> data = await friendsID.get();
      if (data.exists) {
        var userdata = data.data() as Map<String, dynamic>;
        if (userdata.containsKey('friends') && data['friends'] is List) {
          List<dynamic> friendsID = data['friends'];
          return friendsID;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  static Future<void> updateUserOnlineStatus(bool isOnline) async {
    try {
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('UserProfile').doc(user.uid);
      await documentReference
          .update({'is_online': isOnline, 'lastActive': Timestamp.now()});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<List<String>> fetchFriendIDs() async {
    List<String> friends = [];
    try {
      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('UserProfile').get();
      for (var eachUser in querySnapshot.docs) {
        var userData = eachUser.data() as Map<String, dynamic>;
        UserModel userModel = UserModel.fromJson(userData);
        String userID = userModel.userId;
        if (userID == user.uid) {
          if (userData.containsKey('friends')) {
            friends = userModel.friends;
          }
        }
      }
      return friends;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  static Future<List<GroupModel>> fetchUserGroups() async {
    List<GroupModel> groups = [];
    try {
      final groupdoc = FirebaseFirestore.instance
          .collection('UserGroup')
          .where('membersID', arrayContainsAny: [user.uid]);
      QuerySnapshot querySnapshot = await groupdoc.get();
      if (querySnapshot.docs.isEmpty) {
        return groups;
      } else {
        for (var eachDoc in querySnapshot.docs) {
          var data = eachDoc.data() as Map<String, dynamic>;
          GroupModel groupModel = GroupModel.fromJson(data);
          List<String> membersID = groupModel.membersID;
          if (membersID.length > 2) {
            groups.add(groupModel);
          }
        }
      }

      return groups;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  static Future<void> updateNumOfRequest(
      String userlistId, bool isIncrease) async {
    int newnumRequest = 0;
    try {
      DocumentReference docuser =
          FirebaseFirestore.instance.collection('UserProfile').doc(userlistId);

      DocumentSnapshot documentSnapshot = await docuser.get();
      var data = documentSnapshot.data() as Map<String, dynamic>;
      UserModel userModel = UserModel.fromJson(data);
      int numRequest = userModel.numRequest;

      if (isIncrease) {
        newnumRequest = numRequest + 1;
      } else {
        newnumRequest = numRequest - 1;
      }

      docuser.update({'numRequest': newnumRequest});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<void> updateUserProfile(String username, String userbio,
      int usernumber, String urlDownload, bool isPickedImageNull) async {
    try {
      if (isPickedImageNull) {
        final docUserProfile =
            FirebaseFirestore.instance.collection('UserProfile').doc(user.uid);
        await docUserProfile.update({
          'username': username,
          'userbio': userbio,
          'usernumber': usernumber
        });
        updateUserProfileForMessage(username, urlDownload, true);
        final docUserStatus =
            FirebaseFirestore.instance.collection('UserStatus');
        QuerySnapshot querySnapshot = await docUserStatus.get();
        for (var eachDoc in querySnapshot.docs) {
          if (eachDoc.exists) {
            var data = eachDoc.data() as Map<String, dynamic>;
            StatusModel statusModel = StatusModel.fromJson(data);
            String sentBy = statusModel.sentBy;
            if (sentBy == user.uid) {
              String statusID = statusModel.statusID;
              final docUpdate = FirebaseFirestore.instance
                  .collection('UserStatus')
                  .doc(statusID);
              await docUpdate.update({'statusUserName': username});
            }
          } else {
            debugPrint('Username not found');
          }
        }
      } else {
        final docUserProfile =
            FirebaseFirestore.instance.collection('UserProfile').doc(user.uid);
        await docUserProfile.update({
          'userprofile': urlDownload,
          'username': username,
          'userbio': userbio,
          'usernumber': usernumber
        });
        updateUserProfileForMessage(username, urlDownload, false);
        final docUserStatus =
            FirebaseFirestore.instance.collection('UserStatus');
        QuerySnapshot querySnapshot = await docUserStatus.get();
        for (var eachDoc in querySnapshot.docs) {
          if (eachDoc.exists) {
            var data = eachDoc.data() as Map<String, dynamic>;
            StatusModel statusModel = StatusModel.fromJson(data);
            String sentBy = statusModel.sentBy;
            if (sentBy == user.uid) {
              String statusID = statusModel.statusID;
              final docUpdate = FirebaseFirestore.instance
                  .collection('UserStatus')
                  .doc(statusID);
              await docUpdate.update({
                'statusUserName': username,
                'statusUserAvatar': urlDownload
              });
            }
          } else {
            debugPrint('Username not found');
          }
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<void> updateUserProfileForMessage(
      String sentByName, String sentByAvatar, bool isPickedImageNull) async {
    try {
      final docgroup = FirebaseFirestore.instance
          .collection('UserGroup')
          .where('membersID', arrayContainsAny: [UserProfileServices.user.uid]);
      QuerySnapshot querygroup = await docgroup.get();

      for (var eachdocGroup in querygroup.docs) {
        final docmessage = FirebaseFirestore.instance
            .collection('UserGroup')
            .doc(eachdocGroup.id)
            .collection('Messages');

        debugPrint('Group ID: ${eachdocGroup.id}');

        QuerySnapshot querymessage = await docmessage.get();
        for (var eachdocMessage in querymessage.docs) {
          MessageModel messageModel = MessageModel.fromJson(
              eachdocMessage.data() as Map<String, dynamic>);
          String sentBy = messageModel.sentBy;
          if (sentBy == UserProfileServices.user.uid) {
            debugPrint('Message ID: ${eachdocMessage.id}');
            String messageID = messageModel.messageID;
            final docupdateprofilemessage = FirebaseFirestore.instance
                .collection('UserGroup')
                .doc(eachdocGroup.id)
                .collection('Messages')
                .doc(messageID);
            if (isPickedImageNull) {
              docupdateprofilemessage.update({'sentByName': sentByName});
            } else {
              docupdateprofilemessage.update(
                  {'sentByName': sentByName, 'sentByAvatar': sentByAvatar});
            }
          } else {
            debugPrint('Do not update');
          }
        }
      }
      debugPrint(querygroup.docs.length.toString());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<List<String>> fetchUserGroupsSearch() async {
    try {
      List<String> resultList = [];

      final docfiltered = FirebaseFirestore.instance
          .collection('UserProfile')
          .where('friends', arrayContainsAny: [UserProfileServices.user.uid]);
      QuerySnapshot querySnapshot = await docfiltered.get();
      for (var eachDoc in querySnapshot.docs) {
        var data = eachDoc.data() as Map<String, dynamic>;
        UserModel userModel = UserModel.fromJson(data);
        List<String> groups = userModel.groups;
        resultList.addAll(groups);
      }

      return removeDuplicateGroupID(resultList);
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  static List<String> removeDuplicateGroupID(List<String> groupsID) {
    List<String> resultList = [];
    for (var eachGroup in groupsID) {
      if (countDuplicate(groupsID, eachGroup) == 1) {
        resultList.add(eachGroup);
      }
    }

    return resultList;
  }

  static int countDuplicate(List<String> groupsID, String target) {
    int count = 0;
    for (var eachGroup in groupsID) {
      if (eachGroup == target) {
        count++;
      }
    }

    return count;
  }

  //INTEGER

  static List<int> removeDuplicate(List<int> numbers) {
    List<int> resultList = [];

    for (var eachNumber in numbers) {
      if (countOccurrences(numbers, eachNumber) == 1) {
        resultList.add(eachNumber);
      }
    }
    for (var eachResult in resultList) {
      debugPrint(eachResult.toString());
    }
    return resultList;
  }

  static int countOccurrences(List<int> numbers, int target) {
    int count = 0;
    for (var eachNumber in numbers) {
      if (eachNumber == target) {
        count++;
      }
    }
    return count;
  }
}
