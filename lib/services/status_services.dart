import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:message_app/constant/snakbar.dart';
import 'package:message_app/model/status_model.dart';
import 'package:message_app/model/user_model.dart';
import 'package:uuid/uuid.dart';

class StatusServices {
  static User get user => FirebaseAuth.instance.currentUser!;

  static Future<void> uploadStatus(
      String statusURL, String statusURLName, String statusCaption) async {
    try {
      DocumentReference docstatus =
          FirebaseFirestore.instance.collection('UserProfile').doc(user.uid);

      final statusID = Uuid().v4(); // Generate a unique ID);

      Map<String, dynamic> myStatus() {
        return {
          'statusID': statusID,
          'statusURL': statusURL,
          'statusURLName': statusURLName,
          'statusCaption': statusCaption,
          'sentBy': user.uid,
          'sentAt': Timestamp.now(),
          'viewBy': []
        };
      }

      docstatus.update({
        'status': FieldValue.arrayUnion([myStatus()])
      });

      updateLastStatus();

      SnackBarUtil.showSnackBar('Status Uploaded', Colors.green);
    } catch (e) {
      debugPrint(e.toString());
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
    }
  }

  static Future<void> updateLastStatus() async {
    try {
      DocumentReference docstatus =
          FirebaseFirestore.instance.collection('UserProfile').doc(user.uid);

      docstatus.update({'lastStatus': Timestamp.now()});
    } catch (e) {
      debugPrint(e.toString());
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
    }
  }

  static Future<void> deleteStatus(
      Map<String, dynamic> mapDelete, String statusURLName) async {
    try {
      DocumentReference docstatus =
          FirebaseFirestore.instance.collection('UserProfile').doc(user.uid);

      docstatus.update({
        'status': FieldValue.arrayRemove([mapDelete])
      });

      final ref = FirebaseStorage.instance
          .ref()
          .child('UserStatus')
          .child(user.uid)
          .child(statusURLName);

      await ref.delete();

      SnackBarUtil.showSnackBar('Status Deleted', Colors.red);
    } catch (e) {
      debugPrint(e.toString());
      SnackBarUtil.showSnackBar(e.toString(), Colors.red);
    }
  }

  static Future<void> updateSeenStatus(
      String userlistID, String statusID, List<dynamic> statusList) async {
    String statusURL;
    String statusURLName;
    String statusCaption;
    String sentBy;
    Timestamp sentAt;
    List<dynamic> viewBy = [];
    try {
      DocumentReference docstatus =
          FirebaseFirestore.instance.collection('UserProfile').doc(userlistID);

      final docSnapshot = await docstatus.get();

      if (docSnapshot.exists) {
        for (var eachStatus in statusList) {
          String statusid = eachStatus['statusID'];

          if (statusID == statusid) {
            debugPrint(statusID);
            statusURL = eachStatus['statusURL'];
            statusURLName = eachStatus['statusURLName'];
            statusCaption = eachStatus['statusCaption'];
            sentBy = eachStatus['sentBy'];
            sentAt = eachStatus['sentAt'];
            viewBy = eachStatus['viewBy'];

            Map<String, dynamic> viewByMap() {
              return {
                'statusID': statusid,
                'viewBy': user.uid,
                'viewAt': Timestamp.now(),
              };
            }

            Map<String, dynamic> mapUpdate() {
              return {
                'statusID': statusid,
                'statusURL': statusURL,
                'statusURLName': statusURLName,
                'statusCaption': statusCaption,
                'sentBy': sentBy,
                'sentAt': sentAt,
                'viewBy': FieldValue.arrayUnion([viewByMap()])
              };
            }

            // Update the Firestore document
            /*  await docstatus.update({
              'status': FieldValue.arrayUnion([mapUpdate()]),
            });*/

            break;
          }
        }
      } else {
        debugPrint('Do not exist');
      }
    } catch (e) {
      debugPrint('Error to update: ${e.toString()}');
    }
  }

  static Future<List<dynamic>> fetchUserStatus(String userID) async {
    List<dynamic> statusList = [];
    try {
      final status =
          FirebaseFirestore.instance.collection('UserProfile').doc(userID);
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await status.get();
      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic>;
        if (data.containsKey('status')) {
          List<dynamic> status = data['status'];
          statusList.addAll(status);
        }
      } else {
        debugPrint('Dont Exist');
      }

      return statusList;
    } catch (e) {
      debugPrint('Cannot fetch ${e.toString}');
      return [];
    }
  }

  static Future<List<String>> getDocumentIDs() async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('UserProfile')
          .where('friends', arrayContainsAny: [user.uid])
          .orderBy('lastStatus', descending: true)
          .get();
      final List<String> docIDs = querySnapshot.docs.map((e) => e.id).toList();
      return docIDs;
    } catch (e) {
      print(e.toString());
      return [];
    }
  }
}
