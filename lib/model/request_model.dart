import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  final String userId;
  final Timestamp timestamp;

  RequestModel({required this.userId, required this.timestamp});

  Map<String, dynamic> toJson() => {'userId': userId, 'timestamp': timestamp};

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(userId: json['userId'], timestamp: json['timestamp']);
  }

  Map<String, dynamic> createMyMap() {
    return {
      'userId': userId,
    };
  }
}
