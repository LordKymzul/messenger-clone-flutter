import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:message_app/services/userprofile_services.dart';
import 'package:message_app/constant/snakbar.dart';
import 'package:message_app/model/status_model.dart';
import 'package:message_app/model/user_model.dart';

class Status2Services {
  static User get user => FirebaseAuth.instance.currentUser!;

  static Future<void> uploadStatus(
      String statusURL, String statusURLName, String statusCaption) async {
    try {
      UserModel? userModel = await UserProfileServices.getUserDetail(user.uid);
      String statusUserName = userModel!.username;
      String statusUserAvatar = userModel.userprofile;
      final docstatus =
          FirebaseFirestore.instance.collection('UserStatus').doc();
      final status = StatusModel(
          statusID: docstatus.id,
          statusURL: statusURL,
          statusURLName: statusURLName,
          statusCaption: statusCaption,
          sentBy: user.uid,
          sentAt: Timestamp.now(),
          statusUserName: statusUserName,
          statusUserAvatar: statusUserAvatar);

      await docstatus.set(status.toJson());

      updateLastStatusTime(Timestamp.now());

      SnackBarUtil.showSnackBar('Status Uploaded', Colors.green);
    } catch (e) {
      debugPrint(e.toString());
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
    }
  }

  static Future<void> deleteStatus(
      String statusID, String statusURLName, Timestamp lastStatus) async {
    try {
      final docstatus =
          FirebaseFirestore.instance.collection('UserStatus').doc(statusID);
      await docstatus.delete();

      updateLastStatusTime(lastStatus);

      final ref = FirebaseStorage.instance
          .ref()
          .child('UserStatus')
          .child(user.uid)
          .child(statusURLName);

      await ref.delete();

      SnackBarUtil.showSnackBar('Status Deleted', Colors.red);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<List<StatusModel>> fetchUserStatus(String userlistID) async {
    List<StatusModel> statusModels = [];

    try {
      final docstatus = FirebaseFirestore.instance
          .collection('UserStatus')
          .where('sentBy', isEqualTo: userlistID);
      QuerySnapshot querySnapshot = await docstatus.get();
      if (querySnapshot.docs.isNotEmpty) {
        for (var eachdata in querySnapshot.docs) {
          var userData = eachdata.data() as Map<String, dynamic>;
          StatusModel statusModel = StatusModel.fromJson(userData);
          statusModels.add(statusModel);
        }
      } else {
        debugPrint('User Status is Empty');
        statusModels = [];
      }

      debugPrint(statusModels.length.toString());

      return statusModels;
    } catch (e) {
      debugPrint(e.toString());
      SnackBarUtil.showSnackBar('Unable to fetch status', Colors.red);
      return [];
    }
  }

  static Future<StatusModel?> fetchUserStatusDetail(String statusID) async {
    try {
      final docstatus =
          FirebaseFirestore.instance.collection('UserStatus').doc(statusID);
      DocumentSnapshot documentSnapshot = await docstatus.get();
      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic>;
        return StatusModel.fromJson(data);
      } else {
        debugPrint('Do not exist');
        return null;
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<void> updateLastStatusTime(Timestamp lastStatus) async {
    try {
      DocumentReference docstatus =
          FirebaseFirestore.instance.collection('UserProfile').doc(user.uid);
      docstatus.update({'lastStatus': lastStatus});
    } catch (e) {
      debugPrint(e.toString());
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
    }
  }

  static Future<void> deleteStatus24Hours(String statusID) async {
    try {
      final docstatus =
          FirebaseFirestore.instance.collection('UserStatus').doc(statusID);
      DocumentSnapshot documentSnapshot = await docstatus.get();
      var data = documentSnapshot.data() as Map<String, dynamic>;
      StatusModel statusModel = StatusModel.fromJson(data);
      Timestamp sentAt = statusModel.sentAt;
      String statusURLName = statusModel.statusURLName;
      String sentBy = statusModel.sentBy;

      DateTime initialDateTime = sentAt.toDate();

      DateTime newDateTime = initialDateTime.add(const Duration(hours: 24));

      DateTime currentDateTime = DateTime.now();

      if (currentDateTime.isAfter(newDateTime)) {
        await docstatus.delete();
        final ref = FirebaseStorage.instance
            .ref()
            .child('UserStatus')
            .child(sentBy)
            .child(statusURLName);

        await ref.delete();

        deleteStatus(statusID, statusURLName, sentAt);
      } else {
        debugPrint('Do not delete yet: $statusID');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
