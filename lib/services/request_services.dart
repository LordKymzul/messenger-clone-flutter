import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:message_app/services/chat_services.dart';
import 'package:message_app/services/userprofile_services.dart';
import 'package:message_app/constant/snakbar.dart';
import 'package:message_app/model/friend_model.dart';
import 'package:message_app/model/request_model.dart';

class RequestServices {
  static User get user => FirebaseAuth.instance.currentUser!;

  static Future<void> sendRequest(String userlistId) async {
    try {
      final docMyFriend = FirebaseFirestore.instance
          .collection('UserFriend')
          .doc(user.uid)
          .collection('MyFriend')
          .doc(userlistId);

      final docFriend = FirebaseFirestore.instance
          .collection('UserFriend')
          .doc(userlistId)
          .collection('MyFriend')
          .doc(user.uid);

      final myfriend = FriendModel(
        userId: userlistId,
        statusFriend: 'Requested',
        statusProcess: 'Sender',
        timestamp: Timestamp.now(),
      );

      final friend = FriendModel(
        userId: user.uid,
        statusFriend: 'Requested',
        statusProcess: 'Receiver',
        timestamp: Timestamp.now(),
      );

      await docMyFriend.set(myfriend.toJson());
      await docFriend.set(friend.toJson());

      UserProfileServices.updateNumOfRequest(userlistId, true);

      SnackBarUtil.showSnackBar('Added', Colors.green);
    } catch (e) {
      print(e.toString());
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
    }
  }

  static Future<void> cancelRequest(String userlistId, bool isSender) async {
    try {
      final docMyFriend = FirebaseFirestore.instance
          .collection('UserFriend')
          .doc(user.uid)
          .collection('MyFriend')
          .doc(userlistId);

      final docFriend = FirebaseFirestore.instance
          .collection('UserFriend')
          .doc(userlistId)
          .collection('MyFriend')
          .doc(user.uid);

      await docMyFriend.delete();
      await docFriend.delete();

      if (isSender) {
        UserProfileServices.updateNumOfRequest(userlistId, false);
      } else {
        UserProfileServices.updateNumOfRequest(user.uid, false);
      }

      SnackBarUtil.showSnackBar('Removed request', Colors.red);
    } catch (e) {
      print(e.toString());
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
    }
  }

  static Future<bool> checkRequest(String userlistId) async {
    bool isPending = false;
    try {
      final docMyRequest = FirebaseFirestore.instance
          .collection('UserFriend')
          .doc(user.uid)
          .collection('MyFriend')
          .where('statusProcess', isEqualTo: 'Request')
          .where('userId', isEqualTo: userlistId);

      QuerySnapshot querySnapshot = await docMyRequest.get();

      if (querySnapshot.docs.isNotEmpty) {
        print('exist');
        return isPending = true;
      } else {
        print('Not exist');
        return isPending = false;
      }
    } catch (e) {
      print(e.toString());
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
      return isPending = false;
    }
  }

  static Stream<bool> fromFuture(String userlistId) {
    return Stream.fromFuture(checkRequest(userlistId));
  }

  static Future<void> acceptRequest(
      String userlistId, List<String> membersID) async {
    try {
      //---------------Friends Collection---------------//
      final docMyFriend = FirebaseFirestore.instance
          .collection('UserFriend')
          .doc(user.uid)
          .collection('MyFriend')
          .doc(userlistId);

      final docFriend = FirebaseFirestore.instance
          .collection('UserFriend')
          .doc(userlistId)
          .collection('MyFriend')
          .doc(user.uid);

      await docMyFriend.update({
        'statusFriend': 'Accepted',
        'statusProcess': 'Completed',
        'timestamp': Timestamp.now()
      });

      await docFriend.update({
        'statusFriend': 'Accepted',
        'statusProcess': 'Completed',
        'timestamp': Timestamp.now()
      });

      //---------------User Profile Collections---------------//

      addFriendList(userlistId);
      UserProfileServices.updateNumOfRequest(user.uid, false);

      //---------------Group Collections-----------------------//
      ChatServices.createdGroup(membersID, userlistId, '', false, '');

      SnackBarUtil.showSnackBar('Succesfully Accepted', Colors.green);
    } catch (e) {
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
      debugPrint(e.toString());
    }
  }

  static Future<void> addFriendList(String userlistId) async {
    try {
      DocumentReference userref =
          FirebaseFirestore.instance.collection('UserProfile').doc(user.uid);
      DocumentReference userlistref =
          FirebaseFirestore.instance.collection('UserProfile').doc(userlistId);

      userref.update({
        'friends': FieldValue.arrayUnion([userlistId])
      });
      userlistref.update({
        'friends': FieldValue.arrayUnion([user.uid])
      });
    } catch (e) {
      print(e.toString());
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
    }
  }

  static Future<void> removeFriend(String userlistId, String groupID) async {
    try {
      final docMyFriend = FirebaseFirestore.instance
          .collection('UserFriend')
          .doc(user.uid)
          .collection('MyFriend')
          .doc(userlistId);

      final docFriend = FirebaseFirestore.instance
          .collection('UserFriend')
          .doc(userlistId)
          .collection('MyFriend')
          .doc(user.uid);

      await docMyFriend.delete();
      await docFriend.delete();
      removeFriendList(userlistId);

      ChatServices.removeOneToOneGroup(groupID, userlistId);
    } catch (e) {
      debugPrint(e.toString());
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
    }
  }

  static Future<void> removeFriendList(String userlistId) async {
    try {
      DocumentReference userref =
          FirebaseFirestore.instance.collection('UserProfile').doc(user.uid);
      DocumentReference userlistref =
          FirebaseFirestore.instance.collection('UserProfile').doc(userlistId);

      userref.update({
        'friends': FieldValue.arrayRemove([userlistId])
      });
      userlistref.update({
        'friends': FieldValue.arrayRemove([user.uid])
      });
    } catch (e) {
      print(e.toString());
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
    }
  }
}
