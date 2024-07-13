import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String useremail;
  final String userprofile;
  final String username;
  final String userbio;
  final int usernumber;
  final Timestamp createdAt;
  final bool isOnline;
  final Timestamp lastActive;
  final List<String> groups;
  final List<String> friends;
  //-------Status--------//
  final Timestamp lastStatus;
  //-------Request--------//
  final int numRequest;
  UserModel(
      {required this.userId,
      required this.useremail,
      required this.userprofile,
      required this.username,
      required this.userbio,
      required this.usernumber,
      required this.createdAt,
      required this.isOnline,
      required this.lastActive,
      required this.groups,
      required this.friends,
      required this.lastStatus,
      required this.numRequest});

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'useremail': useremail,
        'userprofile': userprofile,
        'username': username,
        'userbio': userbio,
        'usernumber': usernumber,
        'createdAt': createdAt,
        'is_online': isOnline,
        'lastActive': lastActive,
        'groups': [],
        'friends': [],
        'lastStatus': lastStatus,
        'numRequest': numRequest
      };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        userId: json['userId'],
        useremail: json['useremail'],
        userprofile: json['userprofile'],
        username: json['username'],
        userbio: json['userbio'],
        usernumber: json['usernumber'],
        createdAt: json['createdAt'],
        isOnline: json['is_online'],
        lastActive: json['lastActive'],
        groups: List<String>.from(
          json['groups'] ?? [],
        ),
        friends: List<String>.from(json['friends'] ?? []),
        lastStatus: json['lastStatus'],
        numRequest: json['numRequest']);
  }
}
