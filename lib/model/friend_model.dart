import 'package:cloud_firestore/cloud_firestore.dart';

class FriendModel {
  final String userId;
  final String statusFriend;
  final String statusProcess;
  final Timestamp timestamp;

  FriendModel({
    required this.userId,
    required this.statusFriend,
    required this.statusProcess,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'statusFriend': statusFriend,
        'statusProcess': statusProcess,
        'timestamp': timestamp,
      };

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      userId: json['userId'],
      statusFriend: json['statusFriend'],
      statusProcess: json['statusProcess'],
      timestamp: json['timestamp'],
    );
  }
}
